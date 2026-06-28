class_name LevelEnvironmentDraw

const Shapes := preload("res://scripts/draw_shapes.gd")

## When true, uses cheap draw_rect/circles (for one-shot texture bake).
static var bake_mode := false

const LOWER_SHAFT_DEPTH := 300.0
const SKYLINE_BASE_OFFSET := 48.0
const SKYLINE_HEIGHT_SCALE := 4.0
const CLOUD_DRIFT := 6.0
const CLOUD_BANDS := 4


static func _round_rect(
	canvas: CanvasItem,
	rect: Rect2,
	radius: float,
	fill: Color,
	outline: Color = Color.TRANSPARENT,
	outline_width: float = 0.0
) -> void:
	if bake_mode:
		canvas.draw_rect(rect, fill)
		if outline.a > 0.0 and outline_width > 0.0:
			canvas.draw_rect(rect, outline, false, outline_width)
		return
	Shapes.rounded_rect(canvas, rect, radius, fill, outline, outline_width)


static func draw_mission_backdrop(
	canvas: CanvasItem,
	left: float,
	right: float,
	surface_y: float,
	map_id: MapDefs.MapId,
	time: float,
	camera_x: float
) -> void:
	var scene := BiomeSceneDefs.get_scene(map_id)
	var width := right - left
	var sky: Color = scene.get("sky_color", scene.get("sky_top", Color(0.62, 0.82, 0.96)))
	var sky_top := MapDefs.mission_sky_top_y(surface_y)
	canvas.draw_rect(Rect2(left, sky_top, width, surface_y + 640.0 - sky_top), sky)

	var cloud_count: int = int(scene.get("clouds", 3))
	if cloud_count > 0:
		var band_step := MapDefs.MISSION_HEADROOM_ABOVE_GROUND / float(CLOUD_BANDS)
		for band in CLOUD_BANDS:
			var cloud_y := surface_y - 180.0 - float(band) * band_step
			_draw_clouds(canvas, left, right, cloud_y, maxi(2, cloud_count), time, camera_x + float(band) * 40.0)

	var water_y_norm: float = float(scene.get("water_y", -1.0))
	if water_y_norm > 0.0:
		var water_top := surface_y - 120.0 + (1.0 - water_y_norm) * 80.0
		_round_rect(
			canvas,
			Rect2(left, water_top, width, surface_y - water_top + 20.0),
			12.0,
			Color(0.35, 0.62, 0.82, 0.55)
		)

	_draw_skyline(canvas, left, right, surface_y, str(scene.get("skyline", "city")), scene, time)

	if scene.get("window_band", false):
		_draw_window_band(canvas, left, right, surface_y - 95.0 * SKYLINE_HEIGHT_SCALE * 0.25, scene)

	if scene.get("interior_ceiling", false):
		var ceiling_h := 88.0 * SKYLINE_HEIGHT_SCALE
		_round_rect(
			canvas,
			Rect2(left, sky_top, width, ceiling_h),
			0.0,
			scene.get("wall_accent", Color(0.5, 0.5, 0.52)).darkened(0.15)
		)


