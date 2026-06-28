extends Node2D

enum State { RIDING, RESPAWNING }

@export var player_id := 1
@export var team_color := Color(0.9, 0.25, 0.25)
@export var spawn_position := Vector2.ZERO

const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")
const Shapes := preload("res://scripts/draw_shapes.gd")
const UnicycleRig := preload("res://scripts/unicycle/unicycle_rig.gd")

const MAX_HEALTH := 100
const SPEED_ACCEL := 340.0
const SPEED_BRAKE := 500.0
const SPEED_COAST := 105.0
const REVERSAL_CARRY_ABOVE := 0.48
const REVERSAL_CARRY_BRAKE := 0.24
const REVERSAL_SPEED_GATE := 40.0
const GRAVITY_LEAN := 4.0
const INERTIA_FROM_SPEED := 0.00085
const INERTIA_FROM_ACCEL := 0.004
const INERTIA_ACCEL_STRESS_MIN := 0.08
const MOVE_TILT := 25.0
const MOVE_TILT_STRESS_MIN := 0.18
const TURN_WOBBLE_SCALE := 0.92
const TURN_STRESS_ACCEL_REF := 85.0
const BALANCE_SAFE_ANGLE := 0.13
const BALANCE_RECOVERY := 11.0
const BALANCE_RECOVERY_DAMP := 4.2
const GET_UP_LEAN_RATE := 20.0
const MG_RECOIL_BALANCE_RATE := 3.2
const MG_GET_UP_RECOIL_BOOST := 3.5
const BALANCE_DAMP := 1.0
const DEFAULT_WEAPON := WeaponDefs.Type.ROCKET
const RECOIL_SCALE := 0.95
const REGEN_DELAY := 2.5
const REGEN_RATE := 8.0
const MAX_SPEED := 200.0
const ARENA_MIN_X := 100.0
const ARENA_MAX_X := 1180.0

var health := MAX_HEALTH
var state := State.RIDING
var weapon_type: WeaponDefs.Type = WeaponDefs.Type.NONE
var _weapon_user: WeaponUser
var _rig: UnicycleRig
var _current_lean := 0.0
var _time_since_hit := REGEN_DELAY
var _respawn_timer := 0.0
var _ground_y := 490.0
var _last_wheel_x := 0.0
var _move_vx := 0.0
var _last_vel_x := 0.0
var _prev_lean := 0.0
var _sustained_balance_push := 0.0

@onready var wheel: RigidBody2D = $Wheel
@onready var wheel_visual: CharacterVisual = $Wheel/Visual
@onready var pedals: Node2D = $Wheel/Pedals
@onready var pelvis: Node2D = $Wheel/Pelvis
@onready var upper_body: Node2D = $Wheel/Pelvis/UpperBody
@onready var rider_visual: Node2D = $Wheel/Pelvis/UpperBody/Visual
@onready var leg_back: Node2D = $Wheel/LegBackPivot/MoveFacing/LegBack
@onready var leg_front: Node2D = $Wheel/Pelvis/MoveFacing/LegFront
@onready var body_collision: CollisionShape2D = $Wheel/BodyCollision
@onready var pickup_area: Area2D = $PickupArea
@onready var muzzle: Marker2D = $Wheel/Pelvis/UpperBody/Muzzle

var _lean_back_action: String
var _lean_forward_action: String
var _shoot_action: String
var _aim_left_action: String
var _aim_right_action: String

signal eliminated(victim: Node2D, killer: Node2D)
signal health_changed(current: int, maximum: int)
signal fell_over(is_crash: bool)
signal recovered_from_fall
signal weapon_changed(weapon: WeaponDefs.Type)

var _is_fallen := false
var _explosion_impact_meter := 0.0
var _ground_bounce_timer := 0.0
var last_fall_message := ""

