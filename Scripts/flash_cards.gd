# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

class_name Main
extends Control

#Class Variables
var rng = RandomNumberGenerator.new()
var round_manager: RoundManager
var save = SaveManager.new()
var deck = DeckManager.new()
var excel = ExcelAPI.new()
var sequence = SequenceManager.new()

#Var "Persistent" Data
var student_list: Array

#Password Variables
var admin_password: String

#Debug Options
var debug_mode: bool
var send_data: bool

#Deck Editing Variables
var editing_deck: String
var editing_cards: String
var selected_deck: String
var card_generation: String
var card_number: int

#Sequence Editing Variables
var selected_sequence: String

#Graph Variables
var graph_lookup: String
var graph_filter: Array

#Equation Variables
var value_1: float
var value_2: float
var min_value_1: int
var max_value_1: int
var min_value_2: int
var max_value_2: int
var operator: String
var answer: float

#Current Round Variables
var time_passed: float
var completed_problems: int
var failures: int = 0
var playing: bool
var admin_present: bool
var qpm: float

#Settings
var max_questions: int
var student_name: String
var allow_negative_answers: bool
var allow_divided_by_1: bool
var required_number: String
var style: String

var student_to_add: String

#DeckManager Node Variables
@onready var deck_entry = preload("res://Scenes/deck.tscn")
@onready var sequence_entry = preload("res://Scenes/sequence.tscn")

#PopUp Node Variables
@onready var popup = preload("res://Scenes/popup_manager.tscn")
@onready var password = preload("res://Scenes/password_manager.tscn")

#Deck Node Variables
@onready var deck_list = $DeckEditor/ScrollContainer/VBoxContainer

#Graph Node Variables
@onready var graph: LineGraph = $Statistics/LineGraph

#Equation Node Variables
@onready var equation_label = $Flat/Label
@onready var answer_box = $AnswerBox
@onready var flat = $Flat
@onready var column = $Column
@onready var check_mark = $CheckMark
@onready var x_mark = $XMark
@onready var counter = $Counter
@onready var qps = $QPS

#Summary Node Variables
@onready var qpm_summary = $RestartRound/QuestionsPerMinuteLabel
@onready var failures_summary = $RestartRound/TimesIncorrectLabel
@onready var time_taken_summary = $RestartRound/TimeTakenLabel

#Column Node Variables
@onready var column_value_1 = $Column/Value1
@onready var column_value_2 = $Column/Value2
@onready var column_operator = $Column/Operator

@onready var operator_button = $Settings/Operator

#Menu Node Variables
@onready var restart_round_menu = $RestartRound
@onready var settings_menu = $Settings
@onready var statistics_menu = $Statistics
@onready var decks_menu = $DeckEditor
@onready var sequence_menu = $SequenceEditor

#AUDIO CONTROLLER
@onready var audio = $AudioStreamPlayer2D

#------------------------------
#READY FUNCTION
#------------------------------

func _ready() -> void:
	print("Flash cards starting...")
	
#Print USERDATA locations
	print("USER DATA DIR:", OS.get_user_data_dir())
	print("SAVE DIR:", ProjectSettings.globalize_path("user://FlashCards"))
	
#Connecting Quit
	#get_tree().tree_exiting.connect(_on_quit)
	get_tree().root.tree_exiting.connect(_on_quit)
	
#Add RoundManager to scene
	round_manager = RoundManager.new(self)
	add_child(round_manager)
	print("RoundManager Initialized")

#Load password
	var loaded = save.load_json("password.json")
	#Set new password if no password
	if !loaded:
		#Create file structure
		loaded = {
			"password":"password"
		}
		save.save_json("password.json", loaded)
	#set variable to password from file
	admin_password = loaded["password"]
	#Update textbox with password(obsfucated)
	$Settings/Password.text = admin_password
	
#Load student list
	loaded = save.load_json("student_list.json")
	for i in loaded.size():
		student_list.append(loaded[str(i + 1)])
	
#Update student list visuals
	update_student_list_visuals(student_list)
	
#Settings Defaults
	operator = "+"
	allow_negative_answers = false
	allow_divided_by_1 = false
	debug_mode = true
	send_data = false
	playing = false
	admin_present = true
	min_value_1 = 0
	max_value_1 = 12
	min_value_2 = 0
	max_value_2 = 12
	style = "column" #flat, column
	max_questions = 10
	card_generation = "deck"
	card_number = 0
	print("Defaults Loaded")