static func draw_lower_shaft(
	canvas: CanvasItem,
	left: float,
	right: float,
	surface_y: float,
	map_id: MapDefs.MapId,
	_camera_x: float
) -> void:
	var scene := BiomeSceneDefs.get_scene(map_id)
	var top := surface_y + 8.0
	var depth := LOWER_SHAFT_DEPTH
	var base: Color = scene.get("wall_base", Color(0.55, 0.55, 0.58))
	var panel: Color = scene.get("wall_panel", Color(0.65, 0.65, 0.68))
	var accent: Color = scene.get("wall_accent", Color(0.45, 0.48, 0.52))

	_round_rect(canvas, Rect2(left, top, right - left, depth), 0.0, base)

	# Soft horizontal bands
	for band_i in 4:
		var band_y := top + 24.0 + band_i * 68.0
		if band_y > top + depth - 20.0:
			break
		_round_rect(
			canvas,
			Rect2(left + 6.0, band_y, right - left - 12.0, 10.0),
			5.0,
			panel.lightened(0.03 + float(band_i) * 0.01)
		)

	# Cute polka-dot field
	var dot_step := 40.0 if bake_mode else 26.0
	var col_start := int(floor(left / dot_step)) - 1
	var col_end := int(ceil(right / dot_step)) + 1
	var row_y := top + 20.0
	var row_i := 0
	while row_y < top + depth - 16.0:
		for col in range(col_start, col_end + 1):
			var cx := col * dot_step + (dot_step * 0.5 if row_i % 2 == 0 else dot_step * 0.2)
			if cx < left + 8.0 or cx > right - 8.0:
				continue
			var seed := float(col * 7 + row_i * 13)
			var radius := 3.0 + fmod(seed, 2.5)
			var dot_color := accent.lightened(0.12 + fmod(seed, 3.0) * 0.04)
			canvas.draw_circle(Vector2(cx, row_y + fmod(seed, 10.0)), radius, dot_color)
			if int(seed) % 11 == 0:
				_draw_tiny_star(canvas, Vector2(cx + 6.0, row_y + 5.0), accent.lightened(0.2), 5.0)
		row_y += dot_step * 0.85
		row_i += 1

	_round_rect(canvas, Rect2(left, top, 10.0, depth), 5.0, accent.darkened(0.08))
	_round_rect(canvas, Rect2(right - 10.0, top, 10.0, depth), 5.0, accent.darkened(0.08))


static func draw_platform(
	canvas: CanvasItem,
	x: float,
	y: float,
	w: float,
	h: float,
	fill: Color,
	edge: Color
) -> void:
	_round_rect(canvas, Rect2(x, y - h, w, h), 6.0, fill, edge.darkened(0.08), 2.0)
	_round_rect(canvas, Rect2(x + 4.0, y - h - 5.0, w - 8.0, 5.0), 3.0, fill.lightened(0.08))


static func draw_safe_zone(
	canvas: CanvasItem,
	zone_left: float,
	zone_right: float,
	surface_y: float,
	time: float
) -> void:
	var floor_y := surface_y - 14.0
	_round_rect(
		canvas,
		Rect2(zone_left, floor_y - 4.0, zone_right - zone_left, 8.0),
		4.0,
		Color(0.45, 0.88, 0.55, 0.35)
	)

	var flag_x := zone_right - 8.0
	var pole_h := 78.0
	var pole_base := floor_y
	_round_rect(canvas, Rect2(flag_x - 3.0, pole_base - pole_h, 6.0, pole_h), 3.0, Color(0.55, 0.58, 0.62))
	var wave := sin(time * 3.2) * 4.0
	var flag_pts := PackedVector2Array([
		Vector2(flag_x + 4.0, pole_base - pole_h + 8.0),
		Vector2(flag_x + 52.0 + wave, pole_base - pole_h + 20.0),
		Vector2(flag_x + 48.0 + wave, pole_base - pole_h + 44.0),
		Vector2(flag_x + 4.0, pole_base - pole_h + 36.0),
	])
	canvas.draw_colored_polygon(flag_pts, Color(0.35, 0.82, 0.48))
	_round_rect(
		canvas,
		Rect2(flag_x + 10.0, pole_base - pole_h + 16.0, 30.0, 18.0),
		6.0,
		Color(0.28, 0.72, 0.42, 0.55)
	)

	_draw_pill_label(canvas, Vector2(zone_left + 24.0, pole_base - pole_h - 18.0), "SAFE ZONE — learn balance", Color(0.25, 0.72, 0.42))
	_draw_pill_label(
		canvas,
		Vector2(flag_x - 36.0, pole_base - pole_h - 18.0),
		"COMBAT AHEAD",
		Color(0.85, 0.35, 0.28)
	)


static func draw_section_labels(
	canvas: CanvasItem,
	level: LevelAssembler,
	surface_y: float
) -> void:
	if level == null:
		return
	var floor_y := surface_y - 14.0
	for section in level.sections:
		var cx := (float(section.get("x0", 0.0)) + float(section.get("x1", 0.0))) * 0.5
		var label := str(section.get("label", ""))
		if label.is_empty():
			continue
		canvas.draw_string(
			ThemeDB.fallback_font,
			Vector2(cx - label.length() * 3.5, floor_y - 52.0),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			11,
			Color(1.0, 0.92, 0.55, 0.55)
		)


