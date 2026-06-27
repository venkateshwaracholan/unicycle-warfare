extends Area2D

@export var weapon_type: WeaponDefs.Type = WeaponDefs.Type.PISTOL

var velocity := Vector2.ZERO
var ground_y := 490.0
var _bob_time := 0.0
var _settled := false
var _dropped_by := 0
var _spawn_time := 0.0

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	_bob_time = randf() * TAU
	_spawn_time = Time.get_ticks_msec() / 1000.0
	var arena := get_tree().get_first_node_in_group("arena")
	if arena:
		ground_y = arena.ground_surface_y() + 2.0

func _physics_process(delta: float) -> void:
	if not _settled:
		velocity.y += 980.0 * delta
		velocity.x *= pow(0.92, delta * 60.0)
		position += velocity * delta
		if position.y >= ground_y:
			position.y = ground_y
			velocity.y = -velocity.y * 0.35
			velocity.x *= 0.7
			if absf(velocity.y) < 40.0 and absf(velocity.x) < 30.0:
				_settled = true
				velocity = Vector2.ZERO
	else:
		_bob_time += delta * 3.5
		position.y = ground_y + sin(_bob_time) * 2.0
	queue_redraw()

func launch(launch_velocity: Vector2) -> void:
	velocity = launch_velocity
	_settled = false

func get_weapon_type() -> WeaponDefs.Type:
	return weapon_type


func set_dropped_by(player_id: int) -> void:
	_dropped_by = player_id


func get_dropped_by() -> int:
	return _dropped_by


func get_drop_age() -> float:
	return Time.get_ticks_msec() / 1000.0 - _spawn_time

func _draw() -> void:
	WeaponVisual.draw_ground(self, weapon_type)
