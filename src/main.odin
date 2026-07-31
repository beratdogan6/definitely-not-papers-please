package main

import rl "vendor:raylib"

main :: proc() {
	SCREEN_WIDTH :: 1280
	SCREEN_HEIGHT :: 720
	TARGET_FPS :: 60

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Definitely Not Papers, Please")
	rl.SetTargetFPS(TARGET_FPS) // Set our game to run at 60 frames-per-second

	person_texture := rl.LoadTexture("assets/queue_person.png")
	defer rl.UnloadTexture(person_texture)

	customer_portrait_texture := rl.LoadTexture(CUSTOMER_PLACEHOLDER_PICTURE)
	defer rl.UnloadTexture(customer_portrait_texture)

	quadrants := build_quadrants(f32(SCREEN_WIDTH), f32(SCREEN_HEIGHT))
	document := new_document(quadrants[.Docs].bounds)

	dragging := false
	drag_offset: rl.Vector2
	queue_state := Queue_State{}
	customer_state := Customer_State{}

	for !rl.WindowShouldClose() { 	// Detect window close button or ESC key
		mouse_pos := rl.GetMousePosition()

		if rl.IsMouseButtonPressed(.LEFT) {
			if rl.CheckCollisionPointRec(mouse_pos, document.rect) {
				dragging = true
				drag_offset = {mouse_pos.x - document.rect.x, mouse_pos.y - document.rect.y}
			}
			if can_call_next_customer(queue_state, customer_state) && rl.CheckCollisionPointRec(mouse_pos, border_booth_interaction_rect(quadrants[.Border].bounds)) {
				call_next_customer(&queue_state)
			}
		}
		if rl.IsMouseButtonReleased(.LEFT) {
			dragging = false
		}
		if dragging {
			document.rect.x = mouse_pos.x - drag_offset.x
			document.rect.y = mouse_pos.y - drag_offset.y
		}
		document.rect = clamp_rect_to_bounds(document.rect, quadrants[.Docs].bounds)
		update_queue_state(&queue_state, &customer_state, rl.GetFrameTime())
		update_customer_state(&customer_state, rl.GetFrameTime())

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for quadrant in quadrants {
			rl.DrawRectangleRec(quadrant.bounds, quadrant.color)
			if quadrant.label != nil {
				draw_centered_label(quadrant.label, quadrant.bounds, quadrant.label_color)
			}
		}

		draw_border_booth(quadrants[.Border].bounds, queue_state.next_shout_timer > 0)
		draw_customer_room(quadrants[.Customer].bounds, customer_state, customer_portrait_texture)

		QUEUE_SIZE :: 20
		draw_queue(quadrants[.Line].bounds, person_texture, QUEUE_SIZE, &queue_state, border_booth_rect(quadrants[.Border].bounds))

		rl.DrawRectangleRec(document.rect, DOCUMENT_COLOR)

		rl.EndDrawing()
	}

	rl.CloseWindow() // Close window and OpenGL context
}
