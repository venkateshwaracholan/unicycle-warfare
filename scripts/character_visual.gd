extends Node2D

@export var color := Color.WHITE
@export var is_rider := false
@export var is_pelvis := false
@export var team_color := Color.RED

var weapon_type: WeaponDefs.Type = WeaponDefs.Type.NONE

const SHORTS_COLOR := Color(0.45, 0.28, 0.16)
const SKIN_COLOR := Color(0.92, 0.78, 0.45)
const BEARD_COLOR := Color(0.40, 0.24, 0.12)
const BEARD_DARK := Color(0.28, 0.16, 0.08)
const HAT_COLOR := Color(0.15, 0.12, 0.1)
const WeaponVisual := preload("res://scripts/weapon_visual.gd")
const WIRE_SPOKE_COUNT := 20
const BLADE_SPOKE_COUNT := 3
const Shapes := preload("res://scripts/draw_shapes.gd")

func _draw() -> void:
	if is_pelvis:
		_draw_pelvis()
	elif is_rider:
		_draw_upper_body()
	else:
		_draw_wheel()

func _draw_pelvis() -> void:
	Shapes.rounded_rect(self, Rect2(-10, 0, 20, 8), 3.0, SHORTS_COLOR)

func _draw_wheel() -> void:
	var tire_r := 22.0
	var tire_w := 5.0
	var tire_inner := tire_r - tire_w * 0.5
	var rim_attach := tire_inner - 0.55
	var rim_bed := tire_inner - 1.05

	_draw_spoke_bed(rim_bed)
	_draw_wire_spokes(rim_attach)
	_draw_blade_spokes(rim_attach)
	_draw_rim(tire_inner, tire_r, tire_w, rim_bed)
	_draw_hub()

func _draw_spoke_bed(radius: float) -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(0.18, 0.18, 0.21), 2.4)

func _draw_rim(tire_inner: float, tire_r: float, tire_w: float, rim_bed: float) -> void:
	draw_arc(Vector2.ZERO, rim_bed + 0.35, 0, TAU, 48, Color(0.30, 0.30, 0.34), 1.0)
	draw_arc(Vector2.ZERO, tire_inner - 0.45, 0, TAU, 48, Color(0.58, 0.58, 0.62), 1.6)
	draw_arc(Vector2.ZERO, tire_r, 0, TAU, 48, Color(0.10, 0.10, 0.12), tire_w)
	draw_arc(Vector2.ZERO, tire_r - tire_w * 0.35, -PI * 0.42, PI * 0.12, 10, Color(0.20, 0.20, 0.22), 1.1)

func _draw_hub() -> void:
	draw_circle(Vector2.ZERO, 7.2, Color(0.24, 0.24, 0.28))
	draw_arc(Vector2.ZERO, 6.4, 0, TAU, 28, Color(0.42, 0.42, 0.46), 1.6)
	for i in BLADE_SPOKE_COUNT:
		var dir := Vector2(cos(_blade_spoke_angle(i)), sin(_blade_spoke_angle(i)))
		draw_circle(dir * 5.8, 1.1, Color(0.14, 0.14, 0.16))
	draw_circle(Vector2.ZERO, 4.6, Color(0.16, 0.16, 0.19))
	draw_circle(Vector2.ZERO, 2.8, Color(0.54, 0.54, 0.58))
	draw_circle(Vector2.ZERO, 1.2, Color(0.72, 0.72, 0.76))

func _draw_wire_spokes(rim_attach: float) -> void:
	const HUB_ATTACH := 5.6
	var front := Color(0.50, 0.50, 0.54)
	var rear := Color(0.36, 0.36, 0.40)
	var glint := Color(0.70, 0.70, 0.74)
	var nipple := Color(0.46, 0.46, 0.50)

	for i in WIRE_SPOKE_COUNT:
		var angle := _wire_spoke_angle(i)
		var dir := Vector2(cos(angle), sin(angle))
		var from := dir * HUB_ATTACH
		var to := dir * rim_attach
		var body := front if i % 2 == 0 else rear
		Shapes.capsule(self, from, to, 1.05, body)
		var glint_to := from.lerp(to, 0.88)
		Shapes.capsule(self, from.lerp(to, 0.08), glint_to, 0.45, glint)
		draw_circle(to, 0.75, nipple.darkened(0.08 if i % 2 else 0.0))

func _wire_spoke_angle(index: int) -> float:
	return float(index) / float(WIRE_SPOKE_COUNT) * TAU - PI * 0.5

func _blade_spoke_angle(index: int) -> float:
	return float(index) / float(BLADE_SPOKE_COUNT) * TAU - PI * 0.5

func _draw_blade_spokes(rim_attach: float) -> void:
	const HUB_ATTACH := 5.2
	var shadow := Color(0.06, 0.06, 0.08)
	var body := Color(0.11, 0.11, 0.13)
	var edge := Color(0.34, 0.34, 0.38)
	var rim_boss := Color(0.08, 0.08, 0.10)
	var rim_ring := Color(0.42, 0.42, 0.46)

	for i in BLADE_SPOKE_COUNT:
		var dir := Vector2(cos(_blade_spoke_angle(i)), sin(_blade_spoke_angle(i)))
		var from := dir * HUB_ATTACH
		var to := dir * rim_attach
		var light := Vector2(-dir.y, dir.x) * 0.55
		Shapes.capsule(self, from + dir * 0.25 + light * -0.15, to + light * -0.15, 5.2, shadow)
		Shapes.capsule(self, from, to, 4.6, body)
		Shapes.capsule(self, from + light * 0.22, to + light * 0.22, 1.35, edge)
		draw_circle(from, 1.5, body.lightened(0.06))
		draw_circle(to, 1.55, rim_boss)
		draw_arc(to, 1.35, 0, TAU, 12, rim_ring, 0.8)

