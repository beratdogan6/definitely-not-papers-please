package main

import rl "vendor:raylib"

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

// Bounds are computed once at startup, not per frame - they never change after the window opens.
build_quadrants :: proc(screen_width, screen_height: f32) -> [Quadrant_Kind]Quadrant {
	split_x := screen_width * 3 / 10
	split_y := screen_height * 3 / 10

	return [Quadrant_Kind]Quadrant {
		.Line = {
			bounds = {0, 0, split_x, split_y},
			color  = {110, 110, 110, 255}, // outdoor concrete, queue side
		},
		.Border = {
			bounds      = {split_x, 0, screen_width - split_x, split_y},
			color       = {140, 140, 140, 255}, // outdoor concrete, guard side
			label       = "BORDER",
			label_color = rl.WHITE,
		},
		.Customer = {
			bounds = {0, split_y, split_x, screen_height - split_y},
			color  = {85, 27, 24, 255}, // booth wood paneling, covered by draw_customer_room
		},
		.Docs = {
			bounds      = {split_x, split_y, screen_width - split_x, screen_height - split_y},
			color       = {228, 230, 189, 255}, // notebook / paper
			label       = "DOCS",
			label_color = rl.BLACK,
		},
	}
}

draw_centered_label :: proc(text: cstring, bounds: rl.Rectangle, color: rl.Color) {
	FONT_SIZE :: 20

	text_width := f32(rl.MeasureText(text, FONT_SIZE))
	label_x := bounds.x + (bounds.width - text_width) / 2
	label_y := bounds.y + (bounds.height - FONT_SIZE) / 2

	rl.DrawText(text, i32(label_x), i32(label_y), FONT_SIZE, color)
}
