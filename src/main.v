module main

import gg
import gx
import math
import rand

const win_width = 800
const win_height = 800

const bg_color = gx.rgb(39, 40, 34)
const fg_color = gx.rgb(248, 248, 242)
const grey = gx.rgb(117, 113, 94)
const magenta = gx.rgb(174, 129, 255)
const green = gx.rgb(166, 226, 46)
const blue = gx.rgb(102, 217, 239)
const red = gx.rgb(249, 38, 114)
const yellow = gx.rgb(226, 226, 46)

const k = 3

// app struct that has property of current application.
struct App {
mut:
	ctx  &gg.Context = unsafe { nil }
	data []Point
}

struct Point {
	x      f64      @[required]
	y      f64      @[required]
	radius int
	color  gx.Color
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
		sample_count: 50
		window_title: 'K-means'
		frame_fn: frame
		keydown_fn: on_key_down
		user_data: app
	)
	// app.data = calibration_dataset()
	app.data = gaussians_dataset(4, 1000)
	app.ctx.run() // run the app loop
}

fn frame(mut app App) {
	app.ctx.begin()
	app.draw_data()
	app.ctx.end()
}

fn on_key_down(key gg.KeyCode, mod gg.Modifier, mut app App) {
	match key {
		.a {
			println('Closing application.')
			app.ctx.quit()
		}
		else {}
	}
}

fn (app &App) draw_data() {
	for point in app.data {
		screen_x, screen_y := get_screen_position(point)
		app.ctx.draw_circle_filled(screen_x, screen_y, point.radius, point.color)
	}
}

fn get_screen_position(point Point) (int, int) {
	return int(math.round(win_width / 2 + win_width / 2 * point.x)), int(math.round(win_width / 2 +
		win_width / 2 * point.y))
}

// Returns a dataset of calibration points:
// - center of the screen (purple)
// - corners of the screen (yellow)
// - edges of the screen (red)
fn calibration_dataset() []Point {
	return [
		Point{0, 0, 3, magenta},
		Point{1, 0, 3, yellow},
		Point{-1, 0, 3, yellow},
		Point{0, 1, 3, yellow},
		Point{0, -1, 3, yellow},
		Point{-1, -1, 3, red},
		Point{1, -1, 3, red},
		Point{-1, 1, 3, red},
		Point{1, 1, 3, red},
	]
}

// Returns a dataset of n points randomly drawn from k 2D gaussians.
// Each gaussian has a random mean in the (-1, -1), (1, 1) square and a random variance in [0.1, 0.3].
fn gaussians_dataset(k int, n int) []Point {
	mut colors := [magenta, green, blue, red, yellow]
	mut centers := []Point{}
	mut variances := []f64{}
	for _ in 0 .. k {
		centers << Point{rand.f64_in_range(-1, 1) or {
			panic('Could not generate center for gaussian dataset.')
		}, rand.f64_in_range(-1, 1) or { panic('Could not generate center for gaussian dataset.') }, 3, fg_color}
		variances << rand.f64_in_range(0.1, 0.3) or {
			panic('Could not generate variance for gaussian dataset.')
		}
	}
	mut res := []Point{}
	for _ in 0 .. n {
		gaussian := rand.int_in_range(0, k) or {
			panic('Could not choose point gaussian for gaussian dataset.')
		}
		x := rand.normal(mu: centers[gaussian].x, sigma: variances[gaussian]) or {
			panic('Could not generate point for gaussian dataset.')
		}
		y := rand.normal(mu: centers[gaussian].y, sigma: variances[gaussian]) or {
			panic('Could not generate point for gaussian dataset.')
		}
		res << Point{x, y, 3, colors[gaussian % colors.len]}
	}
	return res
}