static func draw_scene_decor(
	canvas: CanvasItem,
	left: float,
	right: float,
	surface_y: float,
	map_id: MapDefs.MapId,
	time: float
) -> void:
	var scene := BiomeSceneDefs.get_scene(map_id)
	var decor: Array = scene.get("decor", [])
	var map_w := right - left
	for entry_variant in decor:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var wx := left + float(entry.get("x", 0.5)) * map_w
		if wx < left or wx > right:
			continue
		_draw_decor_kind(
			canvas,
			str(entry.get("kind", "")),
			Vector2(wx, surface_y - 14.0),
			str(entry.get("label", "")),
			time
		)


static func _draw_tiny_star(canvas: CanvasItem, center: Vector2, color: Color, size: float) -> void:
	canvas.draw_circle(center, size * 0.35, color)
	canvas.draw_circle(center + Vector2(-size * 0.55, 0.0), size * 0.22, color)
	canvas.draw_circle(center + Vector2(size * 0.55, 0.0), size * 0.22, color)


static func _draw_clouds(
	canvas: CanvasItem,
	left: float,
	right: float,
	y: float,
	count: int,
	time: float,
	camera_x: float
) -> void:
	var span := right - left
	for i in count:
		var seed := float(i) * 1.73
		var cx := left + fmod(seed * 317.0 + time * CLOUD_DRIFT + camera_x * 0.04, span)
		var cy := y + sin(time * 0.35 + seed) * 8.0
		_draw_puff_cloud(canvas, Vector2(cx, cy), 38.0 + fmod(seed, 22.0))


static func _draw_puff_cloud(canvas: CanvasItem, center: Vector2, size: float) -> void:
	var fill := Color(1.0, 1.0, 1.0, 0.82)
	_round_rect(canvas, Rect2(center.x - size, center.y - size * 0.35, size * 2.0, size * 0.7), size * 0.35, fill)
	_round_rect(
		canvas,
		Rect2(center.x - size * 0.65, center.y - size * 0.55, size * 0.9, size * 0.55),
		size * 0.25,
		fill.lightened(0.04)
	)
	_round_rect(
		canvas,
		Rect2(center.x + size * 0.05, center.y - size * 0.5, size * 0.85, size * 0.5),
		size * 0.22,
		fill
	)


static func _draw_skyline(
	canvas: CanvasItem,
	left: float,
	right: float,
	surface_y: float,
	kind: String,
	scene: Dictionary,
	time: float
) -> void:
	var base_y := surface_y - SKYLINE_BASE_OFFSET
	match kind:
		"dunes":
			_draw_dunes(canvas, left, right, base_y, scene)
		"city", "harbor":
			_draw_city_skyline(canvas, left, right, base_y, scene, kind == "harbor")
		"factory":
			_draw_factory_skyline(canvas, left, right, base_y, scene, time)
		"castle":
			_draw_castle_skyline(canvas, left, right, base_y, scene)
		"cargo":
			_draw_cargo_interior(canvas, left, right, surface_y, scene)
		"clouds":
			_draw_cloud_skyline(canvas, left, right, base_y, time)
		"cave":
			_draw_cave_skyline(canvas, left, right, base_y, scene)
		"dam":
			_draw_dam_skyline(canvas, left, right, base_y, scene, time)
		"volcano":
			_draw_volcano_skyline(canvas, left, right, base_y, scene, time)
		_:
			_draw_city_skyline(canvas, left, right, base_y, scene, false)


static func _draw_dunes(canvas: CanvasItem, left: float, right: float, base_y: float, scene: Dictionary) -> void:
	var fill: Color = scene.get("wall_panel", Color(0.78, 0.68, 0.52)).lightened(0.12)
	var step := 180.0
	var i := 0
	var x := left - 40.0
	while x < right + 40.0:
		var h := (50.0 + float(i % 3) * 28.0) * SKYLINE_HEIGHT_SCALE
		_round_rect(canvas, Rect2(x, base_y - h, step + 20.0, h + 30.0), 18.0, fill.darkened(0.04 * float(i % 2)))
		x += step * 0.85
		i += 1


