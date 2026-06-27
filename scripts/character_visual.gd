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
	var tire_r := 22.0
	var tire_w := 5.0
	var tire_inner := tire_r - tire_w * 0.5
	# Spokes first, then tire band covers the outer spoke ends at the rim.
	_draw_spokes(tire_inner)
	draw_arc(Vector2.ZERO, tire_r, 0, TAU, 48, Color(0.12, 0.12, 0.14), tire_w)
	draw_circle(Vector2.ZERO, 7, Color(0.32, 0.32, 0.36))
	draw_circle(Vector2.ZERO, 5, Color(0.45, 0.45, 0.5))

func _draw_spokes(tire_inner: float) -> void:
	# Six spokes from hub flange to the inner edge of the tire rubber.
	const SPOKE_COUNT := 6
	const HUB_RADIUS := 6.0
	var dark := Color(0.38, 0.38, 0.42)
	var light := Color(0.58, 0.58, 0.62)
	for i in SPOKE_COUNT:
		var angle := float(i) / float(SPOKE_COUNT) * TAU - PI * 0.5
		var dir := Vector2(cos(angle), sin(angle))
		var from := dir * HUB_RADIUS
		var to := dir * tire_inner
		draw_line(from, to, dark, 3.0)
		draw_line(from, to, light, 1.5)

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
