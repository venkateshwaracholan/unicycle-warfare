class_name DestructibleProp
extends Area2D

var health := 35
var prop_type := "barrel"
var explosive := true
var draw_scale := 1.0
var _time := 0.0


func _ready() -> void:
	add_to_group("destructible")
	collision_layer = 32
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var body := RectangleShape2D.new()
	match prop_type:
		"ammo_crate":
			body.size = Vector2(48.0 * draw_scale, 28.0 * draw_scale)
			shape.position = Vector2(0.0, -14.0 * draw_scale)
		"sandbags":
			body.size = Vector2(68.0 * draw_scale, 26.0 * draw_scale)
			shape.position = Vector2(0.0, -12.0 * draw_scale)
			health = 55
			explosive = false
		_:
			body.size = Vector2(24.0 * draw_scale, 32.0 * draw_scale)
			shape.position = Vector2(0.0, -16.0 * draw_scale)
	shape.shape = body
	add_child(shape)
	queue_redraw()


func take_damage(amount: int, _source: Node = null) -> void:
	health -= amount
	if health <= 0:
		_destroy()


func _destroy() -> void:
	var root := get_tree().current_scene
	if explosive:
		CombatVFX.explosion(global_position, 72.0)
		if root:
			CombatActions.apply_explosion(root, global_position, 72.0, 28, null, Faction.Id.NEUTRAL, 320.0)
	else:
		CombatVFX.bullet_impact(global_position, Vector2.UP)
		CombatVFX.debris(global_position, 4)
	queue_free()


func _draw() -> void:
	var palette := {
		"platform": Color(0.5, 0.45, 0.4),
		"ground": Color(0.4, 0.35, 0.3),
	}
	BiomePropDraw.draw_prop(self, prop_type, Vector2.ZERO, 0.0, draw_scale, _time, palette)
