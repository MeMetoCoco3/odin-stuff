package main

import "core:fmt"
import "core:math/linalg"
Vec2 :: [2]f32
a: Vec2 = {1, 2}
b: Vec2 = {4, 6}
c: Vec2 = {3, 1}


proj_point_over_line :: proc(a, b, c: Vec2) -> Vec2 {
	ab := b - a
	ac := c - a

	dot_abc := linalg.dot(ab, ac)

	length_square := linalg.length2(ab)
	t := dot_abc / length_square
	return Vec2{a.x + t * ab.x, a.y + t * ab.y}
}


main :: proc() {
	// ab := b - a
	// ac := c - a
	//
	// dot_abc := linalg.dot(ab, ac)
	//
	// length_square := linalg.length2(ab)
	// fmt.println(length_square)
	// t := dot_abc / length_square
	// fmt.println(t)

	fmt.println(proj_point_over_line(a, b, c))

}
