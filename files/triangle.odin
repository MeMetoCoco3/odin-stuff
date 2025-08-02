package main

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"
@(private = "file")
Vec2 :: [2]f32

draw_triangle :: proc(s: Shape) {
	vertices := [10]Vec2{}
	for i in 0 ..< s.num_sides {
		angle_i := s.angle + 2 * math.PI * f32(i) / f32(s.num_sides)
		new_vert := s.center + Vec2{math.cos(angle_i), math.sin(angle_i)} * s.size
		vertices[i] = new_vert
	}
	for i in 1 ..< s.num_sides {
		prev := vertices[i - 1]
		curr := vertices[i]
		rl.DrawLine(i32(prev.x), i32(prev.y), i32(curr.x), i32(curr.y), s.color)
	}
	last := vertices[s.num_sides - 1]
	first := vertices[0]


	rl.DrawLine(i32(first.x), i32(first.y), i32(last.x), i32(last.y), s.color)

}
//
// draw_pentagon :: proc(p: Pentagon) {
// 	vertices := [3]Vec2{}
// 	for i in 0 ..< 3 {
// 		angle_i := t.angle + 2 * math.PI * f32(i) / f32(3)
// 		new_vert := t.center + Vec2{math.cos(angle_i), math.sin(angle_i)} * t.size
// 		vertices[i] = new_vert
// 	}
//
// 	rl.DrawTriangle(vertices[0], vertices[2], vertices[1], t.color)
//
// }

Shape :: struct {
	num_sides: i32,
	angle:     f32,
	size:      f32,
	center:    Vec2,
	color:     rl.Color,
}

main :: proc() {
	rl.InitWindow(600, 600, "jamon")
	tri := Shape {
		num_sides = 5,
		angle     = 0,
		size      = 50,
		center    = {400, 400},
		color     = rl.GREEN,
	}

	for !rl.WindowShouldClose() {
		if rl.IsKeyDown(.LEFT) {
			tri.angle -= linalg.RAD_PER_DEG
		} else if rl.IsKeyDown(.RIGHT) {
			tri.angle += linalg.RAD_PER_DEG
		}

		rl.BeginDrawing()
		draw_triangle(tri)
		rl.ClearBackground(rl.RED)
		rl.EndDrawing()
	}
}
