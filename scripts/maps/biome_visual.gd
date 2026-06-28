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
	if not mission_mode:
		queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if mission_mode:
		return
	queue_redraw()


func _draw() -> void:
	if mission_mode:
		_draw_mission_flat()
		return

	var visual: Dictionary = BiomeCatalog.get_visual(map_id)
	if layer_kind == LayerKind.BACKDROP:
		_draw_legacy_backdrop(visual)
	else:
		_draw_legacy_foreground(visual)


func _draw_mission_flat() -> void:
	if layer_kind == LayerKind.BACKDROP:
		LevelEnvironmentDraw.draw_mission_backdrop(
			self,
			world_left_bound,
			world_right_bound,
			surface_y,
			map_id,
			_time,
			world_scroll
		)
	else:
		LevelEnvironmentDraw.draw_scene_decor(
			self,
			world_left_bound,
			world_right_bound,
			surface_y,
			map_id,
			_time
		)


func _draw_legacy_backdrop(visual: Dictionary) -> void:
	var sil := str(visual.get("bg_silhouette", ""))
	if not sil.is_empty():
		BiomePropDraw.draw_silhouette(self, sil, surface_y, _palette, _time)

	_draw_legacy_layer_props(visual.get("layers", {}), "bg", 0.0)
	_draw_legacy_layer_props(visual.get("layers", {}), "mid", 0.0)

	var tint: Color = visual.get("light_tint", Color(1, 1, 1, 0.0))
	if tint.a > 0.01:
		draw_rect(Rect2(-200, -600, 1600, surface_y + 620), tint)

	_draw_legacy_particles(str(visual.get("particles", "")))


func _draw_legacy_foreground(visual: Dictionary) -> void:
	_draw_legacy_layer_props(visual.get("layers", {}), "fg", 0.0)


func _draw_legacy_layer_props(layers: Dictionary, key: String, y_offset: float) -> void:
	var props: Array = layers.get(key, [])
	if props.is_empty():
		return
	var parallax := 0.35 if key == "bg" else (0.15 if key == "mid" else 0.0)
	for prop_variant in props:
		if not prop_variant is Dictionary:
			continue
		var prop: Dictionary = prop_variant
		_draw_legacy_single_prop(prop, key, y_offset, parallax, 0.0)


func _draw_legacy_single_prop(prop: Dictionary, key: String, y_offset: float, parallax: float, tile_origin: float) -> void:
	var norm_x: float = float(prop.get("x", 0.5))
	var scale: float = float(prop.get("scale", 1.0))
	var phase: float = float(prop.get("phase", 0.0))
	var prop_type := str(prop.get("type", ""))
	var base_x := BiomeCatalog.PLAY_LEFT + norm_x * BiomeCatalog.PLAY_WIDTH + tile_origin
	var x := base_x - world_scroll * parallax
	var pos: Vector2 = Vector2(x, surface_y + y_offset)
	BiomePropDraw.draw_prop(self, prop_type, pos, surface_y, scale, _time, _palette, phase)


func _draw_legacy_particles(kind: String) -> void:
	if kind.is_empty():
		return
	var count := 36
	if kind == "dust" or kind == "ash":
		count = 64
	for i in count:
		var seed := float(i) * 17.3 + float(map_id) * 3.7
		var px := fmod(seed * 41.0 + _time * _legacy_particle_speed(kind), 1280.0)
		var py := fmod(seed * 23.0 + sin(_time * 0.4 + seed) * 40.0, surface_y + 80.0) - 80.0
		var alpha := _legacy_particle_alpha(kind, seed)
		var radius := _legacy_particle_radius(kind, seed)
		draw_circle(Vector2(px, py), radius, _legacy_particle_color(kind, alpha))


func _legacy_particle_speed(kind: String) -> float:
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


func _legacy_particle_alpha(kind: String, seed: float) -> float:
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


func _legacy_particle_radius(kind: String, seed: float) -> float:
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


func _legacy_particle_color(kind: String, alpha: float) -> Color:
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
