extends Node

@export var projectileScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over() -> void:
	$BuletTimer.stop()
	
func new_game() -> void:
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_start_timer_timeout() -> void:
	$BuletTimer.start()


func _on_bulet_timer_timeout() -> void:
	var bullet = projectileScene.instantiate()
	
	var bullet_spawn_location = $ProjectilePath/BulletSpawnLocation
	bullet_spawn_location.progress_ratio = randf()
	
	bullet.position = bullet_spawn_location.position
	
	var direction = bullet_spawn_location.rotation + PI / 2
	
	direction += randf_range(-PI / 4, PI / 4)
	bullet.rotation = direction
	
	var speed = bullet.base_projectile_speed
	
	var velocity = Vector2(randf_range(speed - 100, speed + 100), 0.0)
	bullet.linear_velocity = velocity.rotated(direction)
	
	add_child(bullet)
