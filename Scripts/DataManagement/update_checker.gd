extends HTTPRequest

var current_version: String
const REPO := "255-Ping/Flashcards"

var main

func _ready() -> void:
	main = get_tree().current_scene
	current_version = main.version
	check_for_update()
	
func check_for_update() -> void:
	request_completed.connect(_on_request_completed)
	request("https://api.github.com/repos/%s/releases/latest" % REPO)
	
func _on_request_completed(_result, _code, _headers, body: PackedByteArray) -> void:
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	var latest: String = json["tag_name"].trim_prefix("v")
	if latest != current_version:
		print("Update available: ", latest)
