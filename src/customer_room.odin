package main

import rl "vendor:raylib"

// The room is static set dressing: the backdrop and counter look the same
// whether or not a customer is currently standing at the counter. The
// current customer (if any) is drawn between the two, so the counter's
// front face naturally covers their lower half, like they're standing
// behind it.
draw_customer_room :: proc(bounds: rl.Rectangle, customer: Customer_State, portrait: rl.Texture2D) {
	draw_customer_backdrop(bounds)
	draw_current_customer(bounds, customer, portrait)
	draw_customer_counter(bounds)
}

customer_backdrop_rect :: proc(bounds: rl.Rectangle) -> rl.Rectangle {
	return {bounds.x, bounds.y, bounds.width, bounds.height * 0.64}
}

customer_counter_rect :: proc(bounds: rl.Rectangle) -> rl.Rectangle {
	return {
		x = bounds.x,
		y = bounds.y + bounds.height * 0.64,
		width = bounds.width,
		height = bounds.height * 0.30,
	}
}

draw_customer_backdrop :: proc(bounds: rl.Rectangle) {
	WALL :: rl.Color{58, 42, 36, 255}
	WALL_SHADOW :: rl.Color{40, 28, 24, 255}
	PLANK_SEAM :: rl.Color{34, 24, 20, 255}
	RULER_MARK :: rl.Color{224, 216, 194, 200}
	RULER_TEXT :: rl.Color{224, 216, 194, 220}
	LAMP_CORD :: rl.Color{20, 16, 14, 255}
	LAMP_SHADE :: rl.Color{30, 22, 20, 255}
	LAMP_GLOW :: rl.Color{235, 210, 150, 255}

	backdrop := customer_backdrop_rect(bounds)
	rl.DrawRectangleRec(backdrop, WALL)

	PLANK_COUNT :: 8
	plank_width := backdrop.width / PLANK_COUNT
	for i in 1 ..< PLANK_COUNT {
		x := backdrop.x + f32(i) * plank_width
		rl.DrawLineEx({x, backdrop.y}, {x, backdrop.y + backdrop.height}, 2, PLANK_SEAM)
	}

	// vignette under the hanging lamp
	rl.DrawRectangleRec({backdrop.x, backdrop.y, backdrop.width, backdrop.height * 0.16}, WALL_SHADOW)

	lamp_x := backdrop.x + backdrop.width - 34
	rl.DrawLineEx({lamp_x, backdrop.y}, {lamp_x, backdrop.y + 16}, 2, LAMP_CORD)
	rl.DrawCircle(i32(lamp_x), i32(backdrop.y + 16), 3, LAMP_GLOW)
	rl.DrawTriangle(
		{lamp_x - 12, backdrop.y + 30},
		{lamp_x + 12, backdrop.y + 30},
		{lamp_x, backdrop.y + 16},
		LAMP_SHADE,
	)

	// height-chart ruler ticks, like a lineup wall
	RULER_LABELS :: []cstring{"7", "6", "5", "4", "3", "2", "1"}
	ruler_x := backdrop.x + 16
	top_margin := f32(28)
	bottom_margin := f32(20)
	tick_gap := (backdrop.height - top_margin - bottom_margin) / f32(len(RULER_LABELS) - 1)

	for label, i in RULER_LABELS {
		y := backdrop.y + top_margin + f32(i) * tick_gap
		rl.DrawLineEx({ruler_x, y}, {ruler_x + 14, y}, 2, RULER_MARK)
		rl.DrawText(label, i32(ruler_x + 18), i32(y - 6), 12, RULER_TEXT)
	}
}

draw_current_customer :: proc(bounds: rl.Rectangle, customer: Customer_State, portrait: rl.Texture2D) {
	_, present := customer.current.?
	if !present {
		return
	}

	PORTRAIT_SIZE :: f32(200)

	backdrop := customer_backdrop_rect(bounds)
	counter := customer_counter_rect(bounds)

	rest_y := backdrop.y + backdrop.height * 0.16
	start_y := counter.y + counter.height * 0.5
	progress := smooth_step(customer.spawn_t)
	y := start_y + (rest_y - start_y) * progress
	x := bounds.x + (bounds.width - PORTRAIT_SIZE) / 2

	scale := PORTRAIT_SIZE / f32(portrait.width)
	rl.DrawTextureEx(portrait, {x, y}, 0, scale, rl.WHITE)
}

draw_customer_counter :: proc(bounds: rl.Rectangle) {
	COUNTER_SHADOW :: rl.Color{28, 20, 18, 140}
	COUNTER_FRONT :: rl.Color{132, 122, 96, 255}
	COUNTER_TOP :: rl.Color{168, 158, 128, 255}
	COUNTER_POST :: rl.Color{112, 102, 80, 255}
	FLOOR :: rl.Color{46, 34, 30, 255}

	counter := customer_counter_rect(bounds)
	floor := rl.Rectangle {
		x      = bounds.x,
		y      = counter.y + counter.height,
		width  = bounds.width,
		height = bounds.y + bounds.height - (counter.y + counter.height),
	}

	rl.DrawRectangleRec(floor, FLOOR)
	rl.DrawRectangleRec({counter.x, counter.y - 6, counter.width, 6}, COUNTER_SHADOW)
	rl.DrawRectangleRec(counter, COUNTER_FRONT)
	rl.DrawRectangleRec({counter.x, counter.y, counter.width, counter.height * 0.26}, COUNTER_TOP)

	post_radius := counter.height * 0.24
	post_y := counter.y + counter.height * 0.5
	rl.DrawCircle(i32(counter.x + post_radius), i32(post_y), post_radius, COUNTER_POST)
	rl.DrawCircle(i32(counter.x + counter.width - post_radius), i32(post_y), post_radius, COUNTER_POST)
}
