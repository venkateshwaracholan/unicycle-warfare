extends Node

const CombatEffect := preload("res://scripts/combat/combat_effect.gd")


func _spawn(kind: String, pos: Vector2, direction: Vector2 = Vector2.RIGHT, size: float = 1.0, color: Color = Color.WHITE) -> void:
	var world := get_tree().current_scene
	if world == null:
		return
	var fx: Node2D = CombatEffect.new()
	fx.setup(kind, pos, direction, size, color)
	world.add_child(fx)


func muzzle_flash(pos: Vector2, direction: Vector2, weapon: WeaponDefs.Type = WeaponDefs.Type.PISTOL) -> void:
	var size := 1.0
	match weapon:
		WeaponDefs.Type.SHOTGUN, WeaponDefs.Type.SNIPER, WeaponDefs.Type.ROCKET:
			size = 1.45
		WeaponDefs.Type.MINIGUN, WeaponDefs.Type.SMG:
			size = 1.15
	_spawn("muzzle", pos, direction, size)


func bullet_impact(pos: Vector2, direction: Vector2) -> void:
	_spawn("impact", pos, direction, 1.0)
	_spawn("smoke", pos + Vector2(0, -4), Vector2.UP, 0.7)


func explosion(pos: Vector2, radius: float = 85.0) -> void:
	_spawn("explosion", pos, Vector2.RIGHT, radius / 85.0)
	_spawn("smoke", pos + Vector2(0, -8), Vector2.UP, 1.2)


func debris(pos: Vector2, count: int = 3) -> void:
	for i in count:
		_spawn("smoke", pos + Vector2(randf_range(-10, 10), randf_range(-8, 0)), Vector2.UP, 0.55)


func shell_casing(pos: Vector2, direction: Vector2) -> void:
	if randf() > 0.35:
		return
	_spawn("casing", pos, direction, 1.0)
