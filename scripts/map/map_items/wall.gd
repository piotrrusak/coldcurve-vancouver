extends StaticBody2D

@export var size: Vector2 = Vector2(100, 20)

func _ready():
	$CollisionShape2D.shape.size = size
	queue_redraw()

func _draw():
	draw_rect(Rect2(-size / 2, size), Color(0.4, 0.3, 0.2))
