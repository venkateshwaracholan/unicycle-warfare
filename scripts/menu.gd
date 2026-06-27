extends Control

@onready var menu_panel: VBoxContainer = $MenuPanel
@onready var options_panel: PanelContainer = $OptionsPanel

func _ready() -> void:
	menu_panel.get_node("PlayButton").pressed.connect(_on_play_pressed)
	menu_panel.get_node("ArenaButton").pressed.connect(_on_arena_pressed)
	menu_panel.get_node("OptionsButton").pressed.connect(_on_options_pressed)
	menu_panel.get_node("QuitButton").pressed.connect(_on_quit_pressed)
	options_panel.get_node("OptionsVBox/BackButton").pressed.connect(_on_options_back_pressed)

func _on_play_pressed() -> void:
	GameManager.start_play()
	get_tree().change_scene_to_file(GameManager.MAIN_SCENE)

func _on_arena_pressed() -> void:
	GameManager.start_arena()
	get_tree().change_scene_to_file(GameManager.ARENA_SCENE)

func _on_options_pressed() -> void:
	menu_panel.visible = false
	options_panel.visible = true

func _on_options_back_pressed() -> void:
	options_panel.visible = false
	menu_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
