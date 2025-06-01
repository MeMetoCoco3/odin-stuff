package main
import "core:fmt"

vec2_t :: struct {
	x, y: f32,
}

candy :: vec2_t

cell_t :: struct {
	position, direction: vec2_t,
}
cell_ghost_t :: struct {
	position, direction: vec2_t,
}

DIR_IDX :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

Directions: [4]vec2_t = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}

Player :: struct {
	head:             cell_t,
	prev_dir:         vec2_t,
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
	candies:     [MAX_NUM_CANDIES]candy,
	num_candies: i8,
}


get_direction :: proc(idx: DIR_IDX) -> vec2_t {
	return Directions[idx]
}


oposite_directions :: proc(new, curr: vec2_t) -> bool {
	return new.x == -curr.x && new.y == -curr.y
}
