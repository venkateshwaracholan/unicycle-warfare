extends Node2D

## One-shot drawer used by MissionEnvironmentBake SubViewport.

var bake_left := 0.0
var bake_right := 1280.0
var surface_y := 360.0
var map_id: MapDefs.MapId = MapDefs.MapId.DESERT
var level: LevelAssembler = null
var platform_color := Color(0.58, 0.42, 0.28)
var bake_scale_x := 1.0


func _draw() -> void:
	LevelEnvironmentDraw.bake_mode = true
	var bake_y_min := MissionEnvironmentBake.bake_y_min_for(surface_y)
	draw_set_transform(
		Vector2(-bake_left * bake_scale_x, -bake_y_min),
		0.0,
		Vector2(bake_scale_x, 1.0)
	)
	LevelEnvironmentDraw.draw_mission_backdrop(
		self, bake_left, bake_right, surface_y, map_id, 0.0, 0.0
	)
	LevelEnvironmentDraw.draw_lower_shaft(
		self, bake_left, bake_right, surface_y, map_id, 0.0
	)
	LevelEnvironmentDraw.draw_scene_decor(
		self, bake_left, bake_right, surface_y, map_id, 0.0
	)
	if level != null:
		for plat in level.platforms:
			var px := float(plat.get("x", 0.0))
			var py := float(plat.get("y", 0.0))
			var pw := float(plat.get("w", 0.0))
			var ph := float(plat.get("h", 14.0))
			LevelEnvironmentDraw.draw_platform(
				self, px, py, pw, ph, platform_color, platform_color.darkened(0.12)
			)
		LevelEnvironmentDraw.draw_safe_zone(
			self, level.world_left, level.safe_zone_end_x, surface_y, 0.0
		)
		LevelEnvironmentDraw.draw_section_labels(self, level, surface_y)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	LevelEnvironmentDraw.bake_mode = false
