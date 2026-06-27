extends Node2D

enum State { RIDING, RESPAWNING }

@export var player_id := 1
@export var team_color := Color(0.9, 0.25, 0.25)
@export var spawn_position := Vector2.ZERO

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const GRENADE_SCENE := preload("res://scenes/grenade.tscn")
const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")

const MAX_HEALTH := 100
const WHEEL_RADIUS := 22.0
const WHEEL_CIRCUMFERENCE := TAU * WHEEL_RADIUS
const WHEEL_HUB := Vector2(0, -22)
const RIDER_OFFSET_FROM_HUB := Vector2(0, -38)
const PEDAL_ACCEL := 16.0
const PEDAL_TURN_ACCEL := 55.0
const TURN_BRAKE := 300.0
const PEDAL_COAST := 7.0
const GRAVITY_LEAN := 4.0
const INERTIA_FROM_SPEED := 0.001
const INERTIA_FROM_ACCEL := 0.006
const MOVE_TILT := 16.0
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
const BALANCE_ANGLE_MIN := -PI * 0.5
const BALANCE_ANGLE_MAX := PI * 0.5
const RIDER_GROUND_PROBES := [Vector2(0, 14), Vector2(-10, 14), Vector2(10, 14)]

var health := MAX_HEALTH
var state := State.RIDING
var weapon_type: WeaponDefs.Type = WeaponDefs.Type.NONE
var _fire_cooldown := 0.0
var _aim_angle := 0.0
var _current_lean := 0.0
var _wheel_spin := 0.0
var _time_since_hit := REGEN_DELAY
var _respawn_timer := 0.0
var _ground_y := 490.0
var _last_wheel_x := 0.0
var _last_vel_x := 0.0
var _balance_angle := 0.0
var _balance_angular_vel := 0.0
var _sustained_balance_push := 0.0

@onready var wheel: RigidBody2D = $Wheel
@onready var wheel_visual: Node2D = $Wheel/Visual
@onready var rider: Node2D = $Wheel/Rider
@onready var body_collision: CollisionShape2D = $Wheel/BodyCollision
@onready var pickup_area: Area2D = $PickupArea
@onready var muzzle: Marker2D = $Wheel/Rider/Muzzle

var _lean_back_action: String
var _lean_forward_action: String
var _shoot_action: String

signal eliminated(victim: Node2D, killer: Node2D)
signal health_changed(current: int, maximum: int)

func _ready() -> void:
	add_to_group("players")
	_setup_input()
	global_position = spawn_position
	var arena := get_tree().get_first_node_in_group("arena")
	if arena:
		_ground_y = arena.ground_surface_y()
	wheel.global_position = _wheel_spawn_pos()
	_last_wheel_x = wheel.global_position.x
	_snap_to_ground()
	wheel.lock_rotation = true
	wheel.angular_damp = 0.0
	wheel.linear_damp = 0.0
	wheel.max_contacts_reported = 4
	wheel.contact_monitor = true
	wheel.body_entered.connect(_on_wheel_body_entered)
	$Wheel/Rider/Visual.team_color = team_color
	if GameManager.current_mode == GameManager.Mode.GUN_GAME:
		weapon_type = GameManager.get_gun_game_weapon(player_id)
	elif weapon_type == WeaponDefs.Type.NONE:
		weapon_type = DEFAULT_WEAPON
	health_changed.emit(health, MAX_HEALTH)

func _setup_input() -> void:
	if player_id == 1:
		_lean_back_action = "pedal_left"
		_lean_forward_action = "pedal_right"
		_shoot_action = "shoot"
	else:
		_lean_back_action = "p2_pedal_left"
		_lean_forward_action = "p2_pedal_right"
		_shoot_action = "p2_shoot"

func get_player_id() -> int:
	return player_id

func _wheel_spawn_pos() -> Vector2:
	return Vector2(spawn_position.x, _ground_y)

func _physics_process(delta: float) -> void:
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	_time_since_hit += delta

	global_position = wheel.global_position
	pickup_area.global_position = rider.global_position

	if state == State.RIDING and health < MAX_HEALTH and _time_since_hit >= REGEN_DELAY:
		health = mini(MAX_HEALTH, health + int(REGEN_RATE * delta))
		health_changed.emit(health, MAX_HEALTH)

	match state:
		State.RIDING:
			_process_riding(delta)
		State.RESPAWNING:
			_respawn_timer -= delta
			if _respawn_timer <= 0.0:
				_finish_respawn()

	_try_pickup_weapon()
	_update_body_collision()
	_stabilize_physics(delta)
	_sync_wheel_spin(delta)
	_update_aim()
	queue_redraw()

