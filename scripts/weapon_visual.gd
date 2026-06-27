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
			return _muzzle(56.0, -19.0)
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
			return PackedVector2Array([Vector2(8.0, -15.0), Vector2(28.0, -17.0)])
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
			Shapes.rounded_rect(target, Rect2(g.x, g.y - 8.0 * sc, 32.0 * sc, 16.0 * sc), 2.0, color.darkened(0.12))
			for i in 3:
				target.draw_circle(g + Vector2(34.0 * sc + float(i) * 5.0 * sc, -1.0 * sc + float(i) * 0.5 * sc), 3.2 * sc, GRIP_METAL)
			target.draw_circle(g + Vector2(10.0 * sc, 2.0 * sc), 6.0 * sc, color.darkened(0.2))
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
