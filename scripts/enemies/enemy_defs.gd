class_name EnemyDefs

enum Type {
	PISTOL_GUY,
	SHOTGUN_GUY,
	SNIPER,
	ROCKET_GUY,
	SHIELD_GUY,
	SUICIDE_BOMBER,
	TURRET,
	TANK,
	HELICOPTER,
	BOSS,
}

enum Role {
	ADVANCE,
	RUSH,
	KITE,
	ROCKET_KITE,
	HOLD,
}

const DATA := {
	Type.PISTOL_GUY: {
		"name": "Rifleman",
		"hp": 45.0,
		"speed": 38.0,
		"weapon": WeaponDefs.Type.PISTOL,
		"role": Role.ADVANCE,
		"preferred_min": 140.0,
		"preferred_max": 360.0,
		"color": Color(0.85, 0.3, 0.3),
		"size": Vector2(18, 28),
	},
	Type.SHOTGUN_GUY: {
		"name": "Shotgunner",
		"hp": 70.0,
		"speed": 34.0,
		"weapon": WeaponDefs.Type.SHOTGUN,
		"role": Role.RUSH,
		"preferred_min": 40.0,
		"preferred_max": 170.0,
		"color": Color(0.75, 0.45, 0.2),
		"size": Vector2(22, 32),
	},
	Type.SNIPER: {
		"name": "Sniper",
		"hp": 40.0,
		"speed": 22.0,
		"weapon": WeaponDefs.Type.SNIPER,
		"role": Role.KITE,
		"preferred_min": 300.0,
		"preferred_max": 620.0,
		"color": Color(0.4, 0.55, 0.35),
		"size": Vector2(16, 30),
	},
	Type.ROCKET_GUY: {
		"name": "Rocketeer",
		"hp": 55.0,
		"speed": 26.0,
		"weapon": WeaponDefs.Type.ROCKET,
		"role": Role.ROCKET_KITE,
		"preferred_min": 220.0,
		"preferred_max": 480.0,
		"color": Color(0.9, 0.35, 0.25),
		"size": Vector2(20, 30),
	},
	Type.TANK: {
		"name": "Tank Boss",
		"hp": 220.0,
		"speed": 18.0,
		"weapon": WeaponDefs.Type.MINIGUN,
		"role": Role.HOLD,
		"preferred_min": 180.0,
		"preferred_max": 340.0,
		"color": Color(0.35, 0.38, 0.42),
		"size": Vector2(36, 40),
		"is_boss": true,
	},
}


static func get_data(type: Type) -> Dictionary:
	return DATA.get(type, DATA[Type.PISTOL_GUY])


static func default_weapon(type: Type) -> WeaponDefs.Type:
	return get_data(type).get("weapon", WeaponDefs.Type.PISTOL)


static func role(type: Type) -> Role:
	return get_data(type).get("role", Role.ADVANCE)