static func _draw_city_skyline(
	canvas: CanvasItem,
	left: float,
	right: float,
	base_y: float,
	scene: Dictionary,
	harbor: bool
) -> void:
	_draw_city_building_layer(canvas, left, right, base_y, scene, harbor, 0.42, 1.25, 0.58)
	_draw_city_building_layer(canvas, left, right, base_y, scene, harbor, 0.68, 1.0, 0.78)
	_draw_city_building_layer(canvas, left, right, base_y, scene, harbor, 1.0, 0.82, 1.0)


static func _draw_city_building_layer(
	canvas: CanvasItem,
	left: float,
	right: float,
	base_y: float,
	scene: Dictionary,
	harbor: bool,
	height_scale: float,
	width_scale: float,
	tone: float
) -> void:
	var building: Color = scene.get("wall_panel", Color(0.92, 0.9, 0.78)).lightened(0.06 * tone)
	var accent: Color = scene.get("wall_accent", Color(0.72, 0.76, 0.82))
	var x := left - 30.0 * (1.0 - width_scale)
	var i := 0
	while x < right + 20.0:
		var w := (72.0 + float(i % 4) * 26.0) * width_scale
		var h := (90.0 + float((i * 3) % 5) * 32.0) * SKYLINE_HEIGHT_SCALE * height_scale
		_round_rect(canvas, Rect2(x, base_y - h, w, h + 24.0), 8.0, building.darkened(0.03 * float(i % 3)))
		var row_count := maxi(4, int(h / 52.0))
		var col_count := maxi(3, int(w / 22.0))
		for row in row_count:
			for col in col_count:
				if bake_mode and (row + col) % 2 == 1:
					continue
				var wx := x + 14.0 + col * 18.0
				if wx > x + w - 10.0:
					break
				_round_rect(
					canvas,
					Rect2(wx, base_y - h + 16.0 + row * 18.0, 10.0, 12.0),
					3.0,
					accent if (row + col + i) % 2 == 0 else accent.lightened(0.25)
				)
		if harbor and i % 3 == 0 and height_scale > 0.9:
			_round_rect(canvas, Rect2(x + w * 0.2, base_y - h - 18.0, w * 0.6, 14.0), 6.0, Color(0.88, 0.9, 0.92))
		x += w + 12.0
		i += 1


static func _draw_factory_skyline(
	canvas: CanvasItem,
	left: float,
	right: float,
	base_y: float,
	scene: Dictionary,
	time: float
) -> void:
	var body: Color = scene.get("wall_panel", Color(0.52, 0.5, 0.48))
	var x := left
	var i := 0
	while x < right + 30.0:
		var w := 64.0 + float(i % 3) * 20.0
		var h := (70.0 + float(i % 4) * 24.0) * SKYLINE_HEIGHT_SCALE
		_round_rect(canvas, Rect2(x, base_y - h, w, h + 20.0), 6.0, body)
		_round_rect(canvas, Rect2(x + w * 0.35, base_y - h - 48.0 * SKYLINE_HEIGHT_SCALE, 14.0, 52.0 * SKYLINE_HEIGHT_SCALE), 5.0, body.darkened(0.08))
		if i % 2 == 0:
			var steam_y := base_y - h - 52.0 * SKYLINE_HEIGHT_SCALE - sin(time * 2.0 + i) * 4.0
			_round_rect(canvas, Rect2(x + w * 0.3, steam_y, 22.0, 14.0), 7.0, Color(0.85, 0.85, 0.88, 0.35))
		x += w + 16.0
		i += 1


static func _draw_castle_skyline(canvas: CanvasItem, left: float, right: float, base_y: float, scene: Dictionary) -> void:
	var stone: Color = scene.get("wall_panel", Color(0.62, 0.6, 0.56))
	var wall_h := 90.0 * SKYLINE_HEIGHT_SCALE
	_round_rect(canvas, Rect2(left, base_y - wall_h + 20.0, right - left, wall_h), 0.0, stone.darkened(0.06))
	var x := left
	while x < right:
		_round_rect(canvas, Rect2(x, base_y - 95.0 * SKYLINE_HEIGHT_SCALE, 28.0, 28.0 * SKYLINE_HEIGHT_SCALE), 4.0, stone)
		_round_rect(canvas, Rect2(x + 34.0, base_y - 110.0 * SKYLINE_HEIGHT_SCALE, 52.0, 105.0 * SKYLINE_HEIGHT_SCALE), 6.0, stone.lightened(0.05))
		x += 120.0


