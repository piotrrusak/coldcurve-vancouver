extends Node

@export var enemy_scene: PackedScene
var score

func game_over():
	$EnemyTimer.stop()
	$HUD.show_game_over()

func new_game():
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)

func _on_enemy_timer_timeout():
	var enemy = enemy_scene.instantiate()
	var spawn_location = $EnemyPath/EnemySpawnLocation
	spawn_location.progress_ratio = randf()
	enemy.position = spawn_location.position
	enemy.enemy_hit.connect(_on_enemy_killed)
	add_child(enemy)

func _on_enemy_killed():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$EnemyTimer.start()
