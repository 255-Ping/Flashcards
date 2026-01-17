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
	if FileAccess.file_exists(file_path):
		push_error("Sequence already exists, aborting creation")
		return
	var loaded = save.load_json(str(filename, ".seq"))
	if loaded["0"] == null:
		loaded["0"] = deckname
	else:
		loaded[str(loaded.size())] = deckname
	save.save_json(str(filename, ".seq"), loaded)
	
			
