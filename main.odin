package main

import rl "vendor:raylib"

Document :: struct {
	rect: rl.Rectangle,
}

Queue_State :: struct {
	has_customer:     bool,
	advancing:        bool,
	advance_t:        f32,
	next_shout_timer: f32,
}

QUEUE_PERSON_SCALE :: f32(1.5)
QUEUE_PERSON_SPACING :: f32(32)
QUEUE_ADVANCE_DURATION :: f32(0.8)

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

	person_texture := rl.LoadTexture("assets/queue_person.png")
	defer rl.UnloadTexture(person_texture)

	split_x := f32(SCREEN_WIDTH * 3 / 10)
	split_y := f32(SCREEN_HEIGHT * 3 / 10)
	screen_width := f32(SCREEN_WIDTH)
	screen_height := f32(SCREEN_HEIGHT)

	// Bounds are computed once here, not per frame - they never change after the window opens.
	quadrants := [Quadrant_Kind]Quadrant {
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

	dragging := false
	drag_offset: rl.Vector2
	queue_state := Queue_State {}

	for !rl.WindowShouldClose() { 	// Detect window close button or ESC key
		mouse_pos := rl.GetMousePosition()

		if rl.IsMouseButtonPressed(.LEFT) {
			if rl.CheckCollisionPointRec(mouse_pos, document.rect) {
				dragging = true
				drag_offset = {mouse_pos.x - document.rect.x, mouse_pos.y - document.rect.y}
			}
			if can_call_next_customer(queue_state) && rl.CheckCollisionPointRec(mouse_pos, border_booth_interaction_rect(quadrants[.Border].bounds)) {
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
		document.rect = clamp_rect_to_bounds(document.rect, docs_bounds)
		update_queue_state(&queue_state, rl.GetFrameTime())

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for quadrant in quadrants {
			rl.DrawRectangleRec(quadrant.bounds, quadrant.color)
			if quadrant.label != nil {
				draw_centered_label(quadrant.label, quadrant.bounds, quadrant.label_color)
			}
		}

		draw_border_booth(quadrants[.Border].bounds, queue_state.next_shout_timer > 0)

		QUEUE_SIZE :: 20
		draw_queue(quadrants[.Line].bounds, person_texture, QUEUE_SIZE, &queue_state, border_booth_rect(quadrants[.Border].bounds))

		rl.DrawRectangleRec(document.rect, DOCUMENT_COLOR)

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

// Places people along one continuous snaking path so the queue reads as a line,
// not as a set of evenly aligned grid cells.
draw_queue :: proc(bounds: rl.Rectangle, texture: rl.Texture2D, count: int, state: ^Queue_State, booth: rl.Rectangle) {
	if state.advancing {
		progress := smooth_step(state.advance_t)
		new_customer_start := queue_spawn_position(bounds, texture, count)
		new_customer_end := queue_slot_position(bounds, texture, count - 1)
		draw_person(texture, lerp_vec2(new_customer_start, new_customer_end, progress))

		for draw_index in 1 ..< count {
			slot := count - draw_index
			start := queue_slot_position(bounds, texture, slot)
			end := queue_slot_position(bounds, texture, slot - 1)
			draw_person(texture, lerp_vec2(start, end, progress))
		}

		front_start := queue_slot_position(bounds, texture, 0)
		front_end := current_customer_position(booth, texture)
		draw_person(texture, lerp_vec2(front_start, front_end, progress))
		return
	}

	for draw_index in 0 ..< count {
		slot := count - 1 - draw_index
		draw_person(texture, queue_slot_position(bounds, texture, slot))
	}

	// Once a customer reaches the booth, they are considered inside the booth.
}

queue_slot_position :: proc(bounds: rl.Rectangle, texture: rl.Texture2D, slot: int) -> rl.Vector2 {
	person_size := f32(texture.width) * QUEUE_PERSON_SCALE
	margin_x := person_size * 1.1
	margin_y := person_size * 0.75
	left_x := bounds.x + margin_x
	right_x := bounds.x + bounds.width - person_size * 2.25
	top_y := bounds.y + margin_y
	bottom_y := bounds.y + bounds.height - margin_y
	lane_gap := (bottom_y - top_y) / 3

	path := [?]rl.Vector2 {
		{right_x, bottom_y},
		{left_x, bottom_y},
		{left_x, bottom_y - lane_gap},
		{right_x - 28, bottom_y - lane_gap},
		{right_x - 28, bottom_y - lane_gap * 2},
		{left_x + 22, bottom_y - lane_gap * 2},
		{left_x + 22, top_y},
		{right_x - 54, top_y},
	}

	distance := f32(slot) * QUEUE_PERSON_SPACING + f32((slot % 4) - 1) * 2.5
	if distance < 0 {
		distance = 0
	}

	pos := point_on_queue_path(path[:], distance)
	pos.x += f32((slot % 3) - 1) * 4
	pos.y += f32(((slot + 1) % 3) - 1) * 3
	pos.x -= person_size / 2
	pos.y -= person_size / 2
	return pos
}

queue_spawn_position :: proc(bounds: rl.Rectangle, texture: rl.Texture2D, count: int) -> rl.Vector2 {
	pos := queue_slot_position(bounds, texture, count - 1)
	pos.x = bounds.x - f32(texture.width) * QUEUE_PERSON_SCALE - 24
	return pos
}

current_customer_position :: proc(booth: rl.Rectangle, texture: rl.Texture2D) -> rl.Vector2 {
	person_size := f32(texture.width) * QUEUE_PERSON_SCALE
	return {
		booth.x - person_size * 0.65,
		booth.y + booth.height - person_size - 4,
	}
}

draw_person :: proc(texture: rl.Texture2D, pos: rl.Vector2) {
	rl.DrawTextureEx(texture, pos, 0, QUEUE_PERSON_SCALE, rl.WHITE)
}

can_call_next_customer :: proc(state: Queue_State) -> bool {
	return !state.has_customer && !state.advancing
}

call_next_customer :: proc(state: ^Queue_State) {
	state.advancing = true
	state.advance_t = 0
	state.next_shout_timer = 0.55
}

update_queue_state :: proc(state: ^Queue_State, dt: f32) {
	if state.next_shout_timer > 0 {
		state.next_shout_timer -= dt
		if state.next_shout_timer < 0 {
			state.next_shout_timer = 0
		}
	}

	if state.advancing {
		state.advance_t += dt / QUEUE_ADVANCE_DURATION
		if state.advance_t >= 1 {
			state.advancing = false
			state.advance_t = 0
			state.has_customer = true
		}
	}
}

lerp_vec2 :: proc(start, end: rl.Vector2, amount: f32) -> rl.Vector2 {
	return {
		start.x + (end.x - start.x) * amount,
		start.y + (end.y - start.y) * amount,
	}
}

smooth_step :: proc(value: f32) -> f32 {
	t := clamp_f32(value, 0, 1)
	return t * t * (3 - 2 * t)
}

clamp_f32 :: proc(value, min_value, max_value: f32) -> f32 {
	if value < min_value {
		return min_value
	}
	if value > max_value {
		return max_value
	}
	return value
}

point_on_queue_path :: proc(path: []rl.Vector2, distance: f32) -> rl.Vector2 {
	if len(path) == 0 {
		return {}
	}

	remaining_distance := distance
	for i in 0 ..< len(path) - 1 {
		start := path[i]
		end := path[i + 1]
		delta := rl.Vector2{end.x - start.x, end.y - start.y}
		segment_length := abs_f32(delta.x) + abs_f32(delta.y)

		if remaining_distance <= segment_length {
			t := remaining_distance / segment_length
			return {
				start.x + delta.x * t,
				start.y + delta.y * t,
			}
		}

		remaining_distance -= segment_length
	}

	return path[len(path) - 1]
}

abs_f32 :: proc(value: f32) -> f32 {
	if value < 0 {
		return -value
	}
	return value
}
