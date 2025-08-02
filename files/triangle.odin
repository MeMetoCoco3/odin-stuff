package main

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"
@(private = "file")
Vec2 :: [2]f32

draw_triangle :: proc(t: Triangle) {
	vertices := [3]Vec2{}
	for i in 0 ..< 3 {
		angle_i := t.angle + 2 * math.PI * f32(i) / f32(3)
		new_vert := t.center + Vec2{math.cos(angle_i), math.sin(angle_i)} * t.size
		vertices[i] = new_vert
	}

	rl.DrawTriangle(vertices[0], vertices[2], vertices[1], t.color)
}

Triangle :: struct {
	angle:  f32,
	size:   f32,
	center: Vec2,
	color:  rl.Color,
}

main :: proc() {
	rl.InitWindow(600, 600, "jamon")
	tri := Triangle {
		angle  = 0,
		size   = 50,
		center = {400, 400},
		color  = rl.GREEN,
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
