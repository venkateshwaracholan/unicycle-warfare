extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var owner_player: Node2D = null
var is_rocket := false
var is_harpoon := false
var _stuck := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if _stuck:
		return
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
	if target == null or target == owner_player:
		if is_rocket:
			_explode()
		return
	if is_rocket:
		_explode()
		return
	if is_harpoon and target.has_method("apply_harpoon_pull"):
		target.apply_harpoon_pull(owner_player, global_position)
		if owner_player and owner_player.has_method("apply_harpoon_pull"):
			owner_player.apply_harpoon_recoil_pull(global_position)
		queue_free()
		return
	if target.has_method("take_damage"):
		target.take_damage(damage, owner_player)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	_on_body_entered(area)

func _explode() -> void:
	var radius := 85.0
	for node in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(node) or node == owner_player or node is not Node2D:
			continue
		var player: Node2D = node
		var dist: float = player.global_position.distance_to(global_position)
		if dist < radius:
			var falloff: float = 1.0 - dist / radius
			player.take_damage(int(damage * falloff), owner_player)
			if player.has_method("apply_explosion_knockback"):
				player.apply_explosion_knockback((player.global_position - global_position).normalized() * 500.0 * falloff)
	queue_free()

func _resolve_damage_target(node: Node) -> Node:
	var current := node
	while current:
		if current.has_method("take_damage") and current.is_in_group("players"):
			return current
		current = current.get_parent()
	return null
