package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 800
PLAYER_SIZE :: 20
PLAYER_SPEED :: 4
MAX_NUM_BODY :: 20


MAX_NUM_CANDIES :: 10
CANDY_SIZE :: 20
CANDY_RESPAWN_TIME :: 20

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
		head         = cell_t{vec2_t{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}, {0, -1}},
		health       = 3,
		ghost_pieces = &ring_buffer,
		prev_dir     = {0, 0},
	}

	game := Game {
		player      = &pj,
		state       = true,
		candies     = [MAX_NUM_CANDIES]candy{},
		num_candies = 0,
	}

	time := 0

	for !rl.WindowShouldClose() {
		if time >= CANDY_RESPAWN_TIME {
			time = 0
			if game.num_candies < MAX_NUM_CANDIES {
				spawn_candy(&game.candies, &game.num_candies)
			}
		}

		update(&game)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_grid({100, 100, 100, 255})

		draw_player(&pj)
		draw_ghost_cells(pj.ghost_pieces)
		draw_candies(game.candies, game.num_candies)


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

	if game.player.next_dir != game.player.prev_dir && aligned_to_grid(game.player.head.position) {
		try_set_dir(game.player, game.player.next_dir)
	}
}

try_set_dir :: proc(p: ^Player, dir: vec2_t) {
	if !oposite_directions(dir, p.head.direction) && p.prev_dir != dir {
		p.prev_dir = dir
		p.head.direction = dir

		if p.num_cells > 0 {
			put_cell(p.ghost_pieces, cell_ghost_t{p.head.position, p.head.direction})
		}
	}
}

aligned_to_grid :: proc(p: vec2_t) -> bool {
	return i32(p.x) % PLAYER_SIZE == 0 && i32(p.y) % PLAYER_SIZE == 0
}

update_player :: proc(player: ^Player) {
	player.head.position.x += player.head.direction.x * PLAYER_SPEED
	player.head.position.y += player.head.direction.y * PLAYER_SPEED
	for i in 0 ..< player.num_cells {
		piece_to_follow: cell_t
		if i == 0 {
			piece_to_follow = player.head
		} else {
			piece_to_follow = player.body[i - 1]
		}

		// It will start following once its far enough.
		distance := vec2_distance(piece_to_follow.position, player.body[i].position)
		if (distance >= PLAYER_SIZE) {
			player.body[i].direction = piece_to_follow.direction
		}

		if (i == player.num_cells - 1) {
			dealing_ghost_piece(player, i)
		}

		player.body[i].position.x += player.body[i].direction.x * PLAYER_SPEED
		player.body[i].position.y += player.body[i].direction.y * PLAYER_SPEED
	}
}

grow_body :: proc(pj: ^Player) {
	direction: vec2_t
	new_x, new_y: f32

	if pj.num_cells == 0 {
		direction = {0, 0}
		new_x = pj.head.position.x
		new_y = pj.head.position.y
	} else {
		direction = {0, 0}
		new_x = pj.body[pj.num_cells - 1].position.x
		new_y = pj.body[pj.num_cells - 1].position.y
	}

	new_cell := cell_t{{new_x, new_y}, direction}
	pj.body[pj.num_cells] = new_cell
	pj.num_cells += 1
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


spawn_candy :: proc(candies: ^[MAX_NUM_CANDIES]candy, num_candies: ^i8) {
	new_candy := candy{rand.float32() * SCREEN_WIDTH, rand.float32() * SCREEN_HEIGHT}
	candies[num_candies^] = new_candy
	num_candies^ += 1
}

////////////
// RENDER //
////////////
draw_candies :: proc(candies: [MAX_NUM_CANDIES]candy, num_candies: i8) {
	for i in 0 ..< num_candies {
		candy := candies[i]
		rl.DrawRectangle(i32(candy.x), i32(candy.y), CANDY_SIZE, CANDY_SIZE, rl.RED)
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
		rl.DrawRectangle(
			i32(cell.position.x),
			i32(cell.position.y),
			PLAYER_SIZE,
			PLAYER_SIZE,
			rl.ORANGE,
		)
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
	candies := game.candies

	for i := game.num_candies - 1; i >= 0; i -= 1 {
		if rec_colliding(
			player.head.position,
			PLAYER_SIZE,
			PLAYER_SIZE,
			candies[i],
			CANDY_SIZE,
			CANDY_SIZE,
		) {
			// If is not the last, we take the last and put it on new place, then we clamp
			if i != game.num_candies - 1 {
				game.candies[i] = game.candies[game.num_candies - 1]
			}
			game.num_candies -= 1
			grow_body(game.player)
		}
	}
}

rec_colliding :: proc(v0: vec2_t, w0: f32, h0: f32, v1: vec2_t, w1: f32, h1: f32) -> bool {
	horizontal_in :=
		(v0.x <= v1.x && v0.x + w0 >= v1.x) || (v0.x <= v1.x + w1 && v0.x + w0 >= v1.x + w1)
	vertical_in :=
		(v0.y <= v1.y && v0.y + h0 >= v1.y) || (v0.y <= v1.y + h1 && v0.y + h0 >= v1.y + h1)
	return horizontal_in && vertical_in
}


////////////
// OTHERS //
////////////

vec2_distance :: proc(a, b: vec2_t) -> f32 {
	return math.sqrt(math.pow(b.x - a.x, 2.0) + math.pow(b.y - a.y, 2.0))
}