func _ready() -> void:
	add_to_group("players")
	_weapon_user = WeaponUser.new(self, Faction.Id.PLAYER)
	_setup_input()
	global_position = spawn_position
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena:
		if arena.mission_level:
			_ground_y = arena.ground_surface_at(spawn_position.x)
		else:
			_ground_y = arena.ground_surface_y()
	wheel.global_position = _wheel_spawn_pos()
	_last_wheel_x = wheel.global_position.x
	_rig = UnicycleRig.bind(wheel)
	_rig.facing = -1.0 if player_id == 2 else 1.0
	_rig.aim_facing = _rig.facing
	_snap_to_ground()
	wheel.lock_rotation = true
	wheel.angular_damp = 0.0
	wheel.linear_damp = 0.0
	wheel.max_contacts_reported = 4
	wheel.contact_monitor = true
	wheel.body_entered.connect(_on_wheel_body_entered)
	wheel.top_level = true
	_rig.sync_pose()
	$Wheel/Pelvis/UpperBody/Visual.team_color = team_color
	wheel_visual.wheel_style = CharacterVisual.WheelStyle.MILITARY if player_id == 1 else CharacterVisual.WheelStyle.BMX
	if GameManager.is_play_mode():
		set_weapon_type(DEFAULT_WEAPON)
	elif GameManager.current_mode == GameManager.Mode.GUN_GAME:
		set_weapon_type(GameManager.get_gun_game_weapon(player_id))
	elif weapon_type == WeaponDefs.Type.NONE:
		set_weapon_type(DEFAULT_WEAPON)
	else:
		_emit_weapon_changed()
	health_changed.emit(health, MAX_HEALTH)

func _setup_input() -> void:
	if player_id == 1:
		_lean_back_action = "pedal_left"
		_lean_forward_action = "pedal_right"
		_shoot_action = "shoot"
		_aim_left_action = "aim_left"
		_aim_right_action = "aim_right"
	else:
		_lean_back_action = "p2_pedal_left"
		_lean_forward_action = "p2_pedal_right"
		_shoot_action = "p2_shoot"
		_aim_left_action = "p2_aim_left"
		_aim_right_action = "p2_aim_right"

func get_player_id() -> int:
	return player_id


func get_facing() -> float:
	return _rig.facing if _rig else 1.0


func get_aim_facing() -> float:
	return _rig.aim_facing if _rig else 1.0

func get_faction() -> Faction.Id:
	return Faction.Id.PLAYER

func get_weapon_type() -> WeaponDefs.Type:
	return _weapon_user.get_weapon_type() if _weapon_user else weapon_type

func set_weapon_type(weapon: WeaponDefs.Type) -> void:
	_weapon_user.set_weapon_type(weapon)

func get_weapon_muzzle_global() -> Vector2:
	return _rig.get_muzzle_global() if _rig else muzzle.global_position

func can_pickup_loot(loot: Node) -> bool:
	if loot.has_method("is_pickupable") and not loot.is_pickupable():
		return false
	if loot.has_method("get_dropped_by") and loot.get_dropped_by() == player_id:
		if loot.has_method("get_drop_age") and loot.get_drop_age() < FallConsequences.DROP_COOLDOWN:
			return false
	return true

func on_weapon_pickup(_weapon: WeaponDefs.Type) -> void:
	_sync_weapon_visual()

func _wheel_spawn_pos() -> Vector2:
	return Vector2(spawn_position.x, _ground_y)


func _refresh_ground_height() -> void:
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena == null:
		return
	if arena.mission_level:
		_ground_y = arena.ground_surface_at(wheel.global_position.x)
	else:
		_ground_y = arena.ground_surface_y()


func _arena_bounds() -> Vector2:
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena and arena.mission_level:
		return Vector2(arena.world_left() + 20.0, arena.world_right() - 20.0)
	return Vector2(ARENA_MIN_X, ARENA_MAX_X)

