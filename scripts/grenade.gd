extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var fuse := 1.6
var owner_node: Node2D = null
var faction: Faction.Id = Faction.Id.NEUTRAL

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

func _living_owner() -> Node2D:
	return owner_node if is_instance_valid(owner_node) else null


func _explode() -> void:
	var world := get_tree().current_scene
	if world:
		CombatActions.apply_explosion(world, global_position, 90.0, damage, _living_owner(), faction, 600.0)
	queue_free()

func _on_body_entered(body: Node) -> void:
	if fuse > 0.3:
		return
	_explode()
