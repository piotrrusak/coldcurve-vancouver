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
	preload("res://scenes/map/level6_map.tscn"),
	preload("res://scenes/map/level7_map.tscn"),
	preload("res://scenes/map/level8_map.tscn"),
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
	Vector2(4416, 3904),
	Vector2(2752, 5184),
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
		Vector2(448, 448),
		Vector2(5440, 5184),
		Vector2(320, 5184),
		Vector2(4928, 832),
		Vector2(2496, 2880),
		Vector2(3008, 5184),
		Vector2(2752, 320),
		Vector2(5184, 3008),
		Vector2(320, 2880),
		Vector2(1600, 1600),
		Vector2(1600, 4288),
		Vector2(3776, 1984),
		Vector2(3776, 3776),
		Vector2(4160, 4928),
		Vector2(320, 1600),
		Vector2(448, 4032),
		Vector2(1600, 320),
		Vector2(2752, 1472),
		Vector2(3776, 832),
		Vector2(5440, 1856),
		Vector2(5056, 4160),
		Vector2(1344, 2624),
		Vector2(2624, 4032),
		Vector2(4160, 2880),
		Vector2(1344, 5184),
		Vector2(1216, 3520),
		Vector2(4544, 1600),
		Vector2(1088, 960),
		Vector2(2112, 960),
		Vector2(2240, 4800),
		Vector2(3264, 3136),
		Vector2(1984, 3520),
		Vector2(960, 1984),
		Vector2(1984, 2240),
		Vector2(3264, 4416),
		Vector2(832, 4672),
		Vector2(4288, 320),
		Vector2(4672, 2368),
		Vector2(4672, 3520),
		Vector2(2752, 2240),
		Vector2(4800, 4800),
		Vector2(320, 2240),
		Vector2(3392, 320),
		Vector2(3392, 1472),
		Vector2(3392, 2496),
		Vector2(4160, 4288),
		Vector2(5440, 1216),
		Vector2(5440, 3648),
		Vector2(576, 3392),
		Vector2(1856, 2880),
		Vector2(2240, 1728),
		Vector2(3520, 4928),
		Vector2(4032, 1344),
		Vector2(960, 3008),
		Vector2(5440, 4544),
		Vector2(960, 320),
		Vector2(320, 960),
		Vector2(832, 2496),
		Vector2(320, 4544),
		Vector2(960, 4160),
		Vector2(2112, 4160),
		Vector2(2240, 448),
		Vector2(2624, 832),
		Vector2(3264, 960),
		Vector2(2752, 4544),
		Vector2(4416, 960),
		Vector2(5312, 2368),
		Vector2(1600, 832),
		Vector2(960, 1472),
		Vector2(832, 5184),
		Vector2(1728, 4800),
		Vector2(3264, 1984),
		Vector2(3264, 3648),
		Vector2(3776, 3264),
		Vector2(4160, 2368),
		Vector2(4672, 2880),
		Vector2(1472, 3136),
		Vector2(1600, 3776),
		Vector2(2496, 5184),
		Vector2(3776, 4544),
	],
	[
		Vector2(320, 320),
		Vector2(960, 320),
		Vector2(1472, 320),
		Vector2(2112, 320),
		Vector2(2624, 320),
		Vector2(3392, 320),
		Vector2(3776, 320),
		Vector2(4288, 320),
		Vector2(4928, 320),
		Vector2(5440, 320),
		Vector2(320, 832),
		Vector2(960, 832),
		Vector2(1472, 832),
		Vector2(2112, 832),
		Vector2(2624, 832),
		Vector2(3392, 832),
		Vector2(3904, 832),
		Vector2(4416, 832),
		Vector2(4928, 832),
		Vector2(5440, 832),
		Vector2(320, 1472),
		Vector2(960, 1472),
		Vector2(1472, 1472),
		Vector2(2112, 1472),
		Vector2(2624, 1472),
		Vector2(3392, 1472),
		Vector2(3776, 1472),
		Vector2(4288, 1472),
		Vector2(4928, 1472),
		Vector2(5440, 1472),
		Vector2(2624, 1984),
		Vector2(3392, 1984),
		Vector2(3776, 1984),
		Vector2(4416, 1984),
		Vector2(4928, 1984),
		Vector2(5440, 1984),
		Vector2(320, 2112),
		Vector2(960, 2112),
		Vector2(1472, 2112),
		Vector2(2112, 2112),
		Vector2(320, 2496),
		Vector2(960, 2496),
		Vector2(1472, 2496),
		Vector2(2112, 2496),
		Vector2(2624, 2496),
		Vector2(3392, 2496),
		Vector2(3776, 2496),
		Vector2(4416, 2496),
		Vector2(4928, 2496),
		Vector2(5440, 2496),
		Vector2(320, 3136),
		Vector2(960, 3136),
		Vector2(1472, 3136),
		Vector2(2112, 3136),
		Vector2(2624, 3136),
		Vector2(3392, 3136),
		Vector2(3776, 3136),
		Vector2(4416, 3136),
		Vector2(4928, 3136),
		Vector2(5440, 3136),
		Vector2(320, 3648),
		Vector2(960, 3648),
		Vector2(1472, 3648),
		Vector2(2112, 3648),
		Vector2(2624, 3648),
		Vector2(3392, 3648),
		Vector2(3904, 3648),
		Vector2(4416, 3648),
		Vector2(5056, 3648),
		Vector2(5440, 3648),
		Vector2(320, 4160),
		Vector2(960, 4160),
		Vector2(1472, 4160),
		Vector2(2112, 4160),
		Vector2(2624, 4160),
		Vector2(3392, 4160),
		Vector2(3776, 4160),
		Vector2(4288, 4160),
		Vector2(4928, 4160),
		Vector2(5440, 4160),
		Vector2(4928, 4672),
		Vector2(320, 4800),
		Vector2(960, 4800),
		Vector2(1472, 4800),
		Vector2(2112, 4800),
		Vector2(2624, 4800),
		Vector2(3264, 4800),
		Vector2(3776, 4800),
		Vector2(4416, 4800),
		Vector2(5440, 4800),
		Vector2(320, 5184),
		Vector2(960, 5184),
		Vector2(1472, 5184),
		Vector2(2112, 5184),
		Vector2(2624, 5184),
		Vector2(3392, 5184),
		Vector2(3776, 5184),
		Vector2(4416, 5184),
		Vector2(4928, 5184),
		Vector2(5440, 5184),
	],
	[
		Vector2(448, 320), Vector2(960, 320), Vector2(1472, 320), Vector2(2112, 320),
		Vector2(2624, 320), Vector2(3264, 320), Vector2(3776, 320), Vector2(4416, 320),
		Vector2(4928, 320), Vector2(5568, 320), Vector2(6080, 320), Vector2(6720, 320),
		Vector2(7232, 320), Vector2(448, 704), Vector2(960, 704), Vector2(1472, 704),
		Vector2(1984, 704), Vector2(2624, 576), Vector2(3264, 704), Vector2(3776, 704),
		Vector2(4416, 704), Vector2(4928, 704), Vector2(5568, 704), Vector2(6080, 704),
		Vector2(6720, 704), Vector2(7232, 704), Vector2(448, 1088), Vector2(960, 1088),
		Vector2(1472, 1088), Vector2(1984, 1088), Vector2(2624, 1088), Vector2(3136, 1088),
		Vector2(3776, 1088), Vector2(4416, 1088), Vector2(4928, 1088), Vector2(5568, 1088),
		Vector2(6080, 1088), Vector2(6720, 1216), Vector2(7232, 1088), Vector2(448, 1472),
		Vector2(960, 1472), Vector2(1472, 1472), Vector2(1984, 1472), Vector2(2624, 1344),
		Vector2(3264, 1344), Vector2(3776, 1344), Vector2(4416, 1472), Vector2(4928, 1344),
		Vector2(5568, 1472), Vector2(6080, 1472), Vector2(6720, 1344), Vector2(7232, 1472),
		Vector2(448, 1984), Vector2(960, 1984), Vector2(1472, 1856), Vector2(1984, 1856),
		Vector2(2624, 1856), Vector2(3264, 1856), Vector2(3776, 1856), Vector2(4416, 1856),
		Vector2(4928, 1856), Vector2(5568, 1856), Vector2(6080, 1856), Vector2(6720, 1856),
		Vector2(7232, 1856), Vector2(448, 2240), Vector2(960, 2240), Vector2(1472, 2240),
		Vector2(1984, 2240), Vector2(2624, 2112), Vector2(3264, 2240), Vector2(3776, 2240),
		Vector2(4416, 2240), Vector2(4928, 2240), Vector2(5568, 2112), Vector2(6080, 2240),
		Vector2(6720, 2240), Vector2(7232, 2240), Vector2(448, 2752), Vector2(960, 2752),
		Vector2(1472, 2752), Vector2(1984, 2752), Vector2(2624, 2624), Vector2(3264, 2752),
		Vector2(3776, 2752), Vector2(4416, 2752), Vector2(4928, 2752), Vector2(5568, 2880),
		Vector2(6080, 2752), Vector2(6720, 2752), Vector2(7232, 2752), Vector2(448, 3136),
		Vector2(960, 3136), Vector2(1472, 3136), Vector2(1984, 3136), Vector2(2624, 3136),
		Vector2(3136, 3136), Vector2(3776, 3136), Vector2(4416, 3136), Vector2(4928, 3264),
		Vector2(5440, 3136), Vector2(6080, 3136), Vector2(6720, 3264), Vector2(7232, 3136),
		Vector2(448, 3520), Vector2(1088, 3520), Vector2(1344, 3520), Vector2(1984, 3520),
		Vector2(2624, 3520), Vector2(3264, 3392), Vector2(3776, 3392), Vector2(4416, 3520),
		Vector2(4928, 3520), Vector2(5440, 3520), Vector2(6080, 3520), Vector2(6720, 3392),
		Vector2(7232, 3520), Vector2(448, 3904), Vector2(960, 3904), Vector2(1472, 3904),
		Vector2(2112, 3904), Vector2(2624, 3776), Vector2(3264, 3904), Vector2(3776, 3904),
		Vector2(4416, 3904), Vector2(4928, 3904), Vector2(5568, 3904), Vector2(6080, 3904),
		Vector2(6720, 3904), Vector2(7232, 3904), Vector2(448, 4288), Vector2(960, 4288),
		Vector2(1344, 4288), Vector2(2112, 4288), Vector2(2624, 4288), Vector2(3264, 4288),
		Vector2(3776, 4288), Vector2(4416, 4160), Vector2(4800, 4288), Vector2(5440, 4288),
		Vector2(6080, 4288), Vector2(6720, 4288), Vector2(7232, 4288), Vector2(448, 4672),
		Vector2(960, 4544), Vector2(1472, 4544), Vector2(2112, 4544), Vector2(2624, 4544),
		Vector2(3136, 4544), Vector2(3776, 4544), Vector2(4416, 4544), Vector2(4928, 4544),
		Vector2(5440, 4672), Vector2(6080, 4672), Vector2(6720, 4672), Vector2(7232, 4672),
		Vector2(448, 5184), Vector2(960, 5184), Vector2(1472, 5184), Vector2(1984, 5184),
	],
	[
		Vector2(704, 576), Vector2(960, 320), Vector2(1856, 320), Vector2(2624, 320),
		Vector2(3392, 320), Vector2(4288, 320), Vector2(5056, 320), Vector2(5824, 320),
		Vector2(6720, 320), Vector2(7360, 320), Vector2(320, 704), Vector2(960, 576),
		Vector2(1856, 576), Vector2(2624, 576), Vector2(3392, 576), Vector2(4288, 576),
		Vector2(5056, 576), Vector2(5824, 576), Vector2(6720, 576), Vector2(7360, 576),
		Vector2(320, 1216), Vector2(1003, 1273), Vector2(1813, 1273), Vector2(2624, 1273),
		Vector2(3435, 1273), Vector2(4245, 1273), Vector2(5056, 1273), Vector2(5867, 1273),
		Vector2(6677, 1273), Vector2(7360, 1216), Vector2(320, 1856), Vector2(1003, 1813),
		Vector2(1813, 1813), Vector2(2624, 1813), Vector2(3435, 1813), Vector2(4245, 1813),
		Vector2(5056, 1813), Vector2(5867, 1813), Vector2(6677, 1813), Vector2(7360, 1856),
		Vector2(320, 2368), Vector2(1003, 2354), Vector2(1813, 2354), Vector2(2624, 2354),
		Vector2(3435, 2354), Vector2(4245, 2354), Vector2(5056, 2354), Vector2(5867, 2354),
		Vector2(6677, 2354), Vector2(7360, 2368), Vector2(320, 2880), Vector2(1003, 2894),
		Vector2(1813, 2894), Vector2(2624, 2894), Vector2(3435, 2894), Vector2(4245, 2894),
		Vector2(5056, 2894), Vector2(5867, 2894), Vector2(6677, 2894), Vector2(7360, 2880),
		Vector2(320, 3392), Vector2(960, 3520), Vector2(1856, 3520), Vector2(2624, 3520),
		Vector2(3392, 3520), Vector2(4288, 3520), Vector2(5056, 3520), Vector2(5824, 3520),
		Vector2(6720, 3520), Vector2(7360, 3520), Vector2(320, 4160), Vector2(960, 4160),
		Vector2(1856, 4160), Vector2(2624, 4160), Vector2(3392, 4160), Vector2(4288, 4160),
		Vector2(5056, 4160), Vector2(5824, 4160), Vector2(6720, 4160), Vector2(7360, 4032),
		Vector2(320, 4544), Vector2(960, 4416), Vector2(1856, 4416), Vector2(2624, 4416),
		Vector2(3392, 4416), Vector2(4288, 4416), Vector2(5056, 4416), Vector2(5824, 4416),
		Vector2(6720, 4416), Vector2(7360, 4416), Vector2(320, 5056), Vector2(1003, 5056),
		Vector2(1813, 5056), Vector2(2624, 5056), Vector2(3435, 5056), Vector2(4245, 5056),
		Vector2(5056, 5056), Vector2(5867, 5056), Vector2(6677, 5056), Vector2(7360, 5056),
		Vector2(320, 5568), Vector2(1003, 5568), Vector2(1813, 5568), Vector2(2624, 5568),
		Vector2(3435, 5568), Vector2(4245, 5568), Vector2(5056, 5568), Vector2(5867, 5568),
		Vector2(6677, 5568), Vector2(7360, 5568), Vector2(320, 5952), Vector2(1003, 6009),
		Vector2(1813, 6009), Vector2(2624, 6009), Vector2(3435, 6009), Vector2(4245, 6009),
		Vector2(5056, 6009), Vector2(5696, 5952), Vector2(6677, 6009), Vector2(7360, 5952),
		Vector2(320, 6464), Vector2(1003, 6450), Vector2(1813, 6450), Vector2(2624, 6450),
		Vector2(3435, 6450), Vector2(4245, 6450), Vector2(5056, 6450), Vector2(5867, 6450),
		Vector2(6677, 6450), Vector2(7360, 6464), Vector2(320, 6848), Vector2(1003, 6891),
		Vector2(1813, 6891), Vector2(2624, 6891), Vector2(3435, 6891), Vector2(4245, 6891),
		Vector2(5056, 6891), Vector2(5867, 6891), Vector2(6677, 6891), Vector2(7360, 6848),
		Vector2(320, 7360), Vector2(1003, 7332), Vector2(1813, 7332), Vector2(2624, 7332),
		Vector2(3435, 7332), Vector2(4245, 7332), Vector2(5056, 7332), Vector2(5867, 7332),
		Vector2(6720, 7232), Vector2(7360, 7360), Vector2(320, 7744), Vector2(1003, 7772),
		Vector2(1813, 7772), Vector2(2624, 7772), Vector2(3435, 7772), Vector2(4245, 7772),
		Vector2(5056, 7772), Vector2(5867, 7772), Vector2(6592, 7744), Vector2(7360, 7744),
		Vector2(320, 8256), Vector2(1003, 8213), Vector2(1813, 8213), Vector2(2624, 8213),
		Vector2(3435, 8213), Vector2(4245, 8213), Vector2(5056, 8213), Vector2(5867, 8213),
		Vector2(6677, 8213), Vector2(7360, 8256), Vector2(320, 8640), Vector2(1003, 8654),
		Vector2(1984, 8640), Vector2(2624, 8654), Vector2(3435, 8654), Vector2(4245, 8654),
		Vector2(5056, 8654), Vector2(5867, 8654), Vector2(6677, 8654), Vector2(7360, 8640),
		Vector2(320, 9152), Vector2(1003, 9095), Vector2(1813, 9095), Vector2(2624, 9095),
		Vector2(3435, 9095), Vector2(4245, 9095), Vector2(5056, 9095), Vector2(5867, 9095),
		Vector2(6677, 9095), Vector2(7360, 9152), Vector2(320, 9408), Vector2(960, 9408),
		Vector2(1856, 9408), Vector2(2624, 9408), Vector2(3392, 9408), Vector2(4288, 9408),
		Vector2(5056, 9408), Vector2(5824, 9408), Vector2(6720, 9408), Vector2(7360, 9408),
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
