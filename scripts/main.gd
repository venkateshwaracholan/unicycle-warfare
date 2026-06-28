extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const PLAY_CONTROLLER_SCRIPT := preload("res://scripts/modes/play_mode_controller.gd")

const WeaponLoadoutPanel := preload("res://scripts/ui/weapon_loadout_panel.gd")

@onready var arena: Arena = $Arena
@onready var camera: Camera2D = $Camera2D
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
var _loadout_panel: WeaponLoadoutPanel
var _play_controller: Node
var _fps_badge: PanelContainer
var _fps_label: Label

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.match_won.connect(_on_match_won)
	GameManager.mode_changed.connect(_on_mode_changed)
	_apply_session()
	_rebuild_arena()
	_clear_weapons()
	_spawn_players()
	if GameManager.is_play_mode():
		_setup_play_mode()
	else:
		_setup_arena_mode()
	_update_hud()
	title_label.text = _session_title()
	message_label.text = _session_message()
	_setup_hud_buttons()
	_setup_fps_counter()


func _setup_fps_counter() -> void:
	if _fps_badge != null:
		_fps_badge.queue_free()
	_fps_badge = null
	_fps_label = null

	_fps_badge = PanelContainer.new()
	_fps_badge.name = "FpsBadge"
	_fps_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_fps_badge.offset_left = -108.0
	_fps_badge.offset_top = 40.0
	_fps_badge.offset_right = -8.0
	_fps_badge.offset_bottom = 72.0

	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.05, 0.08, 0.06, 0.92)
	badge_style.border_color = Color(0.3, 0.95, 0.42, 1.0)
	badge_style.set_border_width_all(2)
	badge_style.set_corner_radius_all(10)
	badge_style.set_content_margin_all(8)
	_fps_badge.add_theme_stylebox_override("panel", badge_style)

	_fps_label = Label.new()
	_fps_label.name = "FpsLabel"
	_fps_label.text = "— FPS"
	_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fps_label.add_theme_font_size_override("font_size", 17)
	_fps_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.62, 1.0))
	_fps_badge.add_child(_fps_label)
	hud.add_child(_fps_badge)


func _process(_delta: float) -> void:
	if _fps_label != null:
		_fps_label.text = "%d FPS" % Engine.get_frames_per_second()


func _setup_play_mode() -> void:
	p2_health_label.visible = GameManager.player_count > 1
	hill_zone.visible = false
	score_label.text = MissionManager.mission_name
	_play_controller = PLAY_CONTROLLER_SCRIPT.new()
	_play_controller.name = "PlayModeController"
	add_child(_play_controller)
	_play_controller.setup(self, hud)


func _setup_arena_mode() -> void:
	p2_health_label.visible = true
	_setup_loadout_panel()


func _setup_loadout_panel() -> void:
	if _loadout_panel != null:
		_loadout_panel.queue_free()
	_loadout_panel = WeaponLoadoutPanel.new()
	_loadout_panel.name = "WeaponLoadout"
	hud.add_child(_loadout_panel)
	if _players.size() > 0 and is_instance_valid(_players[0]):
		_loadout_panel.bind_player(_players[0])


func _setup_hud_buttons() -> void:
	var menu_btn := Button.new()
	menu_btn.name = "MenuButton"
	menu_btn.text = "Menu"
	menu_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -88.0
	menu_btn.offset_top = 8.0
	menu_btn.offset_right = -8.0
	menu_btn.offset_bottom = 36.0
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.pressed.connect(_on_menu_button_pressed)
	hud.add_child(menu_btn)

	var retry_btn := Button.new()
	retry_btn.name = "RetryButton"
	retry_btn.text = "Retry"
	retry_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	retry_btn.offset_left = -168.0
	retry_btn.offset_top = 8.0
	retry_btn.offset_right = -92.0
	retry_btn.offset_bottom = 36.0
	retry_btn.add_theme_font_size_override("font_size", 14)
	retry_btn.pressed.connect(_on_retry_pressed)
	hud.add_child(retry_btn)


func _on_menu_button_pressed() -> void:
	GameManager.return_to_garage()


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _apply_session() -> void:
	if GameManager.session_type == GameManager.SessionType.NONE:
		GameManager.start_play()
	arena.map_id = GameManager.session_map
	arena._configure_map()
	if not GameManager.is_play_mode():
		GameManager.set_mode(GameManager.session_mode)


func _session_title() -> String:
	if GameManager.is_play_mode():
		return "MISSION — %s" % MissionManager.mission_name
	return "UNICYCLE WARFARE"


func _session_message() -> String:
	var zoom_hint := " · scroll/+/- zoom · 1/2 face · 0 reset"
	var fall_hint := " · " + FallConsequences.rules_hint()
	if GameManager.is_play_mode():
		return "A/D steer · R shoot" + fall_hint + " · Ride east through the mission · Retry/Menu (top-right)" + zoom_hint
	return "A/D steer · R shoot · J/L P2 · P shoot · U=loadout" + fall_hint + " · Tab=mode · M=map · Retry/Menu (top-right)" + zoom_hint


