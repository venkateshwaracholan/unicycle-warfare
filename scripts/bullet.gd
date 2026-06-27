extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var owner_node: Node2D = null
var faction: Faction.Id = Faction.Id.NEUTRAL
var is_rocket := false
var is_harpoon := false
var _stuck := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if _stuck:
		return
	var env := MapEnvironment.find_in_tree(get_tree())
	if env:
		velocity += env.get_wind_for_bullet(global_position.x) * delta
	position += velocity * delta
	if is_rocket:
		velocity.y += 120.0 * delta
	if absf(position.x) > 3000.0 or position.y > 1200.0 or position.y < -400.0:
		if is_rocket:
			_explode()
		else:
			queue_free()

func _draw() -> void:
	if is_rocket:
		draw_rect(Rect2(-6, -3, 14, 6), Color(0.9, 0.25, 0.2))
	else:
		draw_circle(Vector2.ZERO, 4, Color(1, 0.95, 0.3))

func _on_body_entered(body: Node) -> void:
	var target := _resolve_damage_target(body)
	if target == null or target == owner_node:
		if is_rocket:
			_explode()
		return
	if is_rocket:
		_explode()
		return
	if is_harpoon and target.has_method("apply_harpoon_pull"):
		target.apply_harpoon_pull(owner_node, global_position)
		if owner_node and owner_node.has_method("apply_harpoon_recoil_pull"):
			owner_node.apply_harpoon_recoil_pull(global_position)
		queue_free()
		return
	if target.has_method("take_damage"):
		target.take_damage(damage, owner_node)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	_on_body_entered(area)

func _explode() -> void:
	var world := get_tree().current_scene
	if world:
		CombatActions.apply_explosion(world, global_position, 85.0, damage, owner_node, faction, 500.0)
	queue_free()

func _resolve_damage_target(node: Node) -> Node:
	var current := node
	while current:
		if current.has_method("take_damage") and current is Node2D:
			if CombatActions.can_hit(faction, current, owner_node):
				return current
		current = current.get_parent()
	return null
