extends CanvasLayer

signal start_game(level: int)

const OptionsScene = preload("res://scenes/options/options.tscn")
const LevelSelectScene = preload("res://scenes/level_select.tscn")

func show_game_over():
	_show_menu_buttons()
	$GameOverLabel.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	_hide_menu_buttons()
	$GameOverLabel.hide()
	start_game.emit(0)

func _on_level_select_button_pressed():
	_hide_menu_buttons()
	$GameOverLabel.hide()
	var level_select = LevelSelectScene.instantiate()
	level_select.level_selected.connect(_on_level_selected)
	level_select.back.connect(_on_level_select_back)
	get_tree().root.add_child(level_select)

func _on_level_selected(level: int):
	start_game.emit(level)

func _on_level_select_back():
	_show_menu_buttons()

func _show_menu_buttons():
	$StartButton.show()
	$LevelSelectButton.show()
	$OptionsButton.show()
	$ExitButton.show()

func _hide_menu_buttons():
	$StartButton.hide()
	$LevelSelectButton.hide()
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
