extends Control
class_name DeckUi

var text: String
var deck: String
var cards: Dictionary

var deck_manager = DeckManager.new()
var save = SaveManager.new()
var main


#@onready var label = $Panel/Label
@onready var scroll_box = $Panel/ScrollContainer/HBoxContainer

@onready var card = preload("res://Scenes/card.tscn")

func _ready() -> void:
	main = get_tree().current_scene
	reload_card_list()
	
func reload_card_list():
	deck_manager.sort_deck_keys(deck)
	cards = save.load_json(str(deck, ".deck"))
	$Panel/DeckName.text = deck
	for child in $Panel/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	
	for c in cards:
		var instance = card.instantiate()		
		var parts
		if "+" in cards[c]:
			parts = cards[c].split("+")
			instance.operator = "+"
			instance.answer = int(parts[0]) + int(parts[1])
		if "-" in cards[c]:
			parts = cards[c].split("-")
			instance.operator = "-"
			instance.answer = int(parts[0]) - int(parts[1])
		if "x" in cards[c]:
			parts = cards[c].split("x")
			instance.operator = "x"
			instance.answer = int(parts[0]) * int(parts[1])
		instance.value_1 = int(parts[0])
		instance.value_2 = int(parts[1])
		instance.deck = deck
		instance.card = c
		instance.parent_ui = self
		scroll_box.add_child(instance)
	
func _on_delete_button_pressed() -> void:
	deck_manager.delete_deck(deck)
	main.reload_deck_list()
	
func _on_add_button_pressed() -> void:
	var add_line_text = $Panel/AddLine.text
	var parts
	if "+" in add_line_text:
		parts = add_line_text.split("+")
	elif "-" in add_line_text:
		parts = add_line_text.split("-")
	elif "x" in add_line_text:
		parts = add_line_text.split("x")
	else:
		main.create_popup("Invalid equation")
		$Panel/AddLine.text = ""
		return
	if !parts[0].is_valid_float():
		main.create_popup("Invalid equation")
		$Panel/AddLine.text = ""
		return
	if !parts[1].is_valid_float():
		main.create_popup("Invalid equation")
		$Panel/AddLine.text = ""
		return
	deck_manager.add_card(deck, add_line_text)
	$Panel/AddLine.text = ""
	deck_manager.sort_deck_keys(deck)
	reload_card_list()


func _on_select_button_pressed() -> void:
	main.selected_deck = deck
	main.create_popup(str("Deck Selected: ", deck), 0.5)

func _on_deck_name_text_submitted(new_text: String) -> void:
	if new_text == "":
		push_error()
		main.create_popup("Deck name cannot be blank", -1.0, "error")
		return
	deck_manager.rename_deck(deck, new_text)
	main.reload_deck_list()
