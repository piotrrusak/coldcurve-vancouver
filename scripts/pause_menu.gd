extends CanvasLayer

signal resume
signal options

func _on_resume_button_pressed():
	resume.emit()

func _on_options_button_pressed():
	options.emit()

func _on_exit_button_pressed():
	get_tree().quit()
