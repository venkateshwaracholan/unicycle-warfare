class_name BiomePropDraw

## Procedural stylized props — one draw routine per kind, reused across maps.

const Shapes := preload("res://scripts/draw_shapes.gd")


static func draw_silhouette(canvas: CanvasItem, kind: String, surface: float, palette: Dictionary, time: float) -> void:
	match kind:
		"desert_hills":
			for i in 5:
				var cx := 120.0 + i * 240.0
				var h := 90.0 + (i * 29) % 70
				canvas.draw_colored_polygon(
					PackedVector2Array([
						Vector2(cx - 180, surface + 40),
						Vector2(cx, surface + 40 - h),
						Vector2(cx + 180, surface + 40),
					]),
					palette.get("ground", Color.SANDY_BROWN).darkened(0.15)
				)
		"factory_skyline":
			for i in 6:
				var x := 80.0 + i * 190.0
				var h := 120.0 + (i * 17) % 80
				canvas.draw_rect(Rect2(x, surface - h, 70, h + 40), palette.get("ground", Color.GRAY).lightened(0.05))
		"castle_wall":
			canvas.draw_rect(Rect2(40, surface - 160, 1200, 200), palette.get("ground", Color.GRAY).darkened(0.1))
			for i in 14:
				canvas.draw_rect(Rect2(60 + i * 82, surface - 178, 36, 22), palette.get("platform", Color.GRAY))
		"train_trestle":
			for i in 8:
				var x := 100.0 + i * 140.0
				canvas.draw_line(Vector2(x, surface + 20), Vector2(x, surface + 90), palette.get("ground", Color.BROWN), 6.0)
			canvas.draw_rect(Rect2(60, surface + 88, 1120, 10), palette.get("ground", Color.BROWN).darkened(0.1))
		"mine_cave":
			canvas.draw_rect(Rect2(-40, surface - 220, 400, 260), Color(0.05, 0.05, 0.06))
			canvas.draw_rect(Rect2(920, surface - 200, 360, 240), Color(0.05, 0.05, 0.06))
		"sky_clouds":
			for i in 4:
				var cx := 200.0 + i * 280.0 + sin(time * 0.2 + i) * 20.0
				canvas.draw_circle(Vector2(cx, surface - 180), 55, Color(1, 1, 1, 0.08))
		"city_skyline":
			for i in 8:
				var x := 40.0 + i * 150.0
				var h := 100.0 + (i * 23) % 140
				canvas.draw_rect(Rect2(x, surface - h, 90, h + 50), Color(0.06, 0.08, 0.12, 0.9))
		"dam_wall":
			canvas.draw_rect(Rect2(420, surface - 200, 440, 240), palette.get("platform", Color.GRAY).darkened(0.15))
			for i in 4:
				canvas.draw_rect(Rect2(450 + i * 100, surface - 170, 60, 90), Color(0.35, 0.38, 0.42))
		"volcano_peak":
			canvas.draw_colored_polygon(
				PackedVector2Array([
					Vector2(980, surface + 60),
					Vector2(1120, surface - 120),
					Vector2(1260, surface + 60),
				]),
				palette.get("ground", Color.DARK_RED).darkened(0.2)
			)
		"harbor_skyline":
			canvas.draw_rect(Rect2(-60, surface + 20, 1400, 80), palette.get("sky", Color.BLUE).darkened(0.35))
			for i in 3:
				canvas.draw_rect(Rect2(180 + i * 320, surface - 40, 140, 60), Color(0.2, 0.25, 0.3, 0.5))


