extends Control

## Garage hub — Mission Board → Difficulty → Play → Rewards → Upgrades loop.

@onready var garage_panel: VBoxContainer = $GaragePanel
@onready var coins_label: Label = $GaragePanel/CoinsLabel
@onready var mission_panel: PanelContainer = $MissionPanel
@onready var mission_list: VBoxContainer = $MissionPanel/MissionVBox/MissionScroll/MissionList
@onready var difficulty_panel: PanelContainer = $DifficultyPanel
@onready var difficulty_info: Label = $DifficultyPanel/DifficultyVBox/DifficultyInfo
@onready var difficulty_options: VBoxContainer = $DifficultyPanel/DifficultyVBox/DifficultyOptions
@onready var rewards_panel: PanelContainer = $RewardsPanel
@onready var rewards_body: Label = $RewardsPanel/RewardsVBox/RewardsBody
@onready var upgrades_panel: PanelContainer = $UpgradesPanel
@onready var upgrades_list: VBoxContainer = $UpgradesPanel/UpgradesVBox/UpgradesScroll/UpgradesList
@onready var upgrades_coins: Label = $UpgradesPanel/UpgradesVBox/UpgradesCoins
@onready var options_panel: PanelContainer = $OptionsPanel

var _selected_mission_id := ""
var _panels: Array[Control] = []

func _ready() -> void:
	_panels = [garage_panel, mission_panel, difficulty_panel, rewards_panel, upgrades_panel, options_panel]
	garage_panel.get_node("MissionBoardButton").pressed.connect(_on_mission_board_pressed)
	garage_panel.get_node("UpgradesButton").pressed.connect(_on_upgrades_pressed)
	garage_panel.get_node("ArenaButton").pressed.connect(_on_arena_pressed)
	garage_panel.get_node("OptionsButton").pressed.connect(_on_options_pressed)
	garage_panel.get_node("QuitButton").pressed.connect(_on_quit_pressed)
	mission_panel.get_node("MissionVBox/BackButton").pressed.connect(_on_mission_back_pressed)
	difficulty_panel.get_node("DifficultyVBox/BackButton").pressed.connect(_on_difficulty_back_pressed)
	difficulty_panel.get_node("DifficultyVBox/LaunchButton").pressed.connect(_on_launch_pressed)
	rewards_panel.get_node("RewardsVBox/NextMissionButton").pressed.connect(_on_next_mission_pressed)
	rewards_panel.get_node("RewardsVBox/UpgradesButton").pressed.connect(_on_upgrades_pressed)
	rewards_panel.get_node("RewardsVBox/GarageButton").pressed.connect(_on_garage_pressed)
	upgrades_panel.get_node("UpgradesVBox/BackButton").pressed.connect(_on_upgrades_back_pressed)
	options_panel.get_node("OptionsVBox/BackButton").pressed.connect(_on_options_back_pressed)
	PlayerProgress.coins_changed.connect(_on_coins_changed)
	_build_mission_board()
	_build_difficulty_options()
	_update_coins()
	_show_panel(garage_panel)
	if GameManager.show_rewards_on_menu:
		_show_rewards()

func _show_panel(panel: Control) -> void:
	for p in _panels:
		p.visible = p == panel

func _update_coins() -> void:
	var text := "Coins: %d" % PlayerProgress.coins
	coins_label.text = text
	upgrades_coins.text = text

func _on_coins_changed(_amount: int) -> void:
	_update_coins()

func _build_mission_board() -> void:
	for child in mission_list.get_children():
		child.queue_free()

	for mission_id in MissionDefs.list_mission_ids():
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(420, 88)

		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		card.add_child(box)

		var map_label := Label.new()
		map_label.text = MissionDefs.board_map_name(mission_id)
		map_label.add_theme_color_override("font_color", Color(0.65, 0.78, 0.95))
		map_label.add_theme_font_size_override("font_size", 13)
		box.add_child(map_label)

		var title := Label.new()
		title.text = MissionDefs.board_title(mission_id)
		title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
		title.add_theme_font_size_override("font_size", 16)
		box.add_child(title)

		var stars := Label.new()
		var star_count := MissionRewards.mission_stars(mission_id)
		stars.text = DifficultyDefs.stars_text(star_count)
		stars.add_theme_font_size_override("font_size", 14)
		box.add_child(stars)

		var reward := Label.new()
		reward.text = "Reward: %d coins" % MissionRewards.base_coins(mission_id)
		reward.add_theme_color_override("font_color", Color(0.75, 0.85, 0.75))
		reward.add_theme_font_size_override("font_size", 13)
		box.add_child(reward)

		var btn := Button.new()
		btn.text = "Select"
		btn.custom_minimum_size = Vector2(100, 28)
		btn.pressed.connect(_on_mission_selected.bind(mission_id))
		box.add_child(btn)

		mission_list.add_child(card)
		mission_list.add_child(_make_spacer(6))

