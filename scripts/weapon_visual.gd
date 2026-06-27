class_name WeaponVisual
extends RefCounted

const Shapes := preload("res://scripts/draw_shapes.gd")

const WEAPON_SCALE := 1.72
const GRIP := Vector2(4.0, -20.0)
const GRIP_METAL := Color(0.22, 0.20, 0.24)
const GRIP_WRAP := Color(0.32, 0.22, 0.14)


static func get_muzzle_local(weapon_type: WeaponDefs.Type) -> Vector2:
	match weapon_type:
		WeaponDefs.Type.PISTOL:
			return _muzzle(34.0, -20.0)
		WeaponDefs.Type.SMG:
			return _muzzle(48.0, -20.0)
		WeaponDefs.Type.SHOTGUN:
			return _muzzle(58.0, -19.0)
		WeaponDefs.Type.SNIPER:
			return _muzzle(68.0, -20.0)
		WeaponDefs.Type.ROCKET:
			return _muzzle(62.0, -20.0)
		WeaponDefs.Type.MINIGUN:
			return _muzzle(70.0, -19.0)
		WeaponDefs.Type.KATANA:
			return _muzzle(52.0, -28.0)
		WeaponDefs.Type.GRENADE:
			return _muzzle(38.0, -18.0)
		WeaponDefs.Type.HARPOON:
			return _muzzle(56.0, -20.0)
		WeaponDefs.Type.CROSSBOW:
			return _muzzle(52.0, -20.0)
		WeaponDefs.Type.HAMMER:
			return _muzzle(46.0, -18.0)
		_:
			return _muzzle(42.0, -22.0)


static func _muzzle(x: float, y: float) -> Vector2:
	return Vector2(x, y)


static func get_hand_positions(weapon_type: WeaponDefs.Type) -> PackedVector2Array:
	match weapon_type:
		WeaponDefs.Type.NONE:
			return PackedVector2Array([Vector2(10.0, -16.0), Vector2(18.0, -14.0)])
		WeaponDefs.Type.GRENADE:
			return PackedVector2Array([Vector2(14.0, -17.0), Vector2(28.0, -16.0)])
		WeaponDefs.Type.KATANA:
			return PackedVector2Array([Vector2(10.0, -18.0), Vector2(22.0, -20.0)])
		WeaponDefs.Type.HAMMER:
			return PackedVector2Array([Vector2(10.0, -16.0), Vector2(24.0, -15.0)])
		WeaponDefs.Type.MINIGUN:
			return PackedVector2Array([Vector2(6.0, -12.0), Vector2(22.0, -22.0)])
		WeaponDefs.Type.SHOTGUN, WeaponDefs.Type.SNIPER, WeaponDefs.Type.ROCKET:
			return PackedVector2Array([Vector2(10.0, -16.0), Vector2(36.0, -18.0)])
		_:
			return PackedVector2Array([Vector2(10.0, -17.0), Vector2(30.0, -19.0)])


static func draw_hand(target: CanvasItem, pos: Vector2, skin: Color) -> void:
	target.draw_circle(pos, 4.2, skin.darkened(0.06))
	target.draw_circle(pos + Vector2(0.8, -0.4), 3.2, skin)
	target.draw_arc(pos + Vector2(-1.5, 1.8), 3.0, PI * 0.1, PI * 0.85, 8, Color(0.38, 0.28, 0.18), 1.2)