static func _draw_cargo_interior(canvas: CanvasItem, left: float, right: float, surface_y: float, scene: Dictionary) -> void:
	var wall: Color = scene.get("wall_panel", Color(0.68, 0.62, 0.55))
	var wall_h := 118.0 * SKYLINE_HEIGHT_SCALE
	_round_rect(canvas, Rect2(left, surface_y - wall_h - 12.0, right - left, wall_h), 0.0, wall.darkened(0.05))
	var x := left + 40.0
	while x < right - 60.0:
		_round_rect(canvas, Rect2(x, surface_y - wall_h, 64.0, 72.0 * SKYLINE_HEIGHT_SCALE), 8.0, wall.lightened(0.06), wall.darkened(0.12), 2.0)
		x += 96.0


static func _draw_cloud_skyline(canvas: CanvasItem, left: float, right: float, base_y: float, time: float) -> void:
	var x := left
	var i := 0
	while x < right:
		_draw_puff_cloud(canvas, Vector2(x + 60.0, base_y - 80.0 * SKYLINE_HEIGHT_SCALE + sin(time + i) * 6.0), 44.0 + float(i % 3) * 8.0)
		x += 140.0
		i += 1


static func _draw_cave_skyline(canvas: CanvasItem, left: float, right: float, base_y: float, scene: Dictionary) -> void:
	var rock: Color = scene.get("wall_panel", Color(0.42, 0.4, 0.36))
	for i in 8:
		var cx := left + (right - left) * (float(i) / 7.0)
		var h := (40.0 + float(i % 3) * 18.0) * SKYLINE_HEIGHT_SCALE
		canvas.draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 70.0, base_y + 20.0),
				Vector2(cx - 20.0, base_y - h),
				Vector2(cx + 30.0, base_y + 10.0),
			]),
			rock.darkened(0.05 * float(i % 2))
		)


static func _draw_dam_skyline(
	canvas: CanvasItem,
	left: float,
	right: float,
	base_y: float,
	scene: Dictionary,
	time: float
) -> void:
	var concrete: Color = scene.get("wall_panel", Color(0.72, 0.74, 0.76))
	var cx := (left + right) * 0.5
	_round_rect(canvas, Rect2(cx - 120.0, base_y - 130.0 * SKYLINE_HEIGHT_SCALE, 240.0, 150.0 * SKYLINE_HEIGHT_SCALE), 10.0, concrete)
	for i in 4:
		_round_rect(canvas, Rect2(cx - 90.0 + i * 42.0, base_y - 100.0 * SKYLINE_HEIGHT_SCALE, 28.0, 60.0 * SKYLINE_HEIGHT_SCALE), 5.0, concrete.lightened(0.06))
	var mist_y := base_y - 20.0 + sin(time * 1.5) * 3.0
	_round_rect(canvas, Rect2(cx - 40.0, mist_y, 80.0, 18.0), 9.0, Color(0.85, 0.92, 0.98, 0.45))


static func _draw_volcano_skyline(
	canvas: CanvasItem,
	left: float,
	right: float,
	base_y: float,
	scene: Dictionary,
	time: float
) -> void:
	var rock: Color = scene.get("wall_panel", Color(0.42, 0.36, 0.32))
	var cx := left + (right - left) * 0.72
	canvas.draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx - 120.0, base_y + 20.0),
			Vector2(cx, base_y - 140.0 * SKYLINE_HEIGHT_SCALE),
			Vector2(cx + 100.0, base_y + 20.0),
		]),
		rock
	)
	var glow := 0.55 + sin(time * 2.2) * 0.15
	_round_rect(
		canvas,
		Rect2(cx - 18.0, base_y - 50.0 * SKYLINE_HEIGHT_SCALE, 36.0, 22.0),
		8.0,
		Color(1.0, 0.45 * glow, 0.12, 0.75)
	)


