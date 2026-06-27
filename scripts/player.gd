extends Node2D

enum State { RIDING, RESPAWNING }

@export var player_id := 1
@export var team_color := Color(0.9, 0.25, 0.25)
@export var spawn_position := Vector2.ZERO

const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")
const Shapes := preload("res://scripts/draw_shapes.gd")
const UnicycleRig := preload("res://scripts/unicycle/unicycle_rig.gd")

const MAX_HEALTH := 100
const PEDAL_ACCEL := 16.0
const PEDAL_TURN_ACCEL := 40.0
const TURN_BRAKE := 150.0
const REVERSAL_SPEED_GATE := 5.0
const PEDAL_COAST := 7.0
const GRAVITY_LEAN := 4.0
const INERTIA_FROM_SPEED := 0.001
const INERTIA_FROM_ACCEL := 0.004
const INERTIA_ACCEL_STRESS_MIN := 0.08
const MOVE_TILT := 16.0
const MOVE_TILT_STRESS_MIN := 0.06
const TURN_STRESS_ACCEL_REF := 85.0
const BALANCE_SAFE_ANGLE := 0.13
const BALANCE_RECOVERY := 11.0
const BALANCE_RECOVERY_DAMP := 4.2
const GET_UP_LEAN_RATE := 20.0
const MG_RECOIL_BALANCE_RATE := 3.2
const MG_GET_UP_RECOIL_BOOST := 3.5
const BALANCE_DAMP := 1.0
const DEFAULT_WEAPON := WeaponDefs.Type.MINIGUN
const RECOIL_SCALE := 0.95
const KNOCKBACK_SCALE := 0.4
const REGEN_DELAY := 2.5
const REGEN_RATE := 8.0
const MAX_SPEED := 26.0
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
signal fell_over
signal recovered_from_fall
signal weapon_changed(weapon: WeaponDefs.Type)

var _is_fallen := false

func _ready() -> void:
	add_to_group("players")
	_weapon_user = WeaponUser.new(self, Faction.Id.PLAYER)
	_setup_input()
	global_position = spawn_position
	var arena := get_tree().get_first_node_in_group("arena")
	if arena:
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
	_rig.sync_pose()
	$Wheel/Pelvis/UpperBody/Visual.team_color = team_color
	wheel_visual.wheel_style = CharacterVisual.WheelStyle.MILITARY if player_id == 1 else CharacterVisual.WheelStyle.BMX
	if GameManager.is_play_mode():
		set_weapon_type(WeaponDefs.Type.MINIGUN)
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
	if loot.has_method("get_dropped_by") and loot.get_dropped_by() == player_id:
		if loot.has_method("get_drop_age") and loot.get_drop_age() < FallConsequences.DROP_COOLDOWN:
			return false
	return true

func on_weapon_pickup(_weapon: WeaponDefs.Type) -> void:
	_sync_weapon_visual()

func _wheel_spawn_pos() -> Vector2:
	return Vector2(spawn_position.x, _ground_y)

func _physics_process(delta: float) -> void:
	_weapon_user.tick(delta)
	_time_since_hit += delta

	global_position = wheel.global_position
	pickup_area.global_position = pelvis.global_position + Vector2(0, -20)

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
	queue_redraw()

func _apply_environment_forces(delta: float) -> void:
	var env := MapEnvironment.find_in_tree(get_tree())
	if env == null:
		return
	var sample := env.sample(wheel.global_position.x, wheel.global_position.y)
	var vx := wheel.linear_velocity.x
	vx = lerpf(vx, vx + float(sample.get("velocity_x", 0.0)), 1.0 - exp(-3.0 * delta))
	wheel.linear_velocity.x = clampf(vx, -MAX_SPEED * 1.15, MAX_SPEED * 1.15)
	var impulse_x: float = float(sample.get("impulse_x", 0.0))
	var impulse_y: float = float(sample.get("impulse_y", 0.0))
	if absf(impulse_x) > 0.01 or absf(impulse_y) > 0.01:
		wheel.apply_central_impulse(Vector2(impulse_x, impulse_y) * delta * 0.35)
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

	var vx := wheel.linear_velocity.x
	if _current_lean != 0.0:
		var target := _current_lean * MAX_SPEED
		var reversing := absf(vx) > REVERSAL_SPEED_GATE and signf(_current_lean) != signf(vx)
		if reversing:
			var bleed := minf(absf(vx), TURN_BRAKE * delta)
			vx -= signf(vx) * bleed
			# Bleed to a stop before accelerating the other way — avoids physics twitches.
			if absf(vx) > REVERSAL_SPEED_GATE:
				target = 0.0
		var rate := PEDAL_TURN_ACCEL
		if not reversing and absf(vx - target) < MAX_SPEED * 0.2:
			rate = PEDAL_ACCEL
		vx = _smooth_wheel_speed(vx, target, rate, delta)
	else:
		vx = _smooth_wheel_speed(vx, 0.0, PEDAL_COAST, delta)
	wheel.linear_velocity.x = clampf(vx, -MAX_SPEED, MAX_SPEED)

	_update_balance(delta)

