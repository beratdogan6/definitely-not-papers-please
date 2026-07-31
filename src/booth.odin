package main

import rl "vendor:raylib"

border_booth_rect :: proc(bounds: rl.Rectangle) -> rl.Rectangle {
	booth_width :: f32(126)
	booth_height :: f32(74)
	return {
		x = bounds.x - booth_width / 2,
		y = bounds.y + bounds.height - booth_height - 12,
		width = booth_width,
		height = booth_height,
	}
}

border_booth_interaction_rect :: proc(bounds: rl.Rectangle) -> rl.Rectangle {
	booth := border_booth_rect(bounds)
	return {
		x = booth.x - 48,
		y = booth.y - 40,
		width = booth.width + 80,
		height = booth.height + 46,
	}
}

draw_border_booth :: proc(bounds: rl.Rectangle, shouting: bool) {
	booth := border_booth_rect(bounds)

	SHADOW :: rl.Color{58, 43, 39, 120}
	ROOF :: rl.Color{46, 31, 29, 255}
	FRONT :: rl.Color{70, 48, 43, 255}
	SIDE :: rl.Color{52, 37, 35, 255}
	TRIM :: rl.Color{108, 79, 58, 255}
	WINDOW :: rl.Color{35, 42, 50, 255}
	GLASS_HIGHLIGHT :: rl.Color{97, 119, 132, 255}

	rl.DrawRectangleRec({booth.x + 8, booth.y + booth.height - 8, booth.width, 12}, SHADOW)
	rl.DrawRectangleRec(booth, FRONT)
	rl.DrawRectangleRec({booth.x + booth.width - 28, booth.y + 8, 28, booth.height - 8}, SIDE)
	rl.DrawRectangleRec({booth.x - 6, booth.y - 10, booth.width + 18, 18}, ROOF)
	rl.DrawRectangleRec({booth.x - 2, booth.y + 8, booth.width + 4, 6}, TRIM)
	rl.DrawRectangleRec({booth.x + 14, booth.y + 22, 54, 30}, WINDOW)
	rl.DrawRectangleRec({booth.x + 18, booth.y + 25, 7, 24}, GLASS_HIGHLIGHT)
	rl.DrawRectangleRec({booth.x + 76, booth.y + 24, 24, 32}, SIDE)
	rl.DrawRectangleRec({booth.x + 82, booth.y + 30, 12, 5}, TRIM)
	rl.DrawRectangleRec({booth.x + 12, booth.y + booth.height - 10, booth.width - 26, 5}, TRIM)

	draw_megaphone({booth.x + 26, booth.y - 18})
	if shouting {
		draw_next_shout({booth.x - 58, booth.y - 54})
	}
}

draw_megaphone :: proc(anchor: rl.Vector2) {
	METAL_DARK :: rl.Color{82, 57, 41, 255}
	METAL :: rl.Color{160, 112, 55, 255}
	METAL_LIGHT :: rl.Color{204, 151, 73, 255}

	mouth_top := rl.Vector2{anchor.x - 40, anchor.y - 11}
	mouth_bottom := rl.Vector2{anchor.x - 40, anchor.y + 9}
	neck_top := rl.Vector2{anchor.x - 10, anchor.y - 5}
	neck_bottom := rl.Vector2{anchor.x - 10, anchor.y + 4}

	rl.DrawLineEx({anchor.x + 1, anchor.y + 10}, {anchor.x + 17, anchor.y + 26}, 4, METAL_DARK)
	rl.DrawTriangle(mouth_top, neck_top, neck_bottom, METAL)
	rl.DrawTriangle(mouth_top, neck_bottom, mouth_bottom, METAL)
	rl.DrawLineEx(mouth_top, mouth_bottom, 4, METAL_LIGHT)
	rl.DrawRectangleRec({anchor.x - 10, anchor.y - 7, 15, 13}, METAL_DARK)
	rl.DrawRectangleRec({anchor.x + 2, anchor.y - 4, 13, 8}, METAL_LIGHT)
	rl.DrawCircle(i32(anchor.x + 17), i32(anchor.y), 5, METAL_DARK)
}

draw_next_shout :: proc(pos: rl.Vector2) {
	BUBBLE :: rl.Color{238, 225, 178, 255}
	BORDER :: rl.Color{72, 49, 38, 255}
	TEXT :: rl.Color{48, 31, 28, 255}

	bubble := rl.Rectangle{pos.x, pos.y, 70, 26}
	rl.DrawRectangleRec({bubble.x + 2, bubble.y + 2, bubble.width, bubble.height}, {48, 31, 28, 90})
	rl.DrawRectangleRec(bubble, BUBBLE)
	rl.DrawRectangleLinesEx(bubble, 2, BORDER)
	rl.DrawText("NEXT!", i32(bubble.x + 10), i32(bubble.y + 6), 14, TEXT)
}
