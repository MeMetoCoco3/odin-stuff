package main
import "core:fmt"

Vector4 :: [4]f32

vec4_t :: struct {
	x, y, z, w: f32,
}


main :: proc() {
	v1 := Vector4{1, 2, 3, 4}
	v2 := Vector4{4, 3, 2, 1}
	fmt.println(v1)
	fmt.println(v2)
	fmt.println(v1 * v2)
	fmt.println(v1 * 10)
}
