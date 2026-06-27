extends Node2D
class_name Arena

@export var map_id: MapDefs.MapId = MapDefs.MapId.DESERT

var ground_y := 490.0
var spawn_points: Array[Vector2] = []
var weapon_spawns: Array[Vector2] = []

func ground_surface_y() -> float:
	return ground_y - 20.0

func _ready() -> void:
	add_to_group("arena")
	_configure_map()
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

func cycle_map() -> void:
	var ids: Array[MapDefs.MapId] = MapDefs.list_map_ids()
	var index: int = ids.find(map_id)
	index = (index + 1) % ids.size()
	map_id = ids[index]
	_configure_map()
	queue_redraw()

func _draw() -> void:
	var map: Dictionary = MapDefs.get_map(map_id)
	var surface := ground_surface_y()
	draw_rect(Rect2(-200, -600, 1600, surface + 600), map.get("sky", Color(0.62, 0.78, 0.62)))
	draw_rect(Rect2(-200, surface, 1600, 600), map.get("ground", Color(0.42, 0.3, 0.18)))
	draw_rect(Rect2(80, surface - 14, 1120, 14), map.get("platform", Color(0.58, 0.42, 0.28)))

	match map.get("biome", ""):
		"train":
			_draw_train_deco(surface)
		"city", "airship":
			_draw_rooftop_deco(surface)
		"dam", "harbor":
			_draw_bridge_deco(surface)
		"factory":
			_draw_factory_deco(surface)
		"castle":
			_draw_castle_deco(surface)
		"mine":
			_draw_mine_deco(surface)
		"volcano":
			_draw_volcano_deco(surface)

	_draw_side_walls(surface)

func _draw_side_walls(surface: float) -> void:
	draw_rect(Rect2(68, surface - 120, 14, 120), Color(0.45, 0.45, 0.48))
	draw_rect(Rect2(1198, surface - 120, 14, 120), Color(0.45, 0.45, 0.48))

func _draw_bridge_deco(surface: float) -> void:
	for i in range(2, 7):
		var cx := i * 180.0
		draw_arc(Vector2(cx, surface + 54), 48, PI, TAU, 16, Color(0.32, 0.24, 0.18), 8.0)

func _draw_train_deco(surface: float) -> void:
	for i in 3:
		var cx := 320.0 + i * 280.0
		draw_rect(Rect2(cx - 90, surface - 70, 180, 56), Color(0.55, 0.18, 0.18))

func _draw_rooftop_deco(surface: float) -> void:
	for i in 6:
		var h := 80 + (i * 37) % 120
		draw_rect(Rect2(-180 + i * 140, surface + 40, 100, h), Color(0.1, 0.12, 0.18))

func _draw_factory_deco(surface: float) -> void:
	for i in 4:
		var cx := 220.0 + i * 210.0
		draw_rect(Rect2(cx - 24, surface - 90, 48, 76), Color(0.28, 0.3, 0.32))
		draw_rect(Rect2(cx - 40, surface - 110, 80, 18), Color(0.35, 0.38, 0.4))

func _draw_castle_deco(surface: float) -> void:
	for i in 3:
		var cx := 280.0 + i * 320.0
		draw_rect(Rect2(cx - 36, surface - 100, 72, 86), Color(0.38, 0.34, 0.3))
		draw_rect(Rect2(cx - 48, surface - 118, 96, 16), Color(0.45, 0.4, 0.36))

func _draw_mine_deco(surface: float) -> void:
	for i in 5:
		var cx := 180.0 + i * 180.0
		draw_rect(Rect2(cx - 8, surface + 20, 16, 60 + (i * 11) % 40), Color(0.25, 0.22, 0.18))

func _draw_volcano_deco(surface: float) -> void:
	draw_circle(Vector2(1080, surface + 80), 70, Color(0.55, 0.18, 0.08))
	draw_circle(Vector2(1080, surface + 60), 36, Color(0.95, 0.45, 0.12))
