extends CanvasLayer

signal play_again

const OptionsScene = preload("res://scenes/options/options.tscn")

func _on_play_again_button_pressed():
	play_again.emit()
	queue_free()

func _on_options_button_pressed():
	_hide_buttons()
	var options = OptionsScene.instantiate()
	options.back.connect(_on_options_back)
	get_tree().root.add_child(options)

func _on_options_back():
	_show_buttons()

func _on_exit_button_pressed():
	get_tree().quit()

func _show_buttons():
	$PlayAgainButton.show()
	$OptionsButton.show()
	$ExitButton.show()

func _hide_buttons():
	$PlayAgainButton.hide()
	$OptionsButton.hide()
	$ExitButton.hide()