func _physics_process(delta: float) -> void:
	_weapon_user.tick(delta)
	_time_since_hit += delta

	_explosion_impact_meter = FallConsequences.decay_explosion_meter(_explosion_impact_meter, delta)
	_ground_bounce_timer = maxf(0.0, _ground_bounce_timer - delta)

	if state == State.RIDING and health < MAX_HEALTH and _time_since_hit >= REGEN_DELAY:
		health = mini(MAX_HEALTH, health + int(REGEN_RATE * delta))
		health_changed.emit(health, MAX_HEALTH)

	match state:
		State.RIDING:
			_process_riding(delta)
			_apply_environment_forces(delta)
		State.RESPAWNING:
			_respawn_timer -= delta
			if _respawn_timer <= 0.0:
				_finish_respawn()

	_try_pickup_weapon()
	_update_body_collision()
	_stabilize_physics(delta)
	_last_wheel_x = _rig.sync_wheel_spin(
		delta,
		wheel.global_position.x,
		_last_wheel_x,
		_current_lean,
		_is_grounded(),
		absf(_current_lean) if state == State.RIDING else 0.0
	)
	global_position = wheel.global_position
	pickup_area.global_position = pelvis.global_position + Vector2(0, -20)
	queue_redraw()


func _clamp_move_vx() -> void:
	_move_vx = clampf(_move_vx, -MAX_SPEED, MAX_SPEED)


func _apply_wheel_impulse(impulse: Vector2) -> void:
	if wheel.mass <= 0.0:
		return
	_move_vx = clampf(_move_vx + impulse.x / wheel.mass, -MAX_SPEED, MAX_SPEED)
	var vel := wheel.linear_velocity
	vel.y += impulse.y / wheel.mass
	vel.x = 0.0
	wheel.linear_velocity = vel
	wheel.sleeping = false


func _apply_horizontal_move(delta: float) -> void:
	if absf(_move_vx) < 0.0001:
		return
	var pos := wheel.global_position
	pos.x += _move_vx * delta
	wheel.global_position = pos
	wheel.sleeping = false


func _stabilize_physics(delta: float) -> void:
	_clamp_move_vx()

	if state == State.RIDING:
		_refresh_ground_height()
		_snap_to_ground()
		_apply_horizontal_move(delta)

	var pos := wheel.global_position
	var bounds := _arena_bounds()
	if pos.x < bounds.x:
		pos.x = bounds.x
		wheel.global_position = pos
		if _move_vx < 0.0:
			_move_vx = 0.0
	elif pos.x > bounds.y:
		pos.x = bounds.y
		wheel.global_position = pos
		if _move_vx > 0.0:
			_move_vx = 0.0

	wheel.linear_velocity.x = 0.0
	_clamp_move_vx()

func _apply_environment_forces(delta: float) -> void:
	var env := MapEnvironment.find_in_tree(get_tree())
	if env == null:
		return
	var sample := env.sample(wheel.global_position.x, wheel.global_position.y)
	var vx := _move_vx
	vx = lerpf(vx, vx + float(sample.get("velocity_x", 0.0)), 1.0 - exp(-3.0 * delta))
	_move_vx = clampf(vx, -MAX_SPEED, MAX_SPEED)
	var impulse_x: float = float(sample.get("impulse_x", 0.0))
	var impulse_y: float = float(sample.get("impulse_y", 0.0))
	if absf(impulse_x) > 0.01 or absf(impulse_y) > 0.01:
		_apply_wheel_impulse(Vector2(impulse_x, impulse_y) * delta * 0.35)
	var push: float = float(sample.get("balance_push", 0.0))
	if absf(push) > 0.001:
		_rig.balance_angular_vel += push * delta


func _process_riding(delta: float) -> void:
	_current_lean = _read_lean()
	_update_move_facing()
	_update_aim_facing()
	wheel.lock_rotation = true

	if Input.is_action_pressed(_shoot_action):
		_try_attack()

	_process_sustained_recoil(delta)

	var vx := _move_vx
	var target := _pedal_speed_target(vx)
	_move_vx = clampf(_integrate_speed(vx, target, delta), -MAX_SPEED, MAX_SPEED)

	_update_balance(delta)

