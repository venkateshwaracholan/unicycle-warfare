class_name LevelAssembler

## Assembles modular chunks into a mission-sized world.

var map_id: MapDefs.MapId = MapDefs.MapId.DESERT
var base_ground_y := 490.0
var world_width := 1280.0
var world_left := 80.0
var world_right := 1200.0

var chunks: Array[Dictionary] = []
var sections: Array[Dictionary] = []
var platforms: Array[Dictionary] = []
var markers: Dictionary = {}
var spawn_points: Array[Vector2] = []
var enemy_zones: Array[Dictionary] = []
var props: Array[Dictionary] = []
var hazards: Array[Dictionary] = []


static func assemble(map_id: MapDefs.MapId) -> LevelAssembler:
	var assembler := LevelAssembler.new()
	assembler.build(map_id)
	return assembler


static func _pf(entry: Dictionary, key: String, default: float = 0.0) -> float:
	return float(entry.get(key, default))


func build(map_id: MapDefs.MapId) -> void:
	self.map_id = map_id
	chunks.clear()
	sections.clear()
	platforms.clear()
	markers.clear()
	spawn_points.clear()
	enemy_zones.clear()
	props.clear()
	hazards.clear()

	var map: Dictionary = MapDefs.get_map(map_id)
	base_ground_y = float(map.get("ground_y", 490.0))
	var layout: Array = LevelLayoutDefs.get_layout(map_id)

	var cursor_x := 80.0
	for chunk_variant in layout:
		var chunk: Dictionary = chunk_variant
		_place_chunk(chunk, cursor_x)
		cursor_x += float(chunk.get("width", 1000.0))

	world_width = cursor_x + 80.0
	world_right = world_width - 80.0
	world_left = 80.0

	_finalize_spawns()


func _place_chunk(chunk: Dictionary, origin_x: float) -> void:
	var width := float(chunk.get("width", 1000.0))
	var role: int = chunk.get("role", LevelChunkDefs.ChunkRole.TRAVERSAL)
	var surface_base := base_ground_y - 20.0

	sections.append({
		"label": chunk.get("label", ""),
		"role": role,
		"x0": origin_x,
		"x1": origin_x + width,
	})

	for plat_variant in chunk.get("platforms", []):
		if not plat_variant is Dictionary:
			continue
		var plat: Dictionary = plat_variant
		var y_off := float(plat.get("y", 0.0))
		platforms.append({
			"x": origin_x + float(plat.get("x", 0.0)),
			"y": surface_base + y_off,
			"w": float(plat.get("w", width)),
			"h": float(plat.get("h", LevelChunkDefs.PLATFORM_H)),
		})

	for marker_id in chunk.get("markers", {}):
		var nx: float = float(chunk.markers[marker_id])
		var pos: Vector2 = _marker_pos(origin_x, width, nx, surface_base, chunk)
		markers[str(marker_id)] = pos

	var ez: Dictionary = chunk.get("enemy_zone", {})
	if not ez.is_empty():
		enemy_zones.append({
			"x0": origin_x + width * float(ez.get("x0", 0.12)),
			"x1": origin_x + width * float(ez.get("x1", 0.88)),
			"role": role,
		})

	for prop_variant in chunk.get("props", []):
		if not prop_variant is Dictionary:
			continue
		var prop: Dictionary = prop_variant
		var nx: float = float(prop.get("nx", 0.5))
		var surface_y := _surface_y_at(origin_x + width * nx, surface_base)
		props.append({
			"type": str(prop.get("type", "")),
			"pos": Vector2(origin_x + width * nx, surface_y - 14.0),
			"scale": float(prop.get("scale", 1.0)),
		})

	for hazard_variant in chunk.get("hazards", []):
		if not hazard_variant is Dictionary:
			continue
		var hazard: Dictionary = hazard_variant
		var h: Dictionary = hazard.duplicate()
		h["x0"] = origin_x + width * float(hazard.get("x0", 0.0))
		h["x1"] = origin_x + width * float(hazard.get("x1", 1.0))
		hazards.append(h)

	chunks.append({
		"chunk": chunk,
		"origin_x": origin_x,
		"width": width,
	})


func _marker_pos(origin_x: float, width: float, norm_x: float, surface_base: float, chunk: Dictionary) -> Vector2:
	var world_x := origin_x + width * norm_x
	var y_off := 0.0
	for plat_variant in chunk.get("platforms", []):
		if not plat_variant is Dictionary:
			continue
		var plat: Dictionary = plat_variant
		var px := float(plat.get("x", 0.0))
		var pw := float(plat.get("w", width))
		var local_x := world_x - origin_x
		if local_x >= px - 1.0 and local_x <= px + pw + 1.0:
			y_off = float(plat.get("y", 0.0))
			break
	return Vector2(world_x, surface_base + y_off)


func _surface_y_at(world_x: float, surface_base: float) -> float:
	var best_y := surface_base
	for plat in platforms:
		if world_x >= _pf(plat, "x") - 1.0 and world_x <= _pf(plat, "x") + _pf(plat, "w") + 1.0:
			best_y = minf(best_y, _pf(plat, "y"))
	return best_y


func _finalize_spawns() -> void:
	if chunks.is_empty():
		spawn_points = [Vector2(200, base_ground_y - 70), Vector2(world_right - 120, base_ground_y - 70)]
		return
	var first: Dictionary = chunks[0]
	var origin_x := float(first.get("origin_x", 0.0))
	var width := float(first.get("width", 1000.0))
	var surface_base := base_ground_y - 20.0
	var p1_x := origin_x + width * 0.22
	var p2_x := origin_x + width * 0.78
	spawn_points = [
		Vector2(p1_x, _surface_y_at(p1_x, surface_base) - 70.0),
		Vector2(p2_x, _surface_y_at(p2_x, surface_base) - 70.0),
	]


func ground_surface_at(world_x: float) -> float:
	var surface_base := base_ground_y - 20.0
	var best_y := surface_base + 9999.0
	var found := false
	for plat in platforms:
		if world_x >= _pf(plat, "x") - 2.0 and world_x <= _pf(plat, "x") + _pf(plat, "w") + 2.0:
			best_y = minf(best_y, _pf(plat, "y"))
			found = true
	if not found:
		return surface_base
	return best_y


func resolve_marker(marker_id: String) -> Vector2:
	if markers.has(marker_id):
		return markers[marker_id] as Vector2
	var fallback_x := world_left + (world_right - world_left) * 0.5
	return Vector2(fallback_x, ground_surface_at(fallback_x))


func enemy_spawn_positions(count: int, seed_index: int = 0) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if enemy_zones.is_empty():
		var cx := world_left + (world_right - world_left) * 0.65
		for i in count:
			var t := float(i % 5) / 4.0 if count > 1 else 0.5
			var x := lerpf(cx - 200.0, cx + 200.0, t)
			positions.append(Vector2(x, ground_surface_at(x)))
		return positions

	for i in count:
		var zone: Dictionary = enemy_zones[(seed_index + i) % enemy_zones.size()]
		var t := float(i % 5) / 4.0 if count > 1 else 0.5
		var x := lerpf(_pf(zone, "x0"), _pf(zone, "x1"), t)
		positions.append(Vector2(x, ground_surface_at(x)))
	return positions


func section_at(world_x: float) -> Dictionary:
	for section in sections:
		if world_x >= _pf(section, "x0") and world_x <= _pf(section, "x1"):
			return section
	return {}
