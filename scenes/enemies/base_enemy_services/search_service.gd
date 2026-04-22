extends Node

const SCAN_SPEED_DEG: float = 50.0

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")

func process(delta: float):
	_state.facing_angle += deg_to_rad(SCAN_SPEED_DEG * _state.strafe_dir * delta)
	var move_dir := Vector2.RIGHT.rotated(_state.facing_angle + PI / 2.0)
	_enemy.global_position += move_dir * _enemy.strafe_speed * delta
	if _state.player != null and _state.player.visible and _sight.player_in_sight():
		_state.enter_engage()
