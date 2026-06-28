class_name BiomeVisualPlan

## Rollout plan — flat UI environments (Getaway Shootout–inspired, vector not pixel).
##
## Phase 1 — Sky + skyline + lower wall shaft (COMPLETE via LevelEnvironmentDraw)
##   DESERT   dunes, warm sky, sand wall panels, cactus decor
##   CITY     cream towers + window grid, rooftop wall panels
##   HARBOR   terminal windows, water strip, dock wall panels
##
## Phase 2 — Interior / transit layers (scene defs ready, decor pass next)
##   FACTORY  orange sky glow, stack skyline, rivet wall panels
##   TRAIN    cargo-hold ceiling band, crate decor, metal wall panels
##   AIRSHIP  cloud deck, rope accents, hull wall panels below deck
##
## Phase 3 — Heavy structure biomes
##   CASTLE   battlements skyline, stone wall panels, banner decor
##   MINE     cave ceiling, timber supports, rock wall panels
##   DAM      spillway skyline, mist, concrete wall panels
##   VOLCANO  ember sky, lava glow strip, basalt wall panels
##
## Per-map keys live in BiomeSceneDefs. Bump "phase" when a map gets a decor pass.


static func phase_for(map_id: MapDefs.MapId) -> int:
	return int(BiomeSceneDefs.get_scene(map_id).get("phase", 1))


static func phase_label(phase: int) -> String:
	match phase:
		1:
			return "Phase 1 — sky & skyline"
		2:
			return "Phase 2 — interior transit"
		3:
			return "Phase 3 — heavy structure"
	return "Planned"
