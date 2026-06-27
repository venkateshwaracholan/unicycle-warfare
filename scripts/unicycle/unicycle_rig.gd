class_name UnicycleRig

## Lower body (pelvis + legs) = movement flip. Upper body = aim flip (sibling, not under MoveFacing).

const WHEEL_RADIUS := 22.0
const WHEEL_CIRCUMFERENCE := TAU * WHEEL_RADIUS
const WHEEL_HUB := Vector2(0, -22)
const RIDER_OFFSET_FROM_HUB := Vector2(0, -38)
const BALANCE_ANGLE_MIN := -PI * 0.5
const BALANCE_ANGLE_MAX := PI * 0.5
const RIDER_GROUND_PROBES := [Vector2(0, 14), Vector2(-10, 14), Vector2(10, 14)]

var wheel: Node2D
var wheel_visual: Node2D
var pedals: Node2D
var pelvis: Node2D
var pelvis_facing: Node2D
var pelvis_visual: Node2D
var upper_body: Node2D
var upper_visual: Node2D
var leg_back_pivot: Node2D
var leg_back_facing: Node2D
var leg_back: Node2D
var leg_front: Node2D
var muzzle: Marker2D

var rider: Node2D:
	get:
		return pelvis
var rider_visual: Node2D:
	get:
		return upper_visual

var facing := 1.0
var aim_facing := 1.0
var balance_angle := 0.0
var balance_angular_vel := 0.0
var wheel_spin := 0.0


static func bind(wheel_node: Node2D) -> UnicycleRig:
	var rig := UnicycleRig.new()
	rig.wheel = wheel_node
	rig.wheel_visual = wheel_node.get_node_or_null("Visual") as Node2D
	rig.pedals = wheel_node.get_node_or_null("Pedals") as Node2D
	rig.pelvis = wheel_node.get_node_or_null("Pelvis") as Node2D
	if rig.pelvis == null:
		rig.pelvis = wheel_node.get_node_or_null("Rider") as Node2D
	rig._bind_pelvis_chain()
	rig._bind_leg_back_chain(wheel_node)
	return rig


func _bind_pelvis_chain() -> void:
	if pelvis == null:
		return
	pelvis_facing = pelvis.get_node_or_null("MoveFacing") as Node2D
	var body_root: Node = pelvis_facing if pelvis_facing else pelvis
	pelvis_visual = body_root.get_node_or_null("PelvisVisual") as Node2D
	leg_front = body_root.get_node_or_null("LegFront") as Node2D
	upper_body = pelvis.get_node_or_null("UpperBody") as Node2D
	if upper_body == null:
		upper_body = body_root.get_node_or_null("UpperBody") as Node2D
	if upper_body:
		upper_visual = upper_body.get_node_or_null("Visual") as Node2D
		muzzle = upper_body.get_node_or_null("Muzzle") as Marker2D
	else:
		upper_visual = body_root.get_node_or_null("Visual") as Node2D
		muzzle = pelvis.get_node_or_null("Muzzle") as Marker2D


func _bind_leg_back_chain(wheel_node: Node2D) -> void:
	leg_back_pivot = wheel_node.get_node_or_null("LegBackPivot") as Node2D
	if leg_back_pivot:
		leg_back_facing = leg_back_pivot.get_node_or_null("MoveFacing") as Node2D
		if leg_back_facing:
			leg_back = leg_back_facing.get_node_or_null("LegBack") as Node2D
		else:
			leg_back = leg_back_pivot.get_node_or_null("LegBack") as Node2D
	else:
		leg_back = wheel_node.get_node_or_null("LegBack") as Node2D


func set_facing(direction: float) -> void:
	if absf(direction) < 0.01:
		return
	facing = signf(direction)
	sync_pose()


func set_aim_facing(direction: float) -> void:
	if absf(direction) < 0.01:
		return
	aim_facing = signf(direction)
	sync_pose()


func sync_pose() -> void:
	if not is_instance_valid(pelvis):
		return

	var pelvis_pos := WHEEL_HUB + RIDER_OFFSET_FROM_HUB.rotated(balance_angle)
	pelvis.position = pelvis_pos
	pelvis.rotation = balance_angle
	pelvis.scale = Vector2.ONE

	_apply_move_facing(pelvis_facing)

	if is_instance_valid(leg_back_pivot):
		leg_back_pivot.position = pelvis_pos
		leg_back_pivot.rotation = balance_angle
		leg_back_pivot.scale = Vector2.ONE
		_apply_move_facing(leg_back_facing)
	elif is_instance_valid(leg_back):
		leg_back.position = pelvis_pos
		leg_back.rotation = balance_angle
		leg_back.scale = Vector2.ONE
		_apply_move_facing(leg_back)

	if is_instance_valid(upper_body):
		upper_body.position = Vector2.ZERO
		upper_body.rotation = 0.0
		upper_body.scale = Vector2(aim_facing, 1.0)

	_sync_visuals()


func _apply_move_facing(node: Node2D) -> void:
	if not is_instance_valid(node):
		return
	node.scale = Vector2(facing, 1.0)
	node.rotation = 0.0
	node.position = Vector2.ZERO


func _sync_visuals() -> void:
	if is_instance_valid(pelvis_visual):
		pelvis_visual.queue_redraw()
	if is_instance_valid(upper_visual):
		upper_visual.queue_redraw()
	if is_instance_valid(leg_back):
		leg_back.queue_redraw()
	if is_instance_valid(leg_front):
		leg_front.queue_redraw()


