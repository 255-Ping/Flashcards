# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Node
class_name DeckManager

var save = SaveManager.new()

const SAVE_DIR := "user://FlashCards"

func create_deck(deck: Dictionary, filename: String):
	var file_path = SAVE_DIR + "/" + filename + ".deck"
	if FileAccess.file_exists(file_path):
		push_error("Deck already exists, aborting creation")
		return
	var loaded = save.load_json("deck_names.deck")
	if loaded:
		loaded[filename] = filename
	else:
		loaded = {
			filename: filename
		}
	
	for i in deck:
		var parts
		if "+" in deck[i]:
			parts = deck[i].split("+")
		if "-" in deck[i]:
			parts = deck[i].split("-")
		if "x" in deck[i]:
			parts = deck[i].split("x")
		if !parts[0].is_valid_float():
			push_error("Non-Number detected")
			#main.create_popup("Non-Number detected", -1.0, "error")
			return
		if !parts[1].is_valid_float():
			push_error("Non-Number detected")
			#main.create_popup("Non-Number detected", -1.0, "error")
			return
		
	save.save_json("deck_names.deck", loaded)
	save.save_json(str(filename, ".deck"), deck)
	print("Deck ", filename, " created")
	
	
func edit_card(deck: String, index: int, new_problem: String):
	var loaded = save.load_json(str(deck, ".deck"))
	if !loaded:
		push_error("Deck does not exist, aborting edit")
		return
	if loaded.has(index):
		push_error("Index not found, aborting edit")
		return
	loaded[index] = new_problem
	save.save_json(str(deck, ".deck"), loaded)
	print("Card ", index, " changed to ", new_problem)
	
func add_card(deck: String, new_problem: String) -> void:
	var loaded = save.load_json(deck + ".deck")
	if !loaded:
		push_error("Deck does not exist, aborting add")
		return
	
	var new_index = loaded.size()
	loaded[new_index] = new_problem
	
	save.save_json(deck + ".deck", loaded)
	print("Added new card at index ", new_index, ": ", new_problem)
	
func remove_card(deck: String, index: int):
	var loaded = save.load_json(str(deck, ".deck"))
	if !loaded:
		push_error("Deck does not exist, aborting edit")
		return
	if loaded.size() < index:
		push_error("Index to big for Deck, aborting card removal")
		return
	loaded.erase(str(index))
	
	var new_loaded = {}
	var keys = loaded.keys()
	keys.sort()
	
	var new_index = 0
	for k in keys:
		new_loaded[new_index] = loaded[k]
		new_index += 1
	
	if new_loaded.size() > 0:
		save.save_json(str(deck, ".deck"), new_loaded)
	else:
		delete_deck(str(deck))
		
func sort_deck_keys(deck: String):
	var loaded = save.load_json(str(deck, ".deck"))

	var new_loaded = {}
	var keys = loaded.keys()
	
	keys.sort_custom(func(a, b):
		return int(a) < int(b)
	)
	
	var new_index = 0
	for k in keys:
		new_loaded[new_index] = loaded[k]
		new_index += 1
		
	save.save_json(str(deck, ".deck"), new_loaded)
	
func delete_deck(filename: String):
	var loaded = save.load_json("deck_names.deck")
	if !loaded:
		push_error("No decks loaded, aborting deletion")
		return
	if !loaded.has(filename):
		push_error("No deck by the name ", filename, ", aborting deletion")
		return
	if save.delete_file(filename + ".deck"):
		print("Successfully Deleted Deck")
		loaded.erase(filename)
		if loaded.size() > 0:
			save.save_json("deck_names.deck", loaded)
		else:
			save.delete_file("deck_names.deck")
	else:
		print("Failed to Delete Deck")
		
func rename_deck(deck: String, new_name: String):
	var deck_names = save.load_json("deck_names.deck")
	#var loaded = save.load_json("deck_" + deck + ".deck")
	if deck_names.has(new_name):
		push_error("Deck with name exists already")
		return
	deck_names.erase(deck)
	deck_names[new_name] = new_name
	save.save_json("deck_names.deck", deck_names)
	#delete_deck(deck)
	#save.save_json("deck_" + new_name + ".deck", loaded)
	save.rename_file(deck + ".deck", new_name + ".deck")
		
func find_card_answer(value_1: int, value_2: int, operator: String) -> int:
	if operator == "+":
		return value_1 + value_2
	if operator == "-":
		return value_1 - value_2
	if operator == "x":
		return value_1 * value_2
	return 0
	
func split_card(card: String) -> Array:
	var parts
	var array: Array
	if "+" in card:
		parts = card.split("+")
		array.append("+")
	if "-" in card:
		parts = card.split("-")
		array.append("-")
	if "x" in card:
		parts = card.split("x")
		array.append("x")
	array.append(int(parts[0]))
	array.append(int(parts[1]))
	return array
	
