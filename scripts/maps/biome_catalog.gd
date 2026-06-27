class_name BiomeCatalog

## Data-driven visuals + hazards per map. Props are reusable kinds placed by normalized X (0–1).

const PLAY_LEFT := 80.0
const PLAY_RIGHT := 1200.0
const PLAY_WIDTH := PLAY_RIGHT - PLAY_LEFT


static func play_x(norm_x: float) -> float:
	return PLAY_LEFT + clampf(norm_x, 0.0, 1.0) * PLAY_WIDTH


static func get_visual(map_id: MapDefs.MapId) -> Dictionary:
	return VISUALS.get(map_id, VISUALS[MapDefs.MapId.DESERT])


static func get_hazards(map_id: MapDefs.MapId) -> Array:
	return get_visual(map_id).get("hazards", [])


static func get_particle_kind(map_id: MapDefs.MapId) -> String:
	return get_visual(map_id).get("particles", "")


static func get_platform_props(map_id: MapDefs.MapId) -> Array:
	return get_visual(map_id).get("platform", DEFAULT_PLATFORM_PROPS)


const DEFAULT_PLATFORM_PROPS := [
	{"type": "sandbags", "x": 0.07, "scale": 1.0},
	{"type": "barrel", "x": 0.2, "scale": 1.0},
	{"type": "ammo_crate", "x": 0.35, "scale": 1.0},
	{"type": "broken_sign", "x": 0.48, "scale": 1.0},
	{"type": "barbed_wire", "x": 0.58, "scale": 1.0},
	{"type": "junk_truck", "x": 0.72, "scale": 0.85},
	{"type": "rock_pile", "x": 0.84, "scale": 1.0},
	{"type": "tire_stack", "x": 0.93, "scale": 0.9},
]