func _pedal_speed_target(vx: float) -> float:
	if _current_lean == 0.0:
		return 0.0
	if _is_wrong_way(vx):
		var t := 1.0 - clampf(absf(vx) / (MAX_SPEED * 0.28), 0.0, 1.0)
		return _current_lean * MAX_SPEED * t * t
	return _current_lean * MAX_SPEED


func _integrate_speed(vx: float, target: float, delta: float) -> float:
	var diff := target - vx
	if absf(diff) < 0.01:
		return target

	var braking := signf(vx) != 0.0 and signf(diff) != signf(vx)
	var rate: float
	if _current_lean == 0.0:
		rate = SPEED_COAST
	elif braking:
		rate = SPEED_BRAKE
		if absf(vx) > MAX_SPEED * REVERSAL_CARRY_ABOVE:
			var carry_t := clampf(
				(absf(vx) - MAX_SPEED * REVERSAL_CARRY_ABOVE) / (MAX_SPEED * 0.32),
				0.0,
				1.0
			)
			rate *= lerpf(1.0, REVERSAL_CARRY_BRAKE, carry_t)
	elif absf(vx) < MAX_SPEED * 0.14:
		rate = SPEED_ACCEL * lerpf(0.38, 1.0, absf(vx) / (MAX_SPEED * 0.14))
	else:
		rate = SPEED_ACCEL

	var step := minf(absf(diff), rate * delta)
	return vx + signf(diff) * step


func _is_wrong_way(vx: float) -> bool:
	return _current_lean != 0.0 and signf(_current_lean) != signf(vx) and absf(vx) > 1.0


func _is_reversing_pedal(vx: float) -> bool:
	return _is_wrong_way(vx) and absf(vx) > REVERSAL_SPEED_GATE


func _compute_turn_stress(vx: float) -> float:
	var stress := clampf(absf(_current_lean), 0.0, 1.0) * 0.26
	if _current_lean != 0.0 and absf(vx) > REVERSAL_SPEED_GATE and signf(_current_lean) != signf(vx):
		stress = maxf(stress, clampf(absf(vx) / MAX_SPEED, 0.35, 0.7))
	if _prev_lean != 0.0 and _current_lean != 0.0 and signf(_prev_lean) != signf(_current_lean):
		stress = maxf(stress, 0.7)
	_prev_lean = _current_lean
	return stress


func _pedal_tilt_scale(vx: float) -> float:
	if _current_lean == 0.0:
		return 0.0
	if _is_reversing_pedal(vx):
		return lerpf(MOVE_TILT_STRESS_MIN, 0.72, clampf(absf(vx) / MAX_SPEED, 0.35, 0.72))
	# Steady lean while pedaling — no ramp as wheel speed builds.
	return 0.48


func _safe_zone_factor() -> float:
	var angle := absf(_rig.balance_angle)
	if angle >= BALANCE_SAFE_ANGLE:
		return 0.0
	var t := 1.0 - angle / BALANCE_SAFE_ANGLE
	return t * t

