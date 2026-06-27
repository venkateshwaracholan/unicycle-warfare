extends Node2D

## Simple PvE enemy — moves toward nearest player and shoots. Extend per EnemyDefs.Type.

const BULLET_SCENE := preload("res://scenes/bullet.tscn")

@export var enemy_type: EnemyDefs.Type = EnemyDefs.Type.PISTOL_GUY

var _hp := 45.0
var _fire_cd := 0.0
var _data: Dictionary
var is_boss := false

func _ready() -> void:
	add_to_group("enemies")
	if is_boss:
		add_to_group("bosses")
	_data = EnemyDefs.get_data(enemy_type)
	var base_hp: float = _data.get("hp", 45.0)
	if is_boss or _data.get("is_boss", false):
		is_boss = true
		_hp = DifficultyScaling.boss_hp(base_hp)
	else:
		_hp = DifficultyScaling.enemy_hp(base_hp)
	queue_redraw()


func take_damage(amount: int, from: Node2D = null) -> void:
	_hp -= amount
	if _hp <= 0.0:
		if is_boss:
			MissionManager.register_boss_kill()
		else:
			MissionManager.register_enemy_kill()
		queue_free()


func _physics_process(delta: float) -> void:
	var target := _nearest_player()
	if target == null:
		return

	var to_target := target.global_position - global_position
	var dist := to_target.length()
	if dist > 8.0:
		var dir := to_target / dist
		global_position += dir * _data.get("speed", 30.0) * delta

	_fire_cd = maxf(_fire_cd - delta, 0.0)
	if _fire_cd <= 0.0 and dist <= _data.get("range", 400.0):
		_shoot_at(target)
		_fire_cd = _data.get("fire_rate", 1.0)

	queue_redraw()


func _nearest_player() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		var player: Node2D = node
		if "state" in player and player.state != player.State.RIDING:
			continue
		var dist := global_position.distance_squared_to(player.global_position)
		if dist < best_dist:
			best_dist = dist
			best = player
	return best


func _shoot_at(target: Node2D) -> void:
	var dir := (target.global_position - global_position).normalized()
	var bullet := BULLET_SCENE.instantiate()
	bullet.global_position = global_position + dir * 12.0
	bullet.velocity = dir * 340.0
	bullet.damage = _data.get("damage", 8)
	bullet.owner_player = null
	get_tree().current_scene.add_child(bullet)


func _draw() -> void:
	var size: Vector2 = _data.get("size", Vector2(18, 28))
	var color: Color = _data.get("color", Color.RED)
	if is_boss:
		draw_circle(Vector2(0, -size.y * 0.5), size.x * 0.75, Color(1.0, 0.25, 0.2, 0.25))
	draw_rect(Rect2(-size.x * 0.5, -size.y, size.x, size.y), color)
	draw_rect(Rect2(-size.x * 0.5, -size.y - 6, size.x, 6), color.darkened(0.2))