#Update the mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Mouse Settings Updated")
	
#Reloads decks in deck ui
	reload_deck_list()
	print("Deck list reloaded")
	
#Reloads sequences in sequence ui
	reload_sequence_list()
	print("Sequence list reloaded")

#Start Popup
	create_popup("Welcome, press Start to play, Settings to customize, Statistics to view data, and Decks to view, create, or change a deck.", 10)
	
#------------------------------
#PROCESS FUNCTION
#------------------------------

func _process(delta: float) -> void:

#Key Input Detection
	#Submit Answer
	if Input.is_action_just_pressed("submit_answer") and playing:
		_submit_answer()
	#Debug create new flash card
	if Input.is_action_just_pressed("new_flash_card") and debug_mode:
		_reset_flash_card()
		print("[DEBUG] New Flash Card Generated")
	#Debug test popup
	if Input.is_action_just_pressed("test_popup") and debug_mode:
		create_popup("test popup")
		print("[DEBUG] Popup Tested")
	#Exit application
	if Input.is_action_just_pressed("exit"):
		close_program(true)
	#Debug forcible end round
	if Input.is_action_just_pressed("end_round") and debug_mode:
		round_manager.force_end_round("Debug Force End")
		print("[DEBUG] Round Force Ended")
	#Enable mouse after round has completed
	if Input.is_action_just_pressed("complete_round"):
		if !admin_present:
			admin_present = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#Process tracking and function
	if playing:
		time_passed += delta
		qpm = float(round(completed_problems/(time_passed / 60)))
	qps.text = str(qpm)
	if time_passed and playing:
		time_taken_summary.text = str("Time Taken: ", int(round(time_passed)), "s")
		qpm_summary.text = str("Questions Per Minute: ",int(round(completed_problems/(time_passed / 60))))
	failures_summary.text = str("Times Incorrect: ", failures)
	if admin_present == false:
		warp_mouse(Vector2(700, 100))

#------------------------------
#CLOSE PROGRAM FUNCTION
#------------------------------

func close_program(safe: bool):
	create_popup("Goodbye :)")

#Save password
	var password_dict = {
		"password":admin_password
	}
	save.save_json("password.json", password_dict)
	
#Save student list
	var students_dict: Dictionary
	var student_counter: int = 1
	for s in student_list:
		students_dict[student_counter] = s
		student_counter += 1
	save.save_json("student_list.json", students_dict)
	print("Goodbye :)")
	if safe:
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
		return
	else:
		#get_tree().quit()
		return
	
func _exit_tree() -> void:
	print("alt quit")
	close_program(false)
	
func _on_quit() -> void:
	print("alt quit")
	close_program(false)

#------------------------------
#SELECT/GENERATE NEW FLASHCARD IN GAME
#------------------------------

func _reset_flash_card():
	print("Selecting New Flash Card")
#CODE FOR DIVISION
#Does not currently work, will probably never work.
	if card_generation == "random":
		if operator == "/":
			push_warning("Division Operator Selected, Deselect or the Program may Crash")
			value_1 = rng.randi_range(0,12)
			value_2 = rng.randi_range(0,12)
			if !allow_divided_by_1 and value_2 == 1:
				_reset_flash_card()
				return
			if value_2 > value_1:
				_reset_flash_card()
				return
			var string_answer = str(value_1 / value_2)
			#if !str(answer).is_valid_int():
			#	_reset_flash_card()
			#	return
			string_answer = string_answer.replace(".0", "")
			#print(string_answer)
			if !string_answer.is_valid_int():
				_reset_flash_card()
				return
		

	#ANYTHING THAT IS NOT DIVISION
		else:
			value_1 = rng.randi_range(min_value_1,max_value_1)
			print("Value 1 of Flashcard Filled")
			value_2 = rng.randi_range(min_value_2,max_value_2)
			print("Value 2 of Flashcard Filled")
			if required_number:
				value_1 = float(required_number)
				print("Required Number, Value 1 Changed")
		
	#Negative Check
		if !allow_negative_answers and value_1 < value_2 and operator == "-":
			print("First negative check flagged, retrying")
			_reset_flash_card()
			return

	#Column specific negative check 
		if style == "column" and value_1 < value_2:
			print("Column negative check flagged, retrying")
			_reset_flash_card()
			return
			
			
