extends Node

const SCAN_SPEED_DEG: float = 90.0

var _current_goal: Vector2
var _previous_goal: Vector2
var _initialized: bool = false
var _is_paused: bool = false
var _pause_remaining: float = 0.0

var _enemy: CharacterBody2D
var _state: Node
var _sight: Node
var _engage: Node
var _nav: NavigationAgent2D
var _pause_timer: Timer

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight = get_parent().get_node("SightService")
	_engage = get_parent().get_node("EngageService")
	_nav = _enemy.get_node("NavigationAgent2D")
	_pause_timer = _enemy.get_node("SearchPauseTimer")
	call_deferred("_init_goals")

func _init_goals():
	_previous_goal = _enemy.global_position
	if _enemy.pathfinding_goal != null:
		_current_goal = _enemy.pathfinding_goal.global_position
	else:
		_current_goal = _get_random_nav_point()
	_nav.target_desired_distance = _enemy.search_accuracy
	_nav.target_position = _current_goal
	_start_pause_interval()
	_initialized = true

func _start_pause_interval():
	_pause_timer.wait_time = randf_range(_enemy.search_pause_interval_min, _enemy.search_pause_interval_max)
	_pause_timer.start()

func _on_search_pause_timer_timeout():
	if _state.state != StateService.State.SEARCH:
		_start_pause_interval()
		return
	_is_paused = true
	_pause_remaining = _enemy.search_pause_duration

func process(delta: float):
	if not _initialized:
		return

	if _state.player != null and _state.player.visible and _sight.player_in_sight():
		_engage.start()
		_state.enter_engage()
		return

	_nav.target_desired_distance = _enemy.search_accuracy

	if _is_paused:
		_enemy.velocity = Vector2.ZERO
		_state.facing_angle += deg_to_rad(SCAN_SPEED_DEG * _state.strafe_dir * delta)
		_pause_remaining -= delta
		if _pause_remaining <= 0.0:
			_is_paused = false
			_start_pause_interval()
		return

	if _nav.is_navigation_finished():
		_pick_next_goal()
	else:
		var next_pos := _nav.get_next_path_position()
		var dir := _enemy.global_position.direction_to(next_pos)
		_state.turn_toward(dir.angle(), delta)
		_enemy.velocity = dir * _enemy.movement_speed

## Comment/Ascii arts by klaudiusz to explain the idea behind search routine
# Picks the next ping-pong waypoint.
#
# The sweep alternates sides, always overshooting the previous anchor:
#
#   C <~~~~~~~~~~~ A --------- B
#                  ^           ^
#             start pos    first target (pathfinding_goal)
#
# Arrive at B → next target C is past A  (ping_dir = B→A, candidate = A + dir * dist)
# Arrive at C → next target D is past B  (ping_dir = C→B, candidate = B + dir * dist)
# Arrive at D → next target E is past C  ... and so on.
#
#   C <~~ A ~~ D        E ~~ B ~~ F ...
#         ^                  ^
#      past A             past B
#
# If the projected candidate lands off the nav mesh (wall, void) it falls back
# to a fully random point anywhere on the map.
func _pick_next_goal():
	var ping_dir := (_previous_goal - _current_goal).normalized()
	var map := _nav.get_navigation_map()
	var next_goal := Vector2.ZERO
	var found := false

	for _i in range(8):
		var angle_offset := randf_range(-PI * 0.5, PI * 0.5)
		var distance := randf_range(_enemy.search_random_range * 0.4, _enemy.search_random_range)
		var candidate := _previous_goal + ping_dir.rotated(angle_offset) * distance
		var snapped := NavigationServer2D.map_get_closest_point(map, candidate)
		if snapped.distance_to(candidate) <= _enemy.search_snap_threshold and \
				snapped.distance_to(_current_goal) > _enemy.search_accuracy * 2.0:
			next_goal = snapped
			found = true
			break

	if not found:
		next_goal = _get_random_nav_point()

	_previous_goal = _current_goal
	_current_goal = next_goal
	_nav.target_position = _current_goal

func _get_random_nav_point() -> Vector2:
	var map := _nav.get_navigation_map()
	var regions := NavigationServer2D.map_get_regions(map)
	if regions.is_empty():
		return _enemy.global_position
	return NavigationServer2D.region_get_random_point(regions[0], _nav.navigation_layers, false)
