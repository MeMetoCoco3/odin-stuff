package main


import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 800
PLAYER_SIZE :: 20
PLAYER_SPEED :: 2
MAX_NUM_BODY :: 20
MAX_NUM_MOVERS :: 100
MAX_NUM_CANDIES :: 10
CANDY_SIZE :: 20
CANDY_RESPAWN_TIME :: 20

BULLET_SPEED :: 4
BULLET_SIZE :: 16

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "snake_invaders")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	ring_buffer := Ringuffer_t {
		values = [MAX_NUM_BODY]cell_ghost_t{},
		head   = 0,
		tail   = 0,
		count  = 0,
	}

	pj := Player {
		head         = cell_t {
			vec2_t{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2},
			{0, -1},
			0,
			PLAYER_SIZE,
		},
		body         = [MAX_NUM_BODY]cell_t{},
		health       = 3,
		ghost_pieces = &ring_buffer,
		next_dir     = {0, 0},
	}

	scene := scene(.ONE)

	game := Game {
		player = &pj,
		state  = true,
		scene  = scene,
	}

	time := 0

	for !rl.WindowShouldClose() {
		if time >= CANDY_RESPAWN_TIME {
			time = 0
			for i in 0 ..< MAX_NUM_CANDIES {
				index_candy := game.scene.num_initial_colliders + i
				if game.scene.colliders[index_candy].state == .DEAD {
					spawn_candy()
				}
			}
		}

		update(&game)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_grid({100, 100, 100, 255})

		draw_player(&pj)
		draw_ghost_cells(pj.ghost_pieces)
		draw_scene(&game)

		rl.EndDrawing()


		time += 1
	}
}

////////////
// UPDATE //
////////////
update :: proc(game: ^Game) {
	get_input(game)
	check_collision(game)
	update_player(game.player)
	update_scene(game)
	TESTING(game)
}

get_input :: proc(game: ^Game) {
	if (rl.IsKeyPressed(.H) || rl.IsKeyPressed(.LEFT)) {
		game.player.next_dir = {-1, 0}
	}
	if (rl.IsKeyPressed(.L) || rl.IsKeyPressed(.RIGHT)) {
		game.player.next_dir = {1, 0}
	}
	if (rl.IsKeyPressed(.J) || rl.IsKeyPressed(.DOWN)) {
		game.player.next_dir = {0, 1}
	}
	if (rl.IsKeyPressed(.K) || rl.IsKeyPressed(.UP)) {
		game.player.next_dir = {0, -1}
	}
	if (rl.IsKeyPressed(.SPACE)) {
		// TODO: primero chekea los resultados sin moverte, luego muevete y dispara y chekea
		spawn_bullet(game, &game.num_bullets)
	}
}

try_set_dir :: proc(player: ^Player) {
	prev_dir := player.head.direction
	next_dir := player.next_dir
	if !oposite_directions(next_dir, prev_dir) && next_dir != prev_dir {
		player.head.direction = next_dir
		if player.num_cells > 0 && next_dir != {0, 0} {
			put_cell(
				player.ghost_pieces,
				cell_ghost_t{player.head.position, player.head.direction},
			)
			add_turn_count(player)
		}
	}
}

update_scene :: proc(game: ^Game) {
	movers := game.scene.movers
	for i in 0 ..< game.scene.num_movers {
		#partial switch movers[i].kind {
		case .BULLET:
			fmt.println(movers[i].direction)
			game.scene.movers[i].position.x += movers[i].direction.x
			game.scene.movers[i].position.y += movers[i].direction.y
			idx_collider := i + game.scene.num_initial_colliders + MAX_NUM_CANDIES
			game.scene.colliders[idx_collider].position = game.scene.movers[i].position
		case .CANDY:

		}

	}

}

