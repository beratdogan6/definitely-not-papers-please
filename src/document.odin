package main

import rl "vendor:raylib"

DOCUMENT_COLOR :: rl.Color{255, 250, 240, 255} // paper white

Document :: struct {
	rect: rl.Rectangle,
}

new_document :: proc(docs_bounds: rl.Rectangle) -> Document {
	return {
		rect = {
			x = docs_bounds.x + docs_bounds.width / 2 - 60,
			y = docs_bounds.y + docs_bounds.height / 2 - 40,
			width = 120,
			height = 80,
		},
	}
}

clamp_rect_to_bounds :: proc(rect: rl.Rectangle, bounds: rl.Rectangle) -> rl.Rectangle {
	clamped := rect
	clamped.x = clamp(rect.x, bounds.x, bounds.x + bounds.width - rect.width)
	clamped.y = clamp(rect.y, bounds.y, bounds.y + bounds.height - rect.height)
	return clamped
}
