class_name FallConsequences

const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")
const BACKUP_WEAPON := WeaponDefs.Type.PISTOL
const DROP_COOLDOWN := 1.8

## Drop carried weapon on fall. Player keeps a backup sidearm.
static func drop_weapon_from_player(player: Node2D, world: Node) -> void:
	if not player.has_method("get_player_id"):
		return
	var current: WeaponDefs.Type = player.get_weapon_type() if player.has_method("get_weapon_type") else player.weapon_type
	if current == WeaponDefs.Type.NONE or current == BACKUP_WEAPON:
		return

	var muzzle: Node2D = player.get_node_or_null("Wheel/Rider/Muzzle")
	var origin := muzzle.global_position if muzzle else player.global_position
	var facing := 1.0
	if player.has_method("_facing_sign"):
		facing = player.call("_facing_sign")

	var velocity := Vector2(facing * randf_range(60.0, 140.0), randf_range(-160.0, -60.0))
	spawn_weapon_pickup(world, origin, current, velocity, player.get_player_id())
	if player.has_method("set_weapon_type"):
		player.set_weapon_type(BACKUP_WEAPON)
	elif "weapon_type" in player:
		player.weapon_type = BACKUP_WEAPON


static func spawn_weapon_pickup(
	world: Node,
	global_pos: Vector2,
	weapon: WeaponDefs.Type,
	velocity: Vector2,
	dropped_by: int = 0
) -> Node:
	var pickup := WEAPON_PICKUP_SCENE.instantiate()
	pickup.add_to_group("weapon_loot")
	pickup.weapon_type = weapon
	pickup.global_position = global_pos
	if pickup.has_method("set_dropped_by"):
		pickup.set_dropped_by(dropped_by)
	pickup.launch(velocity)
	world.add_child(pickup)
	return pickup
