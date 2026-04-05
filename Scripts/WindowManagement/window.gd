extends Control

var resizing := false
var resize_margin := 16
var resize_dir := Vector2.ZERO

var content: String
var is_window := true

@onready var content_container = $VBoxContainer


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if content:
		open_window_with_content(content)


func _process(_delta):
	
	var content_min = content_container.get_combined_minimum_size()
	print(content_min)
	custom_minimum_size = content_min
	
	var pos := get_global_mouse_position() - global_position
	var dir := get_resize_direction(pos)

	if dir.x != 0 and dir.y == 0:
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif dir.y != 0 and dir.x == 0:
		mouse_default_cursor_shape = Control.CURSOR_VSIZE
	elif dir.x != 0 and dir.y != 0:
		if dir.x == dir.y:
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		else:
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW


func _input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if event.pressed:
				var pos := get_global_mouse_position() - global_position
				resize_dir = get_resize_direction(pos)
				
				if resize_dir != Vector2.ZERO:
					resizing = true
			else:
				resizing = false


	if resizing and event is InputEventMouseMotion:
		resize_window(event.relative)


func get_resize_direction(pos: Vector2) -> Vector2:
	var dir := Vector2.ZERO
	
	if pos.x >= -resize_margin and pos.x <= 0:
		dir.x = -1
	elif pos.x <= size.x + resize_margin and pos.x >= size.x:
		dir.x = 1
		
	if pos.y >= -resize_margin and pos.y <= 0:
		dir.y = -1
	elif pos.y <= size.y + resize_margin and pos.y >= size.y:
		dir.y = 1
		
	return dir


func resize_window(rel: Vector2):

	if resize_dir.x == 1:
		size.x += rel.x
	elif resize_dir.x == -1:
		size.x -= rel.x
		position.x += rel.x

	if resize_dir.y == 1:
		size.y += rel.y
	elif resize_dir.y == -1:
		size.y -= rel.y
		position.y += rel.y

	size.x = max(size.x, 300)
	size.y = max(size.y, 200)


@warning_ignore("shadowed_variable")
func open_window_with_content(content: String):
	var parts = content.split(" ")
	var scene_name = parts[0]

	var path = "res://Scenes/%s.tscn" % scene_name
	var scene = load(path)

	if scene == null:
		push_error("Could not load scene: " + path)
		return

	var instance = scene.instantiate()
	instance.content = content
	

	$VBoxContainer.add_child(instance)
