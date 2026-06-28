extends Node2D

## Lightweight overlay — safe-zone flag + section labels (not baked).

var map_id: MapDefs.MapId = MapDefs.MapId.DESERT
var level: LevelAssembler = null
var surface_y := 360.0
var camera_scroll := 0.0
var _time := 0.0
var _redraw_accum := 0.0


func setup(mid: MapDefs.MapId, lvl: LevelAssembler, surface: float) -> void:
	map_id = mid
	level = lvl
	surface_y = surface
	z_index = 2
	set_process(true)


func set_camera_scroll(x: float) -> void:
	camera_scroll = x


func _process(delta: float) -> void:
	_time += delta
	_redraw_accum += delta
	if _redraw_accum >= 0.08:
		_redraw_accum = 0.0
		queue_redraw()


func _draw() -> void:
	if level == null:
		return
	LevelEnvironmentDraw.draw_safe_zone(
		self, level.world_left, level.safe_zone_end_x, surface_y, _time
	)
	for section in level.sections:
		var cx := (float(section.get("x0", 0.0)) + float(section.get("x1", 0.0))) * 0.5
		var label := str(section.get("label", ""))
		if label.is_empty():
			continue
		var floor_y := surface_y - 14.0
		if absf(cx - camera_scroll - 640.0) > 900.0:
			continue
		draw_string(
			ThemeDB.fallback_font,
			Vector2(cx - label.length() * 3.5, floor_y - 52.0),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			11,
			Color(1.0, 0.92, 0.55, 0.55)
		)