update_player :: proc(player: ^Player) {
	if aligned_to_grid(player.head.position) {
		try_set_dir(player)
	}

	player.head.position.x += player.head.direction.x * PLAYER_SPEED
	player.head.position.y += player.head.direction.y * PLAYER_SPEED

	if player.head.direction != {0, 0} {
		for i in 0 ..< player.num_cells {

			piece_to_follow: cell_t
			if (player.body[i].count_turns_left == 0) {
				piece_to_follow := (i == 0) ? player.head : player.body[i - 1]

				player.body[i].direction = piece_to_follow.direction
			} else {
				index :=
					(MAX_RINGBUFFER_VALUES +
						player.ghost_pieces.tail -
						player.body[i].count_turns_left) %
					MAX_RINGBUFFER_VALUES

				following_ghost_piece := ghost_to_cell(player.ghost_pieces.values[index])

				if (player.body[i].position == following_ghost_piece.position) {
					player.body[i].direction = following_ghost_piece.direction
					player.body[i].count_turns_left -= 1
				} else {
					direction_to_ghost := get_cardinal_direction(
						player.body[i].position,
						following_ghost_piece.position,
					)
					player.body[i].direction = direction_to_ghost
				}


				if (i == player.num_cells - 1) {
					dealing_ghost_piece(player, i)
				}

			}
			player.body[i].position.x += player.body[i].direction.x * PLAYER_SPEED
			player.body[i].position.y += player.body[i].direction.y * PLAYER_SPEED

		}
	}
}

grow_body :: proc(pj: ^Player) {
	if pj.num_cells < MAX_NUM_BODY {
		direction: vec2_t
		new_x, new_y: f32


		if pj.num_cells == 0 {
			direction = pj.head.direction
			new_x = pj.head.position.x - direction.x * PLAYER_SIZE
			new_y = pj.head.position.y - direction.y * PLAYER_SIZE
		} else {
			last := pj.body[pj.num_cells - 1]
			direction = last.direction
			new_x = last.position.x - direction.x * PLAYER_SIZE
			new_y = last.position.y - direction.y * PLAYER_SIZE
		}
		num_ghost_pieces := pj.ghost_pieces.count
		new_cell := cell_t{{new_x, new_y}, direction, num_ghost_pieces, 2}
		pj.body[pj.num_cells] = new_cell
		pj.num_cells += 1
	} else {
		fmt.println("WE DO NOT GROW!")
	}
}

dealing_ghost_piece :: proc(player: ^Player, last_piece: i8) {
	ghost_piece, ok := peek_cell(player.ghost_pieces)
	if !ok {
		return
	}

	is_colliding := rec_colliding(
		player.body[last_piece].position,
		PLAYER_SIZE,
		PLAYER_SIZE,
		ghost_piece.position,
		PLAYER_SIZE,
		PLAYER_SIZE,
	)

	if (is_colliding && player.body[last_piece].direction == ghost_piece.direction) {
		pop_cell(player.ghost_pieces)
	}
}

spawn_bullet :: proc(bullet_c: ^collider_t, bullet_m: ^mover_t, player: ^Player) {
	//TODO: PASS THIS CHECK OUTSIDE 
	// if game.player.num_cells > 0 {
	// idx_collider := game.scene.num_initial_colliders + MAX_NUM_CANDIES + int(game.num_bullets)
	// idx_mover := 0 + int(game.num_bullets)
	head := player.head
	x_position: f32
	y_position: f32
	switch head.direction {
	case {0, 1}:
		x_position = head.position.x + (PLAYER_SIZE / 2)
		y_position = head.position.y + PLAYER_SIZE
	case {0, -1}:
		x_position = head.position.x + (PLAYER_SIZE / 2)
		y_position = head.position.y
	case {1, 0}:
		x_position = head.position.x + PLAYER_SIZE
		y_position = head.position.y + (PLAYER_SIZE / 2)
	case {-1, 0}:
		x_position = head.position.x
		y_position = head.position.y + (PLAYER_SIZE / 2)
	}

	bullet_c.position = {x_position, y_position}
	bullet_c.w = BULLET_SIZE
	bullet_c.h = BULLET_SIZE
	bullet_c.kind = .BULLET
	bullet_c.state = .ALIVE

	mover := new(mover_t)
	mover.direction = head.direction
	mover.position = {x_position, y_position}
	mover.speed = BULLET_SPEED
	mover.kind = .BULLET


	last_cell := game.player.body[game.player.num_cells - 1]
	last_ghost, ok := peek_cell(game.player.ghost_pieces)
	if ok &&
	   last_cell.count_turns_left <= 1 &&
	   vec2_distance(last_cell.position, last_ghost.position) < PLAYER_SIZE {
		pop_cell(game.player.ghost_pieces)
	}

	game.player.num_cells -= 1

	//TODO: CHECK FOR GHOST PIECES WITH NO PARENTS 
}