#Deck card generation
	else:
		if !selected_deck:
			round_manager.force_end_round("No deck selected")
			return
		var loaded = save.load_json(selected_deck + ".deck")
		var parts
		#for i in loaded:
		parts = deck.split_card(loaded[str(card_number)])
		operator = parts[0]
		value_1 = int(parts[1])
		value_2 = int(parts[2])
		
#Operator Check and Answer Calculation
	if operator == "+":
		answer = value_1 + value_2
	if operator == "-":
		answer = value_1 - value_2
	if operator == "x":
		answer = value_1 * value_2
	if operator == "/":
		answer = value_1 / value_2
	print("Flashcard Answer Calulated")
		
#Update Flashcard Visuals
	print(str("Answer: ", answer))
	equation_label.text = str(int(value_1), " ", operator, " ", int(value_2), " = ")
	column_value_1.text = str(int(value_1))
	column_value_2.text = str(int(value_2))
	column_operator.text = str(operator)
	print("Visuals Updated to Match Data")
	
#------------------------------
#SUBMIT ANSWER
#------------------------------

func _submit_answer():
	print("Answer Submitted")
#Create variable for answer
	var submitted_answer = float(answer_box.text)
	
#Correct Answer
	if submitted_answer == answer:
		print("Correct Answer")
		answer_box.text = ""
		completed_problems += 1
		if card_generation == "random":
			counter.text = str(completed_problems, "/", max_questions)
			if completed_problems >= max_questions:
				round_manager.end_round()
				return
		elif card_generation == "deck":
			card_number += 1
			var loaded = save.load_json(selected_deck + ".deck")
			counter.text = str(completed_problems, "/", loaded.size())
			if card_number >= loaded.size():
				round_manager.end_round()
				audio.play()
				card_number = 0
				return
		_reset_flash_card()
		if !check_mark.visible:
			check_mark.visible = true
			await get_tree().create_timer(1).timeout
			check_mark.visible = false

#Incorrect Answer
	elif submitted_answer:
		print("Incorrect Answer")
		answer_box.text = ""
		failures += 1
		if !x_mark.visible:
			x_mark.visible = true
			await get_tree().create_timer(1).timeout
			x_mark.visible = false
			
#Nothing entered in answer box
	else:
		answer_box.text = ""

#Answer box text checker(Answer box submit check is handled with an Input detection)
func _on_answer_box_text_changed() -> void:
	if !answer_box.text.is_valid_float() and not "\n" in answer_box.text and not "-" in answer_box.text:
		answer_box.text = ""
	if answer_box.text.length() > 3 and not "\n" in answer_box.text:
		answer_box.text = ""
	if !playing:
		answer_box.text = ""

#------------------------------
#MAIN MENU BUTTONS
#------------------------------

#Start Round Button
func _on_start_button_pressed() -> void:
	round_manager.start_round()

#Round Summary Settings Button
func _on_settings_button_pressed() -> void:
	create_password("settings")
	
func open_settings_menu():
	restart_round_menu.visible = false
	settings_menu.visible = true

#Statistics Button
func _on_statistics_button_pressed() -> void:
	create_password("statistics")
	
func open_statistics_menu():
	restart_round_menu.visible = false
	statistics_menu.visible = true
	graph.queue_redraw()

#Decks button
func _on_decks_button_pressed() -> void:
	create_password("decks")
	
func open_decks_menu():
	restart_round_menu.visible = false
	decks_menu.visible = true

#Sequence button
func _on_sequence_button_pressed() -> void:
	create_password("sequence")
	
func open_sequence_menu():
	restart_round_menu.visible = false
	sequence_menu.visible = true

func _on_open_folder_button_pressed() -> void:
	create_password("open_folder")


#------------------------------
#SETTINGS BUTTONS
#------------------------------

#Settings Go Back Button
func _on_go_back_button_pressed() -> void:
	restart_round_menu.visible = true
	settings_menu.visible = false
	statistics_menu.visible = false
	decks_menu.visible = false
	sequence_menu.visible = false

#Operator Selector Button
func _on_operator_item_selected(index: int) -> void:
	if index == 0:
		operator = "+"
	if index == 1:
		operator = "-"
	if index == 2:
		operator = "x"
		
func _on_card_generation_item_selected(index: int) -> void:
	if index == 0:
		card_generation = "random"
	if index == 1:
		card_generation = "deck"

