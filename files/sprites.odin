package main


import rl "vendor:raylib"

atlas: rl.Texture2D
main :: proc() {
	rl.InitWindow(800, 800, "jamon")


	atlas = rl.LoadTexture("assets/textures/atlas.png")


	rotation: f32 = 0
	dst_rect := rl.Rectangle{400, 400, 64, 256}
	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.Q) {
			rl.CloseWindow()
		}

		if rl.IsKeyPressed(.SPACE) {
			rotation += 90
		}

		if rl.IsKeyPressed(.A) {
			dst_rect.x -= 2
		}

		if rl.IsKeyPressed(.S) {
			dst_rect.y += 2
		}
		if rl.IsKeyPressed(.D) {
			dst_rect.x += 2
		}
		if rl.IsKeyPressed(.W) {
			dst_rect.y -= 2
		}

		rl.BeginDrawing()
		draw(dst_rect, rotation)

		for i: i32 = 0; i < 800; i += 20 {
			rl.DrawLine(0, i, 800, i, rl.BLACK)
			rl.DrawLine(i, 0, i, 800, rl.BLACK)
		}

		rl.ClearBackground(rl.RED)
		rl.EndDrawing()

	}

}


draw :: proc(dst_rec: rl.Rectangle, angle: f32) {
	src_rect := rl.Rectangle{0, 0, 32, 32}


	origin := rl.Vector2{dst_rec.width / 2, dst_rec.height / 2}


	rl.DrawTexturePro(atlas, src_rect, dst_rec, origin, angle, rl.WHITE)
}
