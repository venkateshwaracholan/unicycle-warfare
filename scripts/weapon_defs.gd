class_name WeaponDefs
extends RefCounted

enum Type {
	NONE, PISTOL, SMG, SHOTGUN, SNIPER, ROCKET, MINIGUN,
	KATANA, GRENADE, HARPOON, CROSSBOW, HAMMER,
}
enum Category { RANGED, MELEE, THROWABLE }

const DATA := {
	Type.NONE: {
		"name": "Unarmed",
		"category": Category.MELEE,
		"color": Color(0.45, 0.45, 0.5),
		"weight": 0.0,
		"damage": 5,
		"fire_rate": 0.45,
		"bullet_speed": 0.0,
		"spread": 0.0,
		"recoil_force": 0.0,
		"recoil_torque": 0.0,
		"recoil_lift": 0.0,
		"pellets": 0,
		"balance_penalty": 0.0,
		"desc": "Punch only. Grab a weapon!",
	},
	Type.PISTOL: {
		"name": "Pistol",
		"category": Category.RANGED,
		"color": Color(0.55, 0.55, 0.62),
		"weight": 0.2,
		"damage": 12,
		"fire_rate": 0.28,
		"bullet_speed": 940.0,
		"spread": 0.04,
		"recoil_force": 110.0,
		"recoil_torque": 280.0,
		"recoil_lift": 0.0,
		"pellets": 1,
		"balance_penalty": 0.05,
		"desc": "pew — barely moves you",
	},
	Type.SMG: {
		"name": "SMG",
		"category": Category.RANGED,
		"color": Color(0.35, 0.75, 0.42),
		"weight": 0.55,
		"damage": 8,
		"fire_rate": 0.08,
		"bullet_speed": 880.0,
		"spread": 0.14,
		"recoil_force": 220.0,
		"recoil_torque": 520.0,
		"recoil_lift": 15.0,
		"pellets": 1,
		"balance_penalty": 0.15,
		"desc": "slow push — spray to stand back up",
		"sustained_recoil": true,
	},
	Type.SHOTGUN: {
		"name": "Shotgun",
		"category": Category.RANGED,
		"color": Color(0.85, 0.45, 0.15),
		"weight": 1.0,
		"damage": 7,
		"fire_rate": 0.75,
		"bullet_speed": 720.0,
		"spread": 0.32,
		"recoil_force": 950.0,
		"recoil_torque": 3200.0,
		"recoil_lift": 60.0,
		"pellets": 6,
		"balance_penalty": 0.35,
		"desc": "BOOM — brace or fall",
	},
	Type.SNIPER: {
		"name": "Sniper",
		"category": Category.RANGED,
		"color": Color(0.25, 0.35, 0.55),
		"weight": 0.85,
		"damage": 38,
		"fire_rate": 1.1,
		"bullet_speed": 1400.0,
		"spread": 0.01,
		"recoil_force": 1400.0,
		"recoil_torque": 1800.0,
		"recoil_lift": 480.0,
		"pellets": 1,
		"balance_penalty": 0.3,
		"desc": "lifts the whole unicycle",
	},
	Type.ROCKET: {
		"name": "Rocket",
		"category": Category.RANGED,
		"color": Color(0.9, 0.22, 0.25),
		"weight": 1.5,
		"damage": 45,
		"fire_rate": 1.3,
		"bullet_speed": 520.0,
		"spread": 0.03,
		"recoil_force": 2100.0,
		"recoil_torque": 2800.0,
		"recoil_lift": 120.0,
		"pellets": 1,
		"balance_penalty": 0.55,
		"desc": "movement tool — shoot ground to jump",
		"explosive": true,
	},
	Type.MINIGUN: {
		"name": "Minigun",
		"category": Category.RANGED,
		"color": Color(0.5, 0.5, 0.55),
		"weight": 2.0,
		"damage": 6,
		"fire_rate": 0.045,
		"bullet_speed": 800.0,
		"spread": 0.22,
		"recoil_force": 320.0,
		"recoil_torque": 1250.0,
		"recoil_lift": 16.0,
		"pellets": 1,
		"balance_penalty": 0.7,
		"desc": "brrrr — slow push, shoot right to stand up",
		"sustained_recoil": true,
	},
	Type.KATANA: {
		"name": "Katana",
		"category": Category.MELEE,
		"color": Color(0.75, 0.78, 0.85),
		"weight": 0.35,
		"damage": 28,
		"fire_rate": 0.42,
		"bullet_speed": 0.0,
		"spread": 0.0,
		"recoil_force": 60.0,
		"recoil_torque": 400.0,
		"recoil_lift": 0.0,
		"pellets": 0,
		"balance_penalty": 0.08,
		"desc": "fast slash — lunge forward",
		"melee_range": 70.0,
	},
	Type.GRENADE: {
		"name": "Grenade",
		"category": Category.THROWABLE,
		"color": Color(0.3, 0.65, 0.3),
		"weight": 0.5,
		"damage": 40,
		"fire_rate": 0.9,
		"bullet_speed": 480.0,
		"spread": 0.0,
		"recoil_force": 350.0,
		"recoil_torque": 500.0,
		"recoil_lift": 20.0,
		"pellets": 0,
		"balance_penalty": 0.12,
		"desc": "lob and scatter",
	},
	Type.HARPOON: {
		"name": "Harpoon",
		"category": Category.RANGED,
		"color": Color(0.6, 0.45, 0.3),
		"weight": 0.75,
		"damage": 22,
		"fire_rate": 0.85,
		"bullet_speed": 680.0,
		"spread": 0.02,
		"recoil_force": 700.0,
		"recoil_torque": 1400.0,
		"recoil_lift": 0.0,
		"pellets": 1,
		"balance_penalty": 0.25,
		"desc": "yanks you and enemies",
		"harpoon": true,
	},
	Type.CROSSBOW: {
		"name": "Crossbow",
		"category": Category.RANGED,
		"color": Color(0.55, 0.35, 0.2),
		"weight": 0.6,
		"damage": 30,
		"fire_rate": 0.95,
		"bullet_speed": 1100.0,
		"spread": 0.02,
		"recoil_force": 650.0,
		"recoil_torque": 900.0,
		"recoil_lift": 40.0,
		"pellets": 1,
		"balance_penalty": 0.2,
		"desc": "punchy bolt, manageable kick",
	},
	Type.HAMMER: {
		"name": "Hammer",
		"category": Category.MELEE,
		"color": Color(0.45, 0.42, 0.48),
		"weight": 1.2,
		"damage": 35,
		"fire_rate": 0.7,
		"bullet_speed": 0.0,
		"spread": 0.0,
		"recoil_force": 200.0,
		"recoil_torque": 2200.0,
		"recoil_lift": 0.0,
		"pellets": 0,
		"balance_penalty": 0.45,
		"desc": "heavy smash — spins you",
		"melee_range": 55.0,
		"knockback": 900.0,
	},
}

