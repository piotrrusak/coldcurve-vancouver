extends Node

const SCAN_SPEED_DEG: float = 50.0

var last_known_pos: Vector2 = Vector2.ZERO
var _los_timer: float = 0.0
var _arrived: bool = false

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node
var _engage: Node
var _nav: NavigationAgent2D

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")
	_engage = get_parent().get_node("EngageService")
	_nav = _enemy.get_node("NavigationAgent2D")

func start():
	last_known_pos = _state.player.global_position
	_los_timer = _enemy.los_grace_period
	_arrived = false
	_nav.target_desired_distance = 40.0
	_nav.target_position = last_known_pos

func process(delta: float):
	if _state.player != null and _state.player.visible and _sight.player_in_sight():
		_engage.start()
		_state.enter_engage()
		return

	if not _arrived:
		if _nav.is_navigation_finished():
			_arrived = true
			_enemy.velocity = Vector2.ZERO
		else:
			var next_pos := _nav.get_next_path_position()
			var dir := _enemy.global_position.direction_to(next_pos)
			_state.turn_toward(dir.angle(), delta)
			_enemy.velocity = dir * _enemy.movement_speed * 2.0
	else:
		_enemy.velocity = Vector2.ZERO
		_state.facing_angle += deg_to_rad(SCAN_SPEED_DEG * _state.strafe_dir * delta)

	_los_timer -= delta
	if _los_timer <= 0.0:
		_state.enter_search()
