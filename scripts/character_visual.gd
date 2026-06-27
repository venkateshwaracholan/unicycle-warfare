extends Node2D

@export var color := Color.WHITE
@export var is_rider := false
@export var team_color := Color.RED

const SHORTS_COLOR := Color(0.45, 0.28, 0.16)
const WHEEL_SPOKE_COUNT := 18
const PROMINENT_SPOKE_COUNT := 3
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
	# Fine spokes first, then three bold spokes every 120 degrees.
	_draw_spokes(tire_inner)
	_draw_prominent_spokes(tire_inner)
	draw_arc(Vector2.ZERO, tire_inner - 0.8, 0, TAU, 48, Color(0.34, 0.34, 0.38), 1.2)
	draw_arc(Vector2.ZERO, tire_r, 0, TAU, 48, Color(0.12, 0.12, 0.14), tire_w)
	_draw_hub()

func _draw_hub() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.28, 0.28, 0.32))
	draw_arc(Vector2.ZERO, 6.2, 0, TAU, 24, Color(0.40, 0.40, 0.44), 1.4)
	draw_circle(Vector2.ZERO, 4.8, Color(0.22, 0.22, 0.26))
	draw_circle(Vector2.ZERO, 3.2, Color(0.48, 0.48, 0.52))

func _draw_spokes(tire_inner: float) -> void:
	# Traditional radial spokes: straight wires from hub flange to rim.
	const HUB_ATTACH := 5.5
	var rim_attach := tire_inner - 0.6
	var shadow := Color(0.32, 0.32, 0.36)
	var highlight := Color(0.56, 0.56, 0.60)
	var nipple := Color(0.50, 0.50, 0.54)

	for i in WHEEL_SPOKE_COUNT:
		var angle := _spoke_angle(i)
		var dir := Vector2(cos(angle), sin(angle))
		var from := dir * HUB_ATTACH
		var to := dir * rim_attach
		Shapes.capsule(self, from, to, 1.2, shadow)
		Shapes.capsule(self, from, to, 0.6, highlight)
		draw_circle(to, 0.8, nipple)

func _spoke_angle(index: int) -> float:
	return float(index) / float(WHEEL_SPOKE_COUNT) * TAU - PI * 0.5

func _prominent_spoke_angle(index: int) -> float:
	return float(index) / float(PROMINENT_SPOKE_COUNT) * TAU - PI * 0.5

func _draw_prominent_spokes(tire_inner: float) -> void:
	const HUB_ATTACH := 5.5
	var rim_attach := tire_inner - 0.6
	var shadow := Color(0.10, 0.10, 0.12)
	var highlight := Color(0.28, 0.28, 0.32)
	var nipple := Color(0.18, 0.18, 0.22)

	for i in PROMINENT_SPOKE_COUNT:
		var dir := Vector2(cos(_prominent_spoke_angle(i)), sin(_prominent_spoke_angle(i)))
		var from := dir * HUB_ATTACH
		var to := dir * rim_attach
		Shapes.capsule(self, from, to, 4.2, shadow)
		Shapes.capsule(self, from, to, 2.4, highlight)
		draw_circle(to, 1.4, nipple)

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