func _process_riding(delta: float) -> void:
	_current_lean = _read_lean()
	wheel.lock_rotation = true

	if Input.is_action_pressed(_shoot_action):
		_try_attack()

	_process_sustained_recoil(delta)

	var vx := wheel.linear_velocity.x
	if _current_lean != 0.0:
		var target := _current_lean * MAX_SPEED
		var reversing := absf(vx) > 0.5 and signf(_current_lean) != signf(vx)
		if reversing:
			var bleed := minf(absf(vx), TURN_BRAKE * delta)
			vx -= signf(vx) * bleed
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

func _update_balance(delta: float) -> void:
	var wdata := WeaponDefs.get_data(weapon_type)
	var weight: float = wdata["weight"]
	var weight_mult := 1.0 + weight * 0.45
	var vx := wheel.linear_velocity.x
	var ax := (vx - _last_vel_x) / maxf(delta, 0.001)
	_last_vel_x = vx

	# Wheel right → rider falls left; wheel left → rider falls right.
	var inertia := -vx * INERTIA_FROM_SPEED - ax * INERTIA_FROM_ACCEL
	var move_tilt := -_current_lean * MOVE_TILT
	# Gravity slowly tips the rider further in whatever direction they lean.
	var gravity := sin(_balance_angle) * GRAVITY_LEAN * weight_mult
	var recovery := 0.0

	if _is_resting_on_ground_lean():
		# Gravity fighting the ground cap zeros velocity and feels "stuck".
		if signf(gravity) == signf(_balance_angle):
			gravity = 0.0
		# Move wheel toward the lean side (Q when fallen left, W when fallen right).
		if _current_lean != 0.0 and signf(_current_lean) == signf(_balance_angle):
			recovery = -signf(_balance_angle) * GET_UP_LEAN_RATE
		# Momentum in the fall direction makes it hard to stand back up.
		if signf(inertia) == signf(_balance_angle):
			inertia *= 0.1

	_balance_angular_vel += (inertia + move_tilt + gravity + recovery) * delta
	_balance_angular_vel *= exp(-BALANCE_DAMP * delta)
	_balance_angle += _balance_angular_vel * delta
	_apply_balance_angle()

func _is_sustained_recoil_weapon() -> bool:
	return WeaponDefs.get_data(weapon_type).get("sustained_recoil", false)

func _process_sustained_recoil(delta: float) -> void:
	if absf(_sustained_balance_push) < 0.001:
		return

	var get_up_boost := 1.0
	if _is_resting_on_ground_lean():
		var fall_sign := signf(_balance_angle)
		var push_sign := signf(_sustained_balance_push)
		if push_sign != 0.0 and push_sign != fall_sign:
			get_up_boost = MG_GET_UP_RECOIL_BOOST

	_balance_angular_vel += _sustained_balance_push * MG_RECOIL_BALANCE_RATE * get_up_boost * delta
	_apply_balance_angle()

	var decay := 1.0 if Input.is_action_pressed(_shoot_action) and _is_sustained_recoil_weapon() else 4.5
	_sustained_balance_push = lerpf(_sustained_balance_push, 0.0, decay * delta)

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

func _is_resting_on_ground_lean() -> bool:
	if absf(_balance_angle) < 0.1:
		return false
	var sign := signf(_balance_angle)
	var limit := absf(_max_balance_angle_for_ground(sign))
	return absf(_balance_angle) >= limit - 0.05