func _update_balance(delta: float) -> void:
	var wdata := WeaponDefs.get_data(weapon_type)
	var weight: float = wdata["weight"]
	var weight_mult := 1.0 + weight * 0.45
	var vx := _move_vx
	var ax := (vx - _last_vel_x) / maxf(delta, 0.001)
	_last_vel_x = vx

	var turn_stress := _compute_turn_stress(vx)
	var accel_stress := 0.0
	if absf(ax) > 1.0:
		accel_stress = clampf(absf(ax) / TURN_STRESS_ACCEL_REF, 0.0, 0.55)
	var wobble_stress := maxf(turn_stress, accel_stress * clampf(absf(_current_lean), 0.0, 1.0))
	var accel_inertia_scale := lerpf(INERTIA_ACCEL_STRESS_MIN, 1.0, wobble_stress) * TURN_WOBBLE_SCALE

	# Wheel right → rider falls left; wheel left → rider falls right.
	var inertia := -vx * INERTIA_FROM_SPEED - clampf(ax, -TURN_STRESS_ACCEL_REF, TURN_STRESS_ACCEL_REF) * INERTIA_FROM_ACCEL * accel_inertia_scale
	var tilt_scale := _pedal_tilt_scale(vx)
	var move_tilt := -_current_lean * MOVE_TILT * tilt_scale * TURN_WOBBLE_SCALE
	# Gravity slowly tips the rider further in whatever direction they lean.
	var gravity := sin(_rig.balance_angle) * GRAVITY_LEAN * weight_mult
	var recovery := 0.0

	var safe := _safe_zone_factor()
	if safe > 0.001 and not _rig.is_resting_on_ground_lean():
		recovery += -_rig.balance_angle * BALANCE_RECOVERY * safe
		_rig.balance_angular_vel *= exp(-BALANCE_RECOVERY_DAMP * safe * delta)

	if _rig.is_resting_on_ground_lean():
		# Gravity fighting the ground cap zeros velocity and feels "stuck".
		if signf(gravity) == signf(_rig.balance_angle):
			gravity = 0.0
		# Move wheel toward the lean side (Q when fallen left, W when fallen right).
		if _current_lean != 0.0 and signf(_current_lean) == signf(_rig.balance_angle):
			recovery = -signf(_rig.balance_angle) * GET_UP_LEAN_RATE
		# Momentum in the fall direction makes it hard to stand back up.
		if signf(inertia) == signf(_rig.balance_angle):
			inertia *= 0.1

	_rig.balance_angular_vel += (inertia + move_tilt + gravity + recovery) * delta
	_rig.balance_angular_vel *= exp(-BALANCE_DAMP * delta)
	_rig.balance_angle += _rig.balance_angular_vel * delta
	_rig.enforce_balance_limits()
	_update_fall_state()

func _update_fall_state() -> void:
	var fallen := _rig.is_resting_on_ground_lean()
	if fallen and not _is_fallen:
		_is_fallen = true
		var is_crash := _classify_crash()
		_apply_fall_consequence(is_crash)
		fell_over.emit(is_crash)
	elif not fallen and _is_fallen:
		_is_fallen = false
		recovered_from_fall.emit()


func _classify_crash() -> bool:
	return FallConsequences.is_hard_crash(
		_rig.balance_angular_vel,
		Vector2(_move_vx, wheel.linear_velocity.y).length()
	)


func _apply_fall_consequence(is_crash: bool) -> void:
	var drop_from_explosion := FallConsequences.should_drop_weapon_from_explosion(_explosion_impact_meter)
	var result := FallConsequences.resolve_fall(self, is_crash, drop_from_explosion)
	_apply_fall_damage(int(result.get("damage", 0)))
	_explosion_impact_meter = 0.0
	last_fall_message = str(result.get("message", ""))


func apply_fall_bounce(bounce: Dictionary) -> void:
	if state != State.RIDING or _rig == null:
		return
	var fall_sign := signf(_rig.balance_angle)
	if fall_sign == 0.0:
		fall_sign = signf(_rig.facing)
	var up: float = bounce.get("up", FallConsequences.BOUNCE_UP_SOFT)
	var horiz_base: float = bounce.get("horiz_base", FallConsequences.BOUNCE_HORIZ_SOFT)
	var spin: float = float(bounce.get("spin", FallConsequences.BOUNCE_SPIN_SOFT)) * -fall_sign
	var horiz := -fall_sign * horiz_base + _move_vx * 0.25
	_apply_wheel_impulse(Vector2(horiz, -up))
	_rig.balance_angular_vel = spin
	_ground_bounce_timer = float(bounce.get("duration", FallConsequences.BOUNCE_TIME_SOFT))
	_rig.enforce_balance_limits()


func _apply_fall_damage(amount: int) -> void:
	if state != State.RIDING:
		return
	health = maxi(0, health - amount)
	_time_since_hit = 0.0
	health_changed.emit(health, MAX_HEALTH)
	if health <= 0:
		_start_respawn(null)

func _is_sustained_recoil_weapon() -> bool:
	return WeaponDefs.get_data(weapon_type).get("sustained_recoil", false)

