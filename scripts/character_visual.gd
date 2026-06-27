extends Node2D

@export var color := Color.WHITE
@export var is_rider := false
@export var team_color := Color.RED

const SHORTS_COLOR := Color(0.45, 0.28, 0.16)
const Shapes := preload("res://scripts/draw_shapes.gd")

func _draw() -> void:
	if is_rider:
		_draw_rider()
	else:
		_draw_wheel()

func _draw_wheel() -> void:
	var r := 22.0
	var inner := r - 9.0
	# Rim only — keep the center empty so the back leg shows through when layered behind.
	draw_arc(Vector2.ZERO, r, 0, TAU, 48, Color(0.12, 0.12, 0.14), 5.0)
	draw_arc(Vector2.ZERO, inner, 0, TAU, 48, Color(0.38, 0.38, 0.42), 2.0)
	draw_circle(Vector2.ZERO, 5, Color(0.45, 0.45, 0.5))
	for i in 4:
		var a := float(i) * PI * 0.5
		draw_line(Vector2.ZERO, Vector2(cos(a), sin(a)) * inner, Color(0.35, 0.35, 0.38), 2.0)

func _draw_rider() -> void:
	var hub_local := _hub_local()
	Shapes.rounded_rect(self, Rect2(-12, -30, 24, 38), 4.0, team_color)
	Shapes.rounded_rect(self, Rect2(-10, 0, 20, 8), 3.0, SHORTS_COLOR)
	Shapes.rounded_rect(self, Rect2(-10, -48, 20, 18), 4.0, Color(0.92, 0.78, 0.45))
	Shapes.rounded_rect(self, Rect2(-14, -54, 28, 8), 2.0, Color(0.15, 0.12, 0.1))
	Shapes.rounded_rect(self, Rect2(-8, -60, 16, 8), 3.0, Color(0.15, 0.12, 0.1))
	_draw_seat_post(hub_local)
	Shapes.rounded_rect(self, Rect2(8, -22, 18, 6), 2.0, Color(0.35, 0.35, 0.38))

func _hub_local() -> Vector2:
	var wheel := get_parent().get_parent()
	if not wheel:
		return Vector2(0, 38)
	var pedals := wheel.get_node_or_null("Pedals")
	if pedals:
		return to_local(pedals.get_hub_global())
	return Vector2(0, 38)

func _draw_seat_post(hub_local: Vector2) -> void:
	var seat := Vector2(0, 8)
	draw_line(seat, hub_local, Color(0.28, 0.28, 0.32), 5.0)
	draw_line(seat, hub_local, Color(0.45, 0.45, 0.5), 2.0)
