extends Node2D

@export var pedal_index := 0
@export var draw_behind := false

const SEAT := Vector2(0, 4)
const HIP := SEAT
const THIGH_LEN := 27.0
const SHIN_LEN := 26.0
const THIGH_THICK := 9.0
const SHIN_THICK := 8.0
const SHOE_LENGTH := 14.0
const SHOE_HEIGHT := 6.0
const SHOE_HIT_LENGTH := 15.0
const SHOE_HIT_WIDTH := 8.0
const BEND_FORWARD := Vector2(1.0, 0.0)
const Shapes := preload("res://scripts/draw_shapes.gd")

@onready var _thigh_hit: CollisionShape2D = $LegHitbox/Thigh
@onready var _shin_hit: CollisionShape2D = $LegHitbox/Shin
@onready var _foot_hit: CollisionShape2D = $LegHitbox/Foot

func _ready() -> void:
	if _thigh_hit.shape:
		_thigh_hit.shape = _thigh_hit.shape.duplicate()
	if _shin_hit.shape:
		_shin_hit.shape = _shin_hit.shape.duplicate()
	if _foot_hit.shape:
		_foot_hit.shape = CapsuleShape2D.new()

func _physics_process(_delta: float) -> void:
	var leg := _solve_leg(_hip_anchor(), _pedal_local())
	_sync_capsule_hit(_thigh_hit, leg["hip"], leg["knee"], THIGH_THICK)
	_sync_capsule_hit(_shin_hit, leg["knee"], leg["foot"], SHIN_THICK)
	_sync_shoe_hit(_foot_hit, leg["pedal"], leg["knee"])

func _draw() -> void:
	var pedal_pos := _pedal_local()
	var hip := _hip_anchor()
	var leg := _solve_leg(hip, pedal_pos)
	_draw_leg_pose(leg)

func _hip_anchor() -> Vector2:
	return HIP

func _wheel() -> Node2D:
	var node := get_parent()
	if node is RigidBody2D:
		return node
	return node.get_parent()

func _pedal_local() -> Vector2:
	var wheel := _wheel()
	var pedals := wheel.get_node_or_null("Pedals")
	if not pedals or not pedals.has_method("get_pedal_positions_global"):
		return _hip_anchor() + Vector2(0, 20)
	var globals: Array = pedals.get_pedal_positions_global()
	return to_local(globals[pedal_index])

func _solve_leg(hip: Vector2, pedal: Vector2) -> Dictionary:
	var max_reach := THIGH_LEN + SHIN_LEN - 0.5
	var to_pedal := pedal - hip
	var dist := to_pedal.length()
	var aim := pedal
	if dist < 0.001:
		aim = hip + Vector2(max_reach * 0.45, max_reach * 0.55)
		to_pedal = aim - hip
		dist = to_pedal.length()
	elif dist > max_reach:
		aim = hip + to_pedal * (max_reach / dist)
		to_pedal = aim - hip
		dist = max_reach

	var dir := to_pedal / dist
	var cos_a := clampf(
		(THIGH_LEN * THIGH_LEN - SHIN_LEN * SHIN_LEN + dist * dist) / (2.0 * dist * THIGH_LEN),
		-1.0,
		1.0
	)
	var sin_a := sqrt(maxf(0.0, 1.0 - cos_a * cos_a))
	var perp := Vector2(-dir.y, dir.x)
	var cand_a := hip + (dir * cos_a + perp * sin_a) * THIGH_LEN
	var cand_b := hip + (dir * cos_a - perp * sin_a) * THIGH_LEN
	var knee := _pick_knee(hip, cand_a, cand_b)
	var shin_dir := aim - knee
	if shin_dir.length_squared() < 0.001:
		shin_dir = Vector2(1.0, 1.0)
	var foot := knee + shin_dir.normalized() * SHIN_LEN
	return {"hip": hip, "knee": knee, "foot": foot, "pedal": pedal}