static func _draw_window_band(canvas: CanvasItem, left: float, right: float, y: float, scene: Dictionary) -> void:
	var frame: Color = scene.get("wall_panel", Color(0.92, 0.93, 0.95))
	_round_rect(canvas, Rect2(left + 40.0, y, right - left - 80.0, 64.0), 12.0, frame, scene.get("wall_accent", Color.GRAY), 2.0)
	var x := left + 56.0
	while x < right - 80.0:
		_round_rect(canvas, Rect2(x, y + 14.0, 36.0, 36.0), 8.0, Color(0.55, 0.72, 0.88, 0.45))
		x += 52.0


static func _draw_pill_label(canvas: CanvasItem, pos: Vector2, text: String, accent: Color) -> void:
	var pad_x := 14.0
	var font := ThemeDB.fallback_font
	var font_size := 13
	var text_w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var rect := Rect2(pos.x, pos.y, text_w + pad_x * 2.0, 26.0)
	_round_rect(canvas, rect, 10.0, accent.darkened(0.55), accent, 2.0)
	canvas.draw_string(font, pos + Vector2(pad_x, 18.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)


static func _draw_decor_kind(canvas: CanvasItem, kind: String, pos: Vector2, label: String, time: float) -> void:
	match kind:
		"cactus":
			_round_rect(canvas, Rect2(pos.x - 5.0, pos.y - 38.0, 10.0, 28.0), 4.0, Color(0.32, 0.68, 0.38))
			_round_rect(canvas, Rect2(pos.x - 14.0, pos.y - 28.0, 12.0, 8.0), 4.0, Color(0.32, 0.68, 0.38))
		"sign":
			_round_rect(canvas, Rect2(pos.x - 22.0, pos.y - 52.0, 44.0, 26.0), 8.0, Color(0.95, 0.92, 0.82), Color(0.55, 0.52, 0.48), 2.0)
			if not label.is_empty():
				canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(-16.0, -34.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.25, 0.22, 0.2))
		"sandbags":
			_round_rect(canvas, Rect2(pos.x - 18.0, pos.y - 16.0, 36.0, 14.0), 5.0, Color(0.62, 0.55, 0.38))
		"barrel":
			_round_rect(canvas, Rect2(pos.x - 12.0, pos.y - 28.0, 24.0, 28.0), 8.0, Color(0.42, 0.48, 0.52))
		"crate":
			_round_rect(canvas, Rect2(pos.x - 16.0, pos.y - 26.0, 32.0, 26.0), 6.0, Color(0.62, 0.48, 0.32), Color(0.42, 0.32, 0.22), 2.0)
		"plant":
			_round_rect(canvas, Rect2(pos.x - 10.0, pos.y - 12.0, 20.0, 12.0), 6.0, Color(0.42, 0.62, 0.38))
			_round_rect(canvas, Rect2(pos.x - 4.0, pos.y - 32.0, 8.0, 22.0), 4.0, Color(0.28, 0.52, 0.32))
		"bench":
			_round_rect(canvas, Rect2(pos.x - 20.0, pos.y - 10.0, 40.0, 8.0), 4.0, Color(0.55, 0.42, 0.32))
		"buoy":
			_round_rect(canvas, Rect2(pos.x - 10.0, pos.y - 22.0, 20.0, 22.0), 10.0, Color(0.92, 0.35, 0.28))
		"anchor":
			_round_rect(canvas, Rect2(pos.x - 3.0, pos.y - 24.0, 6.0, 18.0), 3.0, Color(0.45, 0.48, 0.52))
		"gear":
			canvas.draw_circle(pos + Vector2(0.0, -18.0), 14.0, Color(0.55, 0.58, 0.62))
		"banner":
			_round_rect(canvas, Rect2(pos.x - 8.0, pos.y - 48.0, 16.0, 34.0), 4.0, Color(0.72, 0.22, 0.22))
		"lantern":
			var pulse := 0.65 + sin(time * 4.0) * 0.35
			_round_rect(canvas, Rect2(pos.x - 8.0, pos.y - 32.0, 16.0, 20.0), 6.0, Color(1.0, 0.82, 0.35, pulse))
		"rope":
			canvas.draw_line(pos + Vector2(0.0, -40.0), pos + Vector2(0.0, -8.0), Color(0.52, 0.45, 0.38), 3.0)
		"rock":
			_round_rect(canvas, Rect2(pos.x - 16.0, pos.y - 18.0, 32.0, 18.0), 8.0, Color(0.42, 0.38, 0.35))
