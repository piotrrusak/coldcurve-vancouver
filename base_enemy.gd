extends Area2D

signal enemy_hit

@export var strafe_speed: float = 180.0
@export var shoot_interval: float = 2.0
@export var projectile_scene: PackedScene = preload("res://projectile.tscn")

var _player: Node2D = null
var _strafe_dir: float = 1.0

func _ready():
	_player = get_tree().get_first_node_in_group("player")
	_strafe_dir = 1.0 if randf() > 0.5 else -1.0
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _process(delta):
	queue_redraw()
	if _player == null or not _player.visible:
		return
	var to_player = _player.global_position - global_position
	var strafe = to_player.normalized().rotated(PI / 2.0) * _strafe_dir
	global_position += strafe * strafe_speed * delta

func _draw():
	if _player == null or not _player.visible:
		return
	draw_line(Vector2.ZERO, _player.global_position - global_position, Color.RED, 1.5)

func _on_shoot_timer_timeout():
	if _player == null or not _player.visible:
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
