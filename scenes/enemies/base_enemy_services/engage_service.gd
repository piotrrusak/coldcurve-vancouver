extends Node

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node
var _investigate: Node

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")
	_investigate = get_parent().get_node("InvestigateService")

func process(delta: float):
	var to_player: Vector2 = _state.player.global_position - _enemy.global_position
	_state.facing_angle = to_player.angle()
	_enemy.global_position += to_player.normalized().rotated(PI / 2.0) * _state.strafe_dir * _enemy.strafe_speed * delta
	if not _sight.player_in_sight():
		_investigate.start()
		_state.enter_investigate()
