extends CanvasLayer

signal start_game

func show_game_over():
	$StartButton.show()
	$GameOverLabel.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	$GameOverLabel.hide()
	start_game.emit()
