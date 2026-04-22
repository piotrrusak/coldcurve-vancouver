extends Node

const SCAN_SPEED_DEG: float = 50.0

var last_known_pos: Vector2 = Vector2.ZERO
var _los_timer: float = 0.0

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")

func start():
	last_known_pos = _state.player.global_position
	_los_timer = _enemy.los_grace_period

func process(delta: float):
	var to_target := last_known_pos - _enemy.global_position
	if to_target.length() > 8.0:
		_enemy.global_position += to_target.normalized() * _enemy.strafe_speed * _enemy.in_investigate_speed_multiplier * delta
	else:
		_state.facing_angle += deg_to_rad(SCAN_SPEED_DEG * _state.strafe_dir * delta)
	if _state.player != null and _state.player.visible and _sight.player_in_sight():
		_state.enter_engage()
		return
	_los_timer -= delta
	if _los_timer <= 0.0:
		_state.enter_search()
