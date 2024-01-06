module main

import gg
import gx
import math

const win_width = 600
const win_height = 600

const bg_color := gx.rgb(39, 40, 34)
const fg_color := gx.rgb(248, 248, 242)
const grey := gx.rgb(117, 113, 94)
const magenta := gx.rgb(174, 129, 255)
const green := gx.rgb(166, 226, 46)
const blue := gx.rgb(102, 217, 239)
const red := gx.rgb(249, 38, 114)
const yellow := gx.rgb(226, 226, 46)

const k := 3

// app struct that has property of current windows
struct App {
mut:
	ctx    &gg.Context = unsafe { nil }
	data []Point
}

struct Point {
	x f64
	y f64
	radius int
	color gx.Color
}


// main function
fn main() {
	// app variable
	mut app := &App{}

	// setting values of app
	app.ctx = gg.new_context(
		bg_color: bg_color
		width: win_width
		height: win_height
		window_title: 'K-means'
		frame_fn: frame
		keydown_fn: on_key_down
		user_data: app
	)
	app.data = [
		Point{0, 0, 10, magenta}
		Point{1, 0, 10, grey}
		Point{-1, 0, 10, grey}
		Point{0, 1, 10, grey}
		Point{0, -1, 10, grey}
		Point{-1, -1, 10, grey}
		Point{1, -1, 10, grey}
		Point{-1, 1, 10, grey}
		Point{1, 1, 10, grey}
	] // test values
	app.ctx.run() // run the app loop
}

fn frame(mut app App) {
	app.ctx.begin()
	app.draw_data()
	app.ctx.end()
}

fn on_key_down(key gg.KeyCode, mod gg.Modifier, mut app &App) {
	match key {
		.a {
			println('Closing application.')
			app.ctx.quit()
		}
		else {}
	}
}

fn (app &App) draw_data() {
	for point in app.data{
		screen_x, screen_y := get_screen_position(point)
		app.ctx.draw_circle_filled(screen_x, screen_y, point.radius, point.color)
	}
}

fn get_screen_position(point Point) (int, int) {
	return int(math.round(win_width/2 + win_width/2*point.x)), int(math.round(win_width/2 + win_width/2*point.y))
}
