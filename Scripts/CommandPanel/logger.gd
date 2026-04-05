extends Node

var save = SaveManager.new()

var main_panel: Node = null
var panels: Array

func log(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
		
func log_error(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			panel_loop.log_to_command_panel(str("[color=#f50100]Error: ",text,"[/color]"))
		
func log_warning(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			panel_loop.log_to_command_panel(str("[color=yellow]Warning: ",text,"[/color]"))
		
func log_debug(text: String, panel_node: Node = main_panel):
	if get_tree():
		await get_tree().process_frame
	if panels.size() > 0:
		for panel_loop in panels:
			if panel_loop != panel_node:
				continue
			panel_loop.log_to_command_panel(text)
			print("Logger: ", text)
			panel_loop.log_to_command_panel(str("[color=magenta]Debug: ",text,"[/color]"))
			
#func _write_to_log(text: String):
	
