package main
import "core:fmt"
SCENES :: enum {
	ONE,
}


MAX_NUM_COLLIDERS :: 50

collider_t :: struct {
	position: vec2_t,
	w, h:     f32,
}


scene_t :: struct {
	colliders:     []collider_t,
	num_colliders: int,
	// enemies ...
}


scene :: proc(s: SCENES) -> ^scene_t {
	s := new(scene_t)

	colliders := make([]collider_t, MAX_NUM_COLLIDERS)

	colliders_slice := []collider_t {
		{position = {0, 0}, w = SCREEN_WIDTH, h = 20},
		{position = {0, SCREEN_HEIGHT - 20}, w = SCREEN_WIDTH, h = 20},
		{position = {0, 0}, w = 20, h = SCREEN_HEIGHT},
		{position = {SCREEN_WIDTH - 20, 0}, w = 20, h = SCREEN_HEIGHT},
	}

	for i in 0 ..< len(colliders_slice) {
		colliders[i] = colliders_slice[i]
	}

	s.colliders = colliders
	s.num_colliders = len(s.colliders)
	return s

}
