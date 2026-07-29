package main

import rl "vendor:raylib"

Document :: struct {
	rect: rl.Rectangle,
}

Quadrant_Kind :: enum {
	Line,
	Border,
	Customer,
	Docs,
}

Quadrant :: struct {
	bounds:      rl.Rectangle,
	color:       rl.Color,
	label:       cstring,
	label_color: rl.Color,
}

main :: proc() {
	SCREEN_WIDTH :: 1280
	SCREEN_HEIGHT :: 720
	TARGET_FPS :: 60

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Definitely Not Papers, Please")
	rl.SetTargetFPS(TARGET_FPS) // Set our game to run at 60 frames-per-second

	split_x := f32(SCREEN_WIDTH * 3 / 10)
	split_y := f32(SCREEN_HEIGHT * 3 / 10)
	screen_width := f32(SCREEN_WIDTH)
	screen_height := f32(SCREEN_HEIGHT)

	// Bounds are computed once here, not per frame - they never change after the window opens.
	quadrants := [Quadrant_Kind]Quadrant {
		.Line = {
			bounds      = {0, 0, split_x, split_y},
			color       = {110, 110, 110, 255}, // outdoor concrete, queue side
			label       = "LINE",
			label_color = rl.WHITE,
		},
		.Border = {
			bounds      = {split_x, 0, screen_width - split_x, split_y},
			color       = {140, 140, 140, 255}, // outdoor concrete, guard side
			label       = "BORDER",
			label_color = rl.WHITE,
		},
		.Customer = {
			bounds      = {0, split_y, split_x, screen_height - split_y},
			color       = {85, 27, 24, 255}, // booth wood paneling
			label       = "CUSTOMER",
			label_color = rl.WHITE,
		},
		.Docs = {
			bounds      = {split_x, split_y, screen_width - split_x, screen_height - split_y},
			color       = {228, 230, 189, 255}, // notebook / paper
			label       = "DOCS",
			label_color = rl.BLACK,
		},
	}

	DOCUMENT_COLOR :: rl.Color{255, 250, 240, 255} // paper white

	docs_bounds := quadrants[.Docs].bounds
	document := Document {
		rect = {
			x = docs_bounds.x + docs_bounds.width / 2 - 60,
			y = docs_bounds.y + docs_bounds.height / 2 - 40,
			width = 120,
			height = 80,
		},
	}

	for !rl.WindowShouldClose() { 	// Detect window close button or ESC key
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for quadrant in quadrants {
			rl.DrawRectangleRec(quadrant.bounds, quadrant.color)
			draw_centered_label(quadrant.label, quadrant.bounds, quadrant.label_color)
		}

		document.rect = clamp_rect_to_bounds(document.rect, docs_bounds)
		rl.DrawRectangleRec(document.rect, DOCUMENT_COLOR)

		mouse_pos := rl.GetMousePosition()
		if (rl.IsMouseButtonPressed(.LEFT)) {
			rl.TraceLog(.INFO, "Mouse left click pressed!")
			if (rl.CheckCollisionPointRec(mouse_pos, document.rect)) {
				rl.TraceLog(.INFO, "Mouse clicked in the document!")
			}
		}

		rl.EndDrawing()
	}

	rl.CloseWindow() // Close window and OpenGL context
}

draw_centered_label :: proc(text: cstring, bounds: rl.Rectangle, color: rl.Color) {
	FONT_SIZE :: 20

	text_width := f32(rl.MeasureText(text, FONT_SIZE))
	label_x := bounds.x + (bounds.width - text_width) / 2
	label_y := bounds.y + (bounds.height - FONT_SIZE) / 2

	rl.DrawText(text, i32(label_x), i32(label_y), FONT_SIZE, color)
}

clamp_rect_to_bounds :: proc(rect: rl.Rectangle, bounds: rl.Rectangle) -> rl.Rectangle {
	clamped := rect
	clamped.x = clamp(rect.x, bounds.x, bounds.x + bounds.width - rect.width)
	clamped.y = clamp(rect.y, bounds.y, bounds.y + bounds.height - rect.height)
	return clamped
}
