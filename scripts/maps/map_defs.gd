class_name MapDefs

## Reusable map data — layout, markers, spawn zones. Maps are content; missions pick objectives.

enum MapId {
	DESERT,
	FACTORY,
	CASTLE,
	TRAIN,
	MINE,
	AIRSHIP,
	CITY,
	DAM,
	VOLCANO,
	HARBOR,
}

const MARKER_DESTROY := "destroy"
const MARKER_PICKUP := "pickup"
const MARKER_EXTRACT := "extract"
const MARKER_DEFEND := "defend"
const MARKER_ESCORT_START := "escort_start"
const MARKER_ESCORT_END := "escort_end"
const MARKER_BOSS := "boss"

const MAPS := {
	MapId.DESERT: {
		"name": "Desert",
		"biome": "desert",
		"ground_y": 490.0,
		"spawn_points": [Vector2(220, 420), Vector2(1060, 420)],
		"weapon_spread": {"cx": 640.0, "floor_y": 455.0, "width": 520.0},
		"sky": Color(0.72, 0.82, 0.92),
		"ground": Color(0.82, 0.72, 0.48),
		"platform": Color(0.68, 0.56, 0.36),
		"markers": {
			MARKER_DESTROY: Vector2(980, -14),
			MARKER_PICKUP: Vector2(720, -14),
			MARKER_EXTRACT: Vector2(220, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(280, -14),
			MARKER_ESCORT_END: Vector2(1000, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 380.0, "x_max": 900.0},
	},
	MapId.FACTORY: {
		"name": "Factory",
		"biome": "factory",
		"ground_y": 490.0,
		"spawn_points": [Vector2(200, 420), Vector2(1080, 420)],
		"weapon_spread": {"cx": 640.0, "floor_y": 455.0, "width": 500.0},
		"sky": Color(0.45, 0.48, 0.52),
		"ground": Color(0.22, 0.24, 0.26),
		"platform": Color(0.38, 0.4, 0.42),
		"markers": {
			MARKER_DESTROY: Vector2(920, -14),
			MARKER_PICKUP: Vector2(520, -14),
			MARKER_EXTRACT: Vector2(200, -14),
			MARKER_DEFEND: Vector2(760, -14),
			MARKER_ESCORT_START: Vector2(240, -14),
			MARKER_ESCORT_END: Vector2(1040, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 360.0, "x_max": 920.0},
	},
	MapId.CASTLE: {
		"name": "Castle",
		"biome": "castle",
		"ground_y": 485.0,
		"spawn_points": [Vector2(240, 415), Vector2(1040, 415)],
		"weapon_spread": {"cx": 640.0, "floor_y": 450.0, "width": 480.0},
		"sky": Color(0.55, 0.62, 0.78),
		"ground": Color(0.32, 0.28, 0.24),
		"platform": Color(0.52, 0.48, 0.42),
		"markers": {
			MARKER_DESTROY: Vector2(960, -14),
			MARKER_PICKUP: Vector2(680, -14),
			MARKER_EXTRACT: Vector2(240, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(300, -14),
			MARKER_ESCORT_END: Vector2(980, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 400.0, "x_max": 880.0},
	},
	MapId.TRAIN: {
		"name": "Train",
		"biome": "train",
		"ground_y": 470.0,
		"spawn_points": [Vector2(180, 400), Vector2(1100, 400)],
		"weapon_spread": {"cx": 640.0, "floor_y": 435.0, "width": 480.0},
		"sky": Color(0.58, 0.65, 0.72),
		"ground": Color(0.28, 0.22, 0.18),
		"platform": Color(0.55, 0.18, 0.18),
		"markers": {
			MARKER_DESTROY: Vector2(880, -14),
			MARKER_PICKUP: Vector2(560, -14),
			MARKER_EXTRACT: Vector2(180, -14),
			MARKER_DEFEND: Vector2(720, -14),
			MARKER_ESCORT_START: Vector2(220, -14),
			MARKER_ESCORT_END: Vector2(1060, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 340.0, "x_max": 940.0},
	},
	MapId.MINE: {
		"name": "Mine",
		"biome": "mine",
		"ground_y": 480.0,
		"spawn_points": [Vector2(210, 410), Vector2(1070, 410)],
		"weapon_spread": {"cx": 640.0, "floor_y": 445.0, "width": 500.0},
		"sky": Color(0.18, 0.2, 0.24),
		"ground": Color(0.12, 0.1, 0.08),
		"platform": Color(0.35, 0.3, 0.22),
		"markers": {
			MARKER_DESTROY: Vector2(940, -14),
			MARKER_PICKUP: Vector2(600, -14),
			MARKER_EXTRACT: Vector2(210, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(260, -14),
			MARKER_ESCORT_END: Vector2(990, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 370.0, "x_max": 910.0},
	},
	MapId.AIRSHIP: {
		"name": "Airship",
		"biome": "airship",
		"ground_y": 460.0,
		"spawn_points": [Vector2(260, 390), Vector2(1020, 390)],
		"weapon_spread": {"cx": 640.0, "floor_y": 425.0, "width": 460.0},
		"sky": Color(0.48, 0.58, 0.82),
		"ground": Color(0.15, 0.18, 0.28),
		"platform": Color(0.62, 0.58, 0.52),
		"markers": {
			MARKER_DESTROY: Vector2(900, -14),
			MARKER_PICKUP: Vector2(640, -14),
			MARKER_EXTRACT: Vector2(260, -14),
			MARKER_DEFEND: Vector2(780, -14),
			MARKER_ESCORT_START: Vector2(320, -14),
			MARKER_ESCORT_END: Vector2(960, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 420.0, "x_max": 860.0},
	},
	MapId.CITY: {
		"name": "City",
		"biome": "city",
		"ground_y": 450.0,
		"spawn_points": [Vector2(240, 380), Vector2(1040, 380)],
		"weapon_spread": {"cx": 640.0, "floor_y": 415.0, "width": 500.0},
		"sky": Color(0.42, 0.48, 0.58),
		"ground": Color(0.1, 0.12, 0.18),
		"platform": Color(0.32, 0.34, 0.38),
		"markers": {
			MARKER_DESTROY: Vector2(970, -14),
			MARKER_PICKUP: Vector2(700, -14),
			MARKER_EXTRACT: Vector2(240, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(280, -14),
			MARKER_ESCORT_END: Vector2(1010, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 390.0, "x_max": 890.0},
	},
	MapId.DAM: {
		"name": "Dam",
		"biome": "dam",
		"ground_y": 490.0,
		"spawn_points": [Vector2(220, 420), Vector2(1060, 420)],
		"weapon_spread": {"cx": 640.0, "floor_y": 455.0, "width": 520.0},
		"sky": Color(0.52, 0.68, 0.82),
		"ground": Color(0.28, 0.32, 0.38),
		"platform": Color(0.48, 0.5, 0.54),
		"markers": {
			MARKER_DESTROY: Vector2(950, -14),
			MARKER_PICKUP: Vector2(580, -14),
			MARKER_EXTRACT: Vector2(220, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(260, -14),
			MARKER_ESCORT_END: Vector2(1020, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 380.0, "x_max": 900.0},
	},
	MapId.VOLCANO: {
		"name": "Volcano",
		"biome": "volcano",
		"ground_y": 485.0,
		"spawn_points": [Vector2(230, 415), Vector2(1050, 415)],
		"weapon_spread": {"cx": 640.0, "floor_y": 450.0, "width": 510.0},
		"sky": Color(0.38, 0.22, 0.18),
		"ground": Color(0.18, 0.08, 0.06),
		"platform": Color(0.42, 0.22, 0.12),
		"markers": {
			MARKER_DESTROY: Vector2(930, -14),
			MARKER_PICKUP: Vector2(610, -14),
			MARKER_EXTRACT: Vector2(230, -14),
			MARKER_DEFEND: Vector2(640, -14),
			MARKER_ESCORT_START: Vector2(270, -14),
			MARKER_ESCORT_END: Vector2(1000, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 370.0, "x_max": 910.0},
	},
	MapId.HARBOR: {
		"name": "Harbor",
		"biome": "harbor",
		"ground_y": 488.0,
		"spawn_points": [Vector2(210, 418), Vector2(1070, 418)],
		"weapon_spread": {"cx": 640.0, "floor_y": 453.0, "width": 520.0},
		"sky": Color(0.55, 0.72, 0.88),
		"ground": Color(0.22, 0.28, 0.32),
		"platform": Color(0.48, 0.52, 0.56),
		"markers": {
			MARKER_DESTROY: Vector2(960, -14),
			MARKER_PICKUP: Vector2(540, -14),
			MARKER_EXTRACT: Vector2(210, -14),
			MARKER_DEFEND: Vector2(720, -14),
			MARKER_ESCORT_START: Vector2(250, -14),
			MARKER_ESCORT_END: Vector2(1050, -14),
			MARKER_BOSS: Vector2(640, -14),
		},
		"enemy_zone": {"x_min": 350.0, "x_max": 930.0},
	},
}


static func get_map(map_id: MapId) -> Dictionary:
	return MAPS.get(map_id, MAPS[MapId.DESERT])


static func map_name(map_id: MapId) -> String:
	return get_map(map_id).get("name", "Arena")


static func list_map_ids() -> Array[MapId]:
	var ids: Array[MapId] = []
	for key in MAPS:
		ids.append(key)
	return ids


static func resolve_marker(map_id: MapId, marker_id: String, ground_surface_y: float) -> Vector2:
	var map := get_map(map_id)
	var markers: Dictionary = map.get("markers", {})
	var local: Vector2 = markers.get(marker_id, Vector2(640, -14))
	return Vector2(local.x, ground_surface_y + local.y)


static func enemy_spawn_positions(map_id: MapId, ground_surface_y: float, count: int) -> Array[Vector2]:
	var map := get_map(map_id)
	var spawns: Array = map.get("spawn_points", [Vector2(220, 420), Vector2(1060, 420)])
	var far_x := maxf(float(spawns[0].x), float(spawns[1].x))
	var zone_min := far_x - 140.0
	var zone_max := minf(far_x + 60.0, 1180.0)
	var positions: Array[Vector2] = []
	for i in count:
		var t := float(i % 5) / 4.0 if count > 1 else 0.5
		var x := lerpf(zone_min, zone_max, t)
		positions.append(Vector2(x, ground_surface_y))
	return positions
