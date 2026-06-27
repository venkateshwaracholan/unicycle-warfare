class_name WeaponLoadoutPanel
extends PanelContainer

## Arena loadout — pick a weapon; equips instantly on click.

var _player: Node2D
var _buttons: Dictionary = {}


func _ready() -> void:
	visible = false
	_build_ui()


func bind_player(player: Node2D) -> void:
	_player = player
	if is_instance_valid(player) and player.has_signal("weapon_changed"):
		if not player.weapon_changed.is_connected(_refresh_selection):
			player.weapon_changed.connect(_refresh_selection)
	_refresh_selection()


func toggle() -> void:
	visible = not visible
	mouse_filter = Control.MOUSE_FILTER_STOP if visible else Control.MOUSE_FILTER_IGNORE
	if visible:
		_refresh_selection()


func is_open() -> bool:
	return visible


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(220, 0)
	position = Vector2(16, 72)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.1, 0.92)
	style.border_color = Color(0.45, 0.55, 0.75, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	var title := Label.new()
	title.text = "LOADOUT  (J)"
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	root.add_child(title)

	var hint := Label.new()
	hint.text = "Click to equip instantly"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.65, 0.72, 0.82))
	root.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 320)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)

	for weapon in WeaponDefs.loadout_types():
		var data := WeaponDefs.get_data(weapon)
		var btn := Button.new()
		btn.text = str(data.get("name", "?"))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 13)
		var color: Color = data.get("color", Color.WHITE)
		btn.add_theme_color_override("font_color", color.lightened(0.15))
		btn.pressed.connect(_on_weapon_pressed.bind(weapon))
		list.add_child(btn)
		_buttons[weapon] = btn


func _on_weapon_pressed(weapon: WeaponDefs.Type) -> void:
	if not is_instance_valid(_player) or not _player.has_method("set_weapon_type"):
		return
	_player.set_weapon_type(weapon)
	_refresh_selection()


func _refresh_selection(_weapon: WeaponDefs.Type = WeaponDefs.Type.NONE) -> void:
	var current := WeaponDefs.Type.PISTOL
	if is_instance_valid(_player) and _player.has_method("get_weapon_type"):
		current = _player.get_weapon_type()
	for weapon in _buttons:
		var btn: Button = _buttons[weapon]
		var data := WeaponDefs.get_data(weapon)
		var name: String = data.get("name", "?")
		if weapon == current:
			btn.text = "▸ %s" % name
			btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.55))
		else:
			btn.text = name
			var color: Color = data.get("color", Color.WHITE)
			btn.add_theme_color_override("font_color", color.lightened(0.15))
