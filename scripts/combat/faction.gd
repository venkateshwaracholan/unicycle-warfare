class_name Faction

## Who can hurt whom. Projectiles and explosions use this instead of hardcoded groups.

enum Id { PLAYER, ENEMY, NEUTRAL }


static func can_damage(attacker: Id, victim: Id) -> bool:
	if attacker == Id.NEUTRAL:
		return victim != Id.NEUTRAL
	if attacker == Id.PLAYER:
		return victim == Id.ENEMY
	if attacker == Id.ENEMY:
		return victim == Id.PLAYER
	return false


static func can_damage_between(attacker: Node2D, victim: Node2D) -> bool:
	if attacker == null or victim == null or attacker == victim:
		return false
	var attacker_id: Id = from_node(attacker)
	var victim_id: Id = from_node(victim)
	if attacker_id == Id.PLAYER and victim_id == Id.ENEMY:
		return true
	if attacker_id == Id.ENEMY and victim_id == Id.PLAYER:
		return true
	if attacker_id == Id.NEUTRAL:
		return victim_id != Id.NEUTRAL
	if attacker_id == Id.PLAYER and victim_id == Id.PLAYER:
		return GameManager.is_arena_mode()
	return false


static func from_node(node: Node) -> Id:
	if node == null:
		return Id.NEUTRAL
	if node.has_method("get_faction"):
		return node.call("get_faction") as Id
	if node.is_in_group("players"):
		return Id.PLAYER
	if node.is_in_group("enemies"):
		return Id.ENEMY
	return Id.NEUTRAL
