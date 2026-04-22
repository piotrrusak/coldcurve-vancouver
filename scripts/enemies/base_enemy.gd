extends CharacterBody2D

signal enemy_hit

@export var strafe_speed: float = 180.0
@export var in_investigate_speed_multiplier: float = 2.0
@export var shoot_interval: float = 2.0
@export var fov: float = 60.0
@export var sight_range: float = 500.0
@export var los_grace_period: float = 5.0
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectiles/projectile.tscn")

@onready var _state       := $Services/StateService
@onready var _sight       := $Services/SightService
@onready var _search      := $Services/SearchService
@onready var _investigate := $Services/InvestigateService
@onready var _engage      := $Services/EngageService

func _ready():
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _process(delta):
	if _state.player == null or not _state.player.visible:
		_state.enter_search()
		_sight.update_cone()
		return

	match _state.state:
		StateService.State.SEARCH:
			_search.process(delta)
		StateService.State.INVESTIGATE:
			_investigate.process(delta)
		StateService.State.ENGAGE:
			_engage.process(delta)

	_sight.update_cone()

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
	projectile.linear_velocity = dir * projectile.base_speed
	get_parent().add_child(projectile)

func _on_area_entered(area):
	if area.is_in_group("player"):
		area.die()
		enemy_hit.emit()
