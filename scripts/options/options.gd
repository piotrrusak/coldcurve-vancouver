extends CanvasLayer

signal back

func _ready():
	$Container/BulletSpeedSlider.value = GameSettings.bullet_speed_multiplier
	_update_bullet_label(GameSettings.bullet_speed_multiplier)
	$Container/PlayerSpeedSlider.value = GameSettings.player_speed_multiplier
	_update_player_label(GameSettings.player_speed_multiplier)
	$Container/EnemySpeedSlider.value = GameSettings.enemy_speed_multiplier
	_update_enemy_label(GameSettings.enemy_speed_multiplier)

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

func _on_back_button_pressed():
	back.emit()
	queue_free()
