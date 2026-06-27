extends Area2D

@export var weapon_type: WeaponDefs.Type = WeaponDefs.Type.PISTOL

var velocity := Vector2.ZERO
var ground_y := 490.0
var _bob_time := 0.0
var _settled := false

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	_bob_time = randf() * TAU
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

func _draw() -> void:
	var data := WeaponDefs.get_data(weapon_type)
	var gun_color: Color = data["color"]
	var cat: WeaponDefs.Category = data["category"]

	match cat:
		WeaponDefs.Category.MELEE:
			if weapon_type == WeaponDefs.Type.KATANA:
				draw_line(Vector2(-20, 4), Vector2(22, -8), Color(0.85, 0.88, 0.95), 4.0)
				draw_line(Vector2(-20, 4), Vector2(-24, 8), Color(0.35, 0.2, 0.1), 3.0)
			else:
				draw_rect(Rect2(-8, -16, 16, 28), gun_color)
				draw_rect(Rect2(-14, 8, 28, 8), gun_color.darkened(0.15))
		WeaponDefs.Category.THROWABLE:
			draw_circle(Vector2(0, 0), 8, gun_color)
			draw_rect(Rect2(-2, -12, 4, 6), Color(0.3, 0.3, 0.3))
		_:
			draw_rect(Rect2(-14, -6, 28, 10), gun_color)
			draw_rect(Rect2(10, -4, 18, 6), gun_color.darkened(0.2))
			draw_circle(Vector2(-8, 2), 5, Color(0.2, 0.2, 0.25))

	draw_arc(Vector2.ZERO, 24, 0, TAU, 24, Color(1, 1, 0.5, 0.25), 2.0)
