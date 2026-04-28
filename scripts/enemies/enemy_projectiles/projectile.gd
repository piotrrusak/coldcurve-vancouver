extends RigidBody2D

@export var base_speed = 500.0

func get_projectile_speed():
	var s = base_speed * GameSettings.bullet_speed_multiplier
	return Vector2(randf_range(s, s * 1.25), 0.0)

func _draw():
	# Triangle pointing forward (+X direction), rotated by parent
	# Todo: replace by sprite
	var points = PackedVector2Array([
		Vector2(20, 0),
		Vector2(-15, 13),
		Vector2(-15, -13)
	])
	draw_colored_polygon(points, Color.RED)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