static func get_data(weapon_type: Type) -> Dictionary:
	return DATA.get(weapon_type, DATA[Type.NONE])

static func loadout_types() -> Array:
	var result: Array = []
	for t in DATA.keys():
		if t != Type.NONE:
			result.append(t)
	return result


static func can_spawn_as_pickup(weapon_type: Type) -> bool:
	return weapon_type != Type.NONE and weapon_type != Type.PISTOL


static func random_loot_type() -> Type:
	var pool: Array[Type] = []
	for t in DATA.keys():
		if not can_spawn_as_pickup(t):
			continue
		if DATA[t]["category"] == Category.RANGED:
			pool.append(t)
	return pool[randi() % pool.size()]


static func random_sky_loot_type() -> Type:
	var pool: Array[Type] = []
	for t in DATA.keys():
		if not can_spawn_as_pickup(t) or t == Type.MINIGUN:
			continue
		if DATA[t]["category"] == Category.RANGED:
			pool.append(t)
	return pool[randi() % pool.size()]

static func gun_game_order() -> Array:
	return [
		Type.PISTOL, Type.SMG, Type.CROSSBOW, Type.SHOTGUN,
		Type.HARPOON, Type.SNIPER, Type.GRENADE, Type.ROCKET,
		Type.HAMMER, Type.MINIGUN,
	]

static func all_loot_types() -> Array:
	var result: Array = []
	for t in DATA.keys():
		if t != Type.NONE:
			result.append(t)
	return result
