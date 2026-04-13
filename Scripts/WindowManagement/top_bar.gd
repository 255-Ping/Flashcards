# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control

var dragging = false
var drag_offset = Vector2.ZERO

@export var window: Node

func  _ready() -> void:
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
