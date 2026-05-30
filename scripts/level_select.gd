extends CanvasLayer

signal level_selected(level: int)
signal back

func _on_level1_pressed():
	level_selected.emit(0)
	queue_free()

func _on_level2_pressed():
	level_selected.emit(1)
	queue_free()

func _on_level3_pressed():
	level_selected.emit(2)
	queue_free()

func _on_level4_pressed():
	level_selected.emit(3)
	queue_free()

func _on_level5_pressed():
	level_selected.emit(4)
	queue_free()

func _on_back_pressed():
	back.emit()
	queue_free()
