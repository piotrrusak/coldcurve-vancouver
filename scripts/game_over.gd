extends CanvasLayer

signal restart
signal main_menu

const OptionsScene = preload("res://scenes/options/options.tscn")

func _on_restart_button_pressed():
	restart.emit()
	queue_free()

func _on_options_button_pressed():
	_hide_buttons()
	var options = OptionsScene.instantiate()
	options.back.connect(_on_options_back)
	get_tree().root.add_child(options)

func _on_options_back():
	_show_buttons()

func _on_main_menu_button_pressed():
	main_menu.emit()
	queue_free()

func _on_exit_button_pressed():
	get_tree().quit()

func _show_buttons():
	$RestartButton.show()
	$OptionsButton.show()
	$MainMenuButton.show()
	$ExitButton.show()

func _hide_buttons():
	$RestartButton.hide()
	$OptionsButton.hide()
	$MainMenuButton.hide()
	$ExitButton.hide()