spawn_candy :: proc(candy: ^collider_t) {
	x_position := (int(rand.float32() * SCREEN_WIDTH) % PLAYER_SIZE) * PLAYER_SIZE * 2
	y_position := (int(rand.float32() * SCREEN_HEIGHT) % PLAYER_SIZE) * PLAYER_SIZE * 2

	candy.position = {f32(x_position), f32(y_position)}

	candy.position.x = clamp(candy.position.x, PLAYER_SIZE * 2, SCREEN_WIDTH - PLAYER_SIZE * 2)
	candy.position.y = clamp(candy.position.y, PLAYER_SIZE * 2, SCREEN_HEIGHT - PLAYER_SIZE * 2)
	candy.w = CANDY_SIZE
	candy.h = CANDY_SIZE
	candy.kind = .CANDY
	candy.state = .ALIVE

}

////////////
// RENDER //
// ////////////

draw_scene :: proc(game: ^Game) {
	num_colliders :=
		game.scene.num_initial_colliders + int(game.num_candies) + int(game.num_bullets)
	for i in 0 ..< num_colliders {
		if game.scene.colliders[i].state == .DEAD {
			continue
		}

		rec := rl.Rectangle {
			game.scene.colliders[i].position.x,
			game.scene.colliders[i].position.y,
			game.scene.colliders[i].w,
			game.scene.colliders[i].h,
		}
		color: rl.Color
		#partial switch game.scene.colliders[i].kind {
		case .STATIC:
			color = rl.YELLOW
		case .CANDY:
			color = rl.RED
		case .BULLET:
			color = rl.BLUE
		}
		rl.DrawRectangleRec(rec, color)
	}
}

draw_player :: proc(player: ^Player) {
	rl.DrawRectangle(
		i32(player.head.position.x),
		i32(player.head.position.y),
		PLAYER_SIZE,
		PLAYER_SIZE,
		rl.GREEN,
	)

	for i in 0 ..< player.num_cells {
		cell := player.body[i]
		if cell.size < PLAYER_SIZE {
			x_position: f32
			y_position: f32
			cell_size_x: i8
			cell_size_y: i8
			direction := player.body[i].direction

			piece_to_follow := (i == 0) ? player.head : player.body[i - 1]

			if player.ghost_pieces.count > 0 {
				ghost_piece :=
					player.ghost_pieces.values[get_ghost_piece_index(cell.count_turns_left, player.ghost_pieces.tail)]
				if rec_colliding(
					cell.position,
					PLAYER_SIZE,
					PLAYER_SIZE,
					ghost_piece.position,
					PLAYER_SIZE,
					PLAYER_SIZE,
				) {
					piece_to_follow = ghost_to_cell(ghost_piece)
				}
			}


			switch direction {
			case {0, 1}:
				x_position = piece_to_follow.position.x
				y_position = piece_to_follow.position.y - f32(cell.size)
			case {0, -1}:
				x_position = piece_to_follow.position.x
				y_position = piece_to_follow.position.y + PLAYER_SIZE
			case {1, 0}:
				x_position = piece_to_follow.position.x - f32(cell.size)
				y_position = piece_to_follow.position.y
			case {-1, 0}:
				x_position = piece_to_follow.position.x + PLAYER_SIZE
				y_position = piece_to_follow.position.y
			}
			cell_size_x = PLAYER_SIZE
			cell_size_y = cell.size
			rl.DrawRectangle(
				i32(x_position),
				i32(y_position),
				i32(cell_size_x),
				i32(cell_size_y),
				rl.PURPLE,
			)
			player.body[i].size += 2
		} else {
			rl.DrawRectangle(
				i32(cell.position.x),
				i32(cell.position.y),
				PLAYER_SIZE,
				PLAYER_SIZE,
				rl.ORANGE,
			)
		}
	}
}

