# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Node
class_name SequenceManager

var save = SaveManager.new()

const SAVE_DIR := "user://FlashCards"

func create_blank_sequence(filename: String):
	var file_path = SAVE_DIR + "/" + filename + ".seq"
	if FileAccess.file_exists(file_path):
		push_error("Sequence already exists, aborting creation")
		return
	var loaded = save.load_json("sequence_names.seq")
	if loaded:
		loaded[filename] = filename
	else:
		loaded = {
			filename: filename
		}
	
	save.save_json("sequence_names.seq", loaded)
	var dict: Dictionary
	save.save_json(str(filename, ".seq"), dict)
	
func add_deck_to_sequence(filename: String, deckname: String):
	var file_path = SAVE_DIR + "/" + filename + ".seq"
	if !FileAccess.file_exists(file_path):
		push_error("Sequence does not exist, aborting addition")
		return
	var loaded = save.load_json(str(filename, ".seq"))
	if !loaded.has(deckname):
		loaded[str(loaded.size())] = deckname
	else:
		push_error("Error")
	save.save_json(str(filename, ".seq"), loaded)
	
func delete_sequence(filename: String):
	var loaded = save.load_json("sequence_names.seq")
	if !loaded.has(filename):
		push_error("No sequence by the name ", filename, ", aborting deletion")
		return
	var file_path = SAVE_DIR + "/" + filename + ".seq"
	if !FileAccess.file_exists(file_path):
		push_error("Sequence doesn't exist aborting deletion")
		return
	if save.delete_file(str(filename + ".seq")):
		print("Successfully Deleted Sequence")
		loaded.erase(filename)
		if loaded.size() > 0:
			save.save_json("sequence_names.seq", loaded)
		else:
			save.delete_file("sequence_names.seq")
	else:
		print("Failed to Delete Sequence")
		
func rename_sequence(sequence: String, new_name: String):
	var sequence_names = save.load_json("sequence_names.seq")
	if sequence_names.has(new_name):
		push_error("Sequence with name exists already")
		return
	#var loaded = save.load_json("deck_" + deck + ".deck")
	sequence_names.erase(sequence)
	sequence_names[new_name] = new_name
	save.save_json("sequence_names.seq", sequence_names)
	#delete_deck(deck)
	#save.save_json("deck_" + new_name + ".deck", loaded)
	save.rename_file(sequence + ".seq", new_name + ".seq")
	
func sort_sequence_keys(sequence: String):
	var loaded = save.load_json(str(sequence, ".seq"))

	var new_loaded = {}
	var keys = loaded.keys()
	
	keys.sort_custom(func(a, b):
		return int(a) < int(b)
	)
	
	var new_index = 0
	for k in keys:
		new_loaded[new_index] = loaded[k]
		new_index += 1
		
	save.save_json(str(sequence, ".seq"), new_loaded)
	
