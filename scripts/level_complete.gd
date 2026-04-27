extends CanvasLayer

signal next_level

func setup(level_number: int):
	$LevelLabel.text = "Level %d Complete!" % level_number

func _on_next_button_pressed():
	next_level.emit()
	queue_free()
