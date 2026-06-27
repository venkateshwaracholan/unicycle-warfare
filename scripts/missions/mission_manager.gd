extends Node

## Runtime mission state — objectives, progress, win/lose. Autoload singleton.

signal objective_changed(text: String, phase: int, total: int)
signal phase_started(phase: int)
signal mission_started(mission_id: String, mission_name: String)
signal mission_completed(mission_id: String)
signal mission_failed(mission_id: String)

var active := false
var mission_id := ""
var mission_name := ""
var _objectives: Array = []
var _phase := 0
var _phase_progress := 0
var _defend_timer := 0.0

func reset() -> void:
	active = false
	mission_id = ""
	mission_name = ""
	_objectives.clear()
	_phase = 0
	_phase_progress = 0
	_defend_timer = 0.0

func start_mission(id: String) -> void:
	reset()
	var def := MissionDefs.get_mission(id)
	mission_id = id
	mission_name = def.get("name", "Mission")
	_objectives = _build_objectives(def)
	_phase = 0
	_phase_progress = 0
	active = true
	mission_started.emit(mission_id, mission_name)
	phase_started.emit(_phase)
	_emit_objective()

func _build_objectives(def: Dictionary) -> Array:
	var objectives: Array = def.get("objectives", []).duplicate(true)
	if not def.get("has_boss", false):
		return objectives
	for obj in objectives:
		if int(obj.get("type", -1)) == MissionDefs.ObjectiveType.BOSS:
			return objectives
	var insert_at := objectives.size()
	for i in objectives.size():
		if int(objectives[i].get("type", -1)) == MissionDefs.ObjectiveType.EXTRACT:
			insert_at = i
			break
	objectives.insert(insert_at, {
		"type": MissionDefs.ObjectiveType.BOSS,
		"label": "Defeat the boss",
		"marker": MapDefs.MARKER_BOSS,
		"boss_type": EnemyDefs.Type.TANK,
	})
	return objectives

func get_map_id() -> MapDefs.MapId:
	if not active:
		return MapDefs.MapId.DESERT
	return MissionDefs.get_mission(mission_id).get("map", MapDefs.MapId.DESERT)

func get_enemy_waves() -> Array:
	if not active:
		return []
	return MissionDefs.get_mission(mission_id).get("enemy_waves", [])

func get_phase_waves(phase: int) -> Array:
	if not active:
		return []
	var phase_waves: Dictionary = MissionDefs.get_mission(mission_id).get("phase_waves", {})
	return phase_waves.get(phase, [])

func objective_marker_id(objective: Dictionary = {}) -> String:
	var obj := objective if not objective.is_empty() else current_objective()
	if obj.is_empty():
		return MapDefs.MARKER_DESTROY
	if obj.has("marker"):
		return str(obj.marker)
	match int(obj.get("type", MissionDefs.ObjectiveType.CLEAR_ENEMIES)):
		MissionDefs.ObjectiveType.PICKUP_ITEM:
			return MapDefs.MARKER_PICKUP
		MissionDefs.ObjectiveType.DESTROY_TARGET:
			return MapDefs.MARKER_DESTROY
		MissionDefs.ObjectiveType.EXTRACT:
			return MapDefs.MARKER_EXTRACT
		MissionDefs.ObjectiveType.DEFEND:
			return MapDefs.MARKER_DEFEND
		MissionDefs.ObjectiveType.ESCORT:
			return MapDefs.MARKER_ESCORT_END
		MissionDefs.ObjectiveType.BOSS:
			return MapDefs.MARKER_BOSS
	return MapDefs.MARKER_DESTROY

func current_objective() -> Dictionary:
	if _phase >= _objectives.size():
		return {}
	return _objectives[_phase]

func register_enemy_kill() -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.CLEAR_ENEMIES:
		return
	_phase_progress += 1
	if _phase_progress >= int(obj.get("count", 1)):
		_advance_phase()
	else:
		_emit_objective()

func register_boss_kill() -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.BOSS:
		return
	_advance_phase()

func register_weapon_pickup(weapon: WeaponDefs.Type) -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.PICKUP_ITEM:
		return
	if weapon != obj.get("weapon", WeaponDefs.Type.GRENADE):
		return
	_advance_phase()

func register_target_destroyed() -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.DESTROY_TARGET:
		return
	_advance_phase()

func register_extracted() -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.EXTRACT:
		return
	_advance_phase()

func _process(delta: float) -> void:
	if not active:
		return
	var obj := current_objective()
	if obj.is_empty():
		return
	if obj.get("type") != MissionDefs.ObjectiveType.DEFEND:
		return
	_defend_timer += delta
	_emit_objective()
	if _defend_timer >= float(obj.get("duration", 60.0)):
		_advance_phase()

func _advance_phase() -> void:
	_phase += 1
	_phase_progress = 0
	_defend_timer = 0.0
	if _phase >= _objectives.size():
		_complete_mission()
	else:
		phase_started.emit(_phase)
		_emit_objective()

func _complete_mission() -> void:
	active = false
	mission_completed.emit(mission_id)

func fail_mission() -> void:
	if not active:
		return
	active = false
	mission_failed.emit(mission_id)

func _emit_objective() -> void:
	var total := _objectives.size()
	if _phase >= total:
		objective_changed.emit("Mission complete!", total, total)
		return
	var obj := current_objective()
	var label: String = obj.get("label", "Objective")
	match obj.get("type"):
		MissionDefs.ObjectiveType.CLEAR_ENEMIES:
			label = "%s (%d/%d)" % [label, _phase_progress, int(obj.get("count", 1))]
		MissionDefs.ObjectiveType.DEFEND:
			var left := maxf(0.0, float(obj.get("duration", 60.0)) - _defend_timer)
			label = "%s (%.0fs)" % [label, left]
		MissionDefs.ObjectiveType.BOSS:
			label = "%s — watch your balance!" % label
	objective_changed.emit(label, _phase + 1, total)
