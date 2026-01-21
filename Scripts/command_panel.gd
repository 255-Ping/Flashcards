# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name CommandPanel

var main: Node

var selected_command_history: int = -1
var command_history: Array

@onready var line_edit = $LineEdit

var commands: Dictionary = {
	"help":"",
	"test_popup":"",
	"set_password":"String",
	"open_folder":"",
	"end_round":"",
	"ui_open":"String",
	"ui_close":"String",
	"ui_list":"",
	"student_list":"",
	"window_mode":"String",
	"website":"",
	"docs":"",
	"system_perfs":"",
	"set_fps_cap":"Int",
	"close":""
}

func _ready() -> void:
	main = get_parent()
	PanelLogger.panel = self
	
	#$ScrollContainer/VBoxContainer/RichTextLabel.text = " test"
	$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_enabled = true
	#$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_text = "test test test"
	#log_to_command_panel("test")
	
#func _process(_delta):
#	if Input.is_key_pressed(KEY_A):
#		print("A pressed")

func _on_line_edit_text_submitted(new_text: String) -> void:
	
	#var command_panel_text = $ScrollContainer/VBoxContainer/Label.text
	#command_panel_text = str(command_panel_text + "\n" + new_text)
	var split_command = new_text.split(" ")
	if commands.has(split_command[0]):
		
	#help COMMAND
		if split_command[0] == "help":
			for key in commands:
				#command_panel_text = str(key + " " + commands[key] + "\n" + command_panel_text)
				PanelLogger.log(key + " " + commands[key])
	
	#test_popup COMMAND	
		elif split_command[0] == "test_popup":
			main.create_popup("test popup")
			#command_panel_text = str("Command: test popup created" + "\n" + command_panel_text)
			PanelLogger.log("Command: test popup created")
			
			
	#set_password COMMAND
		elif split_command[0] == "set_password":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				#command_panel_text = str("set_password String" + "\n" + command_panel_text)
				PanelLogger.log("set_password String")
			else:
				PanelLogger.log("Command: Password set to " + split_args[1])
				#command_panel_text = str("Command: Password set to " + split_args[1] + "\n" + command_panel_text)
				main.admin_password = split_args[1]
				main.update_password_in_settings(split_args[1])
				
	#open_folder COMMAND
		elif split_command[0] == "open_folder":
			main.open_flashcards_folder()
			PanelLogger.log("Command: Opened userdata folder")
			#command_panel_text = str("Command: Opened userdata folder" + "\n" + command_panel_text)
			
	#website COMMAND
		elif split_command[0] == "website":
			var url = "https://github.com/255-Ping/Flashcards"
			OS.shell_open(url)
			PanelLogger.log("Command: Opened github website")
			#command_panel_text = str("Command: Opened github website" + "\n" + command_panel_text)
	
	#docs COMMAND
		elif split_command[0] == "docs":
			var url = "https://docs.google.com/document/d/1fbUxYh6ffeberwQp6U5fvy9oFO2EHrU73z2c17AO7bc/edit?usp=sharing"
			OS.shell_open(url)
			PanelLogger.log("Command: Opened documentation")
			#command_panel_text = str("Command: Opened documentation" + "\n" + command_panel_text)
	
	#window_mode		
		elif split_command[0] == "window_mode":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_open String(main/settings/stats/decks/sequences)")
				#command_panel_text = str("ui_open String(main/settings/stats/decks/sequences)" + "\n" + command_panel_text)
			elif split_args[1] == "windowed":
				PanelLogger.log("Command: Window Mode Set to " + split_args[1])
				#command_panel_text = str("Command: Window Mode Set to " + split_args[1] + "\n" + command_panel_text)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			elif split_args[1] == "fullscreen":
				#command_panel_text = str("Command: Window Mode Set to " + split_args[1] + "\n" + command_panel_text)
				PanelLogger.log("Command: Window Mode Set to " + split_args[1])
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				#command_panel_text = str("window_mode String" + "\n" + command_panel_text)
				PanelLogger.log("window_mode String")
				
			
	#ui_open COMMAND
		elif split_command[0] == "ui_open":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_open String(main/settings/stats/decks/sequences)")
				#command_panel_text = str("ui_open String(main/settings/stats/decks/sequences)" + "\n" + command_panel_text)
			else:
				#command_panel_text = str("UI Opened: " + split_args[1] + "\n" + command_panel_text)
				PanelLogger.log("UI Opened: " + split_args[1])
				main.ui_open(split_args[1])
				
	#ui_close COMMAND
		elif split_command[0] == "ui_close":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_close String(main/settings/stats/decks/sequences)")
				#command_panel_text = str("ui_close String(main/settings/stats/decks/sequences)" + "\n" + command_panel_text)
			else:
				PanelLogger.log("UI Closed: " + split_args[1])
				#command_panel_text = str("UI Closed: " + split_args[1] + "\n" + command_panel_text)
				main.ui_close(split_args[1])
				
	#ui_list COMMAND
		elif split_command[0] == "ui_list":
			#command_panel_text = str("main \nsettings \nstats \ndecks \nsequences" + "\n" + command_panel_text)
			PanelLogger.log("main \nsettings \nstats \ndecks \nsequences")
			
	#student_list COMMAND
		elif split_command[0] == "student_list":
			for s in main.student_list:
				#command_panel_text = str(s + "\n" + command_panel_text)
				PanelLogger.log(s)
				
	#end_round COMMAND
		elif split_command[0] == "end_round":
			main.round_manager.force_end_round("Command Panel Force End")
			#command_panel_text = str("" + "\n" + command_panel_text)
				
	#set_fps_cap COMMAND
		elif split_command[0] == "set_fps_cap":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				#command_panel_text = str("set_fps_cap Float" + "\n" + command_panel_text)
				PanelLogger.log("set_fps_cap Int")
			else:
				#command_panel_text = str("Set Fps Cap: " + split_args[1] + "\n" + command_panel_text)
				PanelLogger.log("Set Fps Cap: " + split_args[1])
				main.set_fps_cap(int(split_args[1]))
				
	#system_perf COMMAND
		elif split_command[0] == "system_perfs":
			main.perfs_panel.visible = !main.perfs_panel.visible 
			#command_panel_text = str("Command: System perfs toggled" + "\n" + command_panel_text)
			PanelLogger.log("Command: System perfs toggled")
			
	#close COMMAND
		elif split_command[0] == "close":
			main.close_program(true)
			#command_panel_text = str("Command: Goodbye :)" + "\n" + command_panel_text)
			PanelLogger.log("Command: Goodbye :)")
	
	#unset COMMANDS
		else:
			#command_panel_text = str(new_text + "\n" + command_panel_text)
			PanelLogger.log("Out of bounds command used... how was that possible?")
	else:
		#command_panel_text = str("Unknown Command. Use (help) to view commands" + "\n" + command_panel_text)
		PanelLogger.log("Unknown Command. Use (help) to view commands")
		
	command_history.append(new_text)
	command_history.insert(0, new_text)
	#$ScrollContainer/VBoxContainer/Label.text = command_panel_text
	$LineEdit.text = ""
	#await get_tree().create_timer(0.1).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$LineEdit.editable = true
	$LineEdit.focus_mode = Control.FOCUS_ALL
	$LineEdit.release_focus()
	#await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	$LineEdit.grab_focus()
	print(get_viewport().gui_get_focus_owner())
	
	
func log_to_command_panel(text: String):
	$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_enabled = true
	var command_panel_text = $ScrollContainer/VBoxContainer/RichTextLabel.text
	command_panel_text = str(text + "\n" + command_panel_text)
	$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_text = command_panel_text
	
func _focus_line_edit():
	$LineEdit.grab_focus()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		#print(selected_command_history)
		if !command_history:
			return
		if event.keycode == 4194320:
			selected_command_history += 1
			if selected_command_history > command_history.size() - 1:
				return
			$LineEdit.text = command_history[selected_command_history - command_history.size()]
		if event.keycode == 4194322:
			selected_command_history -= 1
			if selected_command_history < 0:
				selected_command_history = -1
				$LineEdit.text = ""
				return
			$LineEdit.text = command_history[selected_command_history - command_history.size()]
			
#		print(
#			"KEY:",
#			event.keycode,
#			" unicode:",
#			event.unicode,
#			" pressed:",
#			event.pressed
#		)
