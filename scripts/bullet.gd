extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var owner_node: Node2D = null
var faction: Faction.Id = Faction.Id.NEUTRAL
var is_rocket := false
var is_harpoon := false
var tracer_color := Color(1.0, 0.9, 0.35)
var _stuck := false
var _trail: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if is_rocket:
		collision_mask = collision_mask | 1


func _physics_process(delta: float) -> void:
	if _stuck:
		return
	var prev := global_position
	var env := MapEnvironment.find_in_tree(get_tree())
	if env:
		velocity += env.get_wind_for_bullet(global_position.x) * delta
	position += velocity * delta
	_record_trail(prev)
	if is_rocket:
		velocity.y += 120.0 * delta
		if _hits_world_surface():
			_explode()
			return
	if absf(position.x) > 3000.0 or position.y > 1200.0 or position.y < -400.0:
		if is_rocket:
			_explode()
		else:
			_impact_at(global_position, -velocity.normalized())
			queue_free()
	queue_redraw()

func _record_trail(prev: Vector2) -> void:
	if is_rocket:
		return
	_trail.append(to_local(prev))
	if _trail.size() > 8:
		_trail.remove_at(0)

func _draw() -> void:
	if is_rocket:
		draw_rect(Rect2(-8, -4, 18, 8), Color(0.9, 0.25, 0.2))
		draw_circle(Vector2(10, 0), 3.0, Color(1.0, 0.55, 0.15, 0.8))
	else:
		for i in _trail.size():
			var alpha := float(i + 1) / float(_trail.size()) * 0.45
			draw_line(_trail[i], Vector2.ZERO if i == _trail.size() - 1 else _trail[i + 1], Color(tracer_color, alpha))
		draw_circle(Vector2.ZERO, 4.5, tracer_color)
		draw_circle(Vector2.ZERO, 2.0, Color(1.0, 0.95, 0.85))
		draw_line(Vector2(-6, 0), Vector2(6, 0), Color(tracer_color, 0.85), 2.0)

func _impact_at(pos: Vector2, normal: Vector2) -> void:
	if is_instance_valid(CombatVFX):
		CombatVFX.bullet_impact(pos, normal)


func _hits_world_surface() -> bool:
	var arena := get_tree().get_first_node_in_group("arena")
	if arena and global_position.y >= arena.ground_surface_y() - 8.0:
		return true
	if global_position.x < 70.0 or global_position.x > 1210.0:
		return true
	return false

func _on_body_entered(body: Node) -> void:
	var target := _resolve_damage_target(body)
	if target == null or target == owner_node:
		if is_rocket:
			_explode()
		else:
			_impact_at(global_position, -velocity.normalized())
			queue_free()
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
	_impact_at(global_position, -velocity.normalized())
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
		if current.is_in_group("destructible") and current.has_method("take_damage"):
			return current
		if current.has_method("take_damage") and current is Node2D:
			if CombatActions.can_hit(faction, current, owner_node):
				return current
		current = current.get_parent()
	return null
