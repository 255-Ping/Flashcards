extends Node

var panel: Node = null

func log(text: String):
	if get_tree():
		await get_tree().process_frame
	if panel:
		panel.log_to_command_panel(text)
	else:
		print("Logger:", text)
		
func log_error(text: String):
	if get_tree():
		await get_tree().process_frame
	if panel:
		panel.log_to_command_panel(str("[color=#f50100]Error: ",text,"[/color]"))
	else:
		print("Logger:", text)
		
func log_warning(text: String):
	if get_tree():
		await get_tree().process_frame
	if panel:
		panel.log_to_command_panel(str("[color=yellow]Warning: ",text,"[/color]"))
	else:
		print("Logger:", text)
		
func log_debug(text: String):
	if get_tree():
		await get_tree().process_frame
	if panel:
		panel.log_to_command_panel(str("[color=magenta]Debug: ",text,"[/color]"))
	else:
		print("Logger:", text)
