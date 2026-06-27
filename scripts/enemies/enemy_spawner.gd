extends Node

## Spawns mission enemies using DifficultyScaling. Parent: PlayModeController or Main.

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

var _spawned_initial := false
var _world: Node
var _arena: Arena
var _spawn_index := 0

func setup(arena: Arena, world: Node) -> void:
	_arena = arena
	_world = world
	MissionManager.phase_started.connect(_on_phase_started)

func spawn_mission_enemies(arena: Arena, world: Node) -> void:
	if _spawned_initial:
		return
	setup(arena, world)
	_spawned_initial = true
	var waves := MissionManager.get_enemy_waves()
	if waves.is_empty():
		_spawn_default_wave()
	else:
		_spawn_waves(waves)

func _on_phase_started(phase: int) -> void:
	if phase == 0:
		return
	_spawn_waves(MissionManager.get_phase_waves(phase))

func _spawn_waves(waves: Array) -> void:
	if waves.is_empty() or _arena == null or _world == null:
		return
	for wave in waves:
		var type: EnemyDefs.Type = wave.get("type", EnemyDefs.Type.PISTOL_GUY)
		var count: int = DifficultyScaling.enemy_count(int(wave.get("count", 1)))
		for i in count:
			_spawn_enemy(type, _next_spawn_position())
			_spawn_index += 1

func _spawn_default_wave() -> void:
	var count := DifficultyScaling.enemy_count(3)
	for i in count:
		var type := EnemyDefs.Type.PISTOL_GUY if i % 2 == 0 else EnemyDefs.Type.SHOTGUN_GUY
		_spawn_enemy(type, _next_spawn_position())
		_spawn_index += 1

func _next_spawn_position() -> Vector2:
	var positions := MapDefs.enemy_spawn_positions(
		_arena.map_id,
		_arena.ground_surface_y(),
		maxi(_spawn_index + 1, 5)
	)
	return positions[_spawn_index % positions.size()]

func _spawn_enemy(type: EnemyDefs.Type, pos: Vector2, boss: bool = false) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.enemy_type = type
	enemy.is_boss = boss
	enemy.global_position = pos
	_world.add_child(enemy)


func spawn_boss(type: EnemyDefs.Type, pos: Vector2) -> void:
	if _world == null or _arena == null:
		return
	_spawn_enemy(type, pos, true)
