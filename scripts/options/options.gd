extends CanvasLayer

signal back

func _on_back_button_pressed():
	back.emit()
	queue_free()