func _enforce_balance_limits() -> void:
	var prev := _balance_angle
	_balance_angle = clampf(_balance_angle, BALANCE_ANGLE_MIN, BALANCE_ANGLE_MAX)

	var sign := signf(_balance_angle)
	if sign != 0.0 and _rider_lowest_wheel_local_y(_balance_angle) > 0.0:
		var allowed := _max_balance_angle_for_ground(sign)
		if absf(_balance_angle) > absf(allowed):
			_balance_angle = allowed
			if signf(_balance_angular_vel) == sign:
				_balance_angular_vel = 0.0

	if _balance_angle <= BALANCE_ANGLE_MIN + 0.001 and _balance_angular_vel < 0.0:
		_balance_angular_vel = 0.0
	elif _balance_angle >= BALANCE_ANGLE_MAX - 0.001 and _balance_angular_vel > 0.0:
		_balance_angular_vel = 0.0
	elif not _is_resting_on_ground_lean() \
			and signf(_balance_angle - prev) != signf(_balance_angular_vel) \
			and absf(_balance_angle - prev) > 0.0001:
		_balance_angular_vel = 0.0

func _apply_balance_angle() -> void:
	_enforce_balance_limits()
	wheel.angular_velocity = 0.0
	wheel.rotation = 0.0
	rider.position = WHEEL_HUB + RIDER_OFFSET_FROM_HUB.rotated(_balance_angle)
	rider.rotation = _balance_angle

func _set_balance(angle: float, ang_vel: float = 0.0) -> void:
	_balance_angle = angle
	_balance_angular_vel = ang_vel
	_apply_balance_angle()

func _sync_wheel_spin(_delta: float) -> void:
	var x := wheel.global_position.x
	if not _is_grounded():
		_last_wheel_x = x
		return
	var dx := x - _last_wheel_x
	_last_wheel_x = x
	if absf(dx) < 0.0001:
		return
	# Rolling without slip: angle = arc_length / radius = dx / (2πr) × 2π
	_wheel_spin += TAU * (dx / WHEEL_CIRCUMFERENCE)
	wheel_visual.rotation = _wheel_spin

func _read_lean() -> float:
	var lean := 0.0
	if Input.is_action_pressed(_lean_back_action):
		lean -= 1.0
	if Input.is_action_pressed(_lean_forward_action):
		lean += 1.0
	return lean

func _is_grounded() -> bool:
	return _lowest_world_y() >= _ground_y - 12.0

func _wheel_contact_local_y() -> float:
	# Only the lower semicircle touches the ground.
	var max_y := 0.0
	for i in 9:
		var a := float(i) / 8.0 * PI
		var p := WHEEL_HUB + Vector2(cos(a), sin(a)) * WHEEL_RADIUS
		max_y = maxf(max_y, p.y)
	return max_y

func _lowest_local_y() -> float:
	return _wheel_contact_local_y()

func _lowest_world_y() -> float:
	return wheel.global_position.y + _lowest_local_y()

func _snap_to_ground() -> void:
	var local_low := _wheel_contact_local_y()
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
		if area.has_method("get_weapon_type"):
			weapon_type = area.get_weapon_type()
			area.queue_free()
			return true
	return false

func _try_attack() -> void:
	if _fire_cooldown > 0.0:
		return
	var data := WeaponDefs.get_data(weapon_type)
	match data["category"]:
		WeaponDefs.Category.MELEE:
			_do_melee(data)
		WeaponDefs.Category.THROWABLE:
			_throw_grenade(data)
		WeaponDefs.Category.RANGED:
			if weapon_type == WeaponDefs.Type.NONE:
				_do_melee(data)
			else:
				_do_ranged(data)

func _do_ranged(data: Dictionary) -> void:
	_fire_cooldown = data["fire_rate"]
	var base_dir := Vector2.RIGHT.rotated(_aim_angle)
	var pellets: int = data["pellets"]
	for i in pellets:
		var dir := base_dir.rotated(randf_range(-data["spread"], data["spread"]))
		var bullet := BULLET_SCENE.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.velocity = dir * data["bullet_speed"]
		bullet.damage = data["damage"]
		bullet.owner_player = self
		bullet.is_rocket = data.get("explosive", false)
		bullet.is_harpoon = data.get("harpoon", false)
		get_tree().current_scene.add_child(bullet)
	_apply_recoil(base_dir, data)

func _do_melee(data: Dictionary) -> void:
	_fire_cooldown = data["fire_rate"]
	var attack_dir := Vector2.RIGHT.rotated(_aim_angle)
	var attack_range: float = data.get("melee_range", 55.0)
	var origin := muzzle.global_position
	for node in get_tree().get_nodes_in_group("players"):
		if node == self or not is_instance_valid(node) or node is not Node2D:
			continue
		var target: Node2D = node
		var to_target: Vector2 = target.global_position - origin
		if to_target.length() > attack_range:
			continue
		if to_target.normalized().dot(attack_dir) > 0.25:
			target.take_damage(data["damage"], self)
			if data.has("knockback"):
				target.apply_explosion_knockback(attack_dir * data["knockback"])
	wheel.apply_central_impulse(attack_dir * 80.0)
	_apply_recoil(-attack_dir, data)

