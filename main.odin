package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 720, "Definitely Not Papers, Please")
	rl.SetTargetFPS(60) // Set our game to run at 60 frames-per-second

	for !rl.WindowShouldClose() { 	// Detect window close button or ESC key
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
		rl.EndDrawing()
	}

	rl.CloseWindow() // Close window and OpenGL context
}
