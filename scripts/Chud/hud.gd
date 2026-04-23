extends CanvasLayer

signal start_game

const OptionsScene = preload("res://scenes/options/options.tscn")

func show_game_over():
	_show_menu_buttons()
	$GameOverLabel.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	_hide_menu_buttons()
	$GameOverLabel.hide()
	start_game.emit()

func _show_menu_buttons():
	$StartButton.show()
	$OptionsButton.show()
	$ExitButton.show()

func _hide_menu_buttons():
	$StartButton.hide()
	$OptionsButton.hide()
	$ExitButton.hide()

func _on_options_button_pressed():
	_hide_menu_buttons()
	var options = OptionsScene.instantiate()
	options.back.connect(_on_options_back)
	get_tree().root.add_child(options)

func _on_options_back():
	_show_menu_buttons()

func _on_exit_button_pressed():
	get_tree().quit()
