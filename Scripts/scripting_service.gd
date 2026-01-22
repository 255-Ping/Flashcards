extends Control

var sc: String

var sc_text: Array
var save_dict: Dictionary

var save = SaveManager.new()

func _ready() -> void:
	var loaded = save.load_json(sc + ".script")
	if loaded:
		for i in loaded:
			$TextEdit.text = $TextEdit.text + loaded[i] + "\n"
		sc_text = $TextEdit.text.split("\n")
		for i in sc_text.size():
			save_dict[i] = sc_text[i]	


func _on_text_edit_text_changed() -> void:
	sc_text = $TextEdit.text.split("\n")
	for i in sc_text.size():
		save_dict[i] = sc_text[i]


func _on_close_button_pressed() -> void:
	queue_free()


func _on_save_button_pressed() -> void:
	save.save_json(sc + ".script", save_dict)
