package main
import "core:fmt"
SCENES :: enum {
	ONE,
}


scene_t :: struct {
	colliders:             []collider_t,
	num_initial_colliders: int,
	movers:                []mover_t,
	num_movers:            int,
	// enemies ...
}


scene :: proc(s: SCENES) -> ^scene_t {
	s := new(scene_t)

	colliders := make([]collider_t, MAX_NUM_COLLIDERS)

	colliders_slice := []collider_t {
		{position = {0, 0}, w = SCREEN_WIDTH, h = 20, kind = .STATIC, state = .ALIVE},
		{
			position = {0, SCREEN_HEIGHT - 20},
			w = SCREEN_WIDTH,
			h = 20,
			kind = .STATIC,
			state = .ALIVE,
		},
		{position = {0, 0}, w = 20, h = SCREEN_HEIGHT, kind = .STATIC, state = .ALIVE},
		{
			position = {SCREEN_WIDTH - 20, 0},
			w = 20,
			h = SCREEN_HEIGHT,
			kind = .STATIC,
			state = .ALIVE,
		},
	}
	cnt := 0
	for i in 0 ..< len(colliders_slice) {
		colliders[i] = colliders_slice[i]
		cnt += 1
	}

	s.colliders = colliders
	s.num_initial_colliders = cnt
	s.movers = make([]mover_t, MAX_NUM_COLLIDERS)

	return s
}