#Required Number text checker and submitter
func _on_required_number_text_changed(_new_text: String) -> void:
	if !$Settings/RequiredNumber.text.is_valid_float() and "\n" not in $Settings/RequiredNumber.text and float($Settings/RequiredNumber.text) <= max_value_1 and float($Settings/RequiredNumber.text) <= max_value_2:
		$Settings/RequiredNumber.text = ""
		return
	required_number = $Settings/RequiredNumber.text

#Max Questions text checker and submitter
func _on_max_questions_text_changed(_new_text: String) -> void:
	if !$Settings/MaxQuestions.text.is_valid_float() and "\n" not in $Settings/MaxQuestions.text:
		$Settings/MaxQuestions.text = ""
		return
	max_questions = int($Settings/MaxQuestions.text)

func _on_student_item_selected(index: int) -> void:
	var loaded = save.load_json(student_name + ".json")
	print(loaded)
	var new_rounds_completed: int
	if loaded:
		if !loaded.has("Rounds Completed"):
			new_rounds_completed = 0
		else:
			new_rounds_completed = loaded["Rounds Completed"]
	else:
		new_rounds_completed = 0
	save_student_data(loaded,new_rounds_completed)
	student_name = student_list[index]
	update_settings_from_data(student_name)

func _on_remove_student_button_pressed() -> void:
	student_list.erase(student_name)
	student_name = ""
	update_student_list_visuals(student_list)
	
func _on_student_name_to_add_text_changed(new_text: String) -> void:
	student_to_add = new_text
	
func _on_student_name_to_add_text_submitted(new_text: String) -> void:
	student_list.append(new_text)
	update_student_list_visuals(student_list)
	$Settings/StudentNameToAdd.text = ""
	
func _on_add_student_button_pressed() -> void:
	student_list.append($Settings/StudentNameToAdd.text)
	update_student_list_visuals(student_list)
	$Settings/StudentNameToAdd.text = ""
	
func _on_decks_menu_from_settings_button_pressed() -> void:
	$Settings.visible = false
	$DeckEditor.visible = true

#------------------------------
#UPDATE SETTINGS/STUDENT_LIST VISUALS
#------------------------------

func update_student_list_visuals(new_student_list):
	$Settings/Student.clear()
	$Statistics/StudentStatistics.clear()
	for s in new_student_list:
		$Statistics/StudentStatistics.add_item(s)
		$Settings/Student.add_item(s)
	$Statistics/StudentStatistics.select(-1)
	$Settings/Student.select(-1)
	
func update_settings_from_data(new_student_name: String):
	var loaded = save.load_json(new_student_name + ".json")
	print(loaded)
	if loaded:
		if int(loaded["Max Questions"]):
			$Settings/MaxQuestions.text = str(int(loaded["Max Questions"]))
			max_questions = int(loaded["Max Questions"])
		if str(loaded["Required Number"]):
			$Settings/RequiredNumber.text = str(loaded["Required Number"])
			required_number = str(loaded["Required Number"])
		if str(loaded["Operator"]) == "+":
			$Settings/Operator.select(0)
			operator = "+"
		elif str(loaded["Operator"]) == "-":
			$Settings/Operator.select(1)
			operator = "-"
		elif str(loaded["Operator"]) == "x":
			$Settings/Operator.select(2)
			operator = "x"
		else:
			$Settings/Operator.select(0)
			operator = "+"
	else:
		$Settings/MaxQuestions.text = ""
		$Settings/RequiredNumber.text = ""
		$Settings/Operator.select(0)

#------------------------------
#LINE GRAPH BUTTONS
#------------------------------
#func _on_student_statistics_text_changed(new_text: String) -> void:
#	graph_lookup = new_text
#	_update_graph()
	
func _on_student_statistics_item_selected(index: int) -> void:
	graph_lookup = student_list[index]
	_update_graph()
	
func _on_qpm_filter_toggled(toggled_on: bool) -> void:
	if toggled_on:
		graph_filter.append("QPM")
	else:
		graph_filter.erase("QPM")
	_update_graph()
	
func _on_failures_filter_toggled(toggled_on: bool) -> void:
	if toggled_on:
		graph_filter.append("Failures")
	else:
		graph_filter.erase("Failures")
	_update_graph()
		
	
func _on_show_point_labels_toggled(toggled_on: bool) -> void:
	graph.set_show_point_labels(toggled_on)


