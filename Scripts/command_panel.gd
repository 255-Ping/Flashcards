# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Control
class_name CommandPanel

var main: Node

var selected_command_history: int = -1
var command_history: Array

var save = SaveManager.new()

@onready var line_edit = $LineEdit

@onready var scripting_service = preload("res://Scenes/scripting_service.tscn")

var commands: Dictionary = {
	"help":"",
	"close":"",
	"website":"",
	"docs":"",
	"test_popup":"",
	"open_folder":"",
	"end_round":"",
	
	"script":"String String",
	
	"ui_open":"String",
	"ui_close":"String",
	"ui_list":"",
	
	"set_password":"String",
	"set_fps_cap":"Int",
	
	"student_list":"",
	"deck_list":"",
	"window_mode":"String",
	
	"system_perfs":""
}

func _ready() -> void:
	main = get_parent()
	PanelLogger.panel = self
	$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_enabled = true
	
func _open_scripting_window(sc: String):
	var instance = scripting_service.instantiate()
	instance.global_position = Vector2(100,-200)
	instance.sc = sc
	add_child(instance)
	
func _run_script(sc: String):
	ScriptManager.run_script(sc)

func _on_line_edit_text_submitted(new_text: String) -> void:

	var split_command = new_text.split(" ")
	if commands.has(split_command[0]):
		
	#script COMMAND
		if split_command[0] == "script":
			var split_args = new_text.split(" ")
			if split_args.size() < 3:
				PanelLogger.log("script String String")
			elif split_args[1] == "open":
				_open_scripting_window(split_args[2])
			elif split_args[1] == "run":
				_run_script(split_args[2])
				
		
	#help COMMAND
		elif split_command[0] == "help":
			for key in commands:
				PanelLogger.log(key + " " + commands[key])
	
	#test_popup COMMAND	
		elif split_command[0] == "test_popup":
			main.create_popup("test popup")
			PanelLogger.log("Command: test popup created")
			
			
	#set_password COMMAND
		elif split_command[0] == "set_password":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("set_password String")
			else:
				PanelLogger.log("Command: Password set to " + split_args[1])
				main.admin_password = split_args[1]
				main.update_password_in_settings(split_args[1])
				
	#open_folder COMMAND
		elif split_command[0] == "open_folder":
			main.open_flashcards_folder()
			PanelLogger.log("Command: Opened userdata folder")
			
	#website COMMAND
		elif split_command[0] == "website":
			var url = "https://github.com/255-Ping/Flashcards"
			OS.shell_open(url)
			PanelLogger.log("Command: Opened github website")
			
	#docs COMMAND
		elif split_command[0] == "docs":
			var url = "https://docs.google.com/document/d/1fbUxYh6ffeberwQp6U5fvy9oFO2EHrU73z2c17AO7bc/edit?usp=sharing"
			OS.shell_open(url)
			PanelLogger.log("Command: Opened documentation")
			
	#window_mode		
		elif split_command[0] == "window_mode":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_open String(main/settings/stats/decks/sequences)")
			elif split_args[1] == "windowed":
				PanelLogger.log("Command: Window Mode Set to " + split_args[1])
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			elif split_args[1] == "fullscreen":
				PanelLogger.log("Command: Window Mode Set to " + split_args[1])
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				PanelLogger.log("window_mode String")
				
			
	#ui_open COMMAND
		elif split_command[0] == "ui_open":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_open String(main/settings/stats/decks/sequences)")
			else:
				PanelLogger.log("UI Opened: " + split_args[1])
				main.ui_open(split_args[1])
				
	#ui_close COMMAND
		elif split_command[0] == "ui_close":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("ui_close String(main/settings/stats/decks/sequences)")
			else:
				PanelLogger.log("UI Closed: " + split_args[1])
				main.ui_close(split_args[1])
				
	#ui_list COMMAND
		elif split_command[0] == "ui_list":
			PanelLogger.log("main \nsettings \nstats \ndecks \nsequences")
			
	#student_list COMMAND
		elif split_command[0] == "student_list":
			for s in main.student_list:
				PanelLogger.log(s)
				
	#deck_list COMMAND
		elif split_command[0] == "deck_list":
			var loaded = save.load_json("deck_names.deck")
			for d in loaded:
				PanelLogger.log(loaded[d])
				
	#end_round COMMAND
		elif split_command[0] == "end_round":
			main.round_manager.force_end_round("Command Panel Force End")
				
	#set_fps_cap COMMAND
		elif split_command[0] == "set_fps_cap":
			var split_args = new_text.split(" ")
			if split_args.size() < 2:
				PanelLogger.log("set_fps_cap Int")
			else:
				PanelLogger.log("Set Fps Cap: " + split_args[1])
				main.set_fps_cap(int(split_args[1]))
				
	#system_perf COMMAND
		elif split_command[0] == "system_perfs":
			main.perfs_panel.visible = !main.perfs_panel.visible 
			PanelLogger.log("Command: System perfs toggled")
			
	#close COMMAND
		elif split_command[0] == "close":
			main.close_program(true)
			PanelLogger.log("Command: Goodbye :)")
	
	#unset COMMANDS
		else:
			PanelLogger.log("Out of bounds command used... how was that possible?")
	else:
		PanelLogger.log("Unknown Command. Use (help) to view commands")
		
	command_history.append(new_text)
	#command_history.insert(0, new_text)
	$LineEdit.text = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$LineEdit.editable = true
	$LineEdit.focus_mode = Control.FOCUS_ALL
	$LineEdit.release_focus()
	await get_tree().create_timer(0.05).timeout
	$LineEdit.grab_focus()
	#print(get_viewport().gui_get_focus_owner())
	
	
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
