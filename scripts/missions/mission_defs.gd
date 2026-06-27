class_name MissionDefs

enum ObjectiveType {
	CLEAR_ENEMIES,
	PICKUP_ITEM,
	ESCORT,
	DEFEND,
	DESTROY_TARGET,
	EXTRACT,
	BOSS,
}

const MISSIONS := {
	# --- Desert ---
	"desert_radio_towers": {
		"name": "Mining Town — Radio Towers",
		"map": MapDefs.MapId.DESERT,
		"biome_order": 1,
		"stars": 2,
		"base_reward": 200,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Clear the patrol", "count": 3},
			{"type": ObjectiveType.PICKUP_ITEM, "label": "Find explosives", "weapon": WeaponDefs.Type.GRENADE, "marker": "pickup"},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Destroy radio tower", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Extract", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 1},
		],
	},
	"desert_defend_outpost": {
		"name": "Desert — Hold the Outpost",
		"map": MapDefs.MapId.DESERT,
		"biome_order": 1,
		"objectives": [
			{"type": ObjectiveType.DEFEND, "label": "Defend the outpost", "duration": 45.0, "marker": "defend"},
			{"type": ObjectiveType.EXTRACT, "label": "Extract", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
		],
		"phase_waves": {
			0: [{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 2}],
		},
	},
	# --- Factory ---
	"factory_escort": {
		"name": "Factory — Escort Convoy",
		"map": MapDefs.MapId.FACTORY,
		"biome_order": 1,
		"stars": 3,
		"base_reward": 300,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Clear the yard", "count": 2},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Disable gate controls", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Escort to exit", "marker": "escort_end"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 1},
		],
	},
	"factory_destroy_reactor": {
		"name": "Factory — Destroy Reactor",
		"map": MapDefs.MapId.FACTORY,
		"biome_order": 1,
		"stars": 3,
		"base_reward": 280,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Fight to the reactor", "count": 3},
			{"type": ObjectiveType.PICKUP_ITEM, "label": "Grab det pack", "weapon": WeaponDefs.Type.GRENADE, "marker": "pickup"},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Blow the reactor", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Get out", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 2},
		],
	},
	"factory_survive_waves": {
		"name": "Factory — Survive Waves",
		"map": MapDefs.MapId.FACTORY,
		"biome_order": 1,
		"objectives": [
			{"type": ObjectiveType.DEFEND, "label": "Hold the line", "duration": 60.0, "marker": "defend"},
			{"type": ObjectiveType.EXTRACT, "label": "Extract", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
		],
		"phase_waves": {
			0: [{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 2}],
		},
	},
	# --- Dam / Bridge ---
	"dam_bridge_assault": {
		"name": "Dam — Bridge Assault",
		"map": MapDefs.MapId.DAM,
		"biome_order": 2,
		"stars": 3,
		"base_reward": 300,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Cross the bridge", "count": 4},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Blow the relay", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Escape", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 2},
		],
	},
	# --- Train ---
	"train_mining_run": {
		"name": "Train — Mining Run",
		"map": MapDefs.MapId.TRAIN,
		"biome_order": 2,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Clear the cars", "count": 3},
			{"type": ObjectiveType.PICKUP_ITEM, "label": "Grab charges", "weapon": WeaponDefs.Type.GRENADE, "marker": "pickup"},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Blow the cargo", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Jump off", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 3},
		],
	},
	# --- Harbor ---
	"harbor_smuggler_extract": {
		"name": "Harbor — Smuggler Extract",
		"map": MapDefs.MapId.HARBOR,
		"biome_order": 2,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Secure the docks", "count": 3},
			{"type": ObjectiveType.PICKUP_ITEM, "label": "Find the package", "weapon": WeaponDefs.Type.GRENADE, "marker": "pickup"},
			{"type": ObjectiveType.EXTRACT, "label": "Reach the boat", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 1},
		],
	},
	# --- Castle ---
	"castle_siege": {
		"name": "Castle — Breach the Gate",
		"map": MapDefs.MapId.CASTLE,
		"biome_order": 3,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Fight through the gate", "count": 4},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Destroy the gate", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Escape the courtyard", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 3},
		],
	},
	# --- Mine ---
	"mine_generator_defense": {
		"name": "Mine — Generator Defense",
		"map": MapDefs.MapId.MINE,
		"biome_order": 3,
		"stars": 4,
		"base_reward": 350,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.DEFEND, "label": "Defend generators", "duration": 90.0, "marker": "defend"},
			{"type": ObjectiveType.EXTRACT, "label": "Ride out", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
		],
		"phase_waves": {
			0: [
				{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
				{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 1},
			],
		},
	},
	# --- City ---
	"city_rooftop_raid": {
		"name": "City — Rooftop Raid",
		"map": MapDefs.MapId.CITY,
		"biome_order": 3,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Clear rooftops", "count": 3},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Sabotage antenna", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Extract", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 1},
		],
	},
	# --- Airship ---
	"airship_deck_clear": {
		"name": "Airship — Deck Clear",
		"map": MapDefs.MapId.AIRSHIP,
		"biome_order": 4,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Clear the deck", "count": 4},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Destroy engine", "marker": "destroy"},
			{"type": ObjectiveType.EXTRACT, "label": "Parachute out", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 2},
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
		],
	},
	# --- Volcano ---
	"volcano_drill_site": {
		"name": "Volcano — Drill Site",
		"map": MapDefs.MapId.VOLCANO,
		"biome_order": 4,
		"stars": 5,
		"base_reward": 450,
		"has_boss": true,
		"objectives": [
			{"type": ObjectiveType.CLEAR_ENEMIES, "label": "Reach the drill", "count": 3},
			{"type": ObjectiveType.PICKUP_ITEM, "label": "Grab thermite", "weapon": WeaponDefs.Type.GRENADE, "marker": "pickup"},
			{"type": ObjectiveType.DESTROY_TARGET, "label": "Destroy the drill", "marker": "destroy"},
			{"type": ObjectiveType.DEFEND, "label": "Hold until collapse", "duration": 30.0, "marker": "defend"},
			{"type": ObjectiveType.EXTRACT, "label": "Escape", "marker": "extract"},
		],
		"enemy_waves": [
			{"type": EnemyDefs.Type.PISTOL_GUY, "count": 2},
		],
		"phase_waves": {
			3: [{"type": EnemyDefs.Type.SHOTGUN_GUY, "count": 3}],
		},
	},
}


