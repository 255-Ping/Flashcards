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

@onready var sequence_deck = preload("res://Scenes/sequence_deck.tscn")

func _ready() -> void:
	main = get_tree().current_scene
	$Panel/SequenceName.text = sequence
	reload_deck_list()
	
func _on_delete_button_pressed() -> void:
	sequence_manager.delete_sequence(sequence)
	main.reload_sequence_list()
	
func _on_select_button_pressed() -> void:
	main.selected_sequence = sequence
	main.create_popup(str("Sequence Selected: ", sequence), 1.5)
	
func _on_sequence_name_text_submitted(new_text: String) -> void:
	if new_text == "":
		push_error("Sequence name cannot be blank")
		main.create_popup("Sequence name cannot be blank", -1.0, "error")
		return
	sequence_manager.rename_sequence(sequence, new_text)
	main.reload_sequence_list()
	
func reload_deck_list():
	sequence_manager.sort_sequence_keys(sequence)
	decks = save.load_json(str(sequence, ".seq"))
	$Panel/SequenceName.text = sequence
	for child in $Panel/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	
	for d in decks:
		var instance = sequence_deck.instantiate()
		instance.parent_ui = self
		instance.deck = decks[d]
		instance.scale = Vector2(0.5,0.5)
		instance.custom_minimum_size = Vector2(70.0, 120.0)
		scroll_box_1.add_child(instance)