static func draw_held(target: CanvasItem, weapon_type: WeaponDefs.Type) -> void:
	if weapon_type == WeaponDefs.Type.NONE:
		return
	var data := WeaponDefs.get_data(weapon_type)
	var color: Color = data["color"]
	var g := GRIP
	var sc := WEAPON_SCALE
	match weapon_type:
		WeaponDefs.Type.PISTOL:
			_draw_rifle_body(target, g, 26.0 * sc, 5.5 * sc, color, 10.0 * sc)
		WeaponDefs.Type.SMG:
			_draw_rifle_body(target, g, 36.0 * sc, 6.5 * sc, color, 13.0 * sc)
			Shapes.rounded_rect(target, Rect2(g.x + 6.0 * sc, g.y - 1.5 * sc, 12.0 * sc, 12.0 * sc), 1.0, color.darkened(0.12))
		WeaponDefs.Type.SHOTGUN:
			_draw_rifle_body(target, g, 46.0 * sc, 8.0 * sc, color, 16.0 * sc)
			target.draw_line(g + Vector2(16.0 * sc, -1.0 * sc), g + Vector2(46.0 * sc, -1.0 * sc), color.lightened(0.08), 4.0 * sc)
		WeaponDefs.Type.SNIPER:
			_draw_rifle_body(target, g, 56.0 * sc, 5.0 * sc, color, 20.0 * sc)
			Shapes.rounded_rect(target, Rect2(g.x + 12.0 * sc, g.y - 7.0 * sc, 16.0 * sc, 4.0 * sc), 1.0, color.darkened(0.15))
		WeaponDefs.Type.ROCKET:
			Shapes.rounded_rect(target, Rect2(g.x, g.y - 6.0 * sc, 38.0 * sc, 12.0 * sc), 2.0, color.darkened(0.1))
			Shapes.rounded_rect(target, Rect2(g.x + 36.0 * sc, g.y - 7.0 * sc, 18.0 * sc, 14.0 * sc), 2.0, color)
			target.draw_circle(g + Vector2(48.0 * sc, 0.0), 3.0 * sc, Color(0.15, 0.12, 0.1))
		WeaponDefs.Type.MINIGUN:
			_draw_minigun_held(target, g, sc, color)
		WeaponDefs.Type.KATANA:
			target.draw_line(g + Vector2(-2.0 * sc, 4.0 * sc), g + Vector2(46.0 * sc, -24.0 * sc), Color(0.88, 0.90, 0.96), 4.5 * sc)
			target.draw_line(g + Vector2(-2.0 * sc, 4.0 * sc), g + Vector2(-8.0 * sc, 10.0 * sc), GRIP_WRAP, 4.0 * sc)
			target.draw_circle(g + Vector2(0.0, 2.0 * sc), 3.5 * sc, color)
		WeaponDefs.Type.GRENADE:
			target.draw_circle(g + Vector2(22.0 * sc, 0.0), 9.0 * sc, color)
			target.draw_rect(Rect2(g.x + 20.0 * sc, g.y - 14.0 * sc, 5.0 * sc, 7.0 * sc), GRIP_METAL)
		WeaponDefs.Type.HARPOON:
			_draw_rifle_body(target, g, 40.0 * sc, 7.0 * sc, color, 13.0 * sc)
			target.draw_line(g + Vector2(36.0 * sc, 0.0), g + Vector2(50.0 * sc, 0.0), Color(0.75, 0.75, 0.78), 3.0 * sc)
		WeaponDefs.Type.CROSSBOW:
			Shapes.rounded_rect(target, Rect2(g.x + 6.0 * sc, g.y - 4.0 * sc, 28.0 * sc, 8.0 * sc), 1.0, color)
			target.draw_line(g + Vector2(10.0 * sc, -14.0 * sc), g + Vector2(10.0 * sc, 8.0 * sc), color.darkened(0.1), 3.5 * sc)
			target.draw_line(g + Vector2(34.0 * sc, -12.0 * sc), g + Vector2(34.0 * sc, 6.0 * sc), color.darkened(0.1), 3.5 * sc)
			target.draw_line(g + Vector2(10.0 * sc, -14.0 * sc), g + Vector2(34.0 * sc, -12.0 * sc), Color(0.55, 0.35, 0.2), 2.0 * sc)
		WeaponDefs.Type.HAMMER:
			target.draw_line(g + Vector2(0.0, 2.0 * sc), g + Vector2(28.0 * sc, 2.0 * sc), GRIP_WRAP, 4.5 * sc)
			target.draw_rect(Rect2(g.x + 26.0 * sc, g.y - 14.0 * sc, 18.0 * sc, 18.0 * sc), color)
			target.draw_rect(Rect2(g.x + 29.0 * sc, g.y - 11.0 * sc, 12.0 * sc, 12.0 * sc), color.lightened(0.08))
		_:
			_draw_rifle_body(target, g, 28.0 * sc, 5.5 * sc, color, 10.0 * sc)


