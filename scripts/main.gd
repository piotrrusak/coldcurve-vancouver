extends Node

@export var enemy_scene: PackedScene

const LevelCompleteScene = preload("res://scenes/level_complete.tscn")
const GameFinishedScene = preload("res://scenes/game_finished.tscn")
const PauseMenuScene = preload("res://scenes/pause_menu.tscn")
const OptionsScene = preload("res://scenes/options/options.tscn")

var _pause_menu: CanvasLayer = null
var _playing := false

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

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and _playing:
		if _pause_menu:
			_resume()
		else:
			_open_pause_menu()

func _open_pause_menu():
	get_tree().paused = true
	_pause_menu = PauseMenuScene.instantiate()
	_pause_menu.resume.connect(_resume)
	_pause_menu.options.connect(_open_options_from_pause)
	add_child(_pause_menu)

func _resume():
	get_tree().paused = false
	if _pause_menu:
		_pause_menu.queue_free()
		_pause_menu = null

func _open_options_from_pause():
	var options = OptionsScene.instantiate()
	options.back.connect(func(): options.queue_free())
	add_child(options)

func game_over():
	_playing = false
	_resume()
	$HUD.show_game_over()

func new_game():
	_playing = true
	get_tree().paused = false
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	score = 0
	current_level = 0
	_clearing = false
	$HUD.update_score(score)
	start_level()

func start_level():
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	$Player.start($StartPosition.position)
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
	_playing = false
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
	_playing = true
	current_level += 1
	get_tree().paused = false
	start_level()
