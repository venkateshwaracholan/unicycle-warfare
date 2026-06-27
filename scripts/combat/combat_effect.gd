extends Node2D

var _kind := "muzzle"
var _dir := Vector2.RIGHT
var _life := 0.0
var _max_life := 0.12
var _velocity := Vector2.ZERO
var _size := 1.0
var _color := Color.WHITE


func setup(kind: String, pos: Vector2, direction: Vector2 = Vector2.RIGHT, size: float = 1.0, color: Color = Color.WHITE) -> void:
	_kind = kind
	global_position = pos
	_dir = direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	_size = size
	_color = color
	match kind:
		"muzzle":
			_max_life = 0.09
		"impact":
			_max_life = 0.22
		"explosion":
			_max_life = 0.48
		"smoke":
			_max_life = 0.55
		"casing":
			_max_life = 0.75
			_velocity = Vector2(_dir.y, -_dir.x) * randf_range(40.0, 90.0) + Vector2(0, -randf_range(60.0, 120.0))
		_:
			_max_life = 0.15
	z_index = 20


func _process(delta: float) -> void:
	_life += delta
	if _kind == "casing":
		global_position += _velocity * delta
		_velocity.y += 420.0 * delta
	queue_redraw()
	if _life >= _max_life:
		queue_free()


func _draw() -> void:
	var t := clampf(_life / _max_life, 0.0, 1.0)
	var fade := 1.0 - t
	match _kind:
		"muzzle":
			var tip := _dir * 14.0 * _size
			var perp := Vector2(-_dir.y, _dir.x)
			draw_colored_polygon(
				PackedVector2Array([
					tip,
					tip - _dir * 22.0 * _size + perp * 10.0 * _size,
					tip - _dir * 18.0 * _size,
					tip - _dir * 22.0 * _size - perp * 10.0 * _size,
				]),
				Color(1.0, 0.92, 0.45, fade)
			)
			draw_circle(tip - _dir * 6.0 * _size, 8.0 * _size, Color(1.0, 0.55, 0.15, fade * 0.85))
		"impact":
			for i in 6:
				var a := float(i) / 6.0 * TAU + _life * 8.0
				var spark := _dir.rotated(a) * (8.0 + t * 18.0) * _size
				draw_line(Vector2.ZERO, spark, Color(1.0, 0.85, 0.35, fade), 2.0)
			draw_circle(Vector2.ZERO, (4.0 + t * 10.0) * _size, Color(0.35, 0.28, 0.22, fade * 0.7))
		"explosion":
			var ring := lerpf(6.0, 52.0 * _size, t)
			draw_arc(Vector2.ZERO, ring, 0, TAU, 24, Color(1.0, 0.55, 0.12, fade * 0.65), 4.0)
			draw_circle(Vector2.ZERO, ring * 0.55, Color(1.0, 0.35, 0.08, fade * 0.35))
			for i in 8:
				var debris := Vector2(cos(float(i) * 0.9 + _life * 5.0), sin(float(i) * 1.1)) * ring * 0.8
				draw_rect(Rect2(debris - Vector2(2, 2), Vector2(4, 4)), Color(0.25, 0.22, 0.2, fade))
		"smoke":
			for i in 3:
				var puff := Vector2(sin(_life * 4.0 + i) * 6.0, -t * 24.0 - i * 8.0)
				draw_circle(puff, (10.0 + i * 4.0) * _size, Color(0.35, 0.32, 0.3, fade * 0.35))
		"casing":
			draw_rect(Rect2(-2.5, -1.5, 5, 3), Color(0.75, 0.62, 0.22, fade))
			draw_line(Vector2(-2, 0), Vector2(2, 0), Color(0.45, 0.38, 0.15, fade), 1.0)
