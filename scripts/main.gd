extends Node

@export var enemy_scene: PackedScene

const LevelCompleteScene = preload("res://scenes/level_complete.tscn")
const GameFinishedScene = preload("res://scenes/game_finished.tscn")
const GameOverScene = preload("res://scenes/game_over.tscn")
const PauseMenuScene = preload("res://scenes/pause_menu.tscn")
const OptionsScene = preload("res://scenes/options/options.tscn")

const LEVEL_MAPS = [
	preload("res://scenes/map/level1_map.tscn"),
	preload("res://scenes/map/level2_map.tscn"),
	preload("res://scenes/map/level3_map.tscn"),
	preload("res://scenes/map/level4_map.tscn"),
	preload("res://scenes/map/level5_map.tscn"),
]

var _current_map: Node = null

var _pause_menu: CanvasLayer = null
var _playing := false
var _countdown_overlay: CanvasLayer = null
var _countdown_label: Label = null
var _countdown_count: int = 0

const LEVEL_START_POSITIONS = [
	Vector2(963, 713),
	Vector2(963, 713),
	Vector2(1664, 256),
	Vector2(320, 320),
	Vector2(320, 320),
]

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
	[
		Vector2(500, 650), Vector2(1200, 700), Vector2(2100, 650), Vector2(2900, 700),
		Vector2(1408, 1000),
		Vector2(550, 1350), Vector2(700, 1700), Vector2(1050, 1350), Vector2(550, 1850),
		Vector2(1700, 1350), Vector2(2400, 1700), Vector2(2900, 1350), Vector2(1800, 1850),
		Vector2(500, 2100), Vector2(1300, 2200), Vector2(2100, 2100), Vector2(2900, 2200),
		Vector2(600, 2600), Vector2(1500, 2500), Vector2(2400, 2600), Vector2(2850, 2500),
		Vector2(3060, 2950),
		Vector2(550, 3200), Vector2(1400, 3350), Vector2(2300, 3200),
		Vector2(700, 3550), Vector2(1800, 3550), Vector2(2750, 3400),
		Vector2(1792, 3850),
		Vector2(700, 4150), Vector2(2300, 4150),
		Vector2(500, 4600), Vector2(2200, 4600),
		Vector2(900, 4900), Vector2(2000, 4950),
	],
	[
		Vector2(500, 650), Vector2(1200, 700), Vector2(2100, 650), Vector2(2900, 700),
		Vector2(1408, 1000),
		Vector2(550, 1350), Vector2(700, 1700), Vector2(1050, 1350), Vector2(550, 1850),
		Vector2(1700, 1350), Vector2(2400, 1700), Vector2(2900, 1350), Vector2(1800, 1850),
		Vector2(500, 2100), Vector2(1300, 2200), Vector2(2100, 2100), Vector2(2900, 2200),
		Vector2(600, 2600), Vector2(1250, 2750), Vector2(2400, 2600), Vector2(2850, 2500),
		Vector2(3060, 2950),
		Vector2(550, 3200), Vector2(1400, 3350), Vector2(2300, 3200),
		Vector2(700, 3550), Vector2(1800, 3550), Vector2(2750, 3400),
		Vector2(1792, 3850),
		Vector2(700, 4150), Vector2(2300, 4150),
		Vector2(500, 4600), Vector2(2200, 4600),
		Vector2(900, 4900), Vector2(2000, 4950),
		Vector2(750, 4000), Vector2(1100, 4500),
		Vector2(1900, 4900), Vector2(2600, 4100), Vector2(2700, 5250),
	],
	[
		Vector2(500, 650), Vector2(1200, 700), Vector2(2100, 650), Vector2(2900, 700),
		Vector2(1408, 1000),
		Vector2(550, 1350), Vector2(700, 1700), Vector2(1050, 1350), Vector2(550, 1850),
		Vector2(1700, 1350), Vector2(2400, 1700), Vector2(2900, 1350), Vector2(1800, 1850),
		Vector2(500, 2100), Vector2(1300, 2200), Vector2(2100, 2100), Vector2(2900, 2200),
		Vector2(600, 2600), Vector2(1250, 2750), Vector2(2400, 2600), Vector2(2850, 2500),
		Vector2(3060, 2950),
		Vector2(550, 3200), Vector2(1400, 3350), Vector2(2300, 3200),
		Vector2(700, 3550), Vector2(1800, 3550), Vector2(2750, 3400),
		Vector2(1792, 3850),
		Vector2(700, 4150), Vector2(2300, 4150),
		Vector2(500, 4600), Vector2(2200, 4600),
		Vector2(900, 4900), Vector2(2000, 4950),
		Vector2(750, 4000), Vector2(1100, 4500),
		Vector2(1900, 4900), Vector2(2600, 4100), Vector2(2700, 5250),
	],
]

var score: int
var score_at_level_start: int
var current_level: int
var enemies_remaining: int
var _clearing := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and _playing:
		if _countdown_overlay:
			pass
		elif _pause_menu:
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
	if _pause_menu:
		_pause_menu.queue_free()
		_pause_menu = null
	_start_countdown()

func _unpause():
	get_tree().paused = false

func _start_countdown():
	_countdown_overlay = CanvasLayer.new()
	_countdown_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_countdown_overlay.layer = 10
	add_child(_countdown_overlay)

	_countdown_label = Label.new()
	_countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 200)
	_countdown_overlay.add_child(_countdown_label)

	_countdown_count = 3
	_countdown_label.text = str(_countdown_count)

	var timer := Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 1.0
	timer.timeout.connect(_on_countdown_tick)
	_countdown_overlay.add_child(timer)
	timer.start()

func _on_countdown_tick():
	_countdown_count -= 1
	if _countdown_count <= 0:
		_countdown_overlay.queue_free()
		_countdown_overlay = null
		_countdown_label = null
		_unpause()
	else:
		_countdown_label.text = str(_countdown_count)

func _open_options_from_pause():
	_pause_menu.hide()
	var options = OptionsScene.instantiate()
	options.back.connect(func(): _pause_menu.show())
	add_child(options)

func game_over():
	_playing = false
	if _pause_menu:
		_pause_menu.queue_free()
		_pause_menu = null
	if _countdown_overlay:
		_countdown_overlay.queue_free()
		_countdown_overlay = null
		_countdown_label = null
	get_tree().paused = true
	var screen = GameOverScene.instantiate()
	screen.restart.connect(_on_game_over_restart)
	screen.main_menu.connect(_on_game_over_main_menu)
	add_child(screen)

func _on_game_over_restart():
	get_tree().paused = false
	_playing = true
	new_game()

func _on_game_over_main_menu():
	get_tree().paused = false
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	if _current_map:
		_current_map.queue_free()
		_current_map = null
	$Player.hide()
	score = 0
	score_at_level_start = 0
	$HUD.update_score(0)
	_playing = false
	$HUD.show_menu()

func new_game():
	_playing = true
	get_tree().paused = false
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	score = score_at_level_start
	_clearing = false
	$HUD.update_score(score)
	start_level()

func full_reset():
	current_level = 0
	score_at_level_start = 0
	new_game()

func start_game_at_level(level: int):
	current_level = level
	score_at_level_start = 0
	new_game()

func _swap_map(level: int):
	if _current_map:
		_current_map.queue_free()
		_current_map = null
	_current_map = LEVEL_MAPS[level].instantiate()
	$Map.add_child(_current_map)

func start_level():
	score_at_level_start = score
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	_swap_map(current_level)
	$Player.start(LEVEL_START_POSITIONS[current_level])
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
		screen.main_menu.connect(_on_game_over_main_menu)
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
