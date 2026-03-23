extends Control

var dragging = false
var drag_offset = Vector2.ZERO

var window

func  _ready() -> void:
	window = get_parent().get_parent().get_parent()
	mouse_default_cursor_shape = Control.CURSOR_MOVE

func _gui_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				drag_offset = get_global_mouse_position() - window.position

	if event is InputEventMouseMotion and dragging:
		window.position = get_global_mouse_position() - drag_offset


func _on_texture_button_pressed() -> void:
	window.queue_free()
