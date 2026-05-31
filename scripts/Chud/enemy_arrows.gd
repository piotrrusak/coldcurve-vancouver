extends Node2D

var _total_enemies: int = 0
const ARROW_SIZE := 12.0
const MARGIN := 20.0

func setup(total: int) -> void:
	_total_enemies = total

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if _total_enemies == 0:
		return
	var enemies := get_tree().get_nodes_in_group("enemies")
	if float(enemies.size()) / float(_total_enemies) >= 0.1:
		return

	var viewport_size := get_viewport_rect().size
	var canvas_xform := get_viewport().get_canvas_transform()
	var center := viewport_size * 0.5

	for enemy in enemies:
		var screen_pos := canvas_xform * (enemy as Node2D).global_position
		var in_screen := (
			screen_pos.x >= 0 and screen_pos.x <= viewport_size.x and
			screen_pos.y >= 0 and screen_pos.y <= viewport_size.y
		)
		if in_screen:
			continue
		var dir := (screen_pos - center).normalized()
		var edge := _edge_point(center, dir, viewport_size)
		_draw_arrow(edge, dir)

func _edge_point(center: Vector2, dir: Vector2, vp: Vector2) -> Vector2:
	var m := MARGIN
	var min_t := INF
	if dir.x > 0:
		min_t = min(min_t, (vp.x - m - center.x) / dir.x)
	elif dir.x < 0:
		min_t = min(min_t, (m - center.x) / dir.x)
	if dir.y > 0:
		min_t = min(min_t, (vp.y - m - center.y) / dir.y)
	elif dir.y < 0:
		min_t = min(min_t, (m - center.y) / dir.y)
	return center + dir * min_t

func _draw_arrow(pos: Vector2, dir: Vector2) -> void:
	var perp := dir.rotated(PI * 0.5)
	var tip := pos + dir * ARROW_SIZE
	var b1 := pos - perp * (ARROW_SIZE * 0.5)
	var b2 := pos + perp * (ARROW_SIZE * 0.5)
	draw_colored_polygon(PackedVector2Array([tip, b1, b2]), Color.WHITE)