draw_ghost_cells :: proc(rb: ^Ringuffer_t) {
	for i in 0 ..< rb.count {
		current := rb.head + i
		if current >= MAX_RINGBUFFER_VALUES {
			current = current % MAX_RINGBUFFER_VALUES
		}
		cell := rb.values[current]
		rl.DrawRectangle(
			i32(cell.position.x),
			i32(cell.position.y),
			PLAYER_SIZE,
			PLAYER_SIZE,
			rl.PINK,
		)
	}

}

draw_grid :: proc(col: rl.Color) {
	for i: i32 = 0; i < SCREEN_WIDTH; i += PLAYER_SIZE {
		rl.DrawLine(i, 0, i, SCREEN_HEIGHT, col)
		rl.DrawLine(0, i, SCREEN_WIDTH, i, col)
	}
}

/////////////
// COLLIDE //
/////////////
check_collision :: proc(game: ^Game) {
	player := game.player
	colliders := game.scene.colliders

	future_pos := vec2_add(player.head.position, vec2_mul_scalar(player.next_dir, PLAYER_SPEED))
	num_initial_colliders := game.scene.num_initial_colliders + int(game.num_candies)

	for i in 0 ..< num_initial_colliders {
		c := colliders[i]
		if c.kind != .STATIC {
			#partial switch c.kind {
			case .CANDY:
				// CHECK DISTANCE BETWEEN 2 CENTERS IS LESS THAN PLAYER SIZE

				//
				// if rec_colliding_no_edges(
				// 	player.head.position,
				// 	PLAYER_SIZE,
				// 	PLAYER_SIZE,
				// 	colliders[i].position,
				// 	CANDY_SIZE,
				// 	CANDY_SIZE,
				// ) 


				center_player := player.head.position
				center_player.x += PLAYER_SIZE / 2
				center_player.y += PLAYER_SIZE / 2

				center_candy := c.position
				center_candy.x += CANDY_SIZE / 2
				center_candy.y += CANDY_SIZE / 2
				if vec2_distance(center_player, center_candy) < PLAYER_SIZE && c.state != .DEAD {
					fmt.println("PLAYER", center_player)
					fmt.println("CANDY", center_candy)
					// If is not the last, we take the last and put it on new place, then we clamp
					// if i != int(game.num_candies - 1) {
					// 	game.scene.colliders[i] =
					// 		game.scene.colliders[int(game.num_candies) + game.scene.num_initial_colliders - 1]
					// }

					game.num_candies -= 1
					grow_body(game.player)
					colliders[i].state = .DEAD
				}

			// WARN: I DO NOT COLLIDE WITH BULLETS!
			// case .BULLET
			}} else {
			if rec_colliding_no_edges(c.position, c.w, c.h, future_pos, PLAYER_SIZE, PLAYER_SIZE) {
				player.next_dir = {0, 0}
			}
		}
	}
}

aligned_to_grid :: proc(p: vec2_t) -> bool {
	return i32(p.x) % PLAYER_SIZE == 0 && i32(p.y) % PLAYER_SIZE == 0
}


rec_colliding :: proc(v0: vec2_t, w0: f32, h0: f32, v1: vec2_t, w1: f32, h1: f32) -> bool {
	horizontal_in :=
		(v0.x <= v1.x && v0.x + w0 >= v1.x) || (v0.x <= v1.x + w1 && v0.x + w0 >= v1.x + w1)
	vertical_in :=
		(v0.y <= v1.y && v0.y + h0 >= v1.y) || (v0.y <= v1.y + h1 && v0.y + h0 >= v1.y + h1)
	return horizontal_in && vertical_in
}