static func draw_ground(target: CanvasItem, weapon_type: WeaponDefs.Type, glow: bool = true) -> void:
	var data := WeaponDefs.get_data(weapon_type)
	var gun_color: Color = data["color"]
	var cat: WeaponDefs.Category = data["category"]
	match cat:
		WeaponDefs.Category.MELEE:
			if weapon_type == WeaponDefs.Type.KATANA:
				target.draw_line(Vector2(-20, 4), Vector2(22, -8), Color(0.85, 0.88, 0.95), 4.0)
				target.draw_line(Vector2(-20, 4), Vector2(-24, 8), Color(0.35, 0.2, 0.1), 3.0)
			else:
				target.draw_rect(Rect2(-8, -16, 16, 28), gun_color)
				target.draw_rect(Rect2(-14, 8, 28, 8), gun_color.darkened(0.15))
		WeaponDefs.Category.THROWABLE:
			target.draw_circle(Vector2(0, 0), 8, gun_color)
			target.draw_rect(Rect2(-2, -12, 4, 6), Color(0.3, 0.3, 0.3))
		_:
			if weapon_type == WeaponDefs.Type.MINIGUN:
				_draw_minigun_ground(target, gun_color)
			else:
				target.draw_rect(Rect2(-14, -6, 28, 10), gun_color)
				target.draw_rect(Rect2(10, -4, 18, 6), gun_color.darkened(0.2))
				target.draw_circle(Vector2(-8, 2), 5, Color(0.2, 0.2, 0.25))
	if glow:
		target.draw_arc(Vector2.ZERO, 24, 0, TAU, 24, Color(1, 1, 0.5, 0.25), 2.0)


static func _draw_rifle_body(
	target: CanvasItem,
	grip: Vector2,
	length: float,
	height: float,
	color: Color,
	barrel_len: float
) -> void:
	var body_h := height
	Shapes.rounded_rect(target, Rect2(grip.x, grip.y - body_h * 0.5, length - barrel_len * 0.35, body_h), 1.5, color)
	Shapes.rounded_rect(
		target,
		Rect2(grip.x + length - barrel_len, grip.y - body_h * 0.35, barrel_len, body_h * 0.7),
		1.0,
		color.darkened(0.15)
	)
	target.draw_circle(grip + Vector2(2.0, body_h * 0.35), 2.8, GRIP_METAL)
	Shapes.rounded_rect(target, Rect2(grip.x - 1.0, grip.y + 1.0, 5.0, 7.0), 1.0, GRIP_WRAP)


