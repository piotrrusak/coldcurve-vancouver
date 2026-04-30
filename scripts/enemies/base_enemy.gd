extends CharacterBody2D

signal enemy_hit

@export var movement_speed: float = 180.0
@export var strafe_distance: float = 150.0
@export var shoot_interval: float = 0.5
@export var fov: float = 60.0
@export var sight_range: float = 500.0
@export var los_grace_period: float = 5.0
@export var search_accuracy: float = 64.0
@export var search_random_range: float = 300.0
@export var search_snap_threshold: float = 100.0
@export var turn_speed_deg: float = 240.0
@export var search_pause_interval_min: float = 3.0
@export var search_pause_interval_max: float = 8.0
# 1 full spin @ 90deg/s (default speed)
@export var search_pause_duration: float = 4.0
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectiles/projectile.tscn")

@export var pathfinding_goal: Node = null

@onready var _state       := $Services/StateService
@onready var _sight       := $Services/SightService
@onready var _search      := $Services/SearchService
@onready var _investigate := $Services/InvestigateService
@onready var _engage      := $Services/EngageService

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _physics_process(delta):
	if _state.player == null or not _state.player.visible:
		_state.enter_search()
		_sight.update_cone()
		move_and_slide()
		return

	match _state.state:
		StateService.State.SEARCH:
			_search.process(delta)
		StateService.State.INVESTIGATE:
			_investigate.process(delta)
		StateService.State.ENGAGE:
			_engage.process(delta)

	_sight.update_cone()
	velocity *= GameSettings.enemy_speed_multiplier
	move_and_slide()

func _on_shoot_timer_timeout():
	if _state.state != StateService.State.ENGAGE:
		return
	if _state.player == null or not _state.player.visible:
		return
	if not _sight.player_in_sight():
		return
	var projectile := projectile_scene.instantiate()
	var dir: Vector2 = (_state.player.global_position - global_position).normalized()
	projectile.global_position = global_position
	projectile.rotation = dir.angle()
	projectile.linear_velocity = dir * projectile.base_speed * GameSettings.bullet_speed_multiplier
	get_parent().add_child(projectile)

func _on_area_entered(area):
	if area.is_in_group("player"):
		area.die()
		enemy_hit.emit()
