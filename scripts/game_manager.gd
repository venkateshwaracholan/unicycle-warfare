extends Node

enum Mode { DEATHMATCH, KING_OF_HILL, GUN_GAME }
enum SessionType { NONE, PLAY, ARENA }

const WIN_SCORE := 10
const KOTH_TICK := 0.5
const MENU_SCENE := "res://scenes/menu.tscn"
const MAIN_SCENE := "res://scenes/main.tscn"
const ARENA_SCENE := "res://scenes/test_arena.tscn"

var current_mode: Mode = Mode.DEATHMATCH
var session_type: SessionType = SessionType.NONE
var session_mode: Mode = Mode.DEATHMATCH
var session_map: MapDefs.MapId = MapDefs.MapId.DESERT
var mission_id: String = "desert_radio_towers"
var difficulty: DifficultyDefs.Tier = DifficultyDefs.Tier.NORMAL
var player_count: int = 1
var scores: Dictionary = {1: 0, 2: 0}
var gun_game_tier: Dictionary = {1: 0, 2: 0}
var koth_timer := 0.0
var match_over := false
var winner_id := 0
var pending_rewards: Dictionary = {}
var show_rewards_on_menu := false

signal score_changed(p1: int, p2: int)
signal mode_changed(mode: Mode)
signal match_won(winner_id: int, mode: Mode)
signal player_eliminated(victim_id: int, killer_id: int)

func _ready() -> void:
	_reset_scores()

func _process(delta: float) -> void:
	if match_over or current_mode != Mode.KING_OF_HILL:
		return
	koth_timer -= delta
	if koth_timer > 0.0:
		return
	koth_timer = KOTH_TICK
	var hill := get_tree().get_first_node_in_group("hill_zone")
	if hill == null:
		return
	var occupant: int = hill.call("get_occupant")
	if occupant > 0:
		scores[occupant] += 1
		score_changed.emit(scores[1], scores[2])
		_check_win()

func is_arena_mode() -> bool:
	return session_type == SessionType.ARENA

func is_play_mode() -> bool:
	return session_type == SessionType.PLAY

func start_play(mission: String = "", tier: DifficultyDefs.Tier = DifficultyDefs.Tier.NORMAL) -> void:
	session_type = SessionType.PLAY
	mission_id = mission if mission != "" else MissionDefs.get_default_mission_id()
	difficulty = tier
	var def := MissionDefs.get_mission(mission_id)
	session_map = def.get("map", MapDefs.MapId.DESERT)
	session_mode = Mode.DEATHMATCH
	player_count = 1
	match_over = false
	winner_id = 0
	current_mode = Mode.DEATHMATCH
	_reset_scores()

func start_arena(map_id: MapDefs.MapId = MapDefs.MapId.DESERT) -> void:
	session_type = SessionType.ARENA
	session_mode = Mode.DEATHMATCH
	session_map = map_id
	match_over = false
	winner_id = 0
	set_mode(Mode.DEATHMATCH)

func finish_mission_success() -> void:
	var reward := MissionRewards.calculate(mission_id, difficulty)
	pending_rewards = reward
	show_rewards_on_menu = true
	PlayerProgress.record_mission_complete(mission_id, int(reward.get("coins", 0)))

func finish_mission_failed() -> void:
	pending_rewards = {}
	show_rewards_on_menu = false

func consume_pending_rewards() -> Dictionary:
	var reward := pending_rewards.duplicate()
	pending_rewards = {}
	show_rewards_on_menu = false
	return reward

func return_to_garage() -> void:
	session_type = SessionType.NONE
	MissionManager.reset()
	get_tree().change_scene_to_file(MENU_SCENE)

func return_to_menu() -> void:
	return_to_garage()

func set_mode(mode: Mode) -> void:
	current_mode = mode
	match_over = false
	winner_id = 0
	_reset_scores()
	mode_changed.emit(mode)

func _reset_scores() -> void:
	scores = {1: 0, 2: 0}
	gun_game_tier = {1: 0, 2: 0}
	score_changed.emit(0, 0)

func register_elimination(victim_id: int, killer_id: int) -> void:
	if match_over:
		return
	player_eliminated.emit(victim_id, killer_id)
	if is_play_mode():
		return

	match current_mode:
		Mode.DEATHMATCH:
			if killer_id > 0:
				scores[killer_id] += 1
		Mode.GUN_GAME:
			if killer_id > 0:
				gun_game_tier[killer_id] += 1
				var order := WeaponDefs.gun_game_order()
				if gun_game_tier[killer_id] >= order.size():
					_declare_winner(killer_id)
					return
				scores[killer_id] = gun_game_tier[killer_id]
				scores[victim_id] = gun_game_tier.get(victim_id, 0)

	score_changed.emit(scores[1], scores[2])
	if current_mode == Mode.DEATHMATCH:
		_check_win()

func _check_win() -> void:
	for id in scores:
		if scores[id] >= WIN_SCORE:
			_declare_winner(id)
			break

func _declare_winner(id: int) -> void:
	match_over = true
	winner_id = id
	match_won.emit(id, current_mode)

func get_gun_game_weapon(player_id: int) -> WeaponDefs.Type:
	var order := WeaponDefs.gun_game_order()
	var tier: int = clampi(gun_game_tier.get(player_id, 0), 0, order.size() - 1)
	return order[tier]

func mode_name() -> String:
	match current_mode:
		Mode.DEATHMATCH: return "Deathmatch"
		Mode.KING_OF_HILL: return "King of the Hill"
		Mode.GUN_GAME: return "Gun Game"
	return "?"

func cycle_mode() -> void:
	set_mode(((current_mode as int) + 1) % 3 as Mode)
