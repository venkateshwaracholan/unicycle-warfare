extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var fuse := 1.6
var owner_player: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	velocity.y += 980.0 * delta
	position += velocity * delta
	velocity.x *= pow(0.99, delta * 60.0)
	fuse -= delta
	if fuse <= 0.0:
		_explode()
	if position.y > 900.0:
		queue_free()

func _explode() -> void:
	var radius := 90.0
	for node in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		var player: Node2D = node
		var dist: float = player.global_position.distance_to(global_position)
		if dist < radius:
			var falloff: float = 1.0 - dist / radius
			player.take_damage(int(damage * falloff), owner_player)
			if player.has_method("apply_explosion_knockback"):
				var dir: Vector2 = (player.global_position - global_position).normalized()
				player.apply_explosion_knockback(dir * 600.0 * falloff)
	queue_free()

func _on_body_entered(body: Node) -> void:
	if fuse > 0.3:
		return
	_explode()
