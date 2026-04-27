extends Node

@export var enemy_scene: PackedScene

const LevelCompleteScene = preload("res://scenes/level_complete.tscn")
const GameFinishedScene = preload("res://scenes/game_finished.tscn")

const LEVEL_SPAWNS = [
	[
		Vector2(550, 400),
		Vector2(1050, 350),
		Vector2(1550, 400),
		Vector2(450, 850),
		Vector2(1650, 850),
		Vector2(550, 1200),
		Vector2(1550, 1200),
	],
	[
		Vector2(550, 400),
		Vector2(1050, 350),
		Vector2(1550, 400),
		Vector2(450, 850),
		Vector2(1650, 850),
		Vector2(550, 1200),
		Vector2(1550, 1200),
		Vector2(1050, 1200),
		Vector2(750, 650),
		Vector2(1350, 650),
		Vector2(650, 1000),
		Vector2(1450, 1000),
	],
]

var score: int
var current_level: int
var enemies_remaining: int
var _clearing := false

func game_over():
	get_tree().paused = false
	$HUD.show_game_over()

func new_game():
	get_tree().paused = false
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	score = 0
	current_level = 0
	_clearing = false
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	start_level()

func start_level():
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	_clearing = false
	var positions = LEVEL_SPAWNS[current_level]
	enemies_remaining = positions.size()
	for pos in positions:
		var enemy = enemy_scene.instantiate()
		enemy.position = pos
		enemy.enemy_hit.connect(_on_enemy_killed)
		add_child(enemy)

func _on_enemy_killed():
	score += 1
	$HUD.update_score(score)
	enemies_remaining -= 1
	if enemies_remaining <= 0 and not _clearing:
		_clearing = true
		call_deferred("_on_level_cleared")

func _on_level_cleared():
	get_tree().paused = true
	if current_level + 1 >= LEVEL_SPAWNS.size():
		var screen = GameFinishedScene.instantiate()
		screen.play_again.connect(new_game)
		add_child(screen)
	else:
		var screen = LevelCompleteScene.instantiate()
		screen.next_level.connect(_on_next_level)
		add_child(screen)
		screen.setup(current_level + 1)

func _on_next_level():
	current_level += 1
	get_tree().paused = false
	start_level()
