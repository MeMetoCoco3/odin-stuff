package main
import "core:fmt"


vec2_t :: struct {
	x, y: f32,
}

candy :: struct {
	collider: collider_t,
}

cell_t :: struct {
	position, direction: vec2_t,
	count_turns_left:    i8,
	size:                i8,
}

cell_ghost_t :: struct {
	position, direction: vec2_t,
}


Player :: struct {
	head:             cell_t,
	next_dir:         vec2_t,
	body:             [MAX_NUM_BODY]cell_t,
	health:           i8,
	num_cells:        i8,
	num_ghost_pieces: i8,
	ghost_pieces:     ^Ringuffer_t,
}

Game :: struct {
	state:       bool,
	player:      ^Player,
	num_candies: i8,
	num_bullets: i8,
	scene:       ^scene_t,
}


oposite_directions :: proc(new, curr: vec2_t) -> bool {
	return new.x == -curr.x && new.y == -curr.y
}