const VISUALS := {
	MapDefs.MapId.DESERT: {
		"tagline": "War-torn dunes · gusting wind",
		"particles": "dust",
		"light_tint": Color(1.0, 0.88, 0.65, 0.14),
		"bg_silhouette": "desert_hills",
		"platform": [
			{"type": "sandbags", "x": 0.06, "scale": 1.1},
			{"type": "barrel", "x": 0.18, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.32, "scale": 1.0},
			{"type": "broken_sign", "x": 0.44, "scale": 1.0},
			{"type": "sandbags", "x": 0.56, "scale": 0.9},
			{"type": "junk_truck", "x": 0.7, "scale": 0.9},
			{"type": "barrel", "x": 0.82, "scale": 1.0},
			{"type": "rock_pile", "x": 0.92, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "dune", "x": 0.08, "scale": 1.3},
				{"type": "dune", "x": 0.35, "scale": 0.9},
				{"type": "dune", "x": 0.72, "scale": 1.1},
				{"type": "rock_arch", "x": 0.88, "scale": 1.0},
			],
			"mid": [
				{"type": "windmill", "x": 0.14, "scale": 1.0},
				{"type": "junk_truck", "x": 0.28, "scale": 0.75},
				{"type": "cactus", "x": 0.42, "scale": 1.0},
				{"type": "wagon", "x": 0.58, "scale": 1.0},
				{"type": "barrel", "x": 0.68, "scale": 0.85},
				{"type": "windmill", "x": 0.82, "scale": 0.9},
			],
			"fg": [
				{"type": "sandbags", "x": 0.1, "scale": 1.15},
				{"type": "cactus", "x": 0.24, "scale": 1.2},
				{"type": "wagon_wheel", "x": 0.62, "scale": 1.0},
				{"type": "rock_pile", "x": 0.88, "scale": 0.9},
			],
		},
		"hazards": [
			{"type": "wind", "x0": 0.0, "x1": 1.0, "strength": 28.0, "interval": 9.0, "duration": 3.5},
		],
	},
	MapDefs.MapId.FACTORY: {
		"tagline": "Conveyors · steam bursts",
		"particles": "steam",
		"light_tint": Color(1.0, 0.55, 0.2, 0.1),
		"bg_silhouette": "factory_skyline",
		"platform": [
			{"type": "ammo_crate", "x": 0.08, "scale": 1.0},
			{"type": "barrel", "x": 0.22, "scale": 1.0},
			{"type": "tire_stack", "x": 0.38, "scale": 1.0},
			{"type": "sandbags", "x": 0.52, "scale": 1.05},
			{"type": "broken_sign", "x": 0.65, "scale": 0.9},
			{"type": "barrel", "x": 0.78, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.9, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "factory_stack", "x": 0.12, "scale": 1.0},
				{"type": "factory_stack", "x": 0.85, "scale": 1.2},
				{"type": "crane", "x": 0.55, "scale": 1.0},
			],
			"mid": [
				{"type": "pipe", "x": 0.25, "scale": 1.0},
				{"type": "gear", "x": 0.45, "scale": 1.1},
				{"type": "gear", "x": 0.68, "scale": 0.8},
				{"type": "warning_light", "x": 0.82, "scale": 1.0},
			],
			"fg": [
				{"type": "conveyor", "x": 0.35, "scale": 1.0},
				{"type": "chain", "x": 0.72, "scale": 1.0},
				{"type": "steam_vent", "x": 0.52, "scale": 1.0},
			],
		},
		"hazards": [
			{"type": "conveyor", "x0": 0.28, "x1": 0.48, "speed": 38.0},
			{"type": "conveyor", "x0": 0.62, "x1": 0.78, "speed": -32.0},
			{"type": "steam", "x0": 0.48, "x1": 0.58, "force": 120.0, "interval": 6.0, "duration": 1.2},
		],
	},
	MapDefs.MapId.CASTLE: {
		"tagline": "Choke points · high ground",
		"particles": "ember",
		"light_tint": Color(1.0, 0.7, 0.35, 0.1),
		"bg_silhouette": "castle_wall",
		"platform": [
			{"type": "sandbags", "x": 0.1, "scale": 1.1},
			{"type": "barrel", "x": 0.24, "scale": 1.0},
			{"type": "rock_pile", "x": 0.4, "scale": 1.1},
			{"type": "barbed_wire", "x": 0.55, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.68, "scale": 1.0},
			{"type": "broken_sign", "x": 0.82, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "castle_tower", "x": 0.1, "scale": 1.2},
				{"type": "castle_tower", "x": 0.9, "scale": 1.3},
				{"type": "battlement", "x": 0.5, "scale": 1.0},
			],
			"mid": [
				{"type": "banner", "x": 0.22, "scale": 1.0},
				{"type": "torch", "x": 0.38, "scale": 1.0},
				{"type": "wood_bridge", "x": 0.55, "scale": 1.0},
				{"type": "torch", "x": 0.72, "scale": 1.0},
				{"type": "catapult", "x": 0.86, "scale": 0.9},
			],
			"fg": [
				{"type": "stone_pillar", "x": 0.32, "scale": 1.0},
				{"type": "stone_pillar", "x": 0.68, "scale": 1.0},
			],
		},
		"hazards": [],
	},
	MapDefs.MapId.TRAIN: {
		"tagline": "Moving cars · changing ground",
		"particles": "smoke",
		"light_tint": Color(0.85, 0.85, 0.95, 0.08),
		"bg_silhouette": "train_trestle",
		"platform": [
			{"type": "cargo_crate", "x": 0.12, "scale": 1.0},
			{"type": "barrel", "x": 0.28, "scale": 1.0},
			{"type": "cargo_crate", "x": 0.44, "scale": 1.0},
			{"type": "tire_stack", "x": 0.58, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.72, "scale": 1.0},
			{"type": "barrel", "x": 0.86, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "tunnel", "x": 0.15, "scale": 1.0},
				{"type": "train_bridge", "x": 0.5, "scale": 1.0},
			],
			"mid": [
				{"type": "train_car", "x": 0.28, "scale": 1.0, "phase": 0.0},
				{"type": "train_car", "x": 0.52, "scale": 1.0, "phase": 0.33},
				{"type": "train_car", "x": 0.76, "scale": 1.0, "phase": 0.66},
				{"type": "signal", "x": 0.88, "scale": 1.0},
			],
			"fg": [
				{"type": "cargo_crate", "x": 0.4, "scale": 1.0},
				{"type": "cargo_crate", "x": 0.64, "scale": 1.0},
			],
		},
		"hazards": [
			{"type": "scroll", "x0": 0.0, "x1": 1.0, "speed": 18.0},
		],
	},
	MapDefs.MapId.MINE: {
		"tagline": "Tight tunnels · low ceiling",
		"particles": "dust",
		"light_tint": Color(0.6, 0.85, 1.0, 0.08),
		"bg_silhouette": "mine_cave",
		"platform": [
			{"type": "rock_pile", "x": 0.1, "scale": 1.0},
			{"type": "barrel", "x": 0.26, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.42, "scale": 1.0},
			{"type": "sandbags", "x": 0.56, "scale": 0.95},
			{"type": "barrel", "x": 0.7, "scale": 1.0},
			{"type": "rock_pile", "x": 0.86, "scale": 1.1},
		],
		"layers": {
			"bg": [
				{"type": "cave_mouth", "x": 0.08, "scale": 1.0},
				{"type": "crystal_cluster", "x": 0.92, "scale": 1.0},
			],
			"mid": [
				{"type": "mine_support", "x": 0.22, "scale": 1.0},
				{"type": "mine_rail", "x": 0.5, "scale": 1.0},
				{"type": "mine_support", "x": 0.78, "scale": 1.0},
				{"type": "mine_cart", "x": 0.38, "scale": 1.0},
				{"type": "lantern", "x": 0.62, "scale": 1.0},
			],
			"fg": [
				{"type": "crystal", "x": 0.48, "scale": 1.0},
			],
		},
		"hazards": [],
	},
	MapDefs.MapId.AIRSHIP: {
		"tagline": "Open deck · strong gusts",
		"particles": "cloud",
		"light_tint": Color(0.75, 0.88, 1.0, 0.12),
		"bg_silhouette": "sky_clouds",
		"platform": [
			{"type": "ammo_crate", "x": 0.14, "scale": 1.0},
			{"type": "barrel", "x": 0.3, "scale": 1.0},
			{"type": "sandbags", "x": 0.48, "scale": 1.0},
			{"type": "tire_stack", "x": 0.62, "scale": 0.9},
			{"type": "barrel", "x": 0.76, "scale": 1.0},
			{"type": "broken_sign", "x": 0.9, "scale": 0.85},
		],
		"layers": {
			"bg": [
				{"type": "cloud", "x": 0.2, "scale": 1.2},
				{"type": "cloud", "x": 0.65, "scale": 1.4},
			],
			"mid": [
				{"type": "balloon", "x": 0.12, "scale": 0.9},
				{"type": "airship_engine", "x": 0.35, "scale": 1.0},
				{"type": "propeller", "x": 0.58, "scale": 1.0},
				{"type": "rope_rig", "x": 0.78, "scale": 1.0},
			],
			"fg": [
				{"type": "floating_platform", "x": 0.45, "scale": 1.0},
			],
		},
		"hazards": [
			{"type": "wind", "x0": 0.0, "x1": 1.0, "strength": 34.0, "interval": 7.0, "duration": 4.0},
			{"type": "edge_gust", "x0": 0.0, "x1": 0.12, "strength": 20.0, "interval": 4.0, "duration": 2.0},
			{"type": "edge_gust", "x0": 0.88, "x1": 1.0, "strength": -20.0, "interval": 4.0, "duration": 2.0},
		],
	},
	MapDefs.MapId.CITY: {
		"tagline": "Rooftops · vertical lanes",
		"particles": "rain_mist",
		"light_tint": Color(0.55, 0.75, 1.0, 0.1),
		"bg_silhouette": "city_skyline",
		"platform": [
			{"type": "sandbags", "x": 0.08, "scale": 1.0},
			{"type": "barrel", "x": 0.22, "scale": 1.0},
			{"type": "tire_stack", "x": 0.36, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.5, "scale": 1.0},
			{"type": "barbed_wire", "x": 0.64, "scale": 1.0},
			{"type": "junk_truck", "x": 0.78, "scale": 0.75},
			{"type": "barrel", "x": 0.9, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "skyscraper", "x": 0.1, "scale": 1.2},
				{"type": "skyscraper", "x": 0.35, "scale": 1.5},
				{"type": "skyscraper", "x": 0.7, "scale": 1.3},
				{"type": "skyscraper", "x": 0.92, "scale": 1.0},
			],
			"mid": [
				{"type": "billboard", "x": 0.28, "scale": 1.0},
				{"type": "water_tower", "x": 0.52, "scale": 1.0},
				{"type": "construction_crane", "x": 0.78, "scale": 1.0},
				{"type": "fire_escape", "x": 0.62, "scale": 1.0},
			],
			"fg": [
				{"type": "neon_sign", "x": 0.42, "scale": 1.0},
				{"type": "rooftop_ac", "x": 0.68, "scale": 1.0},
			],
		},
		"hazards": [],
	},
	MapDefs.MapId.DAM: {
		"tagline": "Narrow bridge · water spray",
		"particles": "mist",
		"light_tint": Color(0.7, 0.9, 1.0, 0.1),
		"bg_silhouette": "dam_wall",
		"platform": [
			{"type": "sandbags", "x": 0.12, "scale": 1.0},
			{"type": "barrel", "x": 0.28, "scale": 1.0},
			{"type": "rock_pile", "x": 0.44, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.58, "scale": 1.0},
			{"type": "barrel", "x": 0.72, "scale": 1.0},
			{"type": "broken_sign", "x": 0.86, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "dam_wall", "x": 0.5, "scale": 1.0},
				{"type": "spillway", "x": 0.62, "scale": 1.0},
			],
			"mid": [
				{"type": "turbine", "x": 0.35, "scale": 1.0},
				{"type": "walkway", "x": 0.55, "scale": 1.0},
				{"type": "water_spray", "x": 0.68, "scale": 1.0},
			],
			"fg": [
				{"type": "buoy_dam", "x": 0.22, "scale": 1.0},
				{"type": "maintenance_rail", "x": 0.78, "scale": 1.0},
			],
		},
		"hazards": [
			{"type": "water_spray", "x0": 0.58, "x1": 0.72, "force": 90.0, "interval": 5.0, "duration": 2.0},
		],
	},
	MapDefs.MapId.VOLCANO: {
		"tagline": "Lava vents · eruptions",
		"particles": "ash",
		"light_tint": Color(1.0, 0.45, 0.15, 0.14),
		"bg_silhouette": "volcano_peak",
		"platform": [
			{"type": "rock_pile", "x": 0.1, "scale": 1.1},
			{"type": "barrel", "x": 0.26, "scale": 1.0},
			{"type": "sandbags", "x": 0.42, "scale": 1.0},
			{"type": "barrel", "x": 0.58, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.72, "scale": 1.0},
			{"type": "rock_pile", "x": 0.88, "scale": 1.0},
		],
		"layers": {
			"bg": [
				{"type": "volcano_peak", "x": 0.88, "scale": 1.0},
				{"type": "lava_river", "x": 0.25, "scale": 1.0},
			],
			"mid": [
				{"type": "cracked_rock", "x": 0.32, "scale": 1.0},
				{"type": "magma_vent", "x": 0.55, "scale": 1.0},
				{"type": "smoke_column", "x": 0.78, "scale": 1.0},
			],
			"fg": [
				{"type": "cracked_rock", "x": 0.48, "scale": 0.8},
			],
		},
		"hazards": [
			{"type": "eruption", "x0": 0.48, "x1": 0.62, "force": 200.0, "interval": 11.0, "duration": 1.5},
		],
	},
	MapDefs.MapId.HARBOR: {
		"tagline": "Open docks · shifting cargo",
		"particles": "mist",
		"light_tint": Color(0.85, 0.95, 1.0, 0.08),
		"bg_silhouette": "harbor_skyline",
		"platform": [
			{"type": "cargo_crate", "x": 0.1, "scale": 1.0},
			{"type": "barrel", "x": 0.26, "scale": 1.0},
			{"type": "cargo_crate", "x": 0.42, "scale": 1.0},
			{"type": "tire_stack", "x": 0.56, "scale": 1.0},
			{"type": "ammo_crate", "x": 0.7, "scale": 1.0},
			{"type": "barrel", "x": 0.84, "scale": 1.0},
			{"type": "sandbags", "x": 0.94, "scale": 0.9},
		],
		"layers": {
			"bg": [
				{"type": "ship", "x": 0.15, "scale": 1.0},
				{"type": "ship", "x": 0.82, "scale": 1.1},
			],
			"mid": [
				{"type": "container_stack", "x": 0.38, "scale": 1.0},
				{"type": "dock_crane", "x": 0.58, "scale": 1.0},
				{"type": "container_stack", "x": 0.72, "scale": 1.0},
			],
			"fg": [
				{"type": "wooden_dock", "x": 0.5, "scale": 1.0},
				{"type": "buoy", "x": 0.28, "scale": 1.0},
				{"type": "wave", "x": 0.65, "scale": 1.0},
			],
		},
		"hazards": [
			{"type": "wave", "x0": 0.0, "x1": 0.25, "speed": 14.0, "interval": 3.0, "duration": 2.0},
			{"type": "moving_cargo", "x0": 0.55, "x1": 0.7, "speed": 22.0},
		],
	},
}
