extends CanvasLayer

signal start_game

func show_game_over():
	$StartButton.show()
	$OptionsButton.show()
	$ExitButton.show()
	$GameOverLabel.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	$OptionsButton.hide()
	$ExitButton.hide()
	$GameOverLabel.hide()
	start_game.emit()

func _on_options_button_pressed():
	pass

func _on_exit_button_pressed():
	get_tree().quit()
