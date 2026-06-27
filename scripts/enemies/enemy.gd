extends Node2D

## PvE combatant — AI role decides movement; WeaponUser + CombatActions handle weapons.

@export var enemy_type: EnemyDefs.Type = EnemyDefs.Type.PISTOL_GUY

var _hp := 45.0
var _data: Dictionary
var _weapon_user: WeaponUser
var is_boss := false
var _retreat_timer := 0.0

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
	_weapon_user = WeaponUser.new(self, Faction.Id.ENEMY, EnemyDefs.default_weapon(enemy_type))
	queue_redraw()

func get_faction() -> Faction.Id:
	return Faction.Id.ENEMY

func get_weapon_type() -> WeaponDefs.Type:
	return _weapon_user.get_weapon_type()

func set_weapon_type(weapon: WeaponDefs.Type) -> void:
	_weapon_user.set_weapon_type(weapon)
	queue_redraw()

func get_weapon_muzzle_global() -> Vector2:
	return global_position + Vector2(0, -20)

func on_weapon_pickup(_weapon: WeaponDefs.Type) -> void:
	queue_redraw()

func take_damage(amount: int, from: Node2D = null) -> void:
	_hp -= amount
	if _hp <= 0.0:
		_drop_weapon_loot()
		if is_boss:
			MissionManager.register_boss_kill()
		else:
			MissionManager.register_enemy_kill()
		queue_free()

func _drop_weapon_loot() -> void:
	var weapon := get_weapon_type()
	if weapon == WeaponDefs.Type.PISTOL:
		return
	var world := get_tree().current_scene
	if world:
		FallConsequences.spawn_weapon_pickup(world, global_position, weapon, Vector2(randf_range(-80, 80), -120))

func _physics_process(delta: float) -> void:
	_weapon_user.tick(delta)
	_retreat_timer = maxf(_retreat_timer - delta, 0.0)

	var target := _pick_target()
	if target == null:
		return

	_weapon_user.try_pickup_nearby()

	var to_target := target.global_position - global_position
	var dist := to_target.length()
	var dir := to_target / maxf(dist, 0.001)
	_move_for_role(dir, dist, delta)

	if _should_fire(dist):
		var aim := dir
		if get_weapon_type() == WeaponDefs.Type.ROCKET and dist < float(_data.get("preferred_min", 120.0)):
			aim = Vector2(0, 1)
		_weapon_user.try_attack(aim)

	queue_redraw()

func _pick_target() -> Node2D:
	var role: EnemyDefs.Role = _data.get("role", EnemyDefs.Role.ADVANCE)
	var chase_fallen := role == EnemyDefs.Role.RUSH
	return _nearest_player(chase_fallen)

func _move_for_role(dir: Vector2, dist: float, delta: float) -> void:
	var speed: float = _data.get("speed", 30.0)
	var min_dist: float = _data.get("preferred_min", 120.0)
	var max_dist: float = _data.get("preferred_max", 360.0)
	var role: EnemyDefs.Role = _data.get("role", EnemyDefs.Role.ADVANCE)
	var move_dir := dir

	match role:
		EnemyDefs.Role.RUSH:
			if dist > min_dist * 0.85:
				move_dir = dir
			else:
				move_dir = Vector2(dir.x, 0).normalized() if absf(dir.x) > 0.1 else Vector2.ZERO
		EnemyDefs.Role.KITE, EnemyDefs.Role.ROCKET_KITE:
			if dist < min_dist:
				move_dir = -dir
				_retreat_timer = 0.35
			elif dist > max_dist:
				move_dir = dir
			else:
				move_dir = Vector2(-dir.y, dir.x) * signf(global_position.x - 640.0)
		EnemyDefs.Role.HOLD:
			if dist > max_dist:
				move_dir = dir
			elif dist < min_dist:
				move_dir = -dir
			else:
				move_dir = Vector2.ZERO
		_:
			if dist > max_dist:
				move_dir = dir
			elif dist < min_dist:
				move_dir = -dir
			else:
				move_dir = Vector2.ZERO

	if move_dir.length_squared() > 0.01:
		global_position += move_dir.normalized() * speed * delta

func _should_fire(dist: float) -> bool:
	var max_dist: float = _data.get("preferred_max", 360.0)
	if get_weapon_type() == WeaponDefs.Type.SHOTGUN:
		max_dist = minf(max_dist, 200.0)
	if get_weapon_type() == WeaponDefs.Type.ROCKET:
		return dist >= float(_data.get("preferred_min", 180.0)) * 0.75 and dist <= max_dist + 80.0
	return dist <= max_dist + 40.0

func _nearest_player(include_fallen: bool) -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("players"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		var player: Node2D = node
		if not include_fallen and "state" in player and player.state != player.State.RIDING:
			continue
		var dist := global_position.distance_squared_to(player.global_position)
		if dist < best_dist:
			best_dist = dist
			best = player
	return best

func _draw() -> void:
	var size: Vector2 = _data.get("size", Vector2(18, 28))
	var color: Color = _data.get("color", Color.RED)
	if is_boss:
		draw_circle(Vector2(0, -size.y * 0.5), size.x * 0.75, Color(1.0, 0.25, 0.2, 0.25))
	draw_rect(Rect2(-size.x * 0.5, -size.y, size.x, size.y), color)
	draw_rect(Rect2(-size.x * 0.5, -size.y - 6, size.x, 6), color.darkened(0.2))
	var wdata := WeaponDefs.get_data(get_weapon_type())
	draw_rect(Rect2(-10, -size.y - 10, 20, 6), wdata.get("color", Color.GRAY))