func _process_sustained_recoil(delta: float) -> void:
	if absf(_sustained_balance_push) < 0.001:
		return

	var get_up_boost := 1.0
	if _rig.is_resting_on_ground_lean():
		var fall_sign := signf(_rig.balance_angle)
		var push_sign := signf(_sustained_balance_push)
		if push_sign != 0.0 and push_sign != fall_sign:
			get_up_boost = MG_GET_UP_RECOIL_BOOST

	_rig.balance_angular_vel += _sustained_balance_push * MG_RECOIL_BALANCE_RATE * get_up_boost * delta
	_rig.enforce_balance_limits()

	var decay := 1.0 if Input.is_action_pressed(_shoot_action) and _is_sustained_recoil_weapon() else 4.5
	_sustained_balance_push = lerpf(_sustained_balance_push, 0.0, decay * delta)


func _read_lean() -> float:
	var lean := 0.0
	if Input.is_action_pressed(_lean_back_action):
		lean -= 1.0
	if Input.is_action_pressed(_lean_forward_action):
		lean += 1.0
	return lean

func _is_grounded() -> bool:
	if _rig == null:
		return true
	return _rig.lowest_world_y(wheel.global_position.y) >= _ground_y - 12.0


func _snap_to_ground() -> void:
	if _rig == null:
		return
	var floor_y := _ground_y - _rig.wheel_contact_local_y()
	var pos := wheel.global_position
	var vel := wheel.linear_velocity
	var hopped := pos.y < floor_y - 3.0 and (_ground_bounce_timer > 0.0 or vel.y < -8.0)

	if hopped:
		wheel.linear_velocity = vel
		return

	if pos.y > floor_y:
		pos.y = floor_y
		vel.y = minf(vel.y, 0.0)
	elif _ground_bounce_timer <= 0.0:
		pos.y = floor_y
		vel.y = 0.0

	wheel.global_position = pos
	vel.x = 0.0
	wheel.linear_velocity = vel

func _update_body_collision() -> void:
	if body_collision:
		body_collision.disabled = true

func _on_wheel_body_entered(body: Node) -> void:
	if body is StaticBody2D and state == State.RIDING:
		var vel := wheel.linear_velocity
		vel.y = minf(vel.y, 0.0)
		wheel.linear_velocity = vel

func _try_pickup_weapon() -> bool:
	for area in pickup_area.get_overlapping_areas():
		if not area.has_method("get_weapon_type"):
			continue
		if not can_pickup_loot(area):
			continue
		var loot_weapon: WeaponDefs.Type = area.get_weapon_type()
		set_weapon_type(loot_weapon)
		on_weapon_pickup(loot_weapon)
		area.queue_free()
		return true
	return _weapon_user.try_pickup_nearby()


func _emit_weapon_changed() -> void:
	weapon_type = _weapon_user.get_weapon_type()
	weapon_changed.emit(weapon_type)
	_sync_weapon_visual()
	# Re-armed while still grounded — allow another fall-drop cycle.
	if weapon_type != WeaponDefs.Type.PISTOL and weapon_type != WeaponDefs.Type.NONE:
		_is_fallen = false


func _sync_weapon_visual() -> void:
	if rider_visual and rider_visual.has_method("set_weapon"):
		rider_visual.set_weapon(weapon_type)
	if is_instance_valid(muzzle):
		muzzle.position = WeaponVisual.get_muzzle_local(weapon_type)
	if _rig:
		_rig.redraw()

func _try_attack() -> void:
	var aim_dir := _rig.aim_direction()
	var result := _weapon_user.try_attack(aim_dir)
	if not result.get("fired", false):
		return
	var data := WeaponDefs.get_data(result.get("weapon_type", weapon_type))
	match result.get("category"):
		WeaponDefs.Category.MELEE:
			if result.get("melee_lunge", false):
				_apply_wheel_impulse(aim_dir * 80.0)
			_apply_recoil(-aim_dir, data)
		WeaponDefs.Category.THROWABLE, WeaponDefs.Category.RANGED:
			_apply_recoil(aim_dir, data)