func _throw_grenade(data: Dictionary) -> void:
	_fire_cooldown = data["fire_rate"]
	var dir := Vector2.RIGHT.rotated(_aim_angle)
	var nade := GRENADE_SCENE.instantiate()
	nade.global_position = muzzle.global_position
	nade.velocity = dir * data["bullet_speed"] + Vector2(0, -180)
	nade.damage = data["damage"]
	nade.owner_player = self
	get_tree().current_scene.add_child(nade)
	_apply_recoil(dir, data)

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
		_balance_angular_vel += torque * signf(recoil_dir.x) * 0.00065 * RECOIL_SCALE
		_apply_balance_angle()

func _recoil_multiplier(recoil_dir: Vector2) -> float:
	var brace := _current_lean * signf(recoil_dir.x)
	if brace > 0.25:
		return lerpf(1.0, 0.42, brace)
	if brace < -0.25:
		return lerpf(1.0, 1.55, absf(brace))
	return 1.0

func _update_aim() -> void:
	var facing := _facing_sign()
	_aim_angle = rider.rotation + (PI if facing < 0 else 0.0) + deg_to_rad(-8)

func _facing_sign() -> float:
	if _current_lean != 0.0:
		return signf(_current_lean)
	return -1.0 if player_id == 2 else 1.0

func take_damage(amount: int, from: Node2D = null) -> void:
	if state != State.RIDING:
		return
	amount = maxi(1, int(amount * 0.85))
	health -= amount
	_time_since_hit = 0.0
	health_changed.emit(health, MAX_HEALTH)
	wheel.apply_central_impulse(Vector2(randf_range(-20, 20), -35))
	_balance_angular_vel += randf_range(-1.8, 1.8)

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
	_set_balance(0.0, 0.0)
	_sustained_balance_push = 0.0
	_last_vel_x = 0.0
	_wheel_spin = 0.0
	wheel_visual.rotation = 0.0
	_snap_to_ground()
	if GameManager.current_mode == GameManager.Mode.GUN_GAME:
		weapon_type = GameManager.get_gun_game_weapon(player_id)
	elif weapon_type == WeaponDefs.Type.NONE:
		weapon_type = DEFAULT_WEAPON
	state = State.RIDING
	health_changed.emit(health, MAX_HEALTH)

func respawn_at_spawn() -> void:
	_finish_respawn()

func apply_explosion_knockback(impulse: Vector2) -> void:
	var scaled := impulse * KNOCKBACK_SCALE
	wheel.apply_central_impulse(scaled)
	if state == State.RIDING:
		_balance_angular_vel += scaled.x * 0.0012

func apply_harpoon_pull(from: Node2D, hit_pos: Vector2) -> void:
	var dir := (from.global_position - global_position).normalized()
	wheel.apply_central_impulse(dir * 280.0)

func apply_harpoon_recoil_pull(hit_pos: Vector2) -> void:
	var dir := (hit_pos - global_position).normalized()
	wheel.apply_central_impulse(dir * 200.0)

func _draw() -> void:
	if not is_instance_valid(rider):
		return
	var bar_pos := rider.global_position - global_position + Vector2(-28, -72)
	draw_rect(Rect2(bar_pos, Vector2(56, 7)), Color(0.08, 0.08, 0.08, 0.85))
	var fill := 56.0 * (float(health) / MAX_HEALTH)
	var bar_color := team_color if health > 30 else Color(1, 0.35, 0.3)
	draw_rect(Rect2(bar_pos, Vector2(fill, 7)), bar_color)

	var font := ThemeDB.fallback_font
	var wdata := WeaponDefs.get_data(weapon_type)
	var status: String = wdata["name"]
	if state == State.RESPAWNING:
		status = "Respawning..."
	draw_string(font, bar_pos + Vector2(-8, -10), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if Input.is_key_pressed(KEY_H):
		draw_string(font, bar_pos + Vector2(-8, 18), wdata["desc"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.8))
