extends Node2D
class_name Arena

@export var map_id: MapDefs.MapId = MapDefs.MapId.DESERT

var ground_y := 490.0
var spawn_points: Array[Vector2] = []
var weapon_spawns: Array[Vector2] = []
var level: LevelAssembler = null
var mission_level := false

var _backdrop: BiomeVisual
var _foreground: BiomeVisual
var _environment: MapEnvironment
var _arena_time := 0.0
var _destructibles: Array[Node] = []
var _collision_root: Node2D
var _camera_scroll := 0.0


func ground_surface_y() -> float:
	if mission_level and level != null:
		return level.base_ground_y - 20.0
	return ground_y - 20.0


func ground_surface_at(world_x: float) -> float:
	if mission_level and level != null:
		return level.ground_surface_at(world_x)
	return ground_surface_y()


func world_width() -> float:
	if mission_level and level != null:
		return level.world_width
	return 1280.0


func world_left() -> float:
	if mission_level and level != null:
		return level.world_left
	return 80.0


func world_right() -> float:
	if mission_level and level != null:
		return level.world_right
	return 1200.0


func resolve_marker(marker_id: String) -> Vector2:
	if mission_level and level != null:
		return level.resolve_marker(marker_id)
	return MapDefs.resolve_marker(map_id, marker_id, ground_surface_y())


func player_safe_zone_end_x() -> float:
	if mission_level and level != null:
		return level.safe_zone_end_x
	var entry_x := world_left()
	for sp in spawn_points:
		entry_x = minf(entry_x, sp.x)
	return entry_x + MapDefs.PLAYER_SAFE_ZONE_MIN_WIDTH


func get_section_label(world_x: float) -> String:
	if mission_level and level != null:
		return level.section_at(world_x).get("label", "")
	return ""


func get_environment() -> MapEnvironment:
	return _environment


func set_camera_scroll(x: float) -> void:
	_camera_scroll = x
	if _backdrop:
		_backdrop.set_world_scroll(x)
	if _foreground:
		_foreground.set_world_scroll(x)


func _ready() -> void:
	add_to_group("arena")
	_ensure_biome_nodes()
	_configure_map()
	queue_redraw()


func _ensure_biome_nodes() -> void:
	if _backdrop != null:
		return
	_backdrop = BiomeVisual.new()
	_backdrop.name = "BiomeBackdrop"
	_backdrop.layer_kind = BiomeVisual.LayerKind.BACKDROP
	_backdrop.z_index = -10
	add_child(_backdrop)

	_foreground = BiomeVisual.new()
	_foreground.name = "BiomeForeground"
	_foreground.layer_kind = BiomeVisual.LayerKind.FOREGROUND
	_foreground.z_index = 5
	add_child(_foreground)

	_environment = MapEnvironment.new()
	_environment.name = "MapEnvironment"
	add_child(_environment)

	_collision_root = Node2D.new()
	_collision_root.name = "LevelCollision"
	add_child(_collision_root)


func _process(delta: float) -> void:
	_arena_time += delta
	if _environment == null or _backdrop == null:
		return
	var scroll := _environment.scroll_offset
	if not mission_level:
		_backdrop.set_scroll(scroll)
		_foreground.set_scroll(scroll)
	queue_redraw()


func _configure_map() -> void:
	spawn_points.clear()
	weapon_spawns.clear()
	level = null
	mission_level = GameManager.is_play_mode()

	var map: Dictionary = MapDefs.get_map(map_id)
	ground_y = float(map.get("ground_y", 490.0))

	if mission_level:
		_configure_mission_level(map)
	else:
		_configure_arena_mode(map)


func _configure_arena_mode(map: Dictionary) -> void:
	spawn_points.assign(map.get("spawn_points", [Vector2(220, 420), Vector2(1060, 420)]))
	var spread: Dictionary = map.get("weapon_spread", {"cx": 640.0, "floor_y": 455.0, "width": 520.0})
	weapon_spawns = _scatter_weapons(
		float(spread.get("cx", 640.0)),
		float(spread.get("floor_y", 455.0)),
		float(spread.get("width", 520.0))
	)
	_clear_collision()
	_refresh_biome(map)


func _configure_mission_level(map: Dictionary) -> void:
	level = LevelAssembler.assemble(map_id)
	spawn_points = level.spawn_points
	_clear_collision()
	_build_level_collision()
	_refresh_biome(map)
	if _environment:
		_environment.configure(map_id, level.hazards if not level.hazards.is_empty() else null)


