// Odin + Box2D + Raylib example with
// stacking boxes and a shape attached to
// the cursor that can smack the shapes.

// Made during this stream:
// https://www.youtube.com/watch?v=LYW7jdwEnaI

// I have updated this to use the
// `vendor:box2d` bindings instead of the
// ones I used on the stream.

package main

import "core:math"
import b2 "vendor:box2d"
import rl "vendor:raylib"

Box :: struct {
	body:  b2.BodyId,
	shape: b2.ShapeId,
}

create_box :: proc(world_id: b2.WorldId, pos: b2.Vec2) -> Box {
	body_def := b2.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.position = pos
	body := b2.CreateBody(world_id, body_def)

	box := b2.MakeBox(20, 20)
	box_def := b2.DefaultShapeDef()
	shape := b2.CreatePolygonShape(body, box_def, box)

	return {body = body, shape = shape}
}

main :: proc() {
	rl.InitWindow(1280, 720, "Box2D + Raylib example")

	world_def := b2.DefaultWorldDef()
	world_def.gravity = b2.Vec2{0, -1}
	world_id := b2.CreateWorld(world_def)

	ground := rl.Rectangle{0, 600, 1280, 120}

	ground_body_def := b2.DefaultBodyDef()
	ground_body_def.position = b2.Vec2{ground.x, -ground.y - ground.height}
	ground_body_id := b2.CreateBody(world_id, ground_body_def)

	ground_box := b2.MakeBox(ground.width, ground.height)
	ground_shape_def := b2.DefaultShapeDef()
	ground_shape := b2.CreatePolygonShape(ground_body_id, ground_shape_def, ground_box)

	bodies: [dynamic]Box

	// This generates the initial placement
	// for the boxes.
	for x in 0 ..< 10 {
		for y in 0 ..< 5 {
			px := f32(x * 20 + 400)
			py := f32(y * 20 - 400)
			b := create_box(world_id, {px, py})
			append(&bodies, b)
		}
	}

	// A circle that we'll move with the mouse.
	circle_body_def := b2.DefaultBodyDef()
	circle_body_def.type = .dynamicBody
	circle_body_def.position = b2.Vec2{0, 4}
	circle_body_id := b2.CreateBody(world_id, circle_body_def)

	circle_shape_def := b2.DefaultShapeDef()
	circle_shape_def.density = 1000

	circle: b2.Circle
	circle.radius = 40
	circle_shape := b2.CreateCircleShape(circle_body_id, circle_shape_def, circle)

	TIME_STEP :: 1.0 / 60.0
	TIME_SUB_STEPS :: 4

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawRectangleRec(ground, rl.RED)
		mouse_pos := rl.GetMousePosition()

		b2.Body_SetTransform(circle_body_id, {mouse_pos.x, -mouse_pos.y}, {})
		b2.World_Step(world_id, TIME_STEP, TIME_SUB_STEPS)

		for b in bodies {
			position := b2.Body_GetPosition(b.body)
			a := b2.Rot_GetAngle(b2.Body_GetRotation(b.body))

			// There's a negation of
			// position.y because Box2D is
			// Y up and Raylib is Y down.
			rl.DrawRectanglePro(
				{position.x, -position.y, 40, 40},
				{20, 20},
				-a * math.DEG_PER_RAD,
				rl.YELLOW,
			)
		}

		rl.DrawCircleV(mouse_pos, 40, rl.MAGENTA)
		rl.EndDrawing()
	}

	// You don't really need to destroy all
	// these things if you're going to destroy
	// the world. But in a simulation where you
	// have a persistent world and constantly
	// add and remove bodies you'll need to do
	// stuff like this.
	for b in bodies {
		b2.DestroyShape(b.shape)
		b2.DestroyBody(b.body)
	}

	b2.DestroyShape(ground_shape)
	b2.DestroyBody(ground_body_id)
	b2.DestroyShape(circle_shape)
	b2.DestroyBody(circle_body_id)

	b2.DestroyWorld(world_id)

	rl.CloseWindow()
}
