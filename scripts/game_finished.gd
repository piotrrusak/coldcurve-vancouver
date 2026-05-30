extends CanvasLayer

signal main_menu

const OptionsScene = preload("res://scenes/options/options.tscn")

func _on_main_menu_button_pressed():
	main_menu.emit()
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
	$MainMenuButton.show()
	$OptionsButton.show()
	$ExitButton.show()

func _hide_buttons():
	$MainMenuButton.hide()
	$OptionsButton.hide()
	$ExitButton.hide()