func _apply_recoil(aim_dir: Vector2, data: Dictionary) -> void:
	var recoil_dir := -aim_dir.normalized()
	var mult := _recoil_multiplier(recoil_dir) * RECOIL_SCALE

	var force: float = data["recoil_force"] * mult
	var torque: float = data["recoil_torque"] * mult
	var lift: float = data["recoil_lift"] * mult

	if data.get("sustained_recoil", false):
		var sustain_scale := 0.00042 if weapon_type == WeaponDefs.Type.MINIGUN else 0.00024
		var sustain_cap := 7.0 if weapon_type == WeaponDefs.Type.MINIGUN else 4.0
		_sustained_balance_push += torque * signf(recoil_dir.x) * sustain_scale * RECOIL_SCALE * mult
		_sustained_balance_push = clampf(_sustained_balance_push, -sustain_cap, sustain_cap)
		return

	if weapon_type == WeaponDefs.Type.ROCKET and aim_dir.y > 0.5:
		force *= 0.5
		lift = -force * 0.6

	_apply_wheel_impulse(recoil_dir * force + Vector2(0, -lift))
	if state == State.RIDING:
		_rig.balance_angular_vel += torque * signf(recoil_dir.x) * 0.00065 * RECOIL_SCALE
		_rig.enforce_balance_limits()

func _recoil_multiplier(recoil_dir: Vector2) -> float:
	var brace := _current_lean * signf(recoil_dir.x)
	if brace > 0.25:
		return lerpf(1.0, 0.42, brace)
	if brace < -0.25:
		return lerpf(1.0, 1.55, absf(brace))
	return 1.0

func _update_move_facing() -> void:
	# Body/gun face pedal input immediately; wheel velocity may still carry the other way.
	if _current_lean != 0.0:
		_rig.set_facing(_current_lean)
	elif absf(_move_vx) > MAX_SPEED * 0.03:
		_rig.set_facing(_move_vx)


func _update_aim_facing() -> void:
	if Input.is_action_pressed(_aim_left_action):
		_rig.set_aim_facing(-1.0)
	elif Input.is_action_pressed(_aim_right_action):
		_rig.set_aim_facing(1.0)
	else:
		_rig.set_aim_facing(_rig.facing)


func take_damage(amount: int, from: Node2D = null) -> void:
	if state != State.RIDING:
		return
	amount = maxi(1, int(amount * 0.85))
	health -= amount
	_time_since_hit = 0.0
	health_changed.emit(health, MAX_HEALTH)
	_apply_wheel_impulse(Vector2(randf_range(-20, 20), -35))
	_rig.balance_angular_vel += randf_range(-1.8, 1.8)

	if health <= 0:
		_start_respawn(from)

func _start_respawn(killer: Node2D) -> void:
	state = State.RESPAWNING
	_respawn_timer = 1.8
	eliminated.emit(self, killer)
	GameManager.register_elimination(player_id, _killer_id(killer))

func _killer_id(killer: Node2D) -> int:
	if killer and killer.has_method("get_player_id"):
		return killer.get_player_id()
	return 0

func _finish_respawn() -> void:
	health = MAX_HEALTH
	global_position = spawn_position
	wheel.global_position = _wheel_spawn_pos()
	_last_wheel_x = wheel.global_position.x
	_move_vx = 0.0
	wheel.linear_velocity = Vector2.ZERO
	_rig.set_balance(0.0, 0.0)
	_is_fallen = false
	_explosion_impact_meter = 0.0
	_ground_bounce_timer = 0.0
	last_fall_message = ""
	_prev_lean = 0.0
	_sustained_balance_push = 0.0
	_last_vel_x = 0.0
	_rig.reset_wheel_spin()
	_rig.facing = -1.0 if player_id == 2 else 1.0
	_rig.aim_facing = _rig.facing
	_rig.sync_pose()
	if is_instance_valid(leg_back) and leg_back.has_method("reset_pose"):
		leg_back.reset_pose()
	if is_instance_valid(leg_front) and leg_front.has_method("reset_pose"):
		leg_front.reset_pose()
	_refresh_ground_height()
	_snap_to_ground()
	if GameManager.is_play_mode():
		set_weapon_type(WeaponDefs.Type.PISTOL)
	elif GameManager.current_mode == GameManager.Mode.GUN_GAME:
		set_weapon_type(GameManager.get_gun_game_weapon(player_id))
	elif weapon_type == WeaponDefs.Type.NONE:
		set_weapon_type(DEFAULT_WEAPON)
	else:
		_emit_weapon_changed()
	state = State.RIDING
	health_changed.emit(health, MAX_HEALTH)

