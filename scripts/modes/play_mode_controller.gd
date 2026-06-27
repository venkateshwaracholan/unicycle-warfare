extends Node

## Play-mode orchestration: missions, enemies, fall hooks, objective HUD updates.

const ENEMY_SPAWNER_SCRIPT := preload("res://scripts/enemies/enemy_spawner.gd")

const INTERACT_RADIUS := 70.0
const EXTRACT_RADIUS := 90.0

var _main: Node2D
var _arena: Arena
var _enemy_spawner: Node
var _objective_label: Label
var _marker_overlay: Node2D
var _last_weapon: Dictionary = {}
var _mission_pickup_spawned := false
var _boss_spawned := false
var _mission_ending := false
var _active_marker_pos := Vector2.ZERO
var _active_marker_kind := ""

func setup(main: Node2D, hud: CanvasLayer) -> void:
	_main = main
	_arena = _main.get_node("Arena") as Arena
	_objective_label = hud.get_node_or_null("MissionLabel") as Label
	if _objective_label == null:
		_objective_label = Label.new()
		_objective_label.name = "MissionLabel"
		_objective_label.offset_left = 16.0
		_objective_label.offset_top = 132.0
		_objective_label.offset_right = 620.0
		_objective_label.offset_bottom = 158.0
		_objective_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
		_objective_label.add_theme_font_size_override("font_size", 15)
		hud.add_child(_objective_label)

	_marker_overlay = Node2D.new()
	_marker_overlay.name = "MissionMarkers"
	_marker_overlay.z_index = 5
	_marker_overlay.set_script(preload("res://scripts/maps/mission_marker_overlay.gd"))
	_main.add_child(_marker_overlay)

	MissionManager.objective_changed.connect(_on_objective_changed)
	MissionManager.phase_started.connect(_on_phase_started)
	MissionManager.mission_completed.connect(_on_mission_completed)
	MissionManager.mission_failed.connect(_on_mission_failed)
	MissionManager.start_mission(GameManager.mission_id)

	_enemy_spawner = ENEMY_SPAWNER_SCRIPT.new()
	_enemy_spawner.name = "EnemySpawner"
	add_child(_enemy_spawner)
	_enemy_spawner.spawn_mission_enemies(_arena, _main)

	_connect_players()
	_refresh_marker()
	_show_drop_in()

func _show_drop_in() -> void:
	var map_name := MapDefs.map_name(MissionManager.get_map_id())
	var diff_name := DifficultyDefs.tier_name(GameManager.difficulty)
	if is_instance_valid(_main) and _main.has_method("set_mission_message"):
		_main.set_mission_message(
			"DROPPING INTO %s — %s · Ride · Shoot · Balance" % [map_name.to_upper(), diff_name]
		)
	var timer := get_tree().create_timer(2.5)
	timer.timeout.connect(_clear_drop_in_message)

func _clear_drop_in_message() -> void:
	if not is_instance_valid(_main) or not _main.has_method("set_mission_message"):
		return
	var obj := MissionManager.current_objective()
	if obj.is_empty():
		_main.set_mission_message("Complete the objective. Extract to earn rewards.")
	else:
		_main.set_mission_message(obj.get("label", "Complete the objective."))

func _resolve_marker(marker_id: String) -> Vector2:
	return MapDefs.resolve_marker(
		MissionManager.get_map_id(),
		marker_id,
		_arena.ground_surface_y()
	)

func _refresh_marker() -> void:
	var obj := MissionManager.current_objective()
	if obj.is_empty():
		_active_marker_pos = Vector2.ZERO
		_active_marker_kind = ""
	else:
		var marker_id := MissionManager.objective_marker_id(obj)
		_active_marker_pos = _resolve_marker(marker_id)
		_active_marker_kind = marker_id
	if _marker_overlay and _marker_overlay.has_method("set_marker"):
		_marker_overlay.call("set_marker", _active_marker_pos, _active_marker_kind, obj)

func _connect_players() -> void:
	for child in _main.get_children():
		if not child.is_in_group("players"):
			continue
		if child.has_signal("fell_over"):
			if not child.fell_over.is_connected(_on_player_fell):
				child.fell_over.connect(_on_player_fell.bind(child))

func _process(_delta: float) -> void:
	if not is_instance_valid(_main):
		return
	_track_weapon_pickups()
	_handle_mission_interactions()

