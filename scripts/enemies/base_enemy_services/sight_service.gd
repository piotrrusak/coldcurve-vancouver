extends Node

const FOV_RAYS: int = 60

var _enemy: CharacterBody2D
var _state: Node
var _sight_cone: Polygon2D

func _ready():
	_enemy = get_parent().get_parent()
	_state = get_parent().get_node("StateService")
	_sight_cone = _enemy.get_node("SightCone")

func player_in_sight() -> bool:
	var to_player: Vector2 = _state.player.global_position - _enemy.global_position
	if to_player.length() > _enemy.sight_range:
		return false
	if abs(angle_difference(to_player.angle(), _state.facing_angle)) > deg_to_rad(_enemy.fov / 2.0):
		return false
	var space := _enemy.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(_enemy.global_position, _state.player.global_position)
	query.exclude = [_enemy.get_rid()]
	query.collision_mask = 3
	var result := space.intersect_ray(query)
	return not result.is_empty() and result["collider"].is_in_group("player")

func update_cone():
	var half_fov := deg_to_rad(_enemy.fov / 2.0)
	var space := _enemy.get_world_2d().direct_space_state
	var points: Array[Vector2] = [Vector2.ZERO]
	for i in range(FOV_RAYS + 1):
		var t := float(i) / float(FOV_RAYS)
		var ray_angle: float = _state.facing_angle - half_fov + t * deg_to_rad(_enemy.fov)
		var ray_end: Vector2 = _enemy.global_position + Vector2.RIGHT.rotated(ray_angle) * _enemy.sight_range
		var query := PhysicsRayQueryParameters2D.create(_enemy.global_position, ray_end)
		query.exclude = [_enemy.get_rid()]
		query.collision_mask = 1
		var result := space.intersect_ray(query)
		points.append(_enemy.to_local(result["position"] if not result.is_empty() else ray_end))
	_sight_cone.polygon = PackedVector2Array(points)
