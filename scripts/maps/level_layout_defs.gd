class_name LevelLayoutDefs

## Mission-sized level layouts per biome — modular chunk sequences with marker slots.

static var _layouts: Dictionary = {}


static func get_layout(map_id: MapDefs.MapId) -> Array:
	_ensure_layouts()
	return _layouts.get(map_id, _layouts[MapDefs.MapId.DESERT])


static func layout_name(map_id: MapDefs.MapId) -> String:
	var layout: Array = get_layout(map_id)
	if layout.is_empty():
		return MapDefs.map_name(map_id)
	var first: Dictionary = layout[0]
	return str(first.get("label", MapDefs.map_name(map_id)))


static func _ensure_layouts() -> void:
	if not _layouts.is_empty():
		return
	_layouts = {
		MapDefs.MapId.DESERT: _desert(),
		MapDefs.MapId.FACTORY: _factory(),
		MapDefs.MapId.CASTLE: _castle(),
		MapDefs.MapId.TRAIN: _train(),
		MapDefs.MapId.MINE: _mine(),
		MapDefs.MapId.AIRSHIP: _airship(),
		MapDefs.MapId.CITY: _city(),
		MapDefs.MapId.DAM: _dam(),
		MapDefs.MapId.VOLCANO: _volcano(),
		MapDefs.MapId.HARBOR: _harbor(),
	}


