extends Camera2D

const DEFAULT_POS := Vector2(640, 360)
const DEFAULT_ZOOM := 1.0
const MISSION_ZOOM := 0.92
const FACE_ZOOM := 3.6
const MIN_ZOOM := 0.55
const MAX_ZOOM := 6.0
const ZOOM_STEP := 1.12
const FACE_OFFSET := Vector2(4.0, -42.0)
## Ground line screen position during mission follow (0.5 = center; higher = more sky).
const MISSION_GROUND_SCREEN_FRAC := 0.72

enum Focus { WIDE, PLAYER1, PLAYER2, MISSION }

var _focus := Focus.WIDE
var _target_zoom := DEFAULT_ZOOM
var _level_left := 0.0
var _level_right := 1280.0
var _mission_mode := false


func _ready() -> void:
	make_current()


func configure_mission(level_left: float, level_right: float) -> void:
	_mission_mode = true
	_level_left = level_left
	_level_right = level_right
	_focus = Focus.MISSION
	_target_zoom = MISSION_ZOOM


func configure_arena() -> void:
	_mission_mode = false
	_focus = Focus.WIDE
	_target_zoom = DEFAULT_ZOOM
	global_position = DEFAULT_POS


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_by(ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_by(1.0 / ZOOM_STEP)
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_set_focus(Focus.PLAYER1)
				get_viewport().set_input_as_handled()
			KEY_2:
				_set_focus(Focus.PLAYER2)
				get_viewport().set_input_as_handled()
			KEY_0:
				_set_focus(Focus.WIDE if not _mission_mode else Focus.MISSION)
				get_viewport().set_input_as_handled()
			KEY_EQUAL, KEY_KP_ADD:
				_zoom_by(ZOOM_STEP)
				get_viewport().set_input_as_handled()
			KEY_MINUS, KEY_KP_SUBTRACT:
				_zoom_by(1.0 / ZOOM_STEP)
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var target_pos: Vector2 = DEFAULT_POS
	match _focus:
		Focus.PLAYER1:
			target_pos = _face_anchor(1)
		Focus.PLAYER2:
			target_pos = _face_anchor(2)
		Focus.MISSION:
			target_pos = _mission_anchor()

	if _focus == Focus.MISSION:
		target_pos.x = _clamp_camera_x(target_pos.x)

	global_position = global_position.lerp(target_pos, 1.0 - exp(-9.0 * delta))
	var target_zoom_vec := Vector2.ONE * _target_zoom
	zoom = zoom.lerp(target_zoom_vec, 1.0 - exp(-12.0 * delta))

	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena and arena.mission_level:
		arena.set_camera_scroll(global_position.x)


func _clamp_camera_x(x: float) -> float:
	var half_view := 640.0 / _target_zoom
	var min_x := _level_left + half_view
	var max_x := _level_right - half_view
	if max_x < min_x:
		return (_level_left + _level_right) * 0.5
	return clampf(x, min_x, max_x)


func _mission_camera_y() -> float:
	var viewport_h := get_viewport().get_visible_rect().size.y
	var half_h := viewport_h * 0.5
	var surface_y := DEFAULT_POS.y
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena:
		surface_y = arena.ground_surface_y()
	return surface_y - (MISSION_GROUND_SCREEN_FRAC * viewport_h - half_h) / _target_zoom


func _mission_anchor() -> Vector2:
	var cam_y := _mission_camera_y()
	for node in get_tree().get_nodes_in_group("players"):
		if not node is Node2D or not node.has_method("get_player_id"):
			continue
		if node.get_player_id() != 1:
			continue
		var player: Node2D = node
		return Vector2(player.global_position.x, cam_y)
	return Vector2(_level_left + 640.0, cam_y)


func _set_focus(focus: Focus) -> void:
	_focus = focus
	if focus == Focus.WIDE or focus == Focus.MISSION:
		_target_zoom = MISSION_ZOOM if _mission_mode and focus == Focus.MISSION else DEFAULT_ZOOM
	else:
		_target_zoom = maxf(_target_zoom, FACE_ZOOM)


func _zoom_by(factor: float) -> void:
	_target_zoom = clampf(_target_zoom * factor, MIN_ZOOM, MAX_ZOOM)


func _face_anchor(player_id: int) -> Vector2:
	for node in get_tree().get_nodes_in_group("players"):
		if not node is Node2D or not node.has_method("get_player_id"):
			continue
		if node.get_player_id() != player_id:
			continue
		var player: Node2D = node
		var upper: Node2D = player.get_node_or_null("Wheel/Pelvis/UpperBody") as Node2D
		if upper:
			var aim := 1.0
			if player.has_method("get_aim_facing"):
				aim = player.get_aim_facing()
			var pos: Vector2 = upper.global_position + Vector2(FACE_OFFSET.x * aim, FACE_OFFSET.y)
			if _mission_mode:
				pos.x = _clamp_camera_x(pos.x)
			return pos
		var pos: Vector2 = player.global_position + Vector2(0.0, -110.0)
		if _mission_mode:
			pos.x = _clamp_camera_x(pos.x)
		return pos
	return DEFAULT_POS
