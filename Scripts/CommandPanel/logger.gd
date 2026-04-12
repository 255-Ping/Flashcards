extends Node

var save = SaveManager.new()

var main_panel: Node = null
var panels: Array

var date_str: String

func _ready() -> void:
	var date = Time.get_datetime_dict_from_system()
	date_str = "%d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]

func log(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			panel_loop.log_to_command_panel(text)
			_write_to_log(text)
			print("Logger: ", text)
		
func log_error(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			#panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			_write_to_log(text)
			panel_loop.log_to_command_panel(str("[color=#f50100]Error: ",text,"[/color]"))
		
func log_warning(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			#panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			_write_to_log(text)
			panel_loop.log_to_command_panel(str("[color=yellow]Warning: ",text,"[/color]"))
		
func log_debug(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			#panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			_write_to_log(text)
			panel_loop.log_to_command_panel(str("[color=magenta]Debug: ",text,"[/color]"))
			
func _write_to_log(text: String):
	if !FileAccess.file_exists("user://FlashCards/logs/" + date_str + ".log"):
		save.create_file("user://FlashCards/logs/" + date_str + ".log", "")
	var loaded = save.load_text_file("user://FlashCards/logs/" + date_str + ".log")
	if loaded:
		loaded = loaded + "\n" + text
	else:
		loaded = text
	
	save.save_text_file("user://FlashCards/logs/" + date_str + ".log", loaded)