func set_balance(angle: float, angular_vel: float = -999.0) -> void:
	balance_angle = angle
	if angular_vel > -900.0:
		balance_angular_vel = angular_vel
	sync_pose()


func enforce_balance_limits() -> void:
	var prev := balance_angle
	balance_angle = clampf(balance_angle, BALANCE_ANGLE_MIN, BALANCE_ANGLE_MAX)

	var sign := signf(balance_angle)
	if sign != 0.0 and _rider_lowest_wheel_local_y(balance_angle) > 0.0:
		var allowed := _max_balance_angle_for_ground(sign)
		if absf(balance_angle) > absf(allowed):
			balance_angle = allowed
			if signf(balance_angular_vel) == sign:
				balance_angular_vel = 0.0

	if balance_angle <= BALANCE_ANGLE_MIN + 0.001 and balance_angular_vel < 0.0:
		balance_angular_vel = 0.0
	elif balance_angle >= BALANCE_ANGLE_MAX - 0.001 and balance_angular_vel > 0.0:
		balance_angular_vel = 0.0
	elif not is_resting_on_ground_lean() \
			and signf(balance_angle - prev) != signf(balance_angular_vel) \
			and absf(balance_angle - prev) > 0.0001:
		balance_angular_vel = 0.0

	if wheel is RigidBody2D:
		var body := wheel as RigidBody2D
		body.angular_velocity = 0.0
		body.rotation = 0.0

	sync_pose()


func is_resting_on_ground_lean() -> bool:
	if absf(balance_angle) < 0.1:
		return false
	var sign := signf(balance_angle)
	var limit := absf(_max_balance_angle_for_ground(sign))
	return absf(balance_angle) >= limit - 0.05


func aim_direction(aim_offset_deg: float = -8.0) -> Vector2:
	return Vector2(aim_facing, 0.0).rotated(balance_angle + deg_to_rad(aim_offset_deg))


func get_muzzle_global() -> Vector2:
	if is_instance_valid(muzzle):
		return muzzle.global_position
	if is_instance_valid(upper_body):
		return upper_body.to_global(Vector2(26, -22))
	return wheel.global_position if wheel else Vector2.ZERO


func sync_wheel_spin(
	delta: float,
	wheel_world_x: float,
	last_wheel_x: float,
	in_place_lean: float,
	grounded: bool,
	pedal_intensity: float
) -> float:
	var dx := wheel_world_x - last_wheel_x
	if not grounded:
		_update_pedal_visual(delta, 0.0, false)
		return last_wheel_x
	if absf(dx) >= 0.0001:
		wheel_spin += TAU * (dx / WHEEL_CIRCUMFERENCE)
		if is_instance_valid(wheel_visual):
			wheel_visual.rotation = wheel_spin
	elif absf(in_place_lean) > 0.01:
		wheel_spin += in_place_lean * 7.0 * delta
	_update_pedal_visual(delta, pedal_intensity, true)
	return wheel_world_x


func reset_wheel_spin() -> void:
	wheel_spin = 0.0
	if is_instance_valid(wheel_visual):
		wheel_visual.rotation = 0.0
	if is_instance_valid(pedals):
		pedals.spin_angle = 0.0
		pedals.pedaling_intensity = 0.0


func redraw() -> void:
	if is_instance_valid(pedals):
		pedals.queue_redraw()
	_sync_visuals()


func rider_bar_anchor(root: Node2D) -> Vector2:
	var anchor: Node2D = upper_body if is_instance_valid(upper_body) else pelvis
	if not is_instance_valid(anchor) or root == null:
		return Vector2.ZERO
	return anchor.global_position - root.global_position + Vector2(-28, -72)


func wheel_contact_local_y() -> float:
	var max_y := 0.0
	for i in 9:
		var a := float(i) / 8.0 * PI
		var p := WHEEL_HUB + Vector2(cos(a), sin(a)) * WHEEL_RADIUS
		max_y = maxf(max_y, p.y)
	return max_y


func lowest_world_y(wheel_world_y: float) -> float:
	return wheel_world_y + wheel_contact_local_y()


func _update_pedal_visual(delta: float, pedal_intensity: float, grounded: bool) -> void:
	if not is_instance_valid(pedals):
		return
	pedals.spin_angle = wheel_spin
	var target := pedal_intensity if grounded else 0.0
	pedals.pedaling_intensity = lerpf(pedals.pedaling_intensity, target, 1.0 - exp(-14.0 * delta))
	redraw()


func _rider_lowest_wheel_local_y(angle: float) -> float:
	var rider_pos := WHEEL_HUB + RIDER_OFFSET_FROM_HUB.rotated(angle)
	var max_y := rider_pos.y
	for probe in RIDER_GROUND_PROBES:
		max_y = maxf(max_y, (rider_pos + probe.rotated(angle)).y)
	return max_y


func _max_balance_angle_for_ground(sign: float) -> float:
	var lo := 0.0
	var hi := PI * 0.5
	for _i in 10:
		var mid := (lo + hi) * 0.5
		if _rider_lowest_wheel_local_y(mid * sign) <= 0.0:
			lo = mid
		else:
			hi = mid
	return lo * sign
