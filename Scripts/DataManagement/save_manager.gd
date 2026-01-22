# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Node
class_name SaveManager

const SAVE_DIR := "user://FlashCards"

func get_files_with_extension(extension: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(SAVE_DIR)

	if dir == null:
		push_error("Could not open directory: " + SAVE_DIR)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			if file_name.get_extension() == extension:
				result.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return result


func _ensure_dir() -> bool:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var result = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if result != OK:
			push_error("Failed to create save directory at " + SAVE_DIR)
			return false
	return true

func save_json(filename: String, data: Dictionary):
	if _ensure_dir():
		var file_path = SAVE_DIR + "/" + filename
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			file.close()
			print("Saved JSON to:", file_path)
		else:
			push_error("Failed to save JSON to " + file_path)

func load_json(filename: String) -> Dictionary:
	var file_path = SAVE_DIR + "/" + filename
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return {}

func delete_file(filename: String) -> bool:
	var file_path = SAVE_DIR + "/" + filename
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("Deleted file:", file_path)
			return true
		else:
			push_error("Failed to delete file: " + file_path)
	return false

func rename_file(old_name: String, new_name: String) -> bool:
	if not _ensure_dir():
		return false

	var old_path = SAVE_DIR + "/" + old_name
	var new_path = SAVE_DIR + "/" + new_name

	if not FileAccess.file_exists(old_path):
		return false
	if FileAccess.file_exists(new_path):
		return false

	return DirAccess.rename_absolute(old_path, new_path) == OK