static func _desert() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Drop Zone — Dune Edge", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.55},
			"props": [LevelChunkDefs.prop("sandbags", 0.2), LevelChunkDefs.prop("broken_sign", 0.75)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Outpost Ruins", {
			"props": [LevelChunkDefs.prop("barrel", 0.3), LevelChunkDefs.prop("sandbags", 0.6), LevelChunkDefs.prop("junk_truck", 0.82)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Dune Crossing", {
			"terrain": "step_up",
			"hazards": [LevelChunkDefs.hazard("wind", 0.15, 0.85, {"strength": 28.0})],
			"props": [LevelChunkDefs.prop("cactus", 0.25), LevelChunkDefs.prop("rock_pile", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Oasis Relay", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("wagon", 0.35), LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Hidden Ruins", {
			"props": [LevelChunkDefs.prop("rock_pile", 0.4), LevelChunkDefs.prop("barrel", 0.65)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Canyon Pass", {
			"terrain": "bridge",
			"props": [LevelChunkDefs.prop("rock_pile", 0.15), LevelChunkDefs.prop("rock_pile", 0.85)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Radio Tower Ridge", {
			"markers": {MapDefs.MARKER_DESTROY: 0.72},
			"props": [LevelChunkDefs.prop("broken_sign", 0.4), LevelChunkDefs.prop("barbed_wire", 0.55)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Wind Field", {
			"hazards": [LevelChunkDefs.hazard("wind", 0.0, 1.0, {"strength": 32.0, "interval": 4.0, "duration": 2.0})],
			"props": [LevelChunkDefs.prop("sandbags", 0.2), LevelChunkDefs.prop("barrel", 0.45), LevelChunkDefs.prop("junk_truck", 0.78)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Sand Pit Arena", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
			"props": [LevelChunkDefs.prop("sandbags", 0.15), LevelChunkDefs.prop("sandbags", 0.85)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Dune Slide", {
			"terrain": "step_down",
			"hazards": [LevelChunkDefs.hazard("wind", 0.3, 0.9, {"strength": 22.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Evac Zone", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.42, MapDefs.MARKER_ESCORT_END: 0.58},
			"props": [LevelChunkDefs.prop("junk_truck", 0.7), LevelChunkDefs.prop("tire_stack", 0.25)],
		}),
	]


static func _factory() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Loading Dock", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("container_stack", 0.3), LevelChunkDefs.prop("barrel", 0.65)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Warehouse Floor", {
			"props": [LevelChunkDefs.prop("container_stack", 0.25), LevelChunkDefs.prop("junk_truck", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Conveyor Hall", {
			"terrain": "flat",
			"hazards": [LevelChunkDefs.hazard("conveyor", 0.2, 0.8, {"speed": 45.0})],
			"props": [LevelChunkDefs.prop("pipe", 0.4)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Assembly Line", {
			"markers": {MapDefs.MARKER_PICKUP: 0.45, MapDefs.MARKER_DEFEND: 0.6},
			"hazards": [LevelChunkDefs.hazard("steam", 0.35, 0.55, {"force": 70.0, "interval": 5.0, "duration": 1.5})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Maintenance Catwalk", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Reactor Access", {
			"terrain": "step_up",
			"hazards": [LevelChunkDefs.hazard("steam", 0.1, 0.4, {"force": 60.0, "interval": 6.0, "duration": 1.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Reactor Core", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
			"props": [LevelChunkDefs.prop("pipe", 0.3), LevelChunkDefs.prop("barrel", 0.75)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Factory Floor", {
			"hazards": [LevelChunkDefs.hazard("conveyor", 0.0, 0.5, {"speed": 35.0})],
			"props": [LevelChunkDefs.prop("container_stack", 0.2), LevelChunkDefs.prop("junk_truck", 0.5), LevelChunkDefs.prop("container_stack", 0.8)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Core Chamber", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Emergency Exit", {
			"terrain": "step_down",
			"hazards": [LevelChunkDefs.hazard("steam", 0.5, 0.9, {"force": 80.0, "interval": 4.0, "duration": 1.2})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Loading Bay", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.45, MapDefs.MARKER_ESCORT_END: 0.6},
			"props": [LevelChunkDefs.prop("junk_truck", 0.35)],
		}),
	]


static func _castle() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Outer Courtyard", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("sandbags", 0.25), LevelChunkDefs.prop("barrel", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Gatehouse", {
			"props": [LevelChunkDefs.prop("barbed_wire", 0.4), LevelChunkDefs.prop("sandbags", 0.65)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Drawbridge", {
			"terrain": "bridge",
			"props": [LevelChunkDefs.prop("broken_sign", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Barracks Yard", {
			"markers": {MapDefs.MARKER_PICKUP: 0.42, MapDefs.MARKER_DEFEND: 0.58},
			"props": [LevelChunkDefs.prop("ammo_crate", 0.35), LevelChunkDefs.prop("container_stack", 0.72)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Servant Passage", {
			"props": [LevelChunkDefs.prop("barrel", 0.45)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Inner Bridge", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Great Hall", {
			"markers": {MapDefs.MARKER_DESTROY: 0.6},
			"props": [LevelChunkDefs.prop("sandbags", 0.3), LevelChunkDefs.prop("barrel", 0.8)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Courtyard Assault", {
			"props": [LevelChunkDefs.prop("sandbags", 0.15), LevelChunkDefs.prop("barbed_wire", 0.45), LevelChunkDefs.prop("sandbags", 0.85)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Throne Room", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Escape Route", {
			"terrain": "step_down",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Courtyard Gate", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.4, MapDefs.MARKER_ESCORT_END: 0.55},
		}),
	]


static func _train() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Rear Car", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("container_stack", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Passenger Cars", {
			"props": [LevelChunkDefs.prop("barrel", 0.4), LevelChunkDefs.prop("sandbags", 0.75)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Rooftop Run", {
			"terrain": "dual_lane",
			"hazards": [LevelChunkDefs.hazard("scroll", 0.0, 1.0, {"speed": 55.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Cargo Hold", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("container_stack", 0.55)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Side Platform", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Station Platform", {
			"terrain": "flat",
			"props": [LevelChunkDefs.prop("broken_sign", 0.3)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Engine Car", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
			"props": [LevelChunkDefs.prop("pipe", 0.4)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Cargo Yard", {
			"hazards": [LevelChunkDefs.hazard("moving_cargo", 0.2, 0.7, {"speed": 40.0})],
			"props": [LevelChunkDefs.prop("container_stack", 0.25), LevelChunkDefs.prop("junk_truck", 0.65)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Bridge Overpass", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
			"terrain": "bridge",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Jump Section", {
			"terrain": "step_down",
			"hazards": [LevelChunkDefs.hazard("scroll", 0.3, 0.9, {"speed": 65.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Station Exit", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.45, MapDefs.MARKER_ESCORT_END: 0.6},
		}),
	]


static func _mine() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Surface Pit", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("rock_pile", 0.3), LevelChunkDefs.prop("barrel", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Mine Entrance", {
			"props": [LevelChunkDefs.prop("sandbags", 0.45), LevelChunkDefs.prop("container_stack", 0.75)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Tunnel Shaft", {
			"terrain": "step_down",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Crystal Cavern", {
			"markers": {MapDefs.MARKER_PICKUP: 0.5, MapDefs.MARKER_DEFEND: 0.65},
			"props": [LevelChunkDefs.prop("rock_pile", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Collapsed Side Tunnel", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.45)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Lift Shaft", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Generator Room", {
			"markers": {MapDefs.MARKER_DESTROY: 0.52},
			"props": [LevelChunkDefs.prop("pipe", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Deep Tunnel", {
			"props": [LevelChunkDefs.prop("barrel", 0.2), LevelChunkDefs.prop("rock_pile", 0.5), LevelChunkDefs.prop("barrel", 0.8)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Underground Reactor", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Escape Shaft", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Surface Evac", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.42, MapDefs.MARKER_ESCORT_END: 0.58},
			"props": [LevelChunkDefs.prop("junk_truck", 0.65)],
		}),
	]


static func _airship() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Stern Deck", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("container_stack", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Exterior Deck", {
			"hazards": [LevelChunkDefs.hazard("edge_gust", 0.0, 0.25, {"strength": 30.0}), LevelChunkDefs.hazard("edge_gust", 0.75, 1.0, {"strength": 30.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Balloon Supports", {
			"terrain": "bridge",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Cargo Bay", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("container_stack", 0.55)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Rigging Walkway", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Engine Room Access", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Engine Room", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
			"props": [LevelChunkDefs.prop("pipe", 0.4)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Main Deck", {
			"hazards": [LevelChunkDefs.hazard("wind", 0.1, 0.9, {"strength": 26.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Command Bridge", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Deck Escape", {
			"terrain": "step_down",
			"hazards": [LevelChunkDefs.hazard("edge_gust", 0.4, 0.8, {"strength": 35.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Parachute Point", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.45, MapDefs.MARKER_ESCORT_END: 0.6},
		}),
	]


static func _city() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Back Alley", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("junk_truck", 0.35), LevelChunkDefs.prop("barrel", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Street Fight", {
			"props": [LevelChunkDefs.prop("sandbags", 0.4), LevelChunkDefs.prop("junk_truck", 0.75)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Rooftop Crossing", {
			"terrain": "dual_lane",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Construction Site", {
			"markers": {MapDefs.MARKER_PICKUP: 0.45, MapDefs.MARKER_DEFEND: 0.6},
			"props": [LevelChunkDefs.prop("container_stack", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Subway Entrance", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.48)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Plaza Approach", {
			"terrain": "flat",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Antenna Tower", {
			"markers": {MapDefs.MARKER_DESTROY: 0.58},
			"props": [LevelChunkDefs.prop("broken_sign", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Central Plaza", {
			"props": [LevelChunkDefs.prop("sandbags", 0.2), LevelChunkDefs.prop("barrel", 0.5), LevelChunkDefs.prop("sandbags", 0.82)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Rooftop Boss Arena", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
			"terrain": "dual_lane",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Alley Escape", {
			"terrain": "step_down",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Evac Point", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.42, MapDefs.MARKER_ESCORT_END: 0.55},
		}),
	]


static func _dam() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Spillway Entry", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("sandbags", 0.3)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Exterior Wall", {
			"hazards": [LevelChunkDefs.hazard("water_spray", 0.6, 0.85, {"force": 65.0, "interval": 5.0, "duration": 1.5})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Spillway Bridge", {
			"terrain": "bridge",
			"hazards": [LevelChunkDefs.hazard("water_spray", 0.2, 0.5, {"force": 55.0, "interval": 6.0, "duration": 1.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Turbine Room", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("pipe", 0.4)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Maintenance Tunnel", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Control Center Access", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Control Center", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Floodgate Platform", {
			"hazards": [LevelChunkDefs.hazard("wave", 0.3, 0.8, {"speed": 14.0, "interval": 4.0, "duration": 1.5})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Dam Crest", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
			"terrain": "bridge",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Emergency Spillway", {
			"terrain": "step_down",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Evac Bridge", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.45, MapDefs.MARKER_ESCORT_END: 0.6},
		}),
	]


static func _volcano() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Lava Field Edge", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("rock_pile", 0.35)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Ash Flats", {
			"hazards": [LevelChunkDefs.hazard("eruption", 0.4, 0.7, {"force": 100.0, "interval": 6.0, "duration": 1.2})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Magma Bridge", {
			"terrain": "bridge",
			"hazards": [LevelChunkDefs.hazard("eruption", 0.3, 0.6, {"force": 90.0, "interval": 5.0, "duration": 1.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Drill Site", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("barrel", 0.55)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Cave Bypass", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.45)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Summit Approach", {
			"terrain": "step_up",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Crater Rim", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Lava Fields", {
			"hazards": [LevelChunkDefs.hazard("eruption", 0.1, 0.9, {"force": 110.0, "interval": 4.5, "duration": 1.3})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Summit Crater", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Collapse Route", {
			"terrain": "step_down",
			"hazards": [LevelChunkDefs.hazard("eruption", 0.2, 0.8, {"force": 95.0, "interval": 3.5, "duration": 1.0})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Evac Ridge", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.42, MapDefs.MARKER_ESCORT_END: 0.58},
		}),
	]


static func _harbor() -> Array:
	return [
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SPAWN, "Dock Entry", {
			"markers": {MapDefs.MARKER_ESCORT_START: 0.5},
			"props": [LevelChunkDefs.prop("container_stack", 0.3), LevelChunkDefs.prop("barrel", 0.65)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.COMBAT, "Warehouse Row", {
			"props": [LevelChunkDefs.prop("container_stack", 0.45), LevelChunkDefs.prop("junk_truck", 0.78)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Crane Walkway", {
			"terrain": "bridge",
			"hazards": [LevelChunkDefs.hazard("wave", 0.5, 0.9, {"speed": 12.0, "interval": 5.0, "duration": 1.5})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Cargo Ship", {
			"markers": {MapDefs.MARKER_PICKUP: 0.48, MapDefs.MARKER_DEFEND: 0.62},
			"props": [LevelChunkDefs.prop("container_stack", 0.55)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.SECRET, "Smuggler Path", {
			"props": [LevelChunkDefs.prop("ammo_crate", 0.5)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.TRAVERSAL, "Pier Crossing", {
			"terrain": "flat",
			"hazards": [LevelChunkDefs.hazard("wave", 0.0, 0.4, {"speed": 10.0, "interval": 6.0, "duration": 1.2})],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.OBJECTIVE, "Lighthouse Base", {
			"markers": {MapDefs.MARKER_DESTROY: 0.55},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.LARGE_COMBAT, "Main Docks", {
			"hazards": [LevelChunkDefs.hazard("wave", 0.2, 0.75, {"speed": 13.0, "interval": 4.0, "duration": 1.4})],
			"props": [LevelChunkDefs.prop("barrel", 0.25), LevelChunkDefs.prop("container_stack", 0.7)],
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.BOSS, "Cargo Ship Deck", {
			"markers": {MapDefs.MARKER_BOSS: 0.5},
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.ESCAPE, "Pier Escape", {
			"terrain": "step_down",
		}),
		LevelChunkDefs.build(LevelChunkDefs.ChunkRole.EXTRACT, "Evac Boat", {
			"markers": {MapDefs.MARKER_EXTRACT: 0.45, MapDefs.MARKER_ESCORT_END: 0.6},
			"props": [LevelChunkDefs.prop("junk_truck", 0.3)],
		}),
	]
