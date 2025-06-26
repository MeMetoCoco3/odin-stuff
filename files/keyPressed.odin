package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(100, 100, "test")
	cnt := 0

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if rl.IsKeyDown(.SPACE) {
			cnt += 1
		}

		if rl.IsKeyReleased(.SPACE) {
			fmt.println("Pressed", cnt)
			cnt = 0
		}


		rl.DrawText("Press SPACE", 10, 10, 20, rl.BLACK)
		rl.EndDrawing()
	}
}
