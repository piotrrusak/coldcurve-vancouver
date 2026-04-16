extends CharacterBody2D

signal hit

@export var speed = 400
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	hide()

const CIRCLE_RADIUS = 20.0
const BLADE_LENGTH = 75.0

func _draw():
	draw_circle(Vector2.ZERO, CIRCLE_RADIUS, Color.WHITE)
	var mouse_local = get_local_mouse_position()
	if mouse_local.length() < 1.0:
		return
	var dir = mouse_local.normalized()
	var perp = dir.rotated(PI / 2.0)
	# Tapered blade: wide at base (circle edge), pointed at tip
	var base = dir * CIRCLE_RADIUS
	var tip  = dir * (CIRCLE_RADIUS + BLADE_LENGTH)
	var p1 = base + perp * 5.0
	var p2 = base - perp * 5.0
	var p3 = tip  - perp * 1.0
	var p4 = tip  + perp * 1.0
	draw_colored_polygon(PackedVector2Array([p1, p2, p3, p4]), Color.CYAN)

func _physics_process(_delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1

	velocity = dir.normalized() * speed if dir.length() > 0 else Vector2.ZERO
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

func _process(_delta):
	var mouse_local = get_local_mouse_position()
	var dir = mouse_local.normalized() if mouse_local.length() > 1.0 else Vector2.RIGHT
	$Weapon.position = dir * (CIRCLE_RADIUS + BLADE_LENGTH / 2.0)
	$Weapon.rotation = dir.angle()
	queue_redraw()

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	$Weapon/CollisionShape2D.disabled = false

func die():
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	$Weapon/CollisionShape2D.set_deferred("disabled", true)

func _on_weapon_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.enemy_hit:
		body.enemy_hit.emit()
		body.queue_free()
