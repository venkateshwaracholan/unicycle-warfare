class_name FallConsequences

## Standard balance-fall rules — shared by arena and mission maps.

const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")
const BACKUP_WEAPON := WeaponDefs.Type.PISTOL
const DROP_COOLDOWN := 1.8

# --- Soft fall vs hard crash ---
const SOFT_DAMAGE := 5
const CRASH_DAMAGE := 15

# --- Hard crash (HP + bounce only — no weapon drop) ---
const CRASH_BALANCE_VEL := 3.35
const CRASH_SPEED := 25.0

# --- Explosion tracking (fall backup) ---
const EXPLOSION_METER_DECAY := 80.0
const EXPLOSION_DISPLACEMENT_SCALE := 0.4

# --- Ground impact bounce ---
const BOUNCE_UP_SOFT := 110.0
const BOUNCE_UP_CRASH := 200.0
const BOUNCE_HORIZ_SOFT := 60.0
const BOUNCE_HORIZ_CRASH := 125.0
const BOUNCE_SPIN_SOFT := 1.5
const BOUNCE_SPIN_CRASH := 3.0
const BOUNCE_TIME_SOFT := 0.26
const BOUNCE_TIME_CRASH := 0.36


static func rules_hint() -> String:
	return "soft fall −%d HP · blast knocks weapon loose" % SOFT_DAMAGE


static func decay_explosion_meter(meter: float, delta: float) -> float:
	return maxf(0.0, meter - EXPLOSION_METER_DECAY * delta)


static func register_explosion_impact(meter: float, impulse_magnitude: float) -> float:
	return maxf(meter, impulse_magnitude)


static func should_drop_weapon_from_explosion(_explosion_meter: float) -> bool:
	return _explosion_meter > 0.0


static func is_hard_crash(balance_angular_vel: float, wheel_speed: float) -> bool:
	if absf(balance_angular_vel) >= CRASH_BALANCE_VEL:
		return true
	if wheel_speed >= CRASH_SPEED:
		return true
	return false


static func get_damage(severe: bool) -> int:
	return CRASH_DAMAGE if severe else SOFT_DAMAGE


static func get_bounce(severe: bool) -> Dictionary:
	return {
		"up": BOUNCE_UP_CRASH if severe else BOUNCE_UP_SOFT,
		"horiz_base": BOUNCE_HORIZ_CRASH if severe else BOUNCE_HORIZ_SOFT,
		"spin": BOUNCE_SPIN_CRASH if severe else BOUNCE_SPIN_SOFT,
		"duration": BOUNCE_TIME_CRASH if severe else BOUNCE_TIME_SOFT,
	}


static func get_status_message(severe: bool, weapon_dropped: bool) -> String:
	if weapon_dropped:
		return "Blasted! Weapon knocked loose"
	if severe:
		return "Hard crash! −%d HP" % CRASH_DAMAGE
	return "Tumbled! −%d HP · keep your weapon" % SOFT_DAMAGE


## Drop weapon and fling it along the blast direction.
static func drop_weapon_from_blast_unit(unit: Node2D, blast_impulse: Vector2, dropped_by: int = 0) -> bool:
	var current := _read_weapon(unit)
	if _is_non_droppable(current):
		return false
	var world := unit.get_tree().current_scene
	if world == null:
		return false

	var muzzle: Node2D = unit.get_node_or_null("Wheel/Pelvis/UpperBody/Muzzle")
	var origin := muzzle.global_position if muzzle else unit.global_position
	var dir := blast_impulse.normalized() if blast_impulse.length_squared() > 1.0 else Vector2(0.8, -0.45).normalized()
	var strength := clampf(blast_impulse.length() * 0.55, 120.0, 340.0)
	var horiz_sign := signf(dir.x) if absf(dir.x) > 0.12 else (1.0 if randf() > 0.5 else -1.0)
	var horiz_speed := maxf(absf(dir.x) * strength * 1.35, randf_range(110.0, 190.0))
	var launch := Vector2(
		horiz_sign * horiz_speed + randf_range(-40.0, 40.0),
		minf(dir.y, -0.15) * strength * 0.55 + randf_range(-150.0, -70.0)
	)
	spawn_weapon_pickup(world, origin, current, launch, dropped_by)
	if unit.has_method("set_weapon_type"):
		unit.set_weapon_type(BACKUP_WEAPON)
	elif "weapon_type" in unit:
		unit.weapon_type = BACKUP_WEAPON
	return true


