extends Window

var is_window := true

func _on_close_requested() -> void:
	queue_free()