static func draw_prop(
	canvas: CanvasItem,
	prop_type: String,
	pos: Vector2,
	surface: float,
	scale: float,
	time: float,
	palette: Dictionary,
	phase: float = 0.0
) -> void:
	var s := scale
	match prop_type:
		"dune":
			canvas.draw_colored_polygon(
				PackedVector2Array([
					pos + Vector2(-70 * s, 0),
					pos + Vector2(0, -35 * s),
					pos + Vector2(70 * s, 0),
				]),
				palette.get("ground", Color.SANDY_BROWN).lightened(0.08)
			)
		"rock_arch":
			canvas.draw_arc(pos + Vector2(0, -30 * s), 45 * s, PI, TAU, 20, palette.get("platform", Color.GRAY), 10.0)
			canvas.draw_rect(Rect2(pos.x - 8 * s, pos.y - 80 * s, 16 * s, 80 * s), palette.get("platform", Color.GRAY))
		"windmill":
			var hub := pos + Vector2(0, -70 * s)
			canvas.draw_rect(Rect2(pos.x - 5 * s, pos.y - 70 * s, 10 * s, 70 * s), palette.get("platform", Color.GRAY).darkened(0.2))
			for i in 4:
				var a := time * 1.4 + i * TAU / 4.0
				canvas.draw_line(hub, hub + Vector2(cos(a), sin(a)) * 38 * s, Color(0.85, 0.85, 0.9), 4.0)
		"cactus":
			canvas.draw_rect(Rect2(pos.x - 5 * s, pos.y - 55 * s, 10 * s, 55 * s), Color(0.25, 0.55, 0.28))
			canvas.draw_rect(Rect2(pos.x - 18 * s, pos.y - 38 * s, 14 * s, 8 * s), Color(0.25, 0.55, 0.28))
			canvas.draw_rect(Rect2(pos.x - 18 * s, pos.y - 50 * s, 8 * s, 20 * s), Color(0.25, 0.55, 0.28))
		"wagon":
			canvas.draw_rect(Rect2(pos.x - 35 * s, pos.y - 28 * s, 70 * s, 28 * s), Color(0.45, 0.32, 0.22))
			canvas.draw_circle(pos + Vector2(-22 * s, 0), 10 * s, Color(0.2, 0.18, 0.16))
			canvas.draw_circle(pos + Vector2(22 * s, 0), 10 * s, Color(0.2, 0.18, 0.16))
		"wagon_wheel":
			canvas.draw_arc(pos, 16 * s, 0, TAU, 16, Color(0.3, 0.25, 0.2), 4.0)
		"factory_stack":
			canvas.draw_rect(Rect2(pos.x - 18 * s, pos.y - 120 * s, 36 * s, 120 * s), Color(0.35, 0.37, 0.4))
			canvas.draw_circle(pos + Vector2(0, -130 * s), 12 * s, Color(0.55, 0.55, 0.58, 0.35))
		"crane":
			canvas.draw_rect(Rect2(pos.x - 6 * s, pos.y - 100 * s, 12 * s, 100 * s), Color(0.9, 0.55, 0.15))
			canvas.draw_line(pos + Vector2(0, -100 * s), pos + Vector2(60 * s, -80 * s), Color(0.9, 0.55, 0.15), 5.0)
		"pipe":
			Shapes.capsule(canvas, pos + Vector2(0, -40 * s), pos + Vector2(40 * s, -20 * s), 12 * s, Color(0.5, 0.52, 0.55))
		"gear":
			var rot := time * 1.8 + phase * TAU
			for i in 8:
				var a := rot + i * TAU / 8.0
				canvas.draw_line(
					pos + Vector2(0, -35 * s),
					pos + Vector2(cos(a), sin(a)) * 28 * s - Vector2(0, 35 * s),
					Color(0.55, 0.58, 0.62),
					6.0
				)
			canvas.draw_circle(pos + Vector2(0, -35 * s), 12 * s, Color(0.45, 0.48, 0.52))
		"warning_light":
			var blink := sin(time * 6.0) > 0.0
			canvas.draw_circle(pos + Vector2(0, -50 * s), 8 * s, Color(1.0, 0.2, 0.15) if blink else Color(0.3, 0.1, 0.1))
		"conveyor":
			var w := 120.0 * s
			canvas.draw_rect(Rect2(pos.x - w * 0.5, pos.y - 8 * s, w, 8 * s), Color(0.25, 0.27, 0.3))
			for i in 6:
				var ox := fmod(time * 40.0 + i * 18.0, w) - w * 0.5
				canvas.draw_rect(Rect2(pos.x + ox, pos.y - 7 * s, 10 * s, 5 * s), Color(0.15, 0.16, 0.18))
		"chain":
			for i in 6:
				canvas.draw_arc(pos + Vector2(0, -10 * s - i * 12 * s), 6 * s, 0, TAU, 8, Color(0.4, 0.42, 0.45), 3.0)
		"steam_vent":
			if fmod(time, 4.0) < 2.0:
				for i in 3:
					canvas.draw_circle(pos + Vector2(i * 8 - 8, -20 * s - i * 12), 10 + i * 4, Color(1, 1, 1, 0.12))
		"castle_tower":
			canvas.draw_rect(Rect2(pos.x - 28 * s, pos.y - 130 * s, 56 * s, 130 * s), palette.get("platform", Color.GRAY))
			for i in 3:
				canvas.draw_rect(Rect2(pos.x - 32 * s + i * 18 * s, pos.y - 145 * s, 12 * s, 15 * s), palette.get("platform", Color.GRAY).lightened(0.05))
		"battlement":
			for i in 10:
				canvas.draw_rect(Rect2(pos.x - 200 * s + i * 40 * s, pos.y - 90 * s, 20 * s, 90 * s), palette.get("platform", Color.GRAY).darkened(0.05))
		"banner":
			var wave := sin(time * 3.0) * 6.0
			canvas.draw_colored_polygon(
				PackedVector2Array([
					pos + Vector2(0, -90 * s),
					pos + Vector2(30 * s + wave, -70 * s),
					pos + Vector2(0, -50 * s),
				]),
				Color(0.75, 0.2, 0.2)
			)
		"torch":
			canvas.draw_circle(pos + Vector2(0, -55 * s), 6 * s, Color(1.0, 0.6, 0.2, 0.7 + sin(time * 8.0) * 0.2))
		"wood_bridge":
			canvas.draw_rect(Rect2(pos.x - 80 * s, pos.y - 12 * s, 160 * s, 12 * s), Color(0.45, 0.32, 0.22))
		"catapult":
			canvas.draw_line(pos + Vector2(-30 * s, 0), pos + Vector2(30 * s, 0), Color(0.4, 0.3, 0.22), 6.0)
			canvas.draw_line(pos, pos + Vector2(20 * s, -40 * s), Color(0.4, 0.3, 0.22), 5.0)
		"stone_pillar":
			canvas.draw_rect(Rect2(pos.x - 10 * s, pos.y - 70 * s, 20 * s, 70 * s), palette.get("platform", Color.GRAY).darkened(0.1))
		"tunnel":
			canvas.draw_arc(pos + Vector2(0, 20 * s), 70 * s, PI, TAU, 24, Color(0.08, 0.08, 0.1), 40.0)
		"train_bridge":
			canvas.draw_rect(Rect2(pos.x - 200 * s, pos.y - 6 * s, 400 * s, 6 * s), Color(0.35, 0.3, 0.28))
		"train_car":
			var offset := sin(time * 0.8 + phase * TAU) * 6.0
			canvas.draw_rect(Rect2(pos.x - 70 * s + offset, pos.y - 50 * s, 140 * s, 50 * s), Color(0.6, 0.18, 0.18))
			canvas.draw_rect(Rect2(pos.x - 50 * s + offset, pos.y - 62 * s, 30 * s, 12 * s), Color(0.75, 0.78, 0.85, 0.5))
		"signal":
			canvas.draw_circle(pos + Vector2(0, -60 * s), 6 * s, Color(0.2, 0.9, 0.3) if fmod(time, 2.0) > 1.0 else Color(0.9, 0.2, 0.2))
		"cargo_crate":
			canvas.draw_rect(Rect2(pos.x - 22 * s, pos.y - 30 * s, 44 * s, 30 * s), Color(0.55, 0.38, 0.22))
		"cave_mouth":
			canvas.draw_arc(pos + Vector2(0, 30 * s), 80 * s, PI, TAU, 24, Color(0.04, 0.04, 0.05), 50.0)
		"crystal_cluster", "crystal":
			var c := Color(0.45, 0.85, 1.0, 0.75)
			canvas.draw_colored_polygon(PackedVector2Array([pos, pos + Vector2(-12 * s, -30 * s), pos + Vector2(12 * s, -30 * s)]), c)
			canvas.draw_colored_polygon(PackedVector2Array([pos + Vector2(10 * s, 0), pos + Vector2(22 * s, -24 * s), pos + Vector2(28 * s, 0)]), c.lightened(0.1))
		"mine_support":
			canvas.draw_line(pos + Vector2(-20 * s, 0), pos + Vector2(0, -60 * s), Color(0.45, 0.32, 0.22), 6.0)
			canvas.draw_line(pos + Vector2(20 * s, 0), pos + Vector2(0, -60 * s), Color(0.45, 0.32, 0.22), 6.0)
			canvas.draw_line(pos + Vector2(-20 * s, -40 * s), pos + Vector2(20 * s, -40 * s), Color(0.45, 0.32, 0.22), 5.0)
		"mine_rail":
			for i in 8:
				canvas.draw_line(pos + Vector2(-80 * s + i * 22 * s, 0), pos + Vector2(-80 * s + i * 22 * s, -4 * s), Color(0.4, 0.4, 0.42), 3.0)
		"mine_cart":
			canvas.draw_rect(Rect2(pos.x - 25 * s, pos.y - 22 * s, 50 * s, 22 * s), Color(0.42, 0.35, 0.28))
		"lantern":
			canvas.draw_circle(pos + Vector2(0, -45 * s), 7 * s, Color(1.0, 0.85, 0.45, 0.8))
		"cloud":
			canvas.draw_circle(pos + Vector2(-20 * s, -80 * s), 28 * s, Color(1, 1, 1, 0.1))
			canvas.draw_circle(pos + Vector2(10 * s, -90 * s), 34 * s, Color(1, 1, 1, 0.08))
		"balloon":
			canvas.draw_circle(pos + Vector2(0, -90 * s), 22 * s, Color(0.9, 0.3, 0.25))
			canvas.draw_line(pos, pos + Vector2(0, -68 * s), Color(0.6, 0.6, 0.65), 2.0)
		"airship_engine":
			canvas.draw_rect(Rect2(pos.x - 40 * s, pos.y - 35 * s, 80 * s, 35 * s), palette.get("platform", Color.GRAY))
		"propeller":
			var a := time * 10.0
			canvas.draw_line(pos + Vector2(0, -40 * s), pos + Vector2(cos(a), sin(a)) * 30 * s - Vector2(0, 40 * s), Color(0.7, 0.72, 0.75), 3.0)
		"rope_rig":
			canvas.draw_line(pos, pos + Vector2(0, -70 * s), Color(0.55, 0.42, 0.3), 3.0)
		"floating_platform":
			canvas.draw_rect(Rect2(pos.x - 50 * s, pos.y - 10 * s, 100 * s, 10 * s), palette.get("platform", Color.GRAY).lightened(0.1))
		"skyscraper":
			canvas.draw_rect(Rect2(pos.x - 35 * s, pos.y - 160 * s, 70 * s, 160 * s), Color(0.12, 0.14, 0.18, 0.85))
		"billboard":
			canvas.draw_rect(Rect2(pos.x - 40 * s, pos.y - 50 * s, 80 * s, 40 * s), Color(0.2, 0.22, 0.28))
			canvas.draw_rect(Rect2(pos.x - 30 * s, pos.y - 42 * s, 60 * s, 24 * s), Color(0.85, 0.2, 0.55, 0.6))
		"water_tower":
			canvas.draw_rect(Rect2(pos.x - 4 * s, pos.y - 80 * s, 8 * s, 80 * s), Color(0.5, 0.52, 0.55))
			canvas.draw_circle(pos + Vector2(0, -90 * s), 24 * s, Color(0.55, 0.58, 0.62))
		"construction_crane":
			canvas.draw_line(pos + Vector2(0, 0), pos + Vector2(0, -110 * s), Color(0.95, 0.75, 0.15), 5.0)
			canvas.draw_line(pos + Vector2(0, -110 * s), pos + Vector2(70 * s, -90 * s), Color(0.95, 0.75, 0.15), 4.0)
		"fire_escape":
			for i in 5:
				canvas.draw_rect(Rect2(pos.x - 12 * s, pos.y - 80 * s + i * 16 * s, 24 * s, 4 * s), Color(0.35, 0.38, 0.42))
		"neon_sign":
			var glow := 0.6 + sin(time * 4.0) * 0.4
			canvas.draw_rect(Rect2(pos.x - 35 * s, pos.y - 30 * s, 70 * s, 20 * s), Color(0.2, 0.9, 1.0, glow))
		"rooftop_ac":
			canvas.draw_rect(Rect2(pos.x - 20 * s, pos.y - 18 * s, 40 * s, 18 * s), Color(0.45, 0.48, 0.52))
		"dam_wall":
			canvas.draw_rect(Rect2(pos.x - 80 * s, pos.y - 120 * s, 160 * s, 120 * s), palette.get("platform", Color.GRAY))
		"spillway":
			for i in 4:
				canvas.draw_line(pos + Vector2(-30 * s + i * 20 * s, -10 * s), pos + Vector2(-30 * s + i * 20 * s, 40 * s), Color(0.55, 0.72, 0.88, 0.35), 4.0)
		"turbine":
			canvas.draw_circle(pos + Vector2(0, -40 * s), 24 * s, Color(0.4, 0.42, 0.45))
			canvas.draw_line(pos, pos + Vector2(cos(time * 2.0), sin(time * 2.0)) * 20 * s - Vector2(0, 40 * s), Color(0.55, 0.58, 0.62), 4.0)
		"walkway":
			canvas.draw_rect(Rect2(pos.x - 60 * s, pos.y - 8 * s, 120 * s, 8 * s), Color(0.5, 0.52, 0.55))
		"water_spray":
			if fmod(time, 5.0) < 2.5:
				for i in 5:
					var ox := sin(time * 3.0 + i * 1.7) * 20.0
					var oy := 10.0 + i * 7.0 + sin(time * 4.0 + i) * 5.0
					canvas.draw_line(pos, pos + Vector2(ox, oy), Color(0.7, 0.85, 1.0, 0.25), 2.0)
		"buoy_dam":
			canvas.draw_circle(pos + Vector2(0, -15 * s), 12 * s, Color(0.9, 0.25, 0.2))
		"maintenance_rail":
			canvas.draw_line(pos + Vector2(-50 * s, -4 * s), pos + Vector2(50 * s, -4 * s), Color(0.55, 0.58, 0.62), 4.0)
		"volcano_peak":
			draw_silhouette(canvas, "volcano_peak", surface, palette, time)
		"lava_river":
			canvas.draw_rect(Rect2(pos.x - 100 * s, pos.y + 10 * s, 200 * s, 14 * s), Color(0.95, 0.35, 0.1, 0.65))
		"cracked_rock":
			canvas.draw_rect(Rect2(pos.x - 30 * s, pos.y - 20 * s, 60 * s, 20 * s), palette.get("platform", Color.GRAY).darkened(0.2))
			canvas.draw_line(pos + Vector2(-15 * s, -18 * s), pos + Vector2(10 * s, -2 * s), Color(0.15, 0.1, 0.08), 2.0)
		"magma_vent":
			if fmod(time, 8.0) < 3.0:
				canvas.draw_circle(pos + Vector2(0, -8 * s), 16 * s, Color(1.0, 0.45, 0.1, 0.55))
		"smoke_column":
			for i in 4:
				canvas.draw_circle(pos + Vector2(sin(time + i) * 8, -20 * s - i * 18), 14 + i * 4, Color(0.2, 0.2, 0.22, 0.15))
		"ship":
			canvas.draw_rect(Rect2(pos.x - 60 * s, pos.y - 35 * s, 120 * s, 35 * s), Color(0.35, 0.38, 0.42))
			canvas.draw_colored_polygon(
				PackedVector2Array([pos + Vector2(-20 * s, -35 * s), pos + Vector2(0, -70 * s), pos + Vector2(20 * s, -35 * s)]),
				Color(0.5, 0.52, 0.55)
			)
		"container_stack":
			for i in 3:
				canvas.draw_rect(Rect2(pos.x - 28 * s, pos.y - 28 * s - i * 26 * s, 56 * s, 24 * s), Color(0.75, 0.25, 0.2) if i == 0 else Color(0.2, 0.45, 0.75))
		"dock_crane":
			draw_prop(canvas, "crane", pos, surface, s, time, palette, phase)
		"wooden_dock":
			for i in 8:
				canvas.draw_rect(Rect2(pos.x - 90 * s + i * 24 * s, pos.y - 6 * s, 18 * s, 6 * s), Color(0.45, 0.32, 0.22))
		"buoy":
			canvas.draw_circle(pos + Vector2(0, -12 * s), 10 * s, Color(0.95, 0.35, 0.2))
		"wave":
			canvas.draw_arc(pos + Vector2(0, 8 * s), 40 * s, PI, TAU, 16, Color(0.55, 0.72, 0.88, 0.35), 4.0)
		"sandbags":
			for row in 2:
				for col in 3:
					var ox := (-24.0 + col * 24.0) * s
					var oy := (-8.0 - row * 10.0) * s
					canvas.draw_rect(Rect2(pos.x + ox - 10 * s, pos.y + oy - 8 * s, 20 * s, 8 * s), Color(0.52, 0.42, 0.28))
			canvas.draw_rect(Rect2(pos.x - 34 * s, pos.y - 2 * s, 68 * s, 4 * s), Color(0.45, 0.36, 0.24))
		"barrel":
			var blink := sin(time * 5.0 + pos.x * 0.01) > 0.85
			canvas.draw_rect(Rect2(pos.x - 12 * s, pos.y - 32 * s, 24 * s, 32 * s), Color(0.55, 0.22, 0.18))
			canvas.draw_rect(Rect2(pos.x - 10 * s, pos.y - 28 * s, 20 * s, 4 * s), Color(0.15, 0.12, 0.1))
			if blink:
				canvas.draw_circle(pos + Vector2(0, -36 * s), 5 * s, Color(1.0, 0.35, 0.1, 0.75))
		"ammo_crate":
			canvas.draw_rect(Rect2(pos.x - 24 * s, pos.y - 28 * s, 48 * s, 28 * s), Color(0.42, 0.38, 0.32))
			canvas.draw_rect(Rect2(pos.x - 18 * s, pos.y - 22 * s, 36 * s, 6 * s), Color(0.55, 0.48, 0.2))
			canvas.draw_line(pos + Vector2(-16 * s, -14 * s), pos + Vector2(16 * s, -14 * s), Color(0.25, 0.22, 0.18), 2.0)
		"broken_sign":
			canvas.draw_rect(Rect2(pos.x - 3 * s, pos.y - 55 * s, 6 * s, 55 * s), Color(0.42, 0.4, 0.38))
			canvas.draw_colored_polygon(
				PackedVector2Array([
					pos + Vector2(-28 * s, -48 * s),
					pos + Vector2(18 * s, -42 * s),
					pos + Vector2(12 * s, -28 * s),
					pos + Vector2(-22 * s, -32 * s),
				]),
				Color(0.72, 0.18, 0.15)
			)
			canvas.draw_line(pos + Vector2(-8 * s, -38 * s), pos + Vector2(4 * s, -34 * s), Color(0.15, 0.12, 0.1), 2.0)
		"junk_truck":
			canvas.draw_rect(Rect2(pos.x - 55 * s, pos.y - 38 * s, 90 * s, 38 * s), Color(0.38, 0.32, 0.28))
			canvas.draw_rect(Rect2(pos.x + 20 * s, pos.y - 52 * s, 30 * s, 20 * s), Color(0.32, 0.35, 0.38))
			canvas.draw_circle(pos + Vector2(-30 * s, 0), 12 * s, Color(0.12, 0.1, 0.08))
			canvas.draw_circle(pos + Vector2(28 * s, 0), 12 * s, Color(0.12, 0.1, 0.08))
			canvas.draw_line(pos + Vector2(-20 * s, -20 * s), pos + Vector2(10 * s, -35 * s), Color(0.2, 0.18, 0.16), 3.0)
		"rock_pile":
			for i in 4:
				var rx := (-20.0 + i * 13.0 + sin(time + i) * 2.0) * s
				var ry := (-6.0 - (i % 3) * 8.0) * s
				canvas.draw_circle(pos + Vector2(rx, ry), (8.0 + i * 2.0) * s, palette.get("platform", Color.GRAY).darkened(0.05 + i * 0.04))
		"tire_stack":
			for i in 3:
				canvas.draw_arc(pos + Vector2(0, -8 * s - i * 10 * s), 14 * s, 0, TAU, 14, Color(0.12, 0.1, 0.08), 5.0)
		"barbed_wire":
			var w := 90.0 * s
			for i in 6:
				var px := -w * 0.5 + i * (w / 5.0)
				var wave_y := sin(time * 2.0 + i * 0.8) * 3.0 * s
				canvas.draw_line(
					pos + Vector2(px, -18 * s + wave_y),
					pos + Vector2(px + 12 * s, -22 * s - wave_y),
					Color(0.45, 0.45, 0.48),
					2.0
				)
			canvas.draw_line(pos + Vector2(-w * 0.5, -12 * s), pos + Vector2(w * 0.5, -12 * s), Color(0.35, 0.35, 0.38), 2.0)
