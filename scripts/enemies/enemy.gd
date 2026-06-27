extends Node2D

## PvE combatant on a unicycle — shared rig with the player.

@export var enemy_type: EnemyDefs.Type = EnemyDefs.Type.PISTOL_GUY

const UnicycleRig := preload("res://scripts/unicycle/unicycle_rig.gd")
const Shapes := preload("res://scripts/draw_shapes.gd")

var _hp := 45.0
var _max_hp := 45.0
var _data: Dictionary
var _weapon_user: WeaponUser
var _rig: UnicycleRig
var is_boss := false
var _retreat_timer := 0.0
var _last_x := 0.0
var _ground_y := 470.0

@onready var wheel: Node2D = $Wheel


func _ready() -> void:
	add_to_group("enemies")
	if is_boss:
		add_to_group("bosses")
	_data = EnemyDefs.get_data(enemy_type)
	var base_hp: float = _data.get("hp", 45.0)
	if is_boss or _data.get("is_boss", false):
		is_boss = true
		_hp = DifficultyScaling.boss_hp(base_hp)
	else:
		_hp = DifficultyScaling.enemy_hp(base_hp)
	_max_hp = _hp
	_weapon_user = WeaponUser.new(self, Faction.Id.ENEMY, EnemyDefs.default_weapon(enemy_type))
	_rig = UnicycleRig.bind(wheel)
	_ground_y = _resolve_ground_y()
	global_position.y = _ground_y
	_last_x = global_position.x
	_configure_visuals()
	_refresh_fire_rate_mult()
	_rig.sync_pose()


func _refresh_fire_rate_mult() -> void:
	var base_mult := float(_data.get("fire_rate_mult", 3.8))
	var weapon_data := WeaponDefs.get_data(get_weapon_type())
	var weapon_interval: float = float(weapon_data.get("fire_rate", 0.5))
	var pickup_slowdown := clampf(0.40 / maxf(weapon_interval, 0.04), 1.0, 10.0)
	_weapon_user.fire_rate_multiplier = base_mult * pickup_slowdown


func _configure_visuals() -> void:
	var color: Color = _data.get("color", Color(0.85, 0.3, 0.3))
	if _rig.upper_visual:
		_rig.upper_visual.team_color = color
	var body_scale := 1.35 if is_boss else 1.0
	wheel.scale = Vector2(body_scale, body_scale)
	_sync_weapon_visual()


func _sync_weapon_visual() -> void:
	if _rig.upper_visual and _rig.upper_visual.has_method("set_weapon"):
		_rig.upper_visual.set_weapon(get_weapon_type())
	if is_instance_valid(_rig.muzzle):
		_rig.muzzle.position = WeaponVisual.get_muzzle_local(get_weapon_type())
	if _rig:
		_rig.redraw()


func _resolve_ground_y() -> float:
	var arena := get_tree().get_first_node_in_group("arena")
	if arena and arena.has_method("ground_surface_y"):
		return arena.ground_surface_y()
	return global_position.y


func get_faction() -> Faction.Id:
	return Faction.Id.ENEMY


func get_weapon_type() -> WeaponDefs.Type:
	return _weapon_user.get_weapon_type()


func set_weapon_type(weapon: WeaponDefs.Type) -> void:
	_weapon_user.set_weapon_type(weapon)
	_refresh_fire_rate_mult()
	_sync_weapon_visual()


func get_weapon_muzzle_global() -> Vector2:
	return _rig.get_muzzle_global()


func on_weapon_pickup(_weapon: WeaponDefs.Type) -> void:
	_refresh_fire_rate_mult()
	_sync_weapon_visual()


func take_damage(amount: int, from: Node2D = null) -> void:
	_hp -= amount
	queue_redraw()
	if _hp <= 0.0:
		_drop_weapon_loot()
		if is_boss:
			MissionManager.register_boss_kill()
		else:
			MissionManager.register_enemy_kill()
		queue_free()


func _drop_weapon_loot() -> void:
	var weapon := get_weapon_type()
	if weapon == WeaponDefs.Type.PISTOL:
		return
	var world := get_tree().current_scene
	if world:
		FallConsequences.spawn_weapon_pickup(world, global_position, weapon, Vector2(randf_range(-80, 80), -120))


