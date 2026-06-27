extends Node2D
class_name Arena

@export var map_id: MapDefs.MapId = MapDefs.MapId.DESERT

var ground_y := 490.0
var spawn_points: Array[Vector2] = []
var weapon_spawns: Array[Vector2] = []

var _backdrop: BiomeVisual
var _foreground: BiomeVisual
var _environment: MapEnvironment
var _arena_time := 0.0
var _destructibles: Array[Node] = []


func ground_surface_y() -> float:
	return ground_y - 20.0


func get_environment() -> MapEnvironment:
	return _environment


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


func _process(delta: float) -> void:
	_arena_time += delta
	if _environment == null or _backdrop == null:
		return
	var scroll := _environment.scroll_offset
	_backdrop.set_scroll(scroll)
	_foreground.set_scroll(scroll)
	queue_redraw()


func _configure_map() -> void:
	spawn_points.clear()
	weapon_spawns.clear()

	var map: Dictionary = MapDefs.get_map(map_id)
	ground_y = float(map.get("ground_y", 490.0))
	spawn_points.assign(map.get("spawn_points", [Vector2(220, 420), Vector2(1060, 420)]))

	var spread: Dictionary = map.get("weapon_spread", {"cx": 640.0, "floor_y": 455.0, "width": 520.0})
	weapon_spawns = _scatter_weapons(
		float(spread.get("cx", 640.0)),
		float(spread.get("floor_y", 455.0)),
		float(spread.get("width", 520.0))
	)

	_refresh_biome(map)


func _refresh_biome(map: Dictionary) -> void:
	_ensure_biome_nodes()
	var surface := ground_surface_y()
	var palette := {
		"sky": map.get("sky", Color(0.6, 0.7, 0.8)),
		"ground": map.get("ground", Color(0.4, 0.35, 0.3)),
		"platform": map.get("platform", Color(0.5, 0.45, 0.4)),
	}
	_backdrop.configure(map_id, surface, palette)
	_foreground.configure(map_id, surface, palette)
	_environment.configure(map_id)
	_spawn_destructibles(map)
	queue_redraw()


func _clear_destructibles() -> void:
	for node in _destructibles:
		if is_instance_valid(node):
			node.queue_free()
	_destructibles.clear()


func _spawn_destructibles(_map: Dictionary) -> void:
	_clear_destructibles()
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
	var surface := ground_surface_y()

	draw_rect(Rect2(-200, -600, 1600, surface + 600), map.get("sky", Color(0.62, 0.78, 0.62)))
	draw_rect(Rect2(-200, surface, 1600, 600), map.get("ground", Color(0.42, 0.3, 0.18)))
	draw_rect(Rect2(80, surface - 14, 1120, 14), map.get("platform", Color(0.58, 0.42, 0.28)))
	_draw_platform_wear(surface, map)
	_draw_platform_props(surface, map)
	_draw_side_walls(surface)


func _draw_platform_wear(surface: float, map: Dictionary) -> void:
	var platform_color: Color = map.get("platform", Color(0.58, 0.42, 0.28))
	for i in 12:
		var x := 120.0 + i * 88.0
		draw_line(Vector2(x, surface - 13), Vector2(x + 24, surface - 13), platform_color.darkened(0.08), 1.0)
	for i in 8:
		var hx := 160.0 + i * 130.0
		draw_circle(Vector2(hx, surface - 8), 2.0, Color(0.22, 0.18, 0.14, 0.35))


func _draw_platform_props(surface: float, map: Dictionary) -> void:
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
