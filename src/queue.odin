package main

import rl "vendor:raylib"

Queue_State :: struct {
	advancing:        bool,
	advance_t:        f32,
	next_shout_timer: f32,
}

QUEUE_PERSON_SCALE :: f32(1.5)
QUEUE_PERSON_SPACING :: f32(32)
QUEUE_ADVANCE_DURATION :: f32(0.8)

can_call_next_customer :: proc(queue: Queue_State, customer: Customer_State) -> bool {
	return !customer_present(customer) && !queue.advancing
}

call_next_customer :: proc(queue: ^Queue_State) {
	queue.advancing = true
	queue.advance_t = 0
	queue.next_shout_timer = 0.55
}

update_queue_state :: proc(queue: ^Queue_State, customer: ^Customer_State, dt: f32) {
	if queue.next_shout_timer > 0 {
		queue.next_shout_timer -= dt
		if queue.next_shout_timer < 0 {
			queue.next_shout_timer = 0
		}
	}

	if queue.advancing {
		queue.advance_t += dt / QUEUE_ADVANCE_DURATION
		if queue.advance_t >= 1 {
			queue.advancing = false
			queue.advance_t = 0
			customer.current = next_roster_customer(customer)
			customer.spawn_t = 0
		}
	}
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