func _make_spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer

func _build_difficulty_options() -> void:
	for child in difficulty_options.get_children():
		child.queue_free()
	for tier in DifficultyDefs.list_tiers():
		var tier_data := DifficultyDefs.get_tier(tier)
		var btn := Button.new()
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(380, 40)
		btn.text = "%s  %s" % [tier_data.get("name", "?"), DifficultyDefs.stars_text(int(tier_data.get("stars", 2)))]
		btn.pressed.connect(_on_difficulty_selected.bind(tier, btn))
		difficulty_options.add_child(btn)
		if tier == GameManager.difficulty:
			btn.button_pressed = true

func _on_mission_board_pressed() -> void:
	_show_panel(mission_panel)

func _on_mission_selected(mission_id: String) -> void:
	_selected_mission_id = mission_id
	_update_difficulty_preview()
	_show_panel(difficulty_panel)

func _on_difficulty_selected(tier: DifficultyDefs.Tier, btn: Button) -> void:
	GameManager.difficulty = tier
	for child in difficulty_options.get_children():
		if child is Button and child != btn:
			child.button_pressed = false
	btn.button_pressed = true
	_update_difficulty_preview()

func _update_difficulty_preview() -> void:
	if _selected_mission_id == "":
		return
	var def := MissionDefs.get_mission(_selected_mission_id)
	var reward := MissionRewards.calculate(_selected_mission_id, GameManager.difficulty)
	difficulty_info.text = "%s\n%s\n\nDifficulty: %s\nPayout: %d coins" % [
		MissionDefs.board_map_name(_selected_mission_id),
		def.get("name", _selected_mission_id),
		DifficultyDefs.tier_name(GameManager.difficulty),
		int(reward.get("coins", 0)),
	]

func _on_launch_pressed() -> void:
	if _selected_mission_id == "":
		return
	GameManager.start_play(_selected_mission_id, GameManager.difficulty)
	get_tree().change_scene_to_file(GameManager.MAIN_SCENE)

func _on_mission_back_pressed() -> void:
	_show_panel(garage_panel)

func _on_difficulty_back_pressed() -> void:
	_show_panel(mission_panel)

func _show_rewards() -> void:
	var reward := GameManager.consume_pending_rewards()
	if reward.is_empty():
		return
	rewards_body.text = "Mission Complete!\n\n%s — %s\nDifficulty: %s\n\n+%d coins\nTotal: %d coins" % [
		reward.get("map_name", "?"),
		reward.get("mission_name", "Mission"),
		reward.get("difficulty", "Normal"),
		int(reward.get("coins", 0)),
		PlayerProgress.coins,
	]
	_show_panel(rewards_panel)

func _on_next_mission_pressed() -> void:
	_show_panel(mission_panel)

func _on_garage_pressed() -> void:
	_show_panel(garage_panel)

func _on_upgrades_pressed() -> void:
	_build_upgrades_list()
	_show_panel(upgrades_panel)

func _build_upgrades_list() -> void:
	for child in upgrades_list.get_children():
		child.queue_free()
	_update_coins()

	for item in UpgradeDefs.all_items():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.custom_minimum_size = Vector2(400, 44)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label := Label.new()
		name_label.text = item.get("name", "Upgrade")
		name_label.add_theme_font_size_override("font_size", 15)
		info.add_child(name_label)
		var desc := Label.new()
		desc.text = item.get("desc", "")
		desc.add_theme_font_size_override("font_size", 12)
		desc.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
		info.add_child(desc)
		row.add_child(info)

		var btn := Button.new()
		var owned := PlayerProgress.is_upgrade_owned(item)
		if owned:
			btn.text = "Owned"
			btn.disabled = true
		else:
			btn.text = "%d coins" % int(item.get("cost", 0))
			btn.pressed.connect(_on_buy_upgrade.bind(item))
		row.add_child(btn)
		upgrades_list.add_child(row)

func _on_buy_upgrade(item: Dictionary) -> void:
	var cost := int(item.get("cost", 0))
	if not PlayerProgress.spend_coins(cost):
		return
	if item.has("weapon"):
		PlayerProgress.unlock_weapon(item.weapon)
	elif item.has("id"):
		PlayerProgress.unlock_cosmetic(str(item.id))
	_build_upgrades_list()

func _on_upgrades_back_pressed() -> void:
	_show_panel(garage_panel)

func _on_arena_pressed() -> void:
	GameManager.start_arena()
	get_tree().change_scene_to_file(GameManager.ARENA_SCENE)

func _on_options_pressed() -> void:
	_show_panel(options_panel)

func _on_options_back_pressed() -> void:
	_show_panel(garage_panel)

func _on_quit_pressed() -> void:
	get_tree().quit()
