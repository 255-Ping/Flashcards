# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends CanvasLayer
class_name PasswordManager

@onready var panel = $Control/Panel
@onready var message_label = $Control/Panel/Label
@onready var ok_button = $Control/Panel/Button
@onready var background = $Control/ColorRect
@onready var password_box = $Control/Panel/PasswordBox
@onready var wrong_password = $Control/WrongPassword

var main

var menu

var admin_password: String

signal password_correct(menu)

func _ready() -> void:
	main = get_tree().current_scene
	admin_password = main.admin_password
	
	$Control/Panel/PasswordBox.grab_focus()

func _on_button_pressed() -> void:
	if password_box.text == admin_password:
		emit_signal("password_correct", menu)
		clear_all_password_popups()
	else:
		password_box.text = ""
		if !wrong_password.visible:
			wrong_password.visible = true
			await get_tree().create_timer(1).timeout
			wrong_password.visible = false
		$Control/Panel/PasswordBox.grab_focus()
		
func _on_password_box_text_submitted(_new_text: String) -> void:
	if password_box.text == admin_password:
		emit_signal("password_correct", menu)
		clear_all_password_popups()
	else:
		password_box.text = ""
		if !wrong_password.visible:
			wrong_password.visible = true
			await get_tree().create_timer(1).timeout
			wrong_password.visible = false
		$Control/Panel/PasswordBox.grab_focus()

func _on_secret_button_pressed() -> void:
	password_box.secret = !password_box.secret

func _on_x_button_pressed() -> void:
	clear_all_password_popups()
	
func clear_all_password_popups():
	for child in get_parent().get_children():
		#print(child)
		if child.is_in_group("password"):
			child.queue_free()