func _physics_process(delta: float) -> void:
	_weapon_user.tick(delta)
	_retreat_timer = maxf(_retreat_timer - delta, 0.0)

	var target := _pick_target()
	var vx := 0.0
	if target != null:
		_weapon_user.try_pickup_nearby()
		var to_target := target.global_position - global_position
		var dist := to_target.length()
		var dir := to_target / maxf(dist, 0.001)
		_move_for_role(dir, dist, delta)
		vx = (global_position.x - _last_x) / maxf(delta, 0.001)
		_rig.set_aim_facing(dir.x)
		if absf(vx) > 4.0:
			_rig.set_facing(vx)
		elif absf(dir.x) > 0.05:
			_rig.set_facing(dir.x)
		if _should_fire(dist):
			var aim := dir
			if get_weapon_type() == WeaponDefs.Type.ROCKET and dist < float(_data.get("preferred_min", 120.0)):
				aim = Vector2(0, 1)
			_weapon_user.try_attack(aim)

	var speed: float = _data.get("speed", 30.0)
	_last_x = _rig.sync_wheel_spin(
		delta,
		global_position.x,
		_last_x,
		signf(vx),
		true,
		clampf(absf(vx) / speed, 0.0, 1.2)
	)
	queue_redraw()


func _pick_target() -> Node2D:
	var role: EnemyDefs.Role = _data.get("role", EnemyDefs.Role.ADVANCE)
	var chase_fallen := role == EnemyDefs.Role.RUSH
	return _nearest_player(chase_fallen)


func _move_for_role(dir: Vector2, dist: float, delta: float) -> void:
	var speed: float = _data.get("speed", 30.0)
	var min_dist: float = _data.get("preferred_min", 120.0)
	var max_dist: float = _data.get("preferred_max", 360.0)
	var role: EnemyDefs.Role = _data.get("role", EnemyDefs.Role.ADVANCE)
	var move_dir := dir

	match role:
		EnemyDefs.Role.RUSH:
			if dist > min_dist * 0.85:
				move_dir = dir
			else:
				move_dir = Vector2(dir.x, 0).normalized() if absf(dir.x) > 0.1 else Vector2.ZERO
		EnemyDefs.Role.KITE, EnemyDefs.Role.ROCKET_KITE:
			if dist < min_dist:
				move_dir = -dir
				_retreat_timer = 0.35
			elif dist > max_dist:
				move_dir = dir
			else:
				move_dir = Vector2(-dir.y, dir.x) * signf(global_position.x - 640.0)
		EnemyDefs.Role.HOLD:
			if dist > max_dist:
				move_dir = dir
			elif dist < min_dist:
				move_dir = -dir
			else:
				move_dir = Vector2.ZERO
		_:
			if dist > max_dist:
				move_dir = dir
			elif dist < min_dist:
				move_dir = -dir
			else:
				move_dir = Vector2.ZERO

	if move_dir.length_squared() > 0.01:
		global_position.x += move_dir.normalized().x * speed * delta
	global_position.y = _ground_y
	_apply_environment_forces(delta)


func _apply_environment_forces(delta: float) -> void:
	var env := MapEnvironment.find_in_tree(get_tree())
	if env == null:
		return
	var sample := env.sample(global_position.x, global_position.y)
	global_position.x += float(sample.get("velocity_x", 0.0)) * delta
	global_position.y = _ground_y


func _should_fire(dist: float) -> bool:
	var max_dist: float = _data.get("preferred_max", 360.0)
	if get_weapon_type() == WeaponDefs.Type.SHOTGUN:
		max_dist = minf(max_dist, 200.0)
	if get_weapon_type() == WeaponDefs.Type.ROCKET:
		return dist >= float(_data.get("preferred_min", 180.0)) * 0.75 and dist <= max_dist + 80.0
	return dist <= max_dist + 40.0


func _nearest_player(include_fallen: bool) -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		var player: Node2D = node
		if not include_fallen and "state" in player and player.state != player.State.RIDING:
			continue
		var dist := global_position.distance_squared_to(player.global_position)
		if dist < best_dist:
			best_dist = dist
			best = player
	return best


func _draw() -> void:
	if _rig == null or not is_instance_valid(_rig.pelvis):
		return
	var bar_pos := _rig.rider_bar_anchor(self)
	if is_boss:
		draw_circle(bar_pos + Vector2(28, 3), 34.0, Color(1.0, 0.25, 0.2, 0.18))
	Shapes.rounded_rect(self, Rect2(bar_pos, Vector2(56, 7)), 3.0, Color(0.08, 0.08, 0.08, 0.85))
	var fill := 56.0 * (_hp / _max_hp)
	var bar_color: Color = _data.get("color", Color.RED)
	if fill > 0.0:
		Shapes.rounded_rect(self, Rect2(bar_pos, Vector2(fill, 7)), 3.0, bar_color)
