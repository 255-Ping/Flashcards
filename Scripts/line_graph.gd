# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name LineGraph

# --- Data ---
# Each dataset: { "points": Array[Dictionary{ "pos": Vector2, "deck": String }], "color": Color, "label": String }
var datasets: Array = []

# --- Display ranges & style ---
@export var x_range := Vector2(0, 10)
@export var y_range := Vector2(0, 50)
@export var line_color := Color(0.3, 0.8, 0.1)
@export var line_width := 2.0
@export var show_axes := true
@export var show_grid := true
@export var show_labels := true
@export var x_divisions := 10
@export var y_divisions := 10
@export var show_axes_labels := true
@export var label_color := Color(0.8, 0.8, 0.8)
@export var label_font_size := 14
@export var show_point_labels := true
@export var point_label_color := Color(1, 1, 1)
@export var point_label_font_size := 12
@export var show_legend := true
@export var legend_font_size := 12

# --------------------------------------------------
# Node lifecycle
# --------------------------------------------------
func _ready() -> void:
	if datasets.is_empty():
		datasets.append({"points": [], "color": line_color, "label": "Series 1"})
	set_process(false)
	queue_redraw()

func _draw() -> void:
	if show_grid: _draw_grid()
	if show_axes: _draw_axes()
	if show_labels: _draw_labels()
	if show_legend: _draw_legend()
	_draw_lines_and_points()

# --------------------------------------------------
# Drawing helpers
# --------------------------------------------------
func _draw_grid():
	if x_divisions <= 0 or y_divisions <= 0: return
	var x_step = size.x / x_divisions
	var y_step = size.y / y_divisions
	for i in range(1, x_divisions):
		draw_line(Vector2(i*x_step,0), Vector2(i*x_step,size.y), Color(0.2,0.2,0.2,0.4))
	for i in range(1, y_divisions):
		draw_line(Vector2(0,i*y_step), Vector2(size.x,i*y_step), Color(0.2,0.2,0.2,0.4))

func _draw_axes():
	draw_line(Vector2(0,size.y), Vector2(size.x,size.y), Color.GRAY, 2)
	draw_line(Vector2(0,0), Vector2(0,size.y), Color.GRAY, 2)

func _draw_labels():
	if !show_axes_labels: return
	var font := get_theme_default_font()
	if font == null: return
	if x_divisions <= 0 or y_divisions <= 0: return

	var x_step = size.x / x_divisions
	var y_step = size.y / y_divisions
	var x_val_step = (x_range.y - x_range.x) / x_divisions
	var y_val_step = (y_range.y - y_range.x) / y_divisions

	# X-axis
	for i in range(x_divisions+1):
		var value = x_range.x + x_val_step*i
		var pos = Vector2(i*x_step, size.y)
		var text = str(round(value*100.0)/100.0)
		draw_string(font, pos + Vector2(-10,-4), text, HORIZONTAL_ALIGNMENT_CENTER, -1, label_font_size, label_color)

	# Y-axis
	for i in range(y_divisions+1):
		var value = y_range.x + y_val_step*i
		var pos = Vector2(0, size.y - i*y_step)
		var text = str(round(value*100.0)/100.0)
		draw_string(font, pos + Vector2(5,5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_font_size, label_color)

func _draw_lines_and_points():
	var font := get_theme_default_font()
	for ds in datasets:
		var pts: Array = ds.get("points", [])
		if pts.size() < 1: continue
		var color: Color = ds.get("color", line_color)

		# Draw lines
		if pts.size() >= 2:
			var screen_points := []
			for p_data in pts:
				screen_points.append(_to_screen(p_data["pos"]))
			for i in range(screen_points.size()-1):
				draw_line(screen_points[i], screen_points[i+1], color, line_width)

		# Draw points & labels
		for i in range(pts.size()):
			var p_data = pts[i]
			var sp = _to_screen(p_data["pos"])
			draw_circle(sp, 3, color)
			if show_point_labels and font:
				var deck = p_data.get("deck","")
				var label_text = str(round(p_data["pos"].y*100.0)/100.0)
				if deck != "":
					label_text += " (" + deck + ")"
				var label_pos = sp + Vector2(5,-5)
				draw_string(font, label_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, point_label_font_size, point_label_color)

func _draw_legend():
	if !show_legend: return
	var font := get_theme_default_font()
	if font == null: return
	var start = Vector2(size.x - 140, 8)
	var y_offset = 0
	for ds in datasets:
		var color = ds.get("color", line_color)
		var label = ds.get("label","")
		draw_rect(Rect2(start + Vector2(0, y_offset), Vector2(14,12)), color)
		draw_string(font, start + Vector2(20, y_offset+11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, legend_font_size, label_color)
		y_offset += 18

# --------------------------------------------------
# Helper
# --------------------------------------------------
func _to_screen(p: Vector2) -> Vector2:
	var xr = x_range.y - x_range.x
	var yr = y_range.y - y_range.x
	if xr==0: xr=1
	if yr==0: yr=1
	var x_ratio = (p.x - x_range.x) / xr
	var y_ratio = (p.y - y_range.x) / yr
	return Vector2(
		clamp(x_ratio*size.x, 0, size.x),
		clamp(size.y - y_ratio*size.y, 0, size.y)
	)

# --------------------------------------------------
# Public API
# --------------------------------------------------
func add_dataset(points_array: Array=[], color=null, label:String=""):
	var col = color if color != null else line_color
	var ds = {"points": points_array.duplicate(), "color": col, "label": label}
	datasets.append(ds)
	queue_redraw()

func add_point(x: float, y: float, dataset_idx: int=0, deck_name: String=""):
	if dataset_idx<0: return
	while dataset_idx >= datasets.size():
		add_dataset([], line_color, "Series " + str(datasets.size()+1))
	datasets[dataset_idx]["points"].append({"pos": Vector2(x,y), "deck": deck_name})
	queue_redraw()

func clear_points(dataset_idx: int=0):
	if dataset_idx >=0 and dataset_idx<datasets.size():
		datasets[dataset_idx]["points"].clear()
	queue_redraw()

func clear_datasets():
	datasets.clear()
	datasets.append({"points": [], "color": line_color, "label": "Series 1"})
	queue_redraw()

func set_range(x_min: float, x_max: float, y_min: float, y_max: float):
	x_range = Vector2(x_min,x_max)
	y_range = Vector2(y_min,y_max)
	queue_redraw()

func auto_scale():
	if datasets.is_empty(): return
	var all_points := []
	for ds in datasets:
		all_points += ds.get("points", [])
	if all_points.is_empty(): return
	var xs = all_points.map(func(p): return p["pos"].x)
	var ys = all_points.map(func(p): return p["pos"].y)
	x_range = Vector2(xs.min(), xs.max())
	y_range = Vector2(ys.min(), ys.max())
	queue_redraw()

func set_divisions(x_divs:int, y_divs:int):
	x_divisions = max(1,x_divs)
	y_divisions = max(1,y_divs)
	queue_redraw()

func set_line_color(new_color: Color):
	line_color = new_color
	if datasets.size() > 0:
		datasets[0]["color"] = new_color
	queue_redraw()

func set_show_point_labels(new_bool: bool):
	show_point_labels = new_bool
	queue_redraw()

func set_show_axes_labels(new_bool: bool):
	show_axes_labels = new_bool
	queue_redraw()

func set_show_grid(new_bool: bool):
	show_grid = new_bool
	queue_redraw()

func set_show_legend(new_bool: bool):
	show_legend = new_bool
	queue_redraw()
