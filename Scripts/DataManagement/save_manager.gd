# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Node
class_name SaveManager

const SAVE_DIR := "user://FlashCards"

func get_dirs_in_dir(directory: String) -> Array[String]:
	var result: Array[String] = []

	var dir := DirAccess.open(directory)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()

	while entry != "":
		if entry != "." and entry != "..":
			if dir.current_is_dir():
				var subdir_path = directory.path_join(entry)

				# Skip problematic Linux virtual filesystems
				if subdir_path.begins_with("/proc") \
				or subdir_path.begins_with("/sys") \
				or subdir_path.begins_with("/dev"):
					entry = dir.get_next()
					continue

				result.append(subdir_path)

				# Only recurse if the directory can actually be opened
				if DirAccess.open(subdir_path) != null:
					result += get_dirs_in_dir(subdir_path)

		entry = dir.get_next()

	dir.list_dir_end()
	return result

func get_files_in_dir(directory: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(str(directory))
	
	if dir == null:
		push_error("Could not open directory: ", dir)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !dir.current_is_dir():
			result.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return result
	
func get_files_in_dir_probe(directory: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(str("/", directory))
	
	if dir == null:
		push_error(str("Could not open directory: ", dir))
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !dir.current_is_dir():
			result.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return result

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

func create_dir(dir: String):
	if not DirAccess.dir_exists_absolute(SAVE_DIR + "/" + dir):
		var result = DirAccess.make_dir_recursive_absolute(SAVE_DIR + "/" + dir)
		if result != OK:
			push_error("Failed to create directory at " + SAVE_DIR + "/" + dir)

func _ensure_dir() -> bool:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var result = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if result != OK:
			push_error("Failed to create save directory at " + SAVE_DIR)
			return false
	return true

func save_json(filename: String, data: Dictionary):
	if _ensure_dir():
		var file_path = filename
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			file.close()
			print("Saved JSON to:", file_path)
		else:
			push_error("Failed to save JSON to " + file_path)

func load_json(filename: String) -> Dictionary:
	var file_path = filename
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return {}
	
func save_text_file(path: String, text: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		push_error("Could not open file for writing: " + path)
		return
	
	file.store_string(text)
	file.close()
	
func load_text_file(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("Could not open file: " + path)
		return ""
	
	var text = file.get_as_text()
	file.close()
	return text

func delete_file(filename: String) -> bool:
	var file_path = filename
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("Deleted file:", file_path)
			return true
		else:
			push_error("Failed to delete file: " + file_path)
	return false
	
func delete_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: " + path)
		return
	
	dir.list_dir_begin()
	var entry = dir.get_next()
	
	while entry != "":
		if entry != "." and entry != "..":
			var entry_path = path + "/" + entry
			if dir.current_is_dir():
				delete_dir_recursive(entry_path)  # Recurse into subdirectory
			else:
				var file_remove_result = dir.remove(entry_path)
				if file_remove_result != OK:
					push_error("Failed to remove file: " + entry_path)
		entry = dir.get_next()
	
	dir.list_dir_end()
	
	# Remove the now-empty directory itself
	var remove_result = dir.remove(path)
	if remove_result != OK:
		push_error("Failed to remove directory: " + path)

func rename_file(old_name: String, new_name: String) -> bool:
	if not _ensure_dir():
		return false

	var old_path = old_name
	var new_path = new_name

	if not FileAccess.file_exists(old_path):
		return false
	if FileAccess.file_exists(new_path):
		return false

	return DirAccess.rename_absolute(old_path, new_path) == OK

#############
#CREATE FILE#
#############
	
func create_file(path: String, content: String) -> void:
	var dir = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
	else:
		print("Error creating file: ", path)
