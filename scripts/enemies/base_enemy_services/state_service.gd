class_name StateService
extends Node

enum State { SEARCH, INVESTIGATE, ENGAGE }

const COLOR_SEARCH      := Color(0.9, 0.85, 0.2, 0.20)
const COLOR_INVESTIGATE := Color(1.0, 0.50, 0.1, 0.30)
const COLOR_ENGAGE      := Color(1.0, 0.15, 0.1, 0.38)

var state: State = State.SEARCH
var player: Node2D = null
var strafe_dir: float = 1.0
var facing_angle: float = 0.0

var _sight_cone: Polygon2D
var _enemy: CharacterBody2D

func _ready():
	_enemy = get_parent().get_parent()
	player = get_tree().get_first_node_in_group("player")
	strafe_dir = 1.0 if randf() > 0.5 else -1.0
	facing_angle = randf_range(0.0, TAU)
	_sight_cone = _enemy.get_node("SightCone")
	_sight_cone.color = COLOR_SEARCH

func turn_toward(target_angle: float, delta: float):
	var diff := angle_difference(facing_angle, target_angle)
	var max_step := deg_to_rad(_enemy.turn_speed_deg) * delta
	facing_angle += clamp(diff, -max_step, max_step)

func enter_search():
	state = State.SEARCH
	_sight_cone.color = COLOR_SEARCH

func enter_investigate():
	state = State.INVESTIGATE
	_sight_cone.color = COLOR_INVESTIGATE

func enter_engage():
	state = State.ENGAGE
	_sight_cone.color = COLOR_ENGAGE