func _smooth_wheel_speed(current: float, target: float, rate: float, delta: float) -> float:
	return lerpf(current, target, 1.0 - exp(-rate * delta))


func _compute_turn_stress(vx: float, ax: float) -> float:
	var stress := 0.0
	if _current_lean != 0.0 and absf(vx) > REVERSAL_SPEED_GATE and signf(_current_lean) != signf(vx):
		stress = maxf(stress, clampf(absf(vx) / MAX_SPEED, 0.35, 1.0))
	if _prev_lean != 0.0 and _current_lean != 0.0 and signf(_prev_lean) != signf(_current_lean):
		stress = maxf(stress, 0.8)
	if absf(ax) > 1.0:
		var accel_stress := clampf(absf(ax) / TURN_STRESS_ACCEL_REF, 0.0, 1.0)
		stress = maxf(stress, accel_stress * clampf(absf(_current_lean), 0.0, 1.0))
	_prev_lean = _current_lean
	return stress


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
	var vx := wheel.linear_velocity.x
	var ax := (vx - _last_vel_x) / maxf(delta, 0.001)
	_last_vel_x = vx

	var turn_stress := _compute_turn_stress(vx, ax)
	var accel_inertia_scale := lerpf(INERTIA_ACCEL_STRESS_MIN, 1.0, turn_stress)

	# Wheel right → rider falls left; wheel left → rider falls right.
	var inertia := -vx * INERTIA_FROM_SPEED - ax * INERTIA_FROM_ACCEL * accel_inertia_scale
	var tilt_scale := lerpf(MOVE_TILT_STRESS_MIN, 1.0, turn_stress) if _current_lean != 0.0 else 0.0
	var move_tilt := -_current_lean * MOVE_TILT * tilt_scale
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
		fell_over.emit()
	elif not fallen and _is_fallen:
		_is_fallen = false
		recovered_from_fall.emit()

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
	var local_low := _rig.wheel_contact_local_y()
	var pos := wheel.global_position
	pos.y = _ground_y - local_low
	wheel.global_position = pos
	var vel := wheel.linear_velocity
	vel.y = 0.0
	wheel.linear_velocity = vel

func _clamp_horizontal_speed() -> void:
	var vel := wheel.linear_velocity
	vel.x = clampf(vel.x, -MAX_SPEED, MAX_SPEED)
	wheel.linear_velocity = vel

func _update_body_collision() -> void:
	if body_collision:
		body_collision.disabled = true

func _on_wheel_body_entered(body: Node) -> void:
	if body is StaticBody2D and state == State.RIDING:
		var vel := wheel.linear_velocity
		vel.y = minf(vel.y, 0.0)
		wheel.linear_velocity = vel

func _stabilize_physics(delta: float) -> void:
	var vel := wheel.linear_velocity
	var pos := wheel.global_position
	_clamp_horizontal_speed()
	vel = wheel.linear_velocity

	if state == State.RIDING:
		_snap_to_ground()

	pos = wheel.global_position
	if pos.x < ARENA_MIN_X:
		pos.x = ARENA_MIN_X
		wheel.global_position = pos
		if wheel.linear_velocity.x < 0.0:
			wheel.linear_velocity.x = 0.0
	elif pos.x > ARENA_MAX_X:
		pos.x = ARENA_MAX_X
		wheel.global_position = pos
		if wheel.linear_velocity.x > 0.0:
			wheel.linear_velocity.x = 0.0

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
				wheel.apply_central_impulse(aim_dir * 80.0)
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

	wheel.apply_central_impulse(recoil_dir * force + Vector2(0, -lift))
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
	if _current_lean != 0.0:
		_rig.set_facing(_current_lean)
	elif absf(wheel.linear_velocity.x) > 6.0:
		_rig.set_facing(wheel.linear_velocity.x)


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
	wheel.apply_central_impulse(Vector2(randf_range(-20, 20), -35))
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
	wheel.linear_velocity = Vector2.ZERO
	_rig.set_balance(0.0, 0.0)
	_is_fallen = false
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

func apply_explosion_knockback(impulse: Vector2) -> void:
	var scaled := impulse * KNOCKBACK_SCALE
	wheel.apply_central_impulse(scaled)
	if state == State.RIDING:
		_rig.balance_angular_vel += scaled.x * 0.0012

func apply_harpoon_pull(from: Node2D, hit_pos: Vector2) -> void:
	var dir := (from.global_position - global_position).normalized()
	wheel.apply_central_impulse(dir * 280.0)

func apply_harpoon_recoil_pull(hit_pos: Vector2) -> void:
	var dir := (hit_pos - global_position).normalized()
	wheel.apply_central_impulse(dir * 200.0)

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
