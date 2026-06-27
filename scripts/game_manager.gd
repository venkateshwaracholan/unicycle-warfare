extends Node

enum Mode { DEATHMATCH, KING_OF_HILL, GUN_GAME }

const WIN_SCORE := 10
const KOTH_TICK := 0.5

var current_mode: Mode = Mode.DEATHMATCH
var scores: Dictionary = {1: 0, 2: 0}
var gun_game_tier: Dictionary = {1: 0, 2: 0}
var koth_timer := 0.0
var match_over := false
var winner_id := 0

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
