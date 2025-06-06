package main


COLLIDER_TYPE :: enum {
	STATIC,
	BULLET,
	CANDY,
}


MAX_NUM_COLLIDERS :: 100


collider_t :: struct {
	position: vec2_t,
	w, h:     f32,
	kind:     COLLIDER_TYPE,
}

mover_t :: struct {
	position:  vec2_t,
	direction: vec2_t,
	speed:     f32,
	kind:      COLLIDER_TYPE,
}