rec_colliding_no_edges :: proc(
	v0: vec2_t,
	w0: f32,
	h0: f32,
	v1: vec2_t,
	w1: f32,
	h1: f32,
) -> bool {
	horizontal_in :=
		(v0.x < v1.x && v0.x + w0 > v1.x) || (v0.x < v1.x + w1 && v0.x + w0 > v1.x + w1)
	vertical_in := (v0.y < v1.y && v0.y + h0 > v1.y) || (v0.y < v1.y + h1 && v0.y + h0 > v1.y + h1)
	return horizontal_in && vertical_in
}


aligned :: proc(v0: vec2_t, v1: vec2_t) -> bool {
	return v0.x == v1.x || v0.y == v1.y
}


////////////
// OTHERS //
////////////

add_turn_count :: proc(player: ^Player) {
	for i in 0 ..< player.num_cells {
		player.body[i].count_turns_left += 1
	}
}

ghost_to_cell :: proc(cell: cell_ghost_t) -> cell_t {
	return cell_t{position = cell.position, direction = cell.direction}
}

vec2_distance :: proc(a, b: vec2_t) -> f32 {
	return math.sqrt(math.pow(b.x - a.x, 2.0) + math.pow(b.y - a.y, 2.0))
}

get_cardinal_direction :: proc(from, to: vec2_t) -> vec2_t {
	dx := to.x - from.x
	dy := to.y - from.y
	// THE PROBLEM IS THAT WE HAVE TO APLY ANOTHER DIRECTION TO PIECES WHEN THEY ARE SPAWNED, not to all, just to the ones that blaabla, you can check up how is it going
	if (abs(dx) > abs(dy)) {
		return (dx > 0) ? vec2_t{1, 0} : vec2_t{-1, 0}
	} else {
		return (dy > 0) ? vec2_t{0, 1} : vec2_t{0, -1}
	}
}

get_ghost_piece_index :: proc(turns_left, tail: i8) -> i8 {
	index := (MAX_RINGBUFFER_VALUES + tail - turns_left) % MAX_RINGBUFFER_VALUES
	return index
}


TESTING :: proc(game: ^Game) {
	for i in 1 ..< game.player.num_cells {
		prev_cell := game.player.body[i - 1]
		next_cell := game.player.body[i]


		if !rec_colliding(
			prev_cell.position,
			PLAYER_SIZE,
			PLAYER_SIZE,
			next_cell.position,
			PLAYER_SIZE,
			PLAYER_SIZE,
		) {

			fmt.println()
			fmt.printf(
				"LENGTH BODY %d, PREV_CELL IDX %d, NEXT_CELL IDX %d",
				game.player.num_cells,
				i - 1,
				i,
			)
			fmt.println("PREV_CELL POS AND DIR", prev_cell.position, prev_cell.direction)
			fmt.println("NEXT_CELL POS AND DIR", next_cell.position, next_cell.direction)
		}

		index :=
			(MAX_RINGBUFFER_VALUES + game.player.ghost_pieces.tail - next_cell.count_turns_left) %
			MAX_RINGBUFFER_VALUES

		following_ghost_piece := ghost_to_cell(game.player.ghost_pieces.values[index])
		if !aligned(next_cell.position, following_ghost_piece.position) &&
		   next_cell.count_turns_left != 0 &&
		   following_ghost_piece.position != {0, 0} {

			fmt.println()
			fmt.println()
			fmt.println(
				"GHOST POS AND DIR",
				following_ghost_piece.position,
				following_ghost_piece.direction,
			)
			fmt.println("NEXT_CELL POS AND DIR", next_cell.position, next_cell.direction)
		}

	}
}

vec2_add :: proc(v0, v1: vec2_t) -> vec2_t {
	return {v0.x + v1.x, v0.y + v1.y}

}
vec2_mul_scalar :: proc(v: vec2_t, scalar: f32) -> vec2_t {
	return {v.x * scalar, v.y * scalar}
}
