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

const DATA := {
	Type.PISTOL_GUY: {
		"name": "Pistol Guy",
		"hp": 45.0,
		"speed": 38.0,
		"damage": 8,
		"fire_rate": 1.1,
		"range": 420.0,
		"color": Color(0.85, 0.3, 0.3),
		"size": Vector2(18, 28),
	},
	Type.SHOTGUN_GUY: {
		"name": "Shotgun Guy",
		"hp": 70.0,
		"speed": 28.0,
		"damage": 14,
		"fire_rate": 1.6,
		"range": 220.0,
		"color": Color(0.75, 0.45, 0.2),
		"size": Vector2(22, 32),
	},
	Type.SNIPER: {
		"name": "Sniper",
		"hp": 40.0,
		"speed": 20.0,
		"damage": 22,
		"fire_rate": 2.4,
		"range": 700.0,
		"color": Color(0.4, 0.55, 0.35),
		"size": Vector2(16, 30),
	},
	Type.TANK: {
		"name": "Tank Boss",
		"hp": 220.0,
		"speed": 18.0,
		"damage": 18,
		"fire_rate": 1.8,
		"range": 380.0,
		"color": Color(0.35, 0.38, 0.42),
		"size": Vector2(36, 40),
		"is_boss": true,
	},
}


static func get_data(type: Type) -> Dictionary:
	return DATA.get(type, DATA[Type.PISTOL_GUY])
