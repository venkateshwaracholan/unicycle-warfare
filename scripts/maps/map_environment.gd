extends Node
class_name MapEnvironment

## Applies biome hazards — wind, conveyors, steam, scroll, eruptions, waves.

var map_id: MapDefs.MapId = MapDefs.MapId.DESERT
var scroll_offset := 0.0

var _hazards: Array = []
var _time := 0.0


func _ready() -> void:
	add_to_group("map_environment")


func configure(mid: MapDefs.MapId) -> void:
	map_id = mid
	_hazards = BiomeCatalog.get_hazards(mid)
	scroll_offset = 0.0
	_time = 0.0


func _physics_process(delta: float) -> void:
	_time += delta
	for h in _hazards:
		if str(h.get("type", "")) == "scroll":
			scroll_offset += float(h.get("speed", 0.0)) * delta


func sample(world_x: float, _world_y: float) -> Dictionary:
	var out := {
		"velocity_x": 0.0,
		"velocity_y": 0.0,
		"balance_push": 0.0,
		"impulse_x": 0.0,
		"impulse_y": 0.0,
	}
	for h in _hazards:
		if not _in_zone(h, world_x):
			continue
		var kind := str(h.get("type", ""))
		match kind:
			"wind", "edge_gust":
				if _pulse_active(h):
					var strength := float(h.get("strength", 20.0))
					out["velocity_x"] += strength * 0.35
					out["balance_push"] += strength * 0.012
			"conveyor", "moving_cargo":
				out["velocity_x"] += float(h.get("speed", 0.0))
			"scroll":
				out["velocity_x"] += float(h.get("speed", 0.0)) * 0.25
			"steam", "water_spray":
				if _pulse_active(h):
					out["impulse_y"] -= float(h.get("force", 80.0))
			"eruption":
				if _pulse_active(h):
					out["impulse_x"] += float(h.get("force", 120.0)) * 0.4
					out["impulse_y"] -= float(h.get("force", 120.0)) * 0.35
					out["balance_push"] += 0.08
			"wave":
				if _pulse_active(h):
					out["velocity_x"] += float(h.get("speed", 12.0))
					out["balance_push"] += 0.03
	return out


func get_wind_for_bullet(world_x: float) -> Vector2:
	var sample_result := sample(world_x, 0.0)
	return Vector2(sample_result["velocity_x"], sample_result["velocity_y"] * 0.15)


static func find_in_tree(tree: SceneTree) -> MapEnvironment:
	var nodes := tree.get_nodes_in_group("map_environment")
	if nodes.is_empty():
		return null
	return nodes[0] as MapEnvironment


func _in_zone(h: Dictionary, world_x: float) -> bool:
	var x0 := BiomeCatalog.play_x(float(h.get("x0", 0.0)))
	var x1 := BiomeCatalog.play_x(float(h.get("x1", 1.0)))
	return world_x >= minf(x0, x1) and world_x <= maxf(x0, x1)


func _pulse_active(h: Dictionary) -> bool:
	if not h.has("interval"):
		return true
	var interval := float(h.get("interval", 5.0))
	var duration := float(h.get("duration", 1.0))
	var cycle := interval + duration
	var t := fmod(_time, cycle)
	return t < duration