func _pick_knee(hip: Vector2, cand_a: Vector2, cand_b: Vector2) -> Vector2:
	# Both legs bend to the right in rider-local space (Unicycle Hero style).
	var score_a := (cand_a - hip).dot(BEND_FORWARD)
	var score_b := (cand_b - hip).dot(BEND_FORWARD)
	if score_a >= 0.0 and score_b < 0.0:
		return cand_a
	if score_b >= 0.0 and score_a < 0.0:
		return cand_b
	return cand_a if score_a >= score_b else cand_b

func _draw_leg_pose(leg: Dictionary) -> void:
	var hip: Vector2 = leg["hip"]
	var knee: Vector2 = leg["knee"]
	var foot: Vector2 = leg["foot"]
	var pedal: Vector2 = leg["pedal"]
	var skin := Color(0.88, 0.72, 0.38) if draw_behind else Color(0.92, 0.78, 0.45)
	_draw_limb_block(hip, knee, THIGH_THICK, skin.darkened(0.05))
	_draw_limb_block(knee, foot, SHIN_THICK, skin)
	_draw_shoe(pedal, knee)

func _draw_limb_block(from: Vector2, to: Vector2, thickness: float, color: Color) -> void:
	Shapes.capsule(self, from, to, thickness, color)

func _draw_rounded_rect(rect: Rect2, fill: Color, radius: float = 2.0) -> void:
	Shapes.rounded_rect(self, rect, radius, fill)

func _shoe_tangent(pedal: Vector2, knee: Vector2) -> Vector2:
	var to_knee := knee - pedal
	if to_knee.length_squared() < 0.01:
		return Vector2.RIGHT
	return Vector2(-to_knee.y, to_knee.x).normalized()

func _draw_shoe(pedal: Vector2, knee: Vector2) -> void:
	if draw_behind:
		_draw_back_pedal(pedal)
	var tangent := _shoe_tangent(pedal, knee)
	var center := pedal + tangent * 2.0
	var angle := tangent.angle()
	var shoe := Color(0.15, 0.35, 0.68) if draw_behind else Color(0.22, 0.45, 0.82)
	draw_set_transform(center, angle, Vector2.ONE)
	_draw_rounded_rect(Rect2(-SHOE_LENGTH * 0.5, -SHOE_HEIGHT * 0.5, SHOE_LENGTH, SHOE_HEIGHT), shoe)
	_draw_rounded_rect(
		Rect2(-SHOE_LENGTH * 0.5, SHOE_HEIGHT * 0.5 - 2.0, SHOE_LENGTH, 2.0),
		Color(0.92, 0.92, 0.94)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_back_pedal(pedal: Vector2) -> void:
	var tangent := Vector2(1, 0)
	var wheel := _wheel()
	var pedals := wheel.get_node_or_null("Pedals") if wheel else null
	if pedals:
		var hub := to_local(pedals.get_hub_global())
		var radial := pedal - hub
		if radial.length_squared() > 0.01:
			tangent = Vector2(-radial.y, radial.x).normalized()
	var half := 6.0
	draw_line(pedal - tangent * half, pedal + tangent * half, Color(0.55, 0.5, 0.15), 4.0)
	draw_line(pedal - tangent * half, pedal + tangent * half, Color(0.78, 0.72, 0.28), 2.0)

func reset_pose() -> void:
	pass

func _sync_capsule_hit(node: CollisionShape2D, from: Vector2, to: Vector2, thickness: float) -> void:
	var delta := to - from
	var length := delta.length()
	if length < 2.0:
		node.disabled = true
		return
	node.disabled = false
	var capsule := node.shape as CapsuleShape2D
	if capsule == null:
		return
	capsule.radius = thickness * 0.5
	capsule.height = maxf(length - thickness, 2.0)
	node.position = from.lerp(to, 0.5)
	node.rotation = delta.angle() - PI * 0.5

func _sync_shoe_hit(node: CollisionShape2D, pedal: Vector2, knee: Vector2) -> void:
	var tangent := _shoe_tangent(pedal, knee)
	var center := pedal + tangent * 2.0
	var half := SHOE_HIT_LENGTH * 0.5
	_sync_capsule_hit(node, center - tangent * half, center + tangent * half, SHOE_HIT_WIDTH)
