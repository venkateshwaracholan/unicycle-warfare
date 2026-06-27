extends Node2D
class_name Arena

enum MapId { FLAT, BRIDGE, TRAIN, ROOFTOP }

@export var map_id: MapId = MapId.FLAT

var ground_y := 490.0
var spawn_points: Array[Vector2] = []
var weapon_spawns: Array[Vector2] = []

# Top of the physics floor collider (ground_y is collider center, floor is 40px tall).
func ground_surface_y() -> float:
	return ground_y - 20.0

func _ready() -> void:
	add_to_group("arena")
	_configure_map()
	queue_redraw()

func _configure_map() -> void:
	spawn_points.clear()
	weapon_spawns.clear()

	match map_id:
		MapId.FLAT:
			ground_y = 490.0
			spawn_points = [Vector2(220, 420), Vector2(1060, 420)]
			weapon_spawns = _scatter_weapons(640, 455, 520)
		MapId.BRIDGE:
			ground_y = 490.0
			spawn_points = [Vector2(220, 420), Vector2(1060, 420)]
			weapon_spawns = _scatter_weapons(640, 455, 520)
		MapId.TRAIN:
			ground_y = 470.0
			spawn_points = [Vector2(180, 400), Vector2(1100, 400)]
			weapon_spawns = _scatter_weapons(640, 435, 480)
		MapId.ROOFTOP:
			ground_y = 450.0
			spawn_points = [Vector2(240, 380), Vector2(1040, 380)]
			weapon_spawns = _scatter_weapons(640, 415, 500)

func _scatter_weapons(cx: float, floor_y: float, width: float) -> Array[Vector2]:
	var pts: Array[Vector2] = []
	var count := 9
	for i in count:
		var t := float(i) / float(count - 1)
		var x: float = cx + lerp(-width * 0.5, width * 0.5, t) + randf_range(-20, 20)
		pts.append(Vector2(x, floor_y))
	return pts

func get_map_name() -> String:
	match map_id:
		MapId.FLAT: return "Flat Track"
		MapId.BRIDGE: return "Bridge"
		MapId.TRAIN: return "Train"
		MapId.ROOFTOP: return "Rooftops"
	return "Arena"

func cycle_map() -> void:
	map_id = ((map_id as int) + 1) % 4 as MapId
	_configure_map()
	queue_redraw()

func _draw() -> void:
	var surface := ground_surface_y()
	# Sky
	draw_rect(Rect2(-200, -600, 1600, surface + 600), Color(0.62, 0.78, 0.62))
	# Ground fill below the ride surface
	draw_rect(Rect2(-200, surface, 1600, 600), Color(0.42, 0.3, 0.18))
	# Platform slab (what you ride on)
	draw_rect(Rect2(80, surface - 14, 1120, 14), Color(0.58, 0.42, 0.28))

	match map_id:
		MapId.BRIDGE:
			_draw_bridge_deco(surface)
		MapId.TRAIN:
			_draw_train_deco(surface)
		MapId.ROOFTOP:
			_draw_rooftop_deco(surface)

	_draw_side_walls(surface)

func _draw_side_walls(surface: float) -> void:
	draw_rect(Rect2(68, surface - 120, 14, 120), Color(0.45, 0.45, 0.48))
	draw_rect(Rect2(1198, surface - 120, 14, 120), Color(0.45, 0.45, 0.48))

func _draw_bridge_deco(surface: float) -> void:
	# Arches purely below the platform — never overlap play surface
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
