class_name WeaponVisual
extends RefCounted

const Shapes := preload("res://scripts/draw_shapes.gd")

const GRIP := Vector2(6.0, -20.0)
const GRIP_METAL := Color(0.22, 0.20, 0.24)
const GRIP_WRAP := Color(0.32, 0.22, 0.14)


static func get_muzzle_local(weapon_type: WeaponDefs.Type) -> Vector2:
	match weapon_type:
		WeaponDefs.Type.PISTOL:
			return Vector2(22.0, -20.0)
		WeaponDefs.Type.SMG:
			return Vector2(30.0, -20.0)
		WeaponDefs.Type.SHOTGUN:
			return Vector2(36.0, -19.0)
		WeaponDefs.Type.SNIPER:
			return Vector2(42.0, -20.0)
		WeaponDefs.Type.ROCKET:
			return Vector2(38.0, -20.0)
		WeaponDefs.Type.MINIGUN:
			return Vector2(34.0, -19.0)
		WeaponDefs.Type.KATANA:
			return Vector2(32.0, -28.0)
		WeaponDefs.Type.GRENADE:
			return Vector2(24.0, -18.0)
		WeaponDefs.Type.HARPOON:
			return Vector2(34.0, -20.0)
		WeaponDefs.Type.CROSSBOW:
			return Vector2(32.0, -20.0)
		WeaponDefs.Type.HAMMER:
			return Vector2(28.0, -18.0)
		_:
			return Vector2(26.0, -22.0)


static func get_hand_positions(weapon_type: WeaponDefs.Type) -> PackedVector2Array:
	match weapon_type:
		WeaponDefs.Type.NONE:
			return PackedVector2Array([Vector2(10.0, -16.0), Vector2(18.0, -14.0)])
		WeaponDefs.Type.GRENADE:
			return PackedVector2Array([Vector2(12.0, -17.0), Vector2(20.0, -16.0)])
		WeaponDefs.Type.KATANA:
			return PackedVector2Array([Vector2(8.0, -18.0), Vector2(16.0, -20.0)])
		WeaponDefs.Type.HAMMER:
			return PackedVector2Array([Vector2(8.0, -16.0), Vector2(16.0, -15.0)])
		WeaponDefs.Type.MINIGUN:
			return PackedVector2Array([Vector2(6.0, -15.0), Vector2(18.0, -17.0)])
		WeaponDefs.Type.SHOTGUN, WeaponDefs.Type.SNIPER, WeaponDefs.Type.ROCKET:
			return PackedVector2Array([Vector2(8.0, -16.0), Vector2(24.0, -18.0)])
		_:
			return PackedVector2Array([Vector2(8.0, -17.0), Vector2(20.0, -19.0)])


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
	match weapon_type:
		WeaponDefs.Type.PISTOL:
			_draw_rifle_body(target, g, 16.0, 5.0, color, 6.0)
		WeaponDefs.Type.SMG:
			_draw_rifle_body(target, g, 22.0, 6.0, color, 8.0)
			Shapes.rounded_rect(target, Rect2(g.x + 4.0, g.y - 1.0, 8.0, 8.0), 1.0, color.darkened(0.12))
		WeaponDefs.Type.SHOTGUN:
			_draw_rifle_body(target, g, 28.0, 7.0, color, 10.0)
			target.draw_line(g + Vector2(10.0, -1.0), g + Vector2(28.0, -1.0), color.lightened(0.08), 3.0)
		WeaponDefs.Type.SNIPER:
			_draw_rifle_body(target, g, 34.0, 4.0, color, 12.0)
			Shapes.rounded_rect(target, Rect2(g.x + 8.0, g.y - 5.0, 10.0, 3.0), 1.0, color.darkened(0.15))
		WeaponDefs.Type.ROCKET:
			Shapes.rounded_rect(target, Rect2(g.x, g.y - 4.0, 24.0, 8.0), 2.0, color.darkened(0.1))
			Shapes.rounded_rect(target, Rect2(g.x + 22.0, g.y - 5.0, 12.0, 10.0), 2.0, color)
			target.draw_circle(g + Vector2(30.0, 0.0), 2.0, Color(0.15, 0.12, 0.1))
		WeaponDefs.Type.MINIGUN:
			Shapes.rounded_rect(target, Rect2(g.x, g.y - 6.0, 20.0, 12.0), 2.0, color.darkened(0.12))
			for i in 3:
				target.draw_circle(g + Vector2(22.0 + float(i) * 3.5, -1.0 + float(i) * 0.5), 2.2, GRIP_METAL)
			target.draw_circle(g + Vector2(6.0, 2.0), 4.0, color.darkened(0.2))
		WeaponDefs.Type.KATANA:
			target.draw_line(g + Vector2(-2.0, 4.0), g + Vector2(28.0, -16.0), Color(0.88, 0.90, 0.96), 3.5)
			target.draw_line(g + Vector2(-2.0, 4.0), g + Vector2(-6.0, 8.0), GRIP_WRAP, 3.0)
			target.draw_circle(g + Vector2(0.0, 2.0), 2.5, color)
		WeaponDefs.Type.GRENADE:
			target.draw_circle(g + Vector2(14.0, 0.0), 6.0, color)
			target.draw_rect(Rect2(g.x + 12.0, g.y - 10.0, 4.0, 5.0), GRIP_METAL)
		WeaponDefs.Type.HARPOON:
			_draw_rifle_body(target, g, 24.0, 6.0, color, 8.0)
			target.draw_line(g + Vector2(22.0, 0.0), g + Vector2(30.0, 0.0), Color(0.75, 0.75, 0.78), 2.0)
		WeaponDefs.Type.CROSSBOW:
			Shapes.rounded_rect(target, Rect2(g.x + 4.0, g.y - 3.0, 18.0, 6.0), 1.0, color)
			target.draw_line(g + Vector2(6.0, -10.0), g + Vector2(6.0, 6.0), color.darkened(0.1), 2.5)
			target.draw_line(g + Vector2(22.0, -8.0), g + Vector2(22.0, 4.0), color.darkened(0.1), 2.5)
			target.draw_line(g + Vector2(6.0, -10.0), g + Vector2(22.0, -8.0), Color(0.55, 0.35, 0.2), 1.5)
		WeaponDefs.Type.HAMMER:
			target.draw_line(g + Vector2(0.0, 2.0), g + Vector2(18.0, 2.0), GRIP_WRAP, 3.5)
			target.draw_rect(Rect2(g.x + 16.0, g.y - 10.0, 12.0, 14.0), color)
			target.draw_rect(Rect2(g.x + 18.0, g.y - 8.0, 8.0, 10.0), color.lightened(0.08))
		_:
			_draw_rifle_body(target, g, 18.0, 5.0, color, 6.0)


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