func _refresh_biome(map: Dictionary) -> void:
	_ensure_biome_nodes()
	var surface := ground_surface_y()
	var palette := {
		"sky": map.get("sky", Color(0.6, 0.7, 0.8)),
		"ground": map.get("ground", Color(0.4, 0.35, 0.3)),
		"platform": map.get("platform", Color(0.5, 0.45, 0.4)),
	}
	var world_w := world_width()
	_backdrop.configure(map_id, surface, palette, world_w, mission_level)
	_foreground.configure(map_id, surface, palette, world_w, mission_level)
	if not mission_level:
		_environment.configure(map_id)
	_spawn_destructibles(map)
	queue_redraw()


func _clear_collision() -> void:
	if _collision_root == null:
		return
	for child in _collision_root.get_children():
		child.queue_free()


func _build_level_collision() -> void:
	if level == null:
		return
	for plat in level.platforms:
		var px := float(plat.get("x", 0.0))
		var py := float(plat.get("y", 0.0))
		var pw := float(plat.get("w", 0.0))
		var ph := float(plat.get("h", 14.0))
		var body := StaticBody2D.new()
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(pw, ph)
		shape.shape = rect
		shape.position = Vector2(px + pw * 0.5, py + ph * 0.5)
		body.add_child(shape)
		_collision_root.add_child(body)

	var surface := ground_surface_y()
	_add_boundary_wall(level.world_left - 14.0, surface, 14.0, 140.0)
	_add_boundary_wall(level.world_right + 7.0, surface, 14.0, 140.0)


func _add_boundary_wall(x: float, surface: float, w: float, h: float) -> void:
	var body := StaticBody2D.new()
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	shape.position = Vector2(x + w * 0.5, surface - h * 0.5 + 7.0)
	body.add_child(shape)
	_collision_root.add_child(body)


func _clear_destructibles() -> void:
	for node in _destructibles:
		if is_instance_valid(node):
			node.queue_free()
	_destructibles.clear()


func _spawn_destructibles(_map: Dictionary) -> void:
	_clear_destructibles()
	if mission_level and level != null:
		for prop in level.props:
			var prop_type := str(prop.get("type", ""))
			if prop_type not in ["barrel", "ammo_crate"]:
				continue
			var pos: Vector2 = prop.get("pos", Vector2.ZERO)
			var barrel := DestructibleProp.new()
			barrel.prop_type = prop_type
			barrel.draw_scale = float(prop.get("scale", 1.0))
			barrel.explosive = prop_type == "barrel"
			barrel.global_position = pos
			add_child(barrel)
			_destructibles.append(barrel)
		return

	var surface := ground_surface_y()
	for prop in BiomeCatalog.get_platform_props(map_id):
		if not prop is Dictionary:
			continue
		var prop_type := str(prop.get("type", ""))
		if prop_type not in ["barrel", "ammo_crate"]:
			continue
		var norm_x: float = float(prop.get("x", 0.5))
		var scale: float = float(prop.get("scale", 1.0))
		var x := BiomeCatalog.play_x(norm_x)
		var barrel := DestructibleProp.new()
		barrel.prop_type = prop_type
		barrel.draw_scale = scale
		barrel.explosive = prop_type == "barrel"
		barrel.global_position = Vector2(x, surface - 14.0)
		add_child(barrel)
		_destructibles.append(barrel)


func _scatter_weapons(cx: float, floor_y: float, width: float) -> Array[Vector2]:
	var pts: Array[Vector2] = []
	var count := 9
	for i in count:
		var t := float(i) / float(count - 1)
		var x: float = cx + lerp(-width * 0.5, width * 0.5, t) + randf_range(-20, 20)
		pts.append(Vector2(x, floor_y))
	return pts


func get_map_name() -> String:
	if mission_level and level != null:
		return "%s — Mission Route" % MapDefs.map_name(map_id)
	return MapDefs.map_name(map_id)


func get_biome_tagline() -> String:
	return BiomeCatalog.get_visual(map_id).get("tagline", "")


func cycle_map() -> void:
	var ids: Array[MapDefs.MapId] = MapDefs.list_map_ids()
	var index: int = ids.find(map_id)
	index = (index + 1) % ids.size()
	map_id = ids[index]
	_configure_map()


func _draw() -> void:
	var map: Dictionary = MapDefs.get_map(map_id)
	if mission_level and level != null:
		_draw_mission_level(map)
	else:
		_draw_arena_mode(map)


func _draw_arena_mode(map: Dictionary) -> void:
	var surface := ground_surface_y()
	draw_rect(Rect2(-200, -600, 1600, surface + 600), map.get("sky", Color(0.62, 0.78, 0.62)))
	draw_rect(Rect2(-200, surface, 1600, 600), map.get("ground", Color(0.42, 0.3, 0.18)))
	draw_rect(Rect2(80, surface - 14, 1120, 14), map.get("platform", Color(0.58, 0.42, 0.28)))
	_draw_platform_wear(surface, map, 80.0, 1120.0)
	_draw_platform_props(surface, map, false)
	_draw_side_walls(surface)


