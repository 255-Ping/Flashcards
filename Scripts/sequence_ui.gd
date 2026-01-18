# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name SequenceUi

var text: String
var sequence: String
var decks: Dictionary

var sequence_manager = SequenceManager.new()
var save = SaveManager.new()
var main

@onready var scroll_box_1 = $Panel/ScrollContainer/HBoxContainer

@onready var card = preload("res://Scenes/card.tscn")

func _ready() -> void:
	main = get_tree().current_scene
	$Panel/SecquenceName.text = sequence
	
func _on_delete_button_pressed() -> void:
	sequence_manager.delete_sequence(sequence)
	main.reload_sequence_list()
	
func _on_select_button_pressed() -> void:
	main.selected_sequence = sequence
	main.create_popup(str("Sequence Selected: ", sequence), 1.5)
	
func _on_secquence_name_text_submitted(new_text: String) -> void:
	if new_text == "":
		push_error("Sequence name cannot be blank")
		main.create_popup("Sequence name cannot be blank", -1.0, "error")
		return
	sequence_manager.rename_sequence(sequence, new_text)
	main.reload_sequence_list()
