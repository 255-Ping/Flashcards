# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name SequenceDeck

var sequence_manager = SequenceManager.new()
var deck: String
var parent_ui

var new_scale: float = 1
var select_button: bool = true

var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_tree().current_scene
	$DeckName.text = deck
	$SelectButton.visible = select_button
	#$Card.scale = $Card.scale * new_scale
	#custom_minimum_size = custom_minimum_size * new_scale


func _on_select_button_pressed() -> void:
	sequence_manager.add_deck_to_sequence(main.selected_sequence,deck)
	main.reload_sequence_list()