func _track_weapon_pickups() -> void:
	for child in _main.get_children():
		if not child.is_in_group("players"):
			continue
		var player_id: int = child.get_player_id()
		var weapon: WeaponDefs.Type = child.weapon_type
		var key := str(player_id)
		if _last_weapon.get(key, weapon) != weapon:
			_last_weapon[key] = weapon
			MissionManager.register_weapon_pickup(weapon)

func _handle_mission_interactions() -> void:
	var obj := MissionManager.current_objective()
	if obj.is_empty():
		return
	var player := _first_player()
	if player == null:
		return

	match obj.get("type"):
		MissionDefs.ObjectiveType.DESTROY_TARGET:
			if _active_marker_pos != Vector2.ZERO \
					and player.global_position.distance_to(_active_marker_pos) < INTERACT_RADIUS \
					and Input.is_action_just_pressed("shoot"):
				MissionManager.register_target_destroyed()
		MissionDefs.ObjectiveType.EXTRACT:
			var extract_pos := _active_marker_pos
			if extract_pos == Vector2.ZERO:
				extract_pos = player.spawn_position
			if player.global_position.distance_to(extract_pos) < EXTRACT_RADIUS:
				MissionManager.register_extracted()

func _first_player() -> Node2D:
	for child in _main.get_children():
		if child.is_in_group("players") and child is Node2D:
			return child
	return null

func _on_player_fell(player: Node2D) -> void:
	if not is_instance_valid(player):
		return
	FallConsequences.drop_weapon_from_player(player, _main)

func _on_phase_started(_phase: int) -> void:
	_boss_spawned = false
	_mission_pickup_spawned = false

func _on_objective_changed(text: String, phase: int, total: int) -> void:
	if _objective_label:
		_objective_label.text = "Objective %d/%d: %s" % [phase, total, text]
	if is_instance_valid(_main) and _main.has_method("set_mission_message"):
		_main.set_mission_message(text)
	_refresh_marker()
	_spawn_objective_pickup()
	_try_spawn_boss()

func _spawn_objective_pickup() -> void:
	if _mission_pickup_spawned:
		return
	var obj := MissionManager.current_objective()
	if obj.is_empty() or obj.get("type") != MissionDefs.ObjectiveType.PICKUP_ITEM:
		return
	_mission_pickup_spawned = true
	var weapon: WeaponDefs.Type = obj.get("weapon", WeaponDefs.Type.GRENADE)
	var pos := _active_marker_pos
	if pos == Vector2.ZERO:
		pos = _resolve_marker(MapDefs.MARKER_PICKUP)
	FallConsequences.spawn_weapon_pickup(_main, pos, weapon, Vector2.ZERO)

func _try_spawn_boss() -> void:
	if _boss_spawned:
		return
	var obj := MissionManager.current_objective()
	if obj.is_empty() or obj.get("type") != MissionDefs.ObjectiveType.BOSS:
		return
	_boss_spawned = true
	var boss_type: EnemyDefs.Type = obj.get("boss_type", EnemyDefs.Type.TANK)
	var pos := _active_marker_pos
	if pos == Vector2.ZERO:
		pos = _resolve_marker(MapDefs.MARKER_BOSS)
	if is_instance_valid(_enemy_spawner):
		_enemy_spawner.spawn_boss(boss_type, pos)
	if is_instance_valid(_main) and _main.has_method("set_mission_message"):
		_main.set_mission_message("BOSS INCOMING — %s" % obj.get("label", "Defeat the boss"))

func _on_mission_completed(_mission_id: String) -> void:
	if _mission_ending:
		return
	_mission_ending = true
	if _marker_overlay and _marker_overlay.has_method("clear_marker"):
		_marker_overlay.call("clear_marker")
	GameManager.finish_mission_success()
	if is_instance_valid(_main) and _main.has_method("set_mission_message"):
		_main.set_mission_message("EXTRACTED! Returning to garage for rewards...")
	await get_tree().create_timer(2.0).timeout
	GameManager.return_to_garage()

func _on_mission_failed(_mission_id: String) -> void:
	if _mission_ending:
		return
	_mission_ending = true
	GameManager.finish_mission_failed()
	if is_instance_valid(_main) and _main.has_method("set_mission_message"):
		_main.set_mission_message("Mission failed. Returning to garage...")
	await get_tree().create_timer(1.5).timeout
	GameManager.return_to_garage()
