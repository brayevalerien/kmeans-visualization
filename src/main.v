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
const n = 500

// app struct that has property of current application.
struct App {
mut:
	ctx         &gg.Context = unsafe { nil }
	data        []Point
	predictions []int // predictions[i] is the predicted cluster of data[i]
	centroids   []Point
	step        int
}

struct Point {
mut:
	x      f64
	y      f64
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
	app.data = gaussians_dataset(k, n)
	app.step = 0
	app.init_centroids(k)
	app.update_predictions()
	app.ctx.run() // run the app loop
}

fn frame(mut app App) {
	app.ctx.begin()
	app.draw_points()
	app.ctx.draw_text(5, 5, 'Press space to take a step', color: fg_color)
	app.ctx.draw_text(5, 21, '   → current step: ${app.step}', color: fg_color)
	app.ctx.end()
}

fn on_key_down(key gg.KeyCode, mod gg.Modifier, mut app App) {
	match key {
		.a {
			println('Closing application.')
			app.ctx.quit()
		}
		.space {
			app.kmeans_step()
			app.step++
		}
		else {}
	}
}

fn (app &App) draw_points() {
	for point in app.data {
		screen_x, screen_y := get_screen_position(point)
		app.ctx.draw_circle_filled(screen_x, screen_y, point.radius, point.color)
	}
	for centroid in app.centroids {
		screen_x, screen_y := get_screen_position(centroid)
		app.ctx.draw_circle_filled(screen_x, screen_y, centroid.radius, centroid.color)
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

// returns the colors corresponding to the nth cluster
fn get_cluster_color(n int) gx.Color {
	colors := [magenta, yellow, red, blue, green]
	return colors[n % colors.len]
}

// Returns a dataset of n points randomly drawn from k 2D gaussians.
// Each gaussian has a random mean in the (-.75, -.75), (.75, 75) square and a random variance in [0.1, 0.3].
fn gaussians_dataset(k int, n int) []Point {
	mut centers := []Point{}
	mut variances := []f64{}
	for _ in 0 .. k {
		centers << Point{rand.f64_in_range(-0.75, 0.75) or {
			panic('Could not generate center for gaussian dataset.')
		}, rand.f64_in_range(-0.75, 0.75) or {
			panic('Could not generate center for gaussian dataset.')
		}, 3, fg_color}
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
		res << Point{x, y, 3, get_cluster_color(gaussian)}
	}
	return res
}

fn (mut app App) init_centroids(k int) {
	mut centroids := []Point{}
	for _ in 0 .. k {
		centroids << Point{rand.f64_in_range(-1, 1) or { panic('Could not generate centroid.') }, rand.f64_in_range(-1,
			1) or { panic('Could not generate centroid.') }, 8, fg_color}
	}
	app.centroids = centroids
	app.predictions = []int{len: app.data.len, init: 0}
	app.update_predictions()
}

// Does one step in the kmeans algorithm by moving the centroids towards their clusters.
fn (mut app App) kmeans_step() {
	// 1. move each centroid to the mean position of its cluster
	for i, mut centroid in app.centroids {
		// a. find list of points in the cluster
		mut cluster := []Point{}
		for j, point in app.data {
			if app.predictions[j] == i {
				cluster << point
			}
		}
		// b. move the centroid to the average position in this cluster
		centroid.x, centroid.y = get_average_position(cluster)
	}
	// 2. update the cluster (predition) assigned to each point
	app.update_predictions()
}

fn get_average_position(points []Point) (f64, f64) {
	mut sum_x, mut sum_y := f64(0), f64(0)
	for point in points {
		sum_x += point.x
		sum_y += point.y
	}
	return sum_x / points.len, sum_y / points.len
}

// Computes app.predictions to be the new clusters associated with each point.
fn (mut app App) update_predictions() {
	for i, mut point in app.data {
		mut min_dist := math.inf(1)
		for j, centroid in app.centroids {
			if dist(point, centroid) < min_dist {
				min_dist = dist(point, centroid)
				app.predictions[i] = j
			}
		}
		point.color = get_cluster_color(app.predictions[i])
	}
}

// Computes the distance between two points
fn dist(a Point, b Point) f64 {
	return math.sqrt(math.square(b.x - a.x) + math.square(b.y - a.y))
}
