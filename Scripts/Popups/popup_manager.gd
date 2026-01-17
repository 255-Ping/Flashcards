extends CanvasLayer
class_name PopupManager

@onready var panel = $Control/Panel
@onready var message_label = $Control/Panel/Label
@onready var ok_button = $Control/Panel/Button
@onready var background = $Control/ColorRect

var message: String
var auto_hide_time: float
var type: String

func _ready():
	await get_tree().process_frame
	show_message(message, auto_hide_time, type)

func show_message(msg: String, aht: float = -1.0, t: String = "general"):
	message_label.text = msg
	background.visible = true
	if t == "general":
		background.color = Color(0.2, 0.2, 0.2, 0.5)
	elif t == "error":
		background.color = Color(0.8, 0.2, 0.2, 0.5)
	elif t == "round_complete":
		background.color = Color(0.3, 0.9, 0.1, 0.5)
	else:
		background.color = Color(0.2, 0.2, 0.2, 0.5)
	panel.visible = true

	if aht > 0:
		await get_tree().create_timer(aht).timeout
		close_popup()

func close_popup():
	queue_free()

func _on_button_pressed() -> void:
	close_popup()