func _draw_mission_level(map: Dictionary) -> void:
	var surface := ground_surface_y()
	var left := level.world_left - 400.0
	var width := level.world_width + 800.0
	draw_rect(Rect2(left, -600, width, surface + 600), map.get("sky", Color(0.62, 0.78, 0.62)))
	draw_rect(Rect2(left, surface + 40, width, 800), map.get("ground", Color(0.42, 0.3, 0.18)))

	for plat in level.platforms:
		var px := float(plat.get("x", 0.0))
		var py := float(plat.get("y", 0.0))
		var pw := float(plat.get("w", 0.0))
		var ph := float(plat.get("h", 14.0))
		draw_rect(Rect2(px, py - ph, pw, ph), map.get("platform", Color(0.58, 0.42, 0.28)))
		_draw_platform_wear(py, map, px, pw)

	_draw_mission_ground_fill(map, surface)
	_draw_mission_props(map, surface)
	_draw_mission_section_labels()


func _draw_mission_ground_fill(map: Dictionary, surface: float) -> void:
	var ground_color: Color = map.get("ground", Color(0.42, 0.3, 0.18))
	for plat in level.platforms:
		var px := float(plat.get("x", 0.0))
		var py := float(plat.get("y", 0.0))
		var pw := float(plat.get("w", 0.0))
		draw_rect(Rect2(px, py, pw, surface + 200.0 - py), ground_color.darkened(0.04))


func _draw_mission_props(map: Dictionary, surface: float) -> void:
	var palette := {
		"sky": map.get("sky", Color(0.6, 0.7, 0.8)),
		"ground": map.get("ground", Color(0.4, 0.35, 0.3)),
		"platform": map.get("platform", Color(0.5, 0.45, 0.4)),
	}
	for prop in level.props:
		var prop_type := str(prop.get("type", ""))
		if prop_type in ["barrel", "ammo_crate"]:
			continue
		var pos: Vector2 = prop.get("pos", Vector2.ZERO)
		var scale: float = float(prop.get("scale", 1.0))
		BiomePropDraw.draw_prop(self, prop_type, pos, surface, scale, _arena_time, palette)


func _draw_mission_section_labels() -> void:
	for section in level.sections:
		var cx := (float(section.get("x0", 0.0)) + float(section.get("x1", 0.0))) * 0.5
		var label := str(section.get("label", ""))
		if label.is_empty():
			continue
		var surface_y := ground_surface_at(cx)
		if absf(cx - _camera_scroll - 640.0) > 900.0:
			continue
		draw_string(
			ThemeDB.fallback_font,
			Vector2(cx - label.length() * 3.5, surface_y - 52.0),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			11,
			Color(1.0, 0.92, 0.55, 0.55)
		)


func _draw_platform_wear(surface: float, map: Dictionary, start_x: float, span: float) -> void:
	var platform_color: Color = map.get("platform", Color(0.58, 0.42, 0.28))
	var segments := maxi(int(span / 88.0), 1)
	for i in segments:
		var x := start_x + 40.0 + i * 88.0
		if x > start_x + span - 20.0:
			break
		draw_line(Vector2(x, surface - 13), Vector2(x + 24, surface - 13), platform_color.darkened(0.08), 1.0)


func _draw_platform_props(surface: float, map: Dictionary, _mission: bool) -> void:
	var palette := {
		"sky": map.get("sky", Color(0.6, 0.7, 0.8)),
		"ground": map.get("ground", Color(0.4, 0.35, 0.3)),
		"platform": map.get("platform", Color(0.5, 0.45, 0.4)),
	}
	for prop in BiomeCatalog.get_platform_props(map_id):
		if not prop is Dictionary:
			continue
		var norm_x: float = float(prop.get("x", 0.5))
		var scale: float = float(prop.get("scale", 1.0))
		var prop_type := str(prop.get("type", ""))
		if prop_type in ["barrel", "ammo_crate"]:
			continue
		var x := BiomeCatalog.play_x(norm_x)
		BiomePropDraw.draw_prop(self, prop_type, Vector2(x, surface - 14), surface, scale, _arena_time, palette)


func _draw_side_walls(surface: float) -> void:
	var map: Dictionary = MapDefs.get_map(map_id)
	var platform_color: Color = map.get("platform", Color(0.45, 0.45, 0.48))
	var wall := platform_color.darkened(0.05)
	draw_rect(Rect2(68, surface - 120, 14, 120), wall)
	draw_rect(Rect2(1198, surface - 120, 14, 120), wall)
