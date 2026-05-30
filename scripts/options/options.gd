extends CanvasLayer

signal back

func _ready():
	$Container/BulletSpeedSlider.value = GameSettings.bullet_speed_multiplier
	_update_bullet_label(GameSettings.bullet_speed_multiplier)
	$Container/PlayerSpeedSlider.value = GameSettings.player_speed_multiplier
	_update_player_label(GameSettings.player_speed_multiplier)
	$Container/EnemySpeedSlider.value = GameSettings.enemy_speed_multiplier
	_update_enemy_label(GameSettings.enemy_speed_multiplier)
	$Container/ImmortalityCheckBox.button_pressed = GameSettings.immortality
	$Container/ShowSpawnCoordsCheckBox.button_pressed = GameSettings.show_spawn_coords

func _on_bullet_speed_slider_value_changed(value: float):
	GameSettings.bullet_speed_multiplier = value
	_update_bullet_label(value)

func _update_bullet_label(value: float):
	$Container/BulletSpeedLabel.text = "Bullet Speed: %.1fx" % value

func _on_player_speed_slider_value_changed(value: float):
	GameSettings.player_speed_multiplier = value
	_update_player_label(value)

func _update_player_label(value: float):
	$Container/PlayerSpeedLabel.text = "Player Speed: %.1fx" % value

func _on_enemy_speed_slider_value_changed(value: float):
	GameSettings.enemy_speed_multiplier = value
	_update_enemy_label(value)

func _update_enemy_label(value: float):
	$Container/EnemySpeedLabel.text = "Enemy Speed: %.1fx" % value

func _on_immortality_check_box_toggled(toggled_on: bool):
	GameSettings.immortality = toggled_on

func _on_show_spawn_coords_check_box_toggled(toggled_on: bool):
	GameSettings.show_spawn_coords = toggled_on

func _on_back_button_pressed():
	back.emit()
	queue_free()