static func _draw_minigun_held(target: CanvasItem, g: Vector2, sc: float, color: Color) -> void:
	var body := color.darkened(0.08)
	var dark := GRIP_METAL
	var drum := Color(0.42, 0.38, 0.34)
	var brass := Color(0.72, 0.58, 0.28)

	# Ammo drum under receiver
	target.draw_circle(g + Vector2(14.0 * sc, 10.0 * sc), 11.0 * sc, drum)
	target.draw_arc(g + Vector2(14.0 * sc, 10.0 * sc), 11.0 * sc, 0, TAU, 28, dark, 2.0 * sc)
	for i in 4:
		var a := float(i) / 4.0 * TAU
		var p := g + Vector2(14.0 * sc, 10.0 * sc) + Vector2(cos(a), sin(a)) * 7.5 * sc
		target.draw_circle(p, 1.8 * sc, dark.lightened(0.12))

	# Motor / receiver block
	Shapes.rounded_rect(target, Rect2(g.x - 2.0 * sc, g.y - 10.0 * sc, 28.0 * sc, 20.0 * sc), 2.5 * sc, body)
	Shapes.rounded_rect(target, Rect2(g.x + 2.0 * sc, g.y - 7.0 * sc, 20.0 * sc, 6.0 * sc), 1.0 * sc, dark.lightened(0.06))
	for i in 3:
		target.draw_line(
			g + Vector2(6.0 * sc + float(i) * 5.5 * sc, -8.0 * sc),
			g + Vector2(6.0 * sc + float(i) * 5.5 * sc, -2.0 * sc),
			Color(0.18, 0.16, 0.14),
			1.2 * sc
		)

	# Pistol grip + trigger guard
	Shapes.rounded_rect(target, Rect2(g.x + 1.0 * sc, g.y + 2.0 * sc, 7.0 * sc, 11.0 * sc), 1.5 * sc, GRIP_WRAP)
	target.draw_arc(g + Vector2(8.0 * sc, 6.0 * sc), 5.0 * sc, PI * 0.15, PI * 0.85, 10, dark, 1.6 * sc)

	# Feed chute
	Shapes.rounded_rect(target, Rect2(g.x + 10.0 * sc, g.y + 1.0 * sc, 10.0 * sc, 5.0 * sc), 1.0 * sc, brass.darkened(0.15))
	target.draw_line(g + Vector2(12.0 * sc, 3.5 * sc), g + Vector2(18.0 * sc, 3.5 * sc), brass, 1.4 * sc)

	# Barrel shroud / clamp
	Shapes.rounded_rect(target, Rect2(g.x + 24.0 * sc, g.y - 9.0 * sc, 22.0 * sc, 18.0 * sc), 2.0 * sc, dark.lightened(0.04))
	target.draw_rect(Rect2(g.x + 26.0 * sc, g.y - 10.5 * sc, 18.0 * sc, 2.0 * sc), body.lightened(0.06))
	target.draw_rect(Rect2(g.x + 26.0 * sc, g.y + 8.5 * sc, 18.0 * sc, 2.0 * sc), body.lightened(0.06))

	# Six-barrel cluster
	var hub := g + Vector2(52.0 * sc, 0.0)
	target.draw_circle(hub, 5.5 * sc, dark)
	for i in 6:
		var a := float(i) / 6.0 * TAU - PI * 0.5
		var offset := Vector2(cos(a), sin(a)) * 4.5 * sc
		var barrel_start := hub + offset
		var barrel_end := hub + offset + Vector2(18.0 * sc, 0.0)
		target.draw_line(barrel_start, barrel_end, Color(0.28, 0.28, 0.32), 2.6 * sc)
		target.draw_circle(barrel_end, 1.4 * sc, Color(0.15, 0.14, 0.12))

	# Front flash hider ring
	target.draw_arc(hub + Vector2(18.0 * sc, 0.0), 7.0 * sc, -PI * 0.55, PI * 0.55, 12, Color(0.35, 0.34, 0.38), 2.2 * sc)

	# Top carry handle
	var handle_y := g.y - 14.0 * sc
	target.draw_line(g + Vector2(18.0 * sc, handle_y), g + Vector2(34.0 * sc, handle_y), dark, 3.0 * sc)
	target.draw_line(g + Vector2(18.0 * sc, handle_y), g + Vector2(18.0 * sc, handle_y + 5.0 * sc), dark, 2.5 * sc)
	target.draw_line(g + Vector2(34.0 * sc, handle_y), g + Vector2(34.0 * sc, handle_y + 5.0 * sc), dark, 2.5 * sc)
	target.draw_line(g + Vector2(20.0 * sc, handle_y + 5.0 * sc), g + Vector2(32.0 * sc, handle_y + 5.0 * sc), GRIP_WRAP, 2.8 * sc)


static func _draw_minigun_ground(target: CanvasItem, color: Color) -> void:
	_draw_minigun_held(target, Vector2(-18.0, 2.0), 0.62, color)
