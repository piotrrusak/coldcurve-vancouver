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
@export var search_pause_duration: float = 4.0
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectiles/projectile.tscn")

@export var pathfinding_goal: Node = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var _state       := $Services/StateService
@onready var _sight       := $Services/SightService
@onready var _search      := $Services/SearchService
@onready var _investigate := $Services/InvestigateService
@onready var _engage      := $Services/EngageService


func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

	if sprite:
		sprite.play("idle")

	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

	$SightCone.visible = GameSettings.show_sight_cones

	if GameSettings.show_spawn_coords:
		var label := Label.new()
		label.text = "(%d, %d)" % [position.x, position.y]
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.position = Vector2(-40, -50)
		add_child(label)


func _physics_process(delta):
	if _state.player == null or not _state.player.visible:
		_state.enter_search()

		if GameSettings.show_sight_cones and Engine.get_physics_frames() % 3 == get_instance_id() % 3:
			_sight.update_cone()

		update_animation_from_velocity()
		move_and_slide()
		return

	match _state.state:
		StateService.State.SEARCH:
			_search.process(delta)

		StateService.State.INVESTIGATE:
			_investigate.process(delta)

		StateService.State.ENGAGE:
			_engage.process(delta)

	if GameSettings.show_sight_cones and Engine.get_physics_frames() % 3 == get_instance_id() % 3:
		_sight.update_cone()

	velocity *= GameSettings.enemy_speed_multiplier

	update_animation_from_velocity()
	move_and_slide()


func update_animation_from_velocity() -> void:
	if sprite == null:
		return

	if velocity.length() <= 0.1:
		return
		# Nie wracamy do idle.
		# Zostaje ostatnia animacja.

	if abs(velocity.x) > abs(velocity.y):
		sprite.play("walk_side")

		# Zakładam, że walk_side bazowo patrzy w prawo.
		sprite.flip_h = velocity.x < 0

	elif velocity.y > 0:
		sprite.flip_h = false
		sprite.play("walk_down")

	elif velocity.y < 0:
		sprite.flip_h = false
		sprite.play("walk_up")


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
	if area.is_in_group("player") and not GameSettings.immortality:
		area.die()
		enemy_hit.emit()


func die() -> void:
	enemy_hit.emit()
	queue_free()
