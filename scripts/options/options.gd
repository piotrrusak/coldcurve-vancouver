extends CanvasLayer

signal back
signal spawn_rate_changed(seconds: float)

var spawn_rate: float = 5.0

func _ready():
	spawn_rate = GameSettings.enemy_spawn_rate
	$Container/SpawnRateSlider.value = spawn_rate
	_update_label(spawn_rate)

func _on_spawn_rate_slider_value_changed(value: float):
	spawn_rate = value
	GameSettings.enemy_spawn_rate = value
	_update_label(value)
	spawn_rate_changed.emit(value)

func _update_label(value: float):
	$Container/SpawnRateLabel.text = "Enemy Spawn Rate: %ds" % int(value)

func _on_back_button_pressed():
	back.emit()
	queue_free()
