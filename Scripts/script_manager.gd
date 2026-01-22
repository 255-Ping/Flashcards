extends Node


var main: Node = null

var save = SaveManager.new()


func _ready() -> void:
	main = get_tree().current_scene
	
func delete_script(sc: String):
	if !save.get_files_with_extension("script").has(sc + ".script"):
		PanelLogger.log_error("Script: script could not be deleted, as it doesn't exist")
		return
	save.delete_file(sc + ".script")
	PanelLogger.log("Script: script successfully deleted")
	
func run_script(sc: String):
	var loaded = save.load_json(sc + ".script")
	print(loaded)
	print(sc)
	if loaded:
		#print(loaded)
		for i in loaded:
			print(loaded[i])
			if "select_deck" in loaded[i]:
				print("Script: select_deck")
				select_deck(loaded[i], int(i))
			if "begin_round" in loaded[i]:
				print("Script: begin_round")
				begin_round(loaded[i], int(i))
			if "close_cmd" in loaded[i]:
				print("Script: close_cmd")
				close_cmd(loaded[i], int(i))
			if "timer" in loaded[i]:
				print("Script: timer")
				await timer(loaded[i], int(i))
			if "wait_for" in loaded[i]:
				print("Script: wait_for")
				await wait_for(loaded[i], int(i))
			if "print" in loaded[i]:
				print("Script: print")
				script_print(loaded[i], int(i))
			if "close_popups" in loaded[i]:
				print("Script: close_popups")
				close_popups(loaded[i], int(i))
				
				
func select_deck(syntax: String, line: int):
	var split = syntax.split(" ")
	var decks = save.load_json("deck_names.deck")
	if !decks.has(split[1]):
		PanelLogger.log_error("Script: Deck does not exist LINE: " + str(line))
		return
	main.selected_deck = split[1]
	PanelLogger.log("Script: Deck " + str(split[1]) + " selected")
	
func begin_round(_syntax: String, _line: int):
	main.round_manager.start_round()
	PanelLogger.log("Script: Round begun")
	
func close_cmd(_syntax: String, _line: int):
	main.command_panel.visible = false
	PanelLogger.log("Script: Command panel closed")
	
func timer(syntax: String, line: int):
	var split = syntax.split(" ")
	if !float(split[1]):
		PanelLogger.log_error("Script: timer value not float LINE: " + str(line))
		return
	var t := Timer.new()
	t.wait_time = float(split[1])
	t.one_shot = true
	add_child(t)
	PanelLogger.log("Script: Timer for " + String(split[1]) + " seconds created")
	t.start()
	await t.timeout
	PanelLogger.log("Script: Timer finished")
	t.queue_free()
	
func wait_for(syntax: String, _line: int):
	var split = syntax.split(" ")
	if split[1] == "round_end":
		PanelLogger.log("Script: Wait for round end")
		await main.wait_for_signal_round_end
	else:
		PanelLogger.log_error("Script: Unknown wait_for argument")
		return
		
func script_print(syntax: String, _line: int):
	var split = syntax.split(" ")
	split[1].replace("_", " ")
	PanelLogger.log(split[1])
	
func close_popups(_syntax: String, _line: int):
	main.emit_signal("close_popups")
	PanelLogger.log("Script: Closed Popups")
	