static func get_mission(id: String) -> Dictionary:
	return MISSIONS.get(id, MISSIONS["desert_radio_towers"])


static func get_default_mission_id() -> String:
	return "desert_radio_towers"


static func list_mission_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in MISSIONS:
		ids.append(key)
	ids.sort_custom(func(a: String, b: String) -> bool:
		var ma: Dictionary = MISSIONS[a]
		var mb: Dictionary = MISSIONS[b]
		var map_a: String = MapDefs.map_name(ma.get("map", MapDefs.MapId.DESERT))
		var map_b: String = MapDefs.map_name(mb.get("map", MapDefs.MapId.DESERT))
		if map_a != map_b:
			return map_a < map_b
		return ma.get("name", a) < mb.get("name", b)
	)
	return ids


static func list_missions_for_map(map_id: MapDefs.MapId) -> Array[String]:
	var ids: Array[String] = []
	for key in MISSIONS:
		if MISSIONS[key].get("map") == map_id:
			ids.append(key)
	return ids


static func board_title(mission_id: String) -> String:
	var full_name: String = get_mission(mission_id).get("name", mission_id)
	var parts := full_name.split(" — ")
	if parts.size() > 1:
		return parts[1]
	return full_name


static func board_map_name(mission_id: String) -> String:
	var def := get_mission(mission_id)
	return MapDefs.map_name(def.get("map", MapDefs.MapId.DESERT))
