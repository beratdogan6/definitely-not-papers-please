package main

import rl "vendor:raylib"

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

abs_f32 :: proc(value: f32) -> f32 {
	if value < 0 {
		return -value
	}
	return value
}
