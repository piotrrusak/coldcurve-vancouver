extends Node

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node
var _investigate: Node
var _nav: NavigationAgent2D

var _needs_new_target: bool = true

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")
	_investigate = get_parent().get_node("InvestigateService")
	_nav = _enemy.get_node("NavigationAgent2D")

func start():
	_needs_new_target = true

func process(delta: float):
	var to_player: Vector2 = _state.player.global_position - _enemy.global_position
	_state.turn_toward(to_player.angle(), delta)

	if _needs_new_target:
		_nav.target_desired_distance = 40.0
		var perp: Vector2 = to_player.normalized().rotated(PI / 2.0)
		_nav.target_position = _state.player.global_position + perp * _state.strafe_dir * _enemy.strafe_distance
		_needs_new_target = false

	if _nav.is_navigation_finished():
		_state.strafe_dir *= -1.0
		_needs_new_target = true
		_enemy.velocity = Vector2.ZERO
	else:
		var next_pos := _nav.get_next_path_position()
		_enemy.velocity = _enemy.global_position.direction_to(next_pos) * _enemy.movement_speed * 1.5

	if not _sight.player_in_sight():
		_investigate.start()
		_state.enter_investigate()