static func drop_weapon_from_blast(player: Node2D, blast_impulse: Vector2) -> bool:
	if not player.has_method("get_player_id"):
		return false
	return drop_weapon_from_blast_unit(player, blast_impulse, player.get_player_id())


static func try_drop_weapon_on_explosion_unit(unit: Node2D, blast_impulse: Vector2, dropped_by: int = 0) -> bool:
	return drop_weapon_from_blast_unit(unit, blast_impulse, dropped_by)


static func try_drop_weapon_on_explosion(player: Node2D, blast_impulse: Vector2) -> bool:
	var dropped_by: int = player.get_player_id() if player.has_method("get_player_id") else 0
	return try_drop_weapon_on_explosion_unit(player, blast_impulse, dropped_by)


static func explosion_displacement(impulse: Vector2) -> Vector2:
	return impulse * EXPLOSION_DISPLACEMENT_SCALE


static func resolve_fall(player: Node2D, is_crash: bool, drop_from_explosion: bool) -> Dictionary:
	var dropped := false
	var severe := is_crash or drop_from_explosion
	if drop_from_explosion:
		dropped = drop_weapon_from_player(player, player.get_tree().current_scene)
	if player.has_method("apply_fall_bounce"):
		player.call("apply_fall_bounce", get_bounce(severe))
	return {
		"damage": get_damage(severe),
		"is_crash": severe,
		"weapon_dropped": dropped,
		"message": get_status_message(severe, dropped),
	}


static func drop_weapon_from_player(player: Node2D, world: Node) -> bool:
	if world == null or not player.has_method("get_player_id"):
		return false
	var current := _read_weapon(player)
	if _is_non_droppable(current):
		return false

	var muzzle: Node2D = player.get_node_or_null("Wheel/Pelvis/UpperBody/Muzzle")
	var origin := muzzle.global_position if muzzle else player.global_position
	var facing := 1.0
	if player.has_method("get_aim_facing"):
		facing = player.call("get_aim_facing")
	elif player.has_method("get_facing"):
		facing = player.call("get_facing")

	var velocity := Vector2(facing * randf_range(60.0, 140.0), randf_range(-160.0, -60.0))
	spawn_weapon_pickup(world, origin, current, velocity, player.get_player_id())
	if player.has_method("set_weapon_type"):
		player.set_weapon_type(BACKUP_WEAPON)
	elif "weapon_type" in player:
		player.weapon_type = BACKUP_WEAPON
	return true


static func _read_weapon(player: Node2D) -> WeaponDefs.Type:
	if player.has_method("get_weapon_type"):
		return player.get_weapon_type()
	if "weapon_type" in player:
		return player.weapon_type
	return WeaponDefs.Type.NONE


static func _is_non_droppable(weapon: WeaponDefs.Type) -> bool:
	return not WeaponDefs.can_spawn_as_pickup(weapon)


static func spawn_weapon_pickup(
	world: Node,
	global_pos: Vector2,
	weapon: WeaponDefs.Type,
	velocity: Vector2,
	dropped_by: int = 0
) -> Node:
	if _is_non_droppable(weapon):
		return null
	var pickup := WEAPON_PICKUP_SCENE.instantiate()
	pickup.add_to_group("weapon_loot")
	pickup.weapon_type = weapon
	pickup.global_position = global_pos
	if pickup.has_method("set_dropped_by"):
		pickup.set_dropped_by(dropped_by)
	pickup.launch(velocity)
	world.add_child(pickup)
	return pickup
