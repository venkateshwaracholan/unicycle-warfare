class_name WeaponUser

## Holds weapon state for any combatant. Player/enemy decide WHEN to fire; CombatActions decides HOW.

var owner: Node2D
var faction: Faction.Id = Faction.Id.NEUTRAL
var fire_cooldown := 0.0
var fire_rate_multiplier := 1.0
var weapon_type: WeaponDefs.Type = WeaponDefs.Type.PISTOL

func _init(p_owner: Node2D, p_faction: Faction.Id, p_weapon: WeaponDefs.Type = WeaponDefs.Type.PISTOL) -> void:
	owner = p_owner
	faction = p_faction
	weapon_type = p_weapon

func tick(delta: float) -> void:
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)

func get_weapon_type() -> WeaponDefs.Type:
	return weapon_type

func set_weapon_type(weapon: WeaponDefs.Type) -> void:
	weapon_type = weapon
	if owner != null and "weapon_type" in owner:
		owner.weapon_type = weapon

func get_muzzle_global_position() -> Vector2:
	if owner != null and owner.has_method("get_weapon_muzzle_global"):
		return owner.call("get_weapon_muzzle_global")
	if owner != null:
		return owner.global_position + Vector2(12, -14)
	return Vector2.ZERO

func try_attack(aim_dir: Vector2) -> Dictionary:
	if fire_cooldown > 0.0:
		return { "fired": false }
	var result := CombatActions.perform_attack(self, aim_dir)
	if result.get("fired", false):
		fire_cooldown = float(result.get("fire_rate", 0.5)) * fire_rate_multiplier
	return result

func try_pickup_nearby(radius: float = CombatActions.PICKUP_RADIUS) -> bool:
	return CombatActions.try_pickup_nearby(self, radius)