func set_weapon(weapon: WeaponDefs.Type) -> void:
	weapon_type = weapon
	queue_redraw()


func _draw_upper_body() -> void:
	var hub_local := _hub_local()
	Shapes.rounded_rect(self, Rect2(-12, -30, 24, 38), 4.0, team_color)
	Shapes.rounded_rect(self, Rect2(-10, -48, 20, 18), 4.0, SKIN_COLOR)
	_draw_cowboy_face()
	_draw_cowboy_hat()
	_draw_seat_post(hub_local)
	_draw_arms_and_weapon()


func _draw_cowboy_hat() -> void:
	Shapes.rounded_rect(self, Rect2(-14, -54, 28, 8), 2.0, HAT_COLOR)
	Shapes.rounded_rect(self, Rect2(-8, -60, 16, 8), 3.0, HAT_COLOR)


func _draw_cowboy_face() -> void:
	_draw_eyes()
	_draw_mustache()
	_draw_beard()


func _draw_eyes() -> void:
	var eye_y := -44.5
	var eye_forward := 1.5
	var eye_positions := PackedVector2Array([
		Vector2(-3.0 + eye_forward, eye_y),
		Vector2(4.0 + eye_forward, eye_y),
	])
	for i in eye_positions.size():
		var center: Vector2 = eye_positions[i]
		var brow_tilt := -0.18 if i == 0 else 0.12
		draw_line(
			center + Vector2(-3.0, -4.0),
			center + Vector2(3.0, -4.0).rotated(brow_tilt),
			BEARD_DARK,
			1.6
		)
		draw_circle(center, 2.8, Color(0.98, 0.98, 0.96))
		var pupil: Vector2 = center + Vector2(1.2, 0.15)
		draw_circle(pupil, 1.4, Color(0.10, 0.08, 0.06))
		draw_circle(pupil + Vector2(0.3, -0.3), 0.4, Color(1.0, 1.0, 1.0, 0.7))


func _draw_mustache() -> void:
	var lip := Vector2(1.0, -37.0)
	draw_circle(lip, 2.0, BEARD_COLOR)
	var left_curl := PackedVector2Array([
		lip + Vector2(-1.0, 0.5),
		lip + Vector2(-5.5, 1.5),
		lip + Vector2(-8.0, 4.0),
		lip + Vector2(-6.5, 6.0),
		lip + Vector2(-3.0, 4.0),
	])
	var right_curl := PackedVector2Array([
		lip + Vector2(1.0, 0.5),
		lip + Vector2(5.0, 1.0),
		lip + Vector2(8.5, 3.0),
		lip + Vector2(7.0, 6.0),
		lip + Vector2(3.5, 4.0),
	])
	draw_colored_polygon(left_curl, BEARD_DARK)
	draw_colored_polygon(right_curl, BEARD_COLOR)


func _draw_beard() -> void:
	var chin := Vector2(0.5, -32.0)
	var fork := PackedVector2Array([
		chin + Vector2(-5.0, 0.0),
		chin + Vector2(-2.8, 8.0),
		chin + Vector2(-1.2, 10.0),
		chin + Vector2(0.0, 5.0),
		chin + Vector2(1.2, 10.0),
		chin + Vector2(2.8, 8.0),
		chin + Vector2(5.0, 0.0),
		chin + Vector2(2.5, -1.0),
		chin + Vector2(0.0, -0.5),
		chin + Vector2(-2.5, -1.0),
	])
	draw_colored_polygon(fork, BEARD_COLOR)


func _draw_arms_and_weapon() -> void:
	var hands := WeaponVisual.get_hand_positions(weapon_type)
	if weapon_type != WeaponDefs.Type.NONE:
		WeaponVisual.draw_hand(self, hands[0], SKIN_COLOR)
		WeaponVisual.draw_held(self, weapon_type)
		WeaponVisual.draw_hand(self, hands[1], SKIN_COLOR)
	else:
		for i in hands.size():
			WeaponVisual.draw_hand(self, hands[i], SKIN_COLOR)

func _hub_local() -> Vector2:
	var node: Node = get_parent()
	while node != null:
		if node is Node2D and (node as Node2D).has_node("Pedals"):
			var pedals := (node as Node2D).get_node_or_null("Pedals")
			if pedals and pedals.has_method("get_hub_global"):
				return to_local(pedals.get_hub_global())
			break
		node = node.get_parent()
	return Vector2(0, 38)

func _draw_seat_post(hub_local: Vector2) -> void:
	var seat := Vector2(0, 8)
	draw_line(seat, hub_local, Color(0.28, 0.28, 0.32), 5.0)
	draw_line(seat, hub_local, Color(0.45, 0.45, 0.5), 2.0)
