extends Node2D
class_name BiomeVisual

enum LayerKind { BACKDROP, FOREGROUND }

@export var layer_kind: LayerKind = LayerKind.BACKDROP

var map_id: MapDefs.MapId = MapDefs.MapId.DESERT
var surface_y := 470.0
var scroll_offset := 0.0
var world_scroll := 0.0
var world_width := 1280.0
var mission_mode := false
var world_left_bound := 80.0
var world_right_bound := 1200.0

var _palette: Dictionary = {}
var _time := 0.0


func configure(
	mid: MapDefs.MapId,
	surface: float,
	palette: Dictionary,
	world_w: float = 1280.0,
	mission: bool = false,
	left_bound: float = 80.0,
	right_bound: float = 1200.0
) -> void:
	map_id = mid
	surface_y = surface
	_palette = palette
	world_width = world_w
	mission_mode = mission
	world_left_bound = left_bound
	world_right_bound = right_bound
	queue_redraw()


func set_scroll(offset: float) -> void:
	scroll_offset = offset
	queue_redraw()


func set_world_scroll(x: float) -> void:
	world_scroll = x
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var visual: Dictionary = BiomeCatalog.get_visual(map_id)
	if layer_kind == LayerKind.BACKDROP:
		_draw_backdrop(visual)
	else:
		_draw_foreground(visual)


func _draw_backdrop(visual: Dictionary) -> void:
	var sil := str(visual.get("bg_silhouette", ""))
	if not mission_mode and not sil.is_empty():
		BiomePropDraw.draw_silhouette(self, sil, surface_y, _palette, _time)

	_draw_layer_props(visual.get("layers", {}), "bg", 0.0)
	_draw_layer_props(visual.get("layers", {}), "mid", 0.0)

	var tint: Color = visual.get("light_tint", Color(1, 1, 1, 0.0))
	if tint.a > 0.01:
		if mission_mode:
			draw_rect(
				Rect2(world_left_bound, -600, world_right_bound - world_left_bound, surface_y + 620),
				tint
			)
		else:
			draw_rect(Rect2(-200, -600, 1600, surface_y + 620), tint)

	_draw_particles(str(visual.get("particles", "")))


func _draw_foreground(visual: Dictionary) -> void:
	_draw_layer_props(visual.get("layers", {}), "fg", 0.0)


func _draw_layer_props(layers: Dictionary, key: String, y_offset: float) -> void:
	var props: Array = layers.get(key, [])
	if props.is_empty():
		return
	var parallax := 0.35 if key == "bg" else (0.15 if key == "mid" else 0.0)
	if mission_mode:
		var map_w := world_right_bound - world_left_bound
		for prop_variant in props:
			if not prop_variant is Dictionary:
				continue
			var prop: Dictionary = prop_variant
			var norm_x: float = float(prop.get("x", 0.5))
			var world_x := world_left_bound + norm_x * map_w
			if world_x < world_left_bound or world_x > world_right_bound:
				continue
			_draw_single_prop(prop, key, y_offset, parallax, world_x)
	else:
		for prop_variant in props:
			if not prop_variant is Dictionary:
				continue
			var prop: Dictionary = prop_variant
			_draw_single_prop(prop, key, y_offset, parallax, 0.0)


func _draw_single_prop(prop: Dictionary, key: String, y_offset: float, parallax: float, world_x_or_tile: float) -> void:
	var scale: float = float(prop.get("scale", 1.0))
	var phase: float = float(prop.get("phase", 0.0))
	var prop_type := str(prop.get("type", ""))
	var x: float
	if mission_mode:
		x = world_x_or_tile
	else:
		var norm_x: float = float(prop.get("x", 0.5))
		var base_x := BiomeCatalog.PLAY_LEFT + norm_x * BiomeCatalog.PLAY_WIDTH + world_x_or_tile
		x = base_x - world_scroll * parallax
	var pos: Vector2 = Vector2(x, surface_y + y_offset)
	BiomePropDraw.draw_prop(self, prop_type, pos, surface_y, scale, _time, _palette, phase)


func _draw_particles(kind: String) -> void:
	if kind.is_empty():
		return
	var count := 36
	if kind == "dust" or kind == "ash":
		count = 64
	var span := world_width if mission_mode else 1280.0
	var origin := world_left_bound if mission_mode else 0.0
	for i in count:
		var seed := float(i) * 17.3 + float(map_id) * 3.7
		var px := origin + fmod(seed * 41.0 + _time * _particle_speed(kind), span)
		if mission_mode and (px < world_left_bound or px > world_right_bound):
			continue
		var py := fmod(seed * 23.0 + sin(_time * 0.4 + seed) * 40.0, surface_y + 80.0) - 80.0
		var alpha := _particle_alpha(kind, seed)
		var radius := _particle_radius(kind, seed)
		draw_circle(Vector2(px, py), radius, _particle_color(kind, alpha))


func _particle_speed(kind: String) -> float:
	match kind:
		"dust", "ash":
			return 18.0
		"steam", "mist", "cloud", "rain_mist":
			return 8.0
		"smoke":
			return 12.0
		"ember":
			return 6.0
	return 10.0


func _particle_alpha(kind: String, seed: float) -> float:
	var base := 0.18
	match kind:
		"dust", "ash":
			base = 0.22
		"steam", "mist", "cloud", "rain_mist":
			base = 0.12
		"smoke":
			base = 0.16
		"ember":
			base = 0.35
	return base * (0.6 + sin(_time * 2.0 + seed) * 0.4)


func _particle_radius(kind: String, seed: float) -> float:
	match kind:
		"dust", "ash":
			return 1.5 + fmod(seed, 2.5)
		"steam", "mist", "cloud", "rain_mist":
			return 2.0 + fmod(seed, 4.0)
		"smoke":
			return 2.5 + fmod(seed, 3.0)
		"ember":
			return 1.0 + fmod(seed, 1.5)
	return 2.0


func _particle_color(kind: String, alpha: float) -> Color:
	match kind:
		"dust":
			return Color(0.85, 0.75, 0.55, alpha)
		"ash":
			return Color(0.35, 0.32, 0.3, alpha)
		"steam", "mist", "cloud", "rain_mist":
			return Color(0.92, 0.95, 1.0, alpha)
		"smoke":
			return Color(0.25, 0.25, 0.28, alpha)
		"ember":
			return Color(1.0, 0.55, 0.15, alpha)
	return Color(1, 1, 1, alpha)