func set_mission_message(text: String) -> void:
	message_label.text = text


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.return_to_garage()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_match"):
		_on_retry_pressed()
		get_viewport().set_input_as_handled()
		return
	if not GameManager.is_play_mode() and event.is_action_pressed("weapon_loadout"):
		if _loadout_panel:
			_loadout_panel.toggle()
		get_viewport().set_input_as_handled()
		return
	if GameManager.is_play_mode():
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
	arena._configure_map()
	if GameManager.is_play_mode():
		ground.visible = false
		ground.set_collision_layer_value(1, false)
		left_wall.visible = false
		left_wall.set_collision_layer_value(1, false)
		right_wall.visible = false
		right_wall.set_collision_layer_value(1, false)
		if camera.has_method("configure_mission"):
			camera.configure_mission(arena.world_left(), arena.world_right())
	else:
		ground.visible = true
		ground.set_collision_layer_value(1, true)
		left_wall.visible = true
		left_wall.set_collision_layer_value(1, true)
		right_wall.visible = true
		right_wall.set_collision_layer_value(1, true)
		if camera.has_method("configure_arena"):
			camera.configure_arena()
		var gy := arena.ground_y
		ground.position = Vector2(640, gy)
		left_wall.position = Vector2(60, gy - 30)
		right_wall.position = Vector2(1220, gy - 30)
	hill_zone.position = Vector2(640, arena.ground_y - 60)
	var tagline := arena.get_biome_tagline()
	var map_line := arena.get_map_name()
	if not tagline.is_empty():
		map_line = "%s · %s" % [map_line, tagline]
	if GameManager.is_play_mode():
		mode_label.text = "%s — %s" % [MissionManager.mission_name, map_line]
	else:
		hill_zone.visible = GameManager.current_mode == GameManager.Mode.KING_OF_HILL
		mode_label.text = "%s — %s" % [GameManager.mode_name(), map_line]


func spawn_weapon_pickup(global_pos: Vector2, weapon: WeaponDefs.Type, velocity: Vector2, dropped_by: int = 0) -> void:
	FallConsequences.spawn_weapon_pickup(self, global_pos, weapon, velocity, dropped_by)


func _clear_weapons() -> void:
	for child in get_children():
		if child.is_in_group("weapon_loot"):
			child.queue_free()


func _spawn_players() -> void:
	for p in _players:
		if is_instance_valid(p):
			p.queue_free()
	_players.clear()

	var spawns := arena.spawn_points
	var colors := [Color(0.95, 0.32, 0.32), Color(0.32, 0.58, 0.95)]
	var count := GameManager.player_count if GameManager.is_play_mode() else 2
	for i in count:
		var p := PLAYER_SCENE.instantiate()
		p.player_id = i + 1
		p.team_color = colors[i]
		p.spawn_position = spawns[i]
		p.health_changed.connect(_on_health_changed.bind(i + 1))
		p.eliminated.connect(_on_player_eliminated)
		if p.has_signal("fell_over") and not p.fell_over.is_connected(_on_player_fell):
			p.fell_over.connect(_on_player_fell.bind(p))
		add_child(p)
		_players.append(p)


func _on_player_fell(player: Node2D, _is_crash: bool) -> void:
	if is_instance_valid(player) and player.last_fall_message != "":
		message_label.text = player.last_fall_message


func _respawn_all() -> void:
	_clear_weapons()
	for i in _players.size():
		var p = _players[i]
		if is_instance_valid(p):
			p.spawn_position = arena.spawn_points[i]
			p.respawn_at_spawn()


func _on_player_eliminated(_victim: Node2D, killer: Node2D) -> void:
	if GameManager.is_play_mode():
		message_label.text = "Down! Respawning — protect your balance."
		return
	message_label.text = "Elimination! Vulnerable players go down — fight continues."
	if killer and is_instance_valid(killer) and GameManager.current_mode == GameManager.Mode.GUN_GAME:
		killer.weapon_type = GameManager.get_gun_game_weapon(killer.get_player_id())


func _on_health_changed(current: int, maximum: int, player_id: int) -> void:
	var text := "HP: %d/%d" % [current, maximum] if GameManager.is_play_mode() else "P%d HP: %d/%d" % [player_id, current, maximum]
	if player_id == 1:
		p1_health_label.text = text
	else:
		p2_health_label.text = text


func _on_score_changed(p1: int, p2: int) -> void:
	if GameManager.is_play_mode():
		return
	score_label.text = "Score  P1: %d   P2: %d   (first to %d)" % [p1, p2, GameManager.WIN_SCORE]


func _on_mode_changed(_mode: GameManager.Mode) -> void:
	if GameManager.is_play_mode():
		return
	_rebuild_arena()
	for p in _players:
		if is_instance_valid(p):
			if GameManager.current_mode == GameManager.Mode.GUN_GAME:
				p.weapon_type = GameManager.get_gun_game_weapon(p.player_id)
			else:
				p.weapon_type = WeaponDefs.Type.ROCKET
	_update_hud()


func _on_match_won(winner_id: int, _mode: GameManager.Mode) -> void:
	message_label.text = "PLAYER %d WINS!  Retry/Menu (top-right)  F5=retry" % winner_id


func _update_hud() -> void:
	title_label.text = _session_title()
	if GameManager.is_play_mode():
		score_label.text = MissionManager.mission_name
	else:
		score_label.text = "Score  P1: %d   P2: %d   (first to %d)" % [
			GameManager.scores[1], GameManager.scores[2], GameManager.WIN_SCORE
		]
	_rebuild_arena()
