# Flashcards - Godot Project
# Copyright (C) 2026 Mr. Winans
# Licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.txt

extends Node
class_name RoundManager

var main
var save = SaveManager.new()
var excel = ExcelAPI.new()

func _init(_main):
	main = _main
	
func start_round():
	main.time_passed = 0
	main.completed_problems = 0
	main.failures = 0
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if main.card_generation == "random":
		main.counter.text = str("0", "/", main.max_questions)
	elif main.card_generation == "deck":
		main.counter.text = str("0", "/", "x")
	main.restart_round_menu.visible = false
	main.playing = true
	main.admin_present = false
	
	#await Engine.get_main_loop().process_frame
	if main.style == "flat":
		main.answer_box.position = Vector2(375, 198)
		main.flat.visible = true
	elif main.style == "column":
		main.answer_box.position = Vector2(385, 375)
		main.column.visible = true
	else:
		push_error("No style selected")
		force_end_round("No Style Selected")
	main._reset_flash_card()
	main.answer_box.grab_focus()
	
func end_round():
	if !main.playing:
		main.create_popup("Round cannot end, not currently playing.", -1.0, "error")
		push_error("Round cannot end, not currently playing.")
		return
	main.answer_box.position = Vector2(1104, 183)
	main.restart_round_menu.visible = true
	var loaded = save.load_json(main.student_name + ".json")
	print(loaded)
	var new_rounds_completed: int
	if loaded:
		if !loaded.has("Rounds Completed"):
			new_rounds_completed = 1
		else:
			new_rounds_completed = loaded["Rounds Completed"] + 1
	else:
		new_rounds_completed += 1
		
	main.save_student_data(loaded,new_rounds_completed)
	main.playing = false
	main.create_popup("Round Complete! Wait for Help.", -1, "round_complete")

func force_end_round(reason: String):
	if !main.playing:
		main.create_popup("Round cannot end, not currently playing.", -1.0, "error")
		push_error("Round cannot end, not currently playing.")
		return
	main.playing = false
	main.answer_box.position = Vector2(1104, 183)
	main.restart_round_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	main.create_popup(str("Round was force ended: ", reason), -1.0, "error")
