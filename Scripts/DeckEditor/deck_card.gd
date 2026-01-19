# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name Card

var main
var deck_manager = DeckManager.new()
var deck_ui
var save = SaveManager.new()

var deck: String
var card: int
var parent_ui

var value_1: int
var value_2: int
var operator: String
var answer: int

func _ready() -> void:
	main = get_tree().current_scene
	deck_ui = parent_ui
	
	$Value1.text = str(value_1)
	$Value2.text = str(value_2)
	$Operator.text = str(operator)
	$Answer.text = str(answer)


func _on_delete_card_pressed() -> void:
	var loaded = save.load_json(deck + ".deck")
	if loaded.size() > 1:
		deck_manager.remove_card(deck, card)
		deck_ui.reload_card_list()
	else:
		main.create_popup("Please use the delete deck button")
	#main.reload_deck_list()