func respawn_at_spawn() -> void:
	_finish_respawn()

func get_blast_sample_position() -> Vector2:
	if _rig and is_instance_valid(_rig.pelvis):
		return _rig.pelvis.global_position
	return wheel.global_position if is_instance_valid(wheel) else global_position


func receive_explosion_blast(
	blast_damage: int,
	falloff: float,
	knockback: float,
	push_dir: Vector2,
	is_owner: bool,
	owner: Node2D
) -> void:
	if state != State.RIDING:
		return
	var impulse := push_dir * knockback * falloff
	var scaled := FallConsequences.explosion_displacement(impulse)
	_apply_wheel_impulse(scaled)
	_rig.balance_angular_vel += scaled.x * 0.0012
	if FallConsequences.try_drop_weapon_on_explosion(self, impulse):
		last_fall_message = FallConsequences.get_status_message(true, true)
		_notify_combat_message(last_fall_message)
		_explosion_impact_meter = 0.0
	else:
		_explosion_impact_meter = FallConsequences.register_explosion_impact(
			_explosion_impact_meter,
			scaled.length()
		)
	if not is_owner:
		take_damage(int(blast_damage * falloff), owner)


func apply_explosion_knockback(impulse: Vector2) -> void:
	if state != State.RIDING:
		return
	var scaled := FallConsequences.explosion_displacement(impulse)
	_apply_wheel_impulse(scaled)
	_rig.balance_angular_vel += scaled.x * 0.0012
	if FallConsequences.try_drop_weapon_on_explosion(self, impulse):
		last_fall_message = FallConsequences.get_status_message(true, true)
		_notify_combat_message(last_fall_message)
		_explosion_impact_meter = 0.0
	else:
		_explosion_impact_meter = FallConsequences.register_explosion_impact(
			_explosion_impact_meter,
			scaled.length()
		)


func _notify_combat_message(text: String) -> void:
	var root := get_tree().current_scene
	if root and root.has_method("set_mission_message"):
		root.call("set_mission_message", text)

func apply_harpoon_pull(from: Node2D, hit_pos: Vector2) -> void:
	var dir := (from.global_position - global_position).normalized()
	_apply_wheel_impulse(dir * 280.0)

func apply_harpoon_recoil_pull(hit_pos: Vector2) -> void:
	var dir := (hit_pos - global_position).normalized()
	_apply_wheel_impulse(dir * 200.0)

func _draw() -> void:
	if not is_instance_valid(pelvis) or _rig == null:
		return
	var bar_pos := _rig.rider_bar_anchor(self)
	Shapes.rounded_rect(self, Rect2(bar_pos, Vector2(56, 7)), 3.0, Color(0.08, 0.08, 0.08, 0.85))
	var fill := 56.0 * (float(health) / MAX_HEALTH)
	var bar_color := team_color if health > 30 else Color(1, 0.35, 0.3)
	if fill > 0.0:
		Shapes.rounded_rect(self, Rect2(bar_pos, Vector2(fill, 7)), 3.0, bar_color)

	var font := ThemeDB.fallback_font
	var wdata := WeaponDefs.get_data(weapon_type)
	var status: String = wdata["name"]
	if state == State.RESPAWNING:
		status = "Respawning..."
	draw_string(font, bar_pos + Vector2(-8, -10), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if Input.is_key_pressed(KEY_H):
		draw_string(font, bar_pos + Vector2(-8, 18), wdata["desc"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.8))