func _on_show_axes_labels_toggled(toggled_on: bool) -> void:
	graph.set_show_axes_labels(toggled_on)


func _on_show_grid_toggled(toggled_on: bool) -> void:
	graph.set_show_grid(toggled_on)
	
func _on_show_legend_toggled(toggled_on: bool) -> void:
	graph.set_show_legend(toggled_on)

#------------------------------
#UPDATE LINE GRAPH WITH DATA FUNCTION
#------------------------------
#Function to update the line graph for Statistics
func _update_graph():
	var loaded = save.load_json(graph_lookup + ".json")
	
	graph.clear_datasets()

	if loaded:
		# Failures dataset
		if graph_filter.has("Failures"):
			var data: Array = []
			for i in loaded["Rounds Completed"]:
				# Example: assuming deck info is stored somewhere in loaded
				var deck_name = loaded.get(str(int(i), "deck"), "") 
				data.append({
					"pos": Vector2(i, loaded[str(int(i), "failures")]),
					"deck": deck_name
				})
			graph.add_dataset(data, Color(0.9, 0.2, 0.1), "Failures")
			graph.set_range(0, loaded["Rounds Completed"], 0, 15)
			graph.set_divisions(loaded["Rounds Completed"], 3)
		
		# QPM dataset
		if graph_filter.has("QPM"):
			var data: Array = []
			for i in loaded["Rounds Completed"]:
				var deck_name = loaded.get(str(int(i), "deck"), "")
				data.append({
					"pos": Vector2(i, loaded[str(int(i), "qpm")]),
					"deck": deck_name
				})
			graph.add_dataset(data, Color(0.3, 0.8, 0.1), "QPM")
			graph.set_range(0, loaded["Rounds Completed"], 0, 50)
			graph.set_divisions(loaded["Rounds Completed"], 10)
	else:
		graph.clear_datasets()
		graph.set_range(0,10,0,50)
		graph.set_divisions(10,10)


#------------------------------
#DECK EDITOR BUTTONS
#------------------------------

func _submit_deck():
	if " " in editing_deck:
		push_error("No spaces in deck names")
		create_popup("No spaces in deck names", -1.0, "error")
		return
	if " " in editing_cards:
		push_error("No spaces in card list")
		create_popup("No spaces in card list", -1.0, "error")
		return
	var cards = editing_cards.split(",")
	print(cards)
	var dict := {}
	var card_counter = 0
	for c in cards:
		dict[card_counter] = c
		card_counter += 1
	deck.create_deck(dict, editing_deck)
	reload_deck_list()
	
func _on_cards_text_changed(new_text: String) -> void:
	editing_cards = new_text
	
func _on_cards_text_submitted(_new_text: String) -> void:
	_submit_deck()

func _on_editing_deck_text_changed(new_text: String) -> void:
	editing_deck = new_text
	
func _on_editing_deck_text_submitted(_new_text: String) -> void:
	_submit_deck()

#------------------------------
#RELOAD DECK VISUALS FUNCTION
#------------------------------

func reload_deck_list():
#Deletes children in deck list
	for child in $DeckEditor/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
#Loads deck names data and checks if it exists
	var loaded_deck_names = save.load_json("deck_names.deck")
	if !loaded_deck_names:
		return
#Loops through decks
	for i in loaded_deck_names:
	#Creates a deck data var and makes sure it has data
		var loaded_deck = save.load_json(str(i, ".deck"))
		if !loaded_deck:
			push_error("Data fault, deck_names contains a name with no data.")
			create_popup("Data fault, deck_names contains a name with no data.", -1.0, "error")
			return
	#Adds the deck to the visual list
		var instance = deck_entry.instantiate()
		instance.text = str(loaded_deck)
		instance.deck = i
		instance.cards = loaded_deck
		$DeckEditor/ScrollContainer/VBoxContainer.add_child(instance)
		
		
#------------------------------
#SEQUENCE EDITOR BUTTONS
#------------------------------

func _on_create_blank_sequence_button_pressed() -> void:
	sequence.create_blank_sequence("blank")
	reload_sequence_list()

#------------------------------
#RELOAD SEQUENCE VISUALS FUNCTION
#------------------------------

func reload_sequence_list():
#Deletes children in sequence list
	for child in $SequenceEditor/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
#Loads sequence names data and checks if it exists
	var loaded_sequence_names = save.load_json("sequence_names.seq")
	if !loaded_sequence_names:
		return
