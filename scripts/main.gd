extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const WEAPON_PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")

const WEAPON_DROP_MIN := 2.5
const WEAPON_DROP_MAX := 5.0
const MAX_SKY_WEAPONS := 7

@onready var arena: Arena = $Arena
@onready var hill_zone: Area2D = $HillZone
@onready var ground: StaticBody2D = $Ground
@onready var left_wall: StaticBody2D = $LeftWall
@onready var right_wall: StaticBody2D = $RightWall
@onready var hud: CanvasLayer = $HUD
@onready var p1_health_label: Label = $HUD/P1Health
@onready var p2_health_label: Label = $HUD/P2Health
@onready var score_label: Label = $HUD/Score
@onready var message_label: Label = $HUD/Message
@onready var mode_label: Label = $HUD/ModeLabel
@onready var title_label: Label = $HUD/Title

var _players: Array = []
var _weapon_drop_timer := 1.2

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.match_won.connect(_on_match_won)
	GameManager.mode_changed.connect(_on_mode_changed)
	_apply_session()
	_rebuild_arena()
	_clear_weapons()
	_spawn_players()
	_update_hud()
	title_label.text = _session_title()
	message_label.text = _session_message()
	_setup_menu_button()

func _setup_menu_button() -> void:
	var btn := Button.new()
	btn.name = "MenuButton"
	btn.text = "Menu"
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.offset_left = -88.0
	btn.offset_top = 8.0
	btn.offset_right = -8.0
	btn.offset_bottom = 36.0
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_on_menu_button_pressed)
	hud.add_child(btn)

func _on_menu_button_pressed() -> void:
	GameManager.return_to_menu()

func _apply_session() -> void:
	if GameManager.session_type == GameManager.SessionType.NONE:
		GameManager.start_play()
	arena.map_id = GameManager.session_map
	arena._configure_map()
	GameManager.set_mode(GameManager.session_mode)

func _session_title() -> String:
	return "UNICYCLE WARFARE"

func _session_message() -> String:
	return "Start with minigun · weapons drop from the sky · Menu (top-right) to quit"

func _physics_process(delta: float) -> void:
	_weapon_drop_timer -= delta
	if _weapon_drop_timer <= 0.0:
		_drop_weapon_from_sky()
		_weapon_drop_timer = randf_range(WEAPON_DROP_MIN, WEAPON_DROP_MAX)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.return_to_menu()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_match"):
		get_tree().reload_current_scene()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("cycle_mode"):
		GameManager.cycle_mode()
		_on_mode_changed(GameManager.current_mode)
	if event.is_action_pressed("cycle_map"):
		arena.cycle_map()
		GameManager.session_map = arena.map_id
		_rebuild_arena()
		_respawn_all()

func _rebuild_arena() -> void:
	var gy := arena.ground_y
	ground.position = Vector2(640, gy)
	left_wall.position = Vector2(60, gy - 30)
	right_wall.position = Vector2(1220, gy - 30)
	hill_zone.position = Vector2(640, gy - 60)
	hill_zone.visible = GameManager.current_mode == GameManager.Mode.KING_OF_HILL
	mode_label.text = "%s — %s" % [GameManager.mode_name(), arena.get_map_name()]

func _clear_weapons() -> void:
	for child in get_children():
		if child.is_in_group("weapon_loot"):
			child.queue_free()

func _sky_weapon_count() -> int:
	var count := 0
	for child in get_children():
		if child.is_in_group("weapon_loot"):
			count += 1
	return count

func _drop_weapon_from_sky() -> void:
	if _sky_weapon_count() >= MAX_SKY_WEAPONS:
		return

	var pickup := WEAPON_PICKUP_SCENE.instantiate()
	pickup.add_to_group("weapon_loot")
	pickup.weapon_type = WeaponDefs.random_sky_loot_type()
	var x := randf_range(160.0, 1120.0)
	var y := randf_range(-160.0, -30.0)
	pickup.global_position = Vector2(x, y)
	pickup.launch(Vector2(randf_range(-100.0, 100.0), randf_range(40.0, 120.0)))
	add_child(pickup)

func _spawn_players() -> void:
	for p in _players:
		if is_instance_valid(p):
			p.queue_free()
	_players.clear()

	var spawns := arena.spawn_points
	var colors := [Color(0.95, 0.32, 0.32), Color(0.32, 0.58, 0.95)]
	for i in 2:
		var p := PLAYER_SCENE.instantiate()
		p.player_id = i + 1
		p.team_color = colors[i]
		p.spawn_position = spawns[i]
		p.health_changed.connect(_on_health_changed.bind(i + 1))
		p.eliminated.connect(_on_player_eliminated)
		add_child(p)
		_players.append(p)

func _respawn_all() -> void:
	_clear_weapons()
	_weapon_drop_timer = 1.2
	for i in _players.size():
		var p = _players[i]
		if is_instance_valid(p):
			p.spawn_position = arena.spawn_points[i]
			p.respawn_at_spawn()

func _on_player_eliminated(_victim: Node2D, killer: Node2D) -> void:
	message_label.text = "Elimination! Vulnerable players go down — fight continues."
	if killer and is_instance_valid(killer) and GameManager.current_mode == GameManager.Mode.GUN_GAME:
		killer.weapon_type = GameManager.get_gun_game_weapon(killer.get_player_id())

func _on_health_changed(current: int, maximum: int, player_id: int) -> void:
	var text := "P%d HP: %d/%d" % [player_id, current, maximum]
	if player_id == 1:
		p1_health_label.text = text
	else:
		p2_health_label.text = text

func _on_score_changed(p1: int, p2: int) -> void:
	score_label.text = "Score  P1: %d   P2: %d   (first to %d)" % [p1, p2, GameManager.WIN_SCORE]

func _on_mode_changed(_mode: GameManager.Mode) -> void:
	_rebuild_arena()
	for p in _players:
		if is_instance_valid(p):
			if GameManager.current_mode == GameManager.Mode.GUN_GAME:
				p.weapon_type = GameManager.get_gun_game_weapon(p.player_id)
			else:
				p.weapon_type = WeaponDefs.Type.MINIGUN
	_update_hud()

func _on_match_won(winner_id: int, _mode: GameManager.Mode) -> void:
message_label.text = "PLAYER %d WINS!  Menu (top-right)  F5=restart" % winner_id

func _update_hud() -> void:
	title_label.text = _session_title()
	score_label.text = "Score  P1: %d   P2: %d   (first to %d)" % [
		GameManager.scores[1], GameManager.scores[2], GameManager.WIN_SCORE
	]
	mode_label.text = "%s — %s" % [GameManager.mode_name(), arena.get_map_name()]
