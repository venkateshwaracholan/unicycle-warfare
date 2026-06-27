class_name CombatActions

## Shared weapon behavior — what happens when a WeaponUser fires weapon X.

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const GRENADE_SCENE := preload("res://scenes/grenade.tscn")

const PICKUP_RADIUS := 44.0


static func perform_attack(user: WeaponUser, aim_dir: Vector2) -> Dictionary:
	var weapon: WeaponDefs.Type = user.get_weapon_type()
	var data := WeaponDefs.get_data(weapon)
	var dir := aim_dir.normalized()
	if dir.length_squared() < 0.01:
		dir = Vector2.RIGHT

	match data["category"]:
		WeaponDefs.Category.MELEE:
			return _melee_swing(user, dir, data, weapon)
		WeaponDefs.Category.THROWABLE:
			return _throw_grenade(user, dir, data, weapon)
		_:
			return _fire_ranged(user, dir, data, weapon)


static func _fire_ranged(
	user: WeaponUser,
	dir: Vector2,
	data: Dictionary,
	weapon: WeaponDefs.Type
) -> Dictionary:
	var pellets: int = maxi(1, int(data.get("pellets", 1)))
	var root := _scene_root(user.owner)
	if root == null:
		return { "fired": false }

	for i in pellets:
		var shot_dir := dir.rotated(randf_range(-data.get("spread", 0.0), data.get("spread", 0.0)))
		var muzzle := user.get_muzzle_global_position()
		var bullet := BULLET_SCENE.instantiate()
		bullet.global_position = muzzle
		bullet.velocity = shot_dir * float(data.get("bullet_speed", 800.0))
		bullet.damage = int(data.get("damage", 8))
		bullet.owner_node = user.owner
		bullet.faction = user.faction
		bullet.is_rocket = data.get("explosive", false)
		bullet.is_harpoon = data.get("harpoon", false)
		bullet.tracer_color = data["color"]
		root.add_child(bullet)

	if pellets > 0:
		var muzzle_pos := user.get_muzzle_global_position()
		CombatVFX.muzzle_flash(muzzle_pos, dir, weapon)
		CombatVFX.shell_casing(muzzle_pos, dir)

	return {
		"fired": true,
		"fire_rate": float(data.get("fire_rate", 0.5)),
		"aim_dir": dir,
		"weapon_type": weapon,
		"category": data["category"],
	}


static func _throw_grenade(
	user: WeaponUser,
	dir: Vector2,
	data: Dictionary,
	weapon: WeaponDefs.Type
) -> Dictionary:
	var root := _scene_root(user.owner)
	if root == null:
		return { "fired": false }

	var nade := GRENADE_SCENE.instantiate()
	nade.global_position = user.get_muzzle_global_position()
	nade.velocity = dir * float(data.get("bullet_speed", 480.0)) + Vector2(0, -180)
	nade.damage = int(data.get("damage", 40))
	nade.owner_node = user.owner
	nade.faction = user.faction
	root.add_child(nade)

	return {
		"fired": true,
		"fire_rate": float(data.get("fire_rate", 0.9)),
		"aim_dir": dir,
		"weapon_type": weapon,
		"category": data["category"],
	}


static func _melee_swing(user: WeaponUser, dir: Vector2, data: Dictionary, weapon: WeaponDefs.Type) -> Dictionary:
	var origin := user.get_muzzle_global_position()
	var attack_range: float = float(data.get("melee_range", 55.0))
	var root := _scene_root(user.owner)
	if root == null:
		return { "fired": false }

	for group_name in ["players", "enemies"]:
		for node in root.get_tree().get_nodes_in_group(group_name):
			if node == user.owner or not is_instance_valid(node) or node is not Node2D:
				continue
			var target: Node2D = node
			if not can_hit(user.faction, target, user.owner):
				continue
			var to_target: Vector2 = target.global_position - origin
			if to_target.length() > attack_range:
				continue
			if to_target.normalized().dot(dir) <= 0.25:
				continue
			if target.has_method("take_damage"):
				target.take_damage(int(data.get("damage", 8)), user.owner)
			if data.has("knockback") and target.has_method("apply_explosion_knockback"):
				target.apply_explosion_knockback(dir * float(data.knockback))

	return {
		"fired": true,
		"fire_rate": float(data.get("fire_rate", 0.5)),
		"aim_dir": dir,
		"weapon_type": weapon,
		"category": WeaponDefs.Category.MELEE,
		"melee_lunge": true,
	}


static func apply_explosion(
	world: Node,
	center: Vector2,
	radius: float,
	damage: int,
	owner = null,
	faction: Faction.Id = Faction.Id.NEUTRAL,
	knockback: float = 500.0,
	direct_target: Node2D = null
) -> void:
	var blast_owner: Node2D = owner if is_instance_valid(owner) else null
	CombatVFX.explosion(center, radius)
	for group_name in ["players", "enemies"]:
		for node in world.get_tree().get_nodes_in_group(group_name):
			if not is_instance_valid(node) or node is not Node2D:
				continue
			var target: Node2D = node
			var is_owner := blast_owner != null and target == blast_owner
			if not is_owner and not can_hit(faction, target, blast_owner):
				continue
			var sample_pos := target.global_position
			if target.has_method("get_blast_sample_position"):
				sample_pos = target.call("get_blast_sample_position")
			var offset := sample_pos - center
			var dist: float = offset.length()
			var direct_hit := direct_target != null and target == direct_target
			if not direct_hit and dist >= radius:
				continue
			var falloff: float = 1.0 if direct_hit else (1.0 - dist / radius)
			var push_dir := offset.normalized() if offset.length_squared() > 4.0 else Vector2(0.65, -0.55).normalized()
			if target.has_method("receive_explosion_blast"):
				target.call("receive_explosion_blast", damage, falloff, knockback, push_dir, is_owner, blast_owner)
				continue
			if not is_owner and target.has_method("take_damage"):
				target.take_damage(int(damage * falloff), blast_owner)
			if target.has_method("apply_explosion_knockback"):
				target.apply_explosion_knockback(push_dir * knockback * falloff)


static func can_hit(attacker_faction: Faction.Id, target: Node2D, attacker_node = null) -> bool:
	if not is_instance_valid(target):
		return false
	if attacker_node != null and is_instance_valid(attacker_node):
		return Faction.can_damage_between(attacker_node, target)
	return Faction.can_damage(attacker_faction, Faction.from_node(target))


static func try_pickup_nearby(user: WeaponUser, radius: float = PICKUP_RADIUS) -> bool:
	if user.owner == null:
		return false
	var best: Node = null
	var best_dist := radius
	for loot in user.owner.get_tree().get_nodes_in_group("weapon_loot"):
		if not is_instance_valid(loot) or not loot.has_method("get_weapon_type"):
			continue
		if user.owner.has_method("can_pickup_loot") and not user.owner.can_pickup_loot(loot):
			continue
		var dist: float = user.owner.global_position.distance_to(loot.global_position)
		if dist < best_dist:
			best_dist = dist
			best = loot
	if best == null:
		return false
	var loot_weapon: WeaponDefs.Type = best.get_weapon_type()
	best.queue_free()
	if user.owner.has_method("set_weapon_type"):
		user.owner.set_weapon_type(loot_weapon)
	else:
		user.set_weapon_type(loot_weapon)
	if user.owner.has_method("on_weapon_pickup"):
		user.owner.on_weapon_pickup(loot_weapon)
	return true


static func _scene_root(owner: Node2D) -> Node:
	if owner == null:
		return null
	return owner.get_tree().current_scene