#Loops through sequences
	for i in loaded_sequence_names:
	#Creates a deck data var and makes sure it has data
		var loaded_sequence = save.load_json(str(i, ".seq"))
		if !loaded_sequence:
			push_warning("Data fault, sequence_names contains a name with no data.")
			#create_popup("Data fault, deck_names contains a name with no data.", -1.0, "error")
			#return
	#Adds the deck to the visual list
		var instance = sequence_entry.instantiate()
		instance.text = str(loaded_sequence)
		instance.sequence = i
		instance.decks = loaded_sequence
		$SequenceEditor/ScrollContainer/VBoxContainer.add_child(instance)

#------------------------------
#POPUP CREATOR FUNCTIONS
#------------------------------

#regular popup
func create_popup(message: String, auto_hide_time: float = -1.0, type: String = "general"):
	var instance = popup.instantiate()
	instance.message = message
	instance.auto_hide_time = auto_hide_time
	instance.type = type
	add_child(instance)

#password popup
func create_password(menu: String):
	var instance = password.instantiate()
	instance.menu = menu
	instance.connect("password_correct", Callable(self, "_on_password_correct"))
	add_child(instance)

#Password correct event/detection
func _on_password_correct(menu: String):
	if menu == "settings":
		open_settings_menu()
	if menu == "statistics":
		open_statistics_menu()
	if menu == "decks":
		open_decks_menu()
	if menu == "sequence":
		open_sequence_menu()
	if menu == "open_folder":
		open_flashcards_folder()

#Update password, sets password to something else in settings ui
func _on_password_text_submitted(new_text: String) -> void:
	if new_text == "":
		create_popup("Password cannot be blank!", -1.0, "error")
		return
	if new_text == admin_password:
		return
	admin_password = new_text
	create_popup("Password Changed!")

#Sets visiblity of password text
func _on_password_vision_button_pressed() -> void:
	$Settings/Password.secret = !$Settings/Password.secret

#------------------------------
#IMPORT NEW DECK
#------------------------------

func _on_import_dialog_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open file.")
		create_popup("Could not open file.", -1, "error")
		return

	var text := file.get_as_text()

	var data = JSON.parse_string(text)
	if data == null or not data is Dictionary:
		push_error("Invalid flashcard JSON format.")
		create_popup("Invalid flashcard JSON format. This file will not work!", -1, "error")
		return
	var filename = path.get_file()
	filename = filename.replace(".deck", "")
	deck.create_deck(data, filename)
	reload_deck_list()


func _on_import_button_pressed() -> void:
	$DeckEditor/ImportDialog.visible = true
	
	
#------------------------------
#SAVE STUDENT DATA
#------------------------------
	
func save_student_data(loaded, new_rounds_completed):
	var data = {
		"Name": student_name,
		"Operator": operator,
		"Required Number": required_number,
		"Incorrect Questions": failures,
		"Max Questions": max_questions,
		"Questions Per Minute": qpm,
		"Time Taken": roundf(time_passed),
		"Rounds Completed": new_rounds_completed
	}
	for i in new_rounds_completed:
		
		if !loaded.has(str(i, "qpm")):
			data[str(i, "qpm")] = qpm
		else:
			data[str(i, "qpm")] = loaded[str(i, "qpm")]
		
		if !loaded.has(str(i, "failures")):
			data[str(i, "failures")] = failures
		else:
			data[str(i, "failures")] = loaded[str(i, "failures")]
			
		if !loaded.has(str(i, "deck")):
			data[str(i, "deck")] = selected_deck
		else:
			data[str(i, "deck")] = loaded[str(i, "deck")]
			
	if !student_name == "":
		save.save_json(str(student_name + ".json"), data)
		if send_data:
			excel.send_round_data(student_name, String(operator), required_number, failures, max_questions, qpm, roundf(time_passed))


#------------------------------
#OPEN FLASHCARDS DATA FOLDER
#------------------------------

func open_flashcards_folder():
	var path = ProjectSettings.globalize_path("user://FlashCards")
	
	# Create the folder if it doesn't exist
	var dir = DirAccess.open(path)
	if dir == null:
		DirAccess.open(ProjectSettings.globalize_path("user://")).make_dir_recursive("FlashCards")
	
	# Open it in the OS file explorer
	OS.shell_open(path)
