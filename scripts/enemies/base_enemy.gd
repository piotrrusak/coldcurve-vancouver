extends CharacterBody2D

signal enemy_hit

@export var strafe_speed: float = 180.0
@export var shoot_interval: float = 2.0
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectiles/projectile.tscn")

var _player: Node2D = null
var _strafe_dir: float = 1.0
var _aim_endpoint: Vector2 = Vector2.ZERO
var _has_los: bool = false

func _ready():
	_player = get_tree().get_first_node_in_group("player")
	_strafe_dir = 1.0 if randf() > 0.5 else -1.0
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _process(delta):
	queue_redraw()
	if _player == null or not _player.visible:
		_has_los = false
		return
	var to_player = _player.global_position - global_position
	var strafe = to_player.normalized().rotated(PI / 2.0) * _strafe_dir
	global_position += strafe * strafe_speed * delta

	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, _player.global_position)
	query.exclude = [self.get_rid()]
	query.collision_mask = 3  # walls (1) + player (2)
	var result = space.intersect_ray(query)
	if result.is_empty():
		_aim_endpoint = _player.global_position
		_has_los = false
	else:
		_aim_endpoint = result["position"]
		_has_los = result["collider"].is_in_group("player")

func _draw():
	if _player == null or not _player.visible:
		return
	draw_line(Vector2.ZERO, to_local(_aim_endpoint), Color.RED, 1.5)

func _on_shoot_timer_timeout():
	if _player == null or not _player.visible:
		return
	if not _has_los:
		return
	var projectile = projectile_scene.instantiate()
	var dir = (_player.global_position - global_position).normalized()
	projectile.global_position = global_position
	projectile.rotation = dir.angle()
	projectile.linear_velocity = dir * projectile.base_speed
	get_parent().add_child(projectile)

func _on_area_entered(area):
	if area.is_in_group("player"):
		area.die()
		enemy_hit.emit()
