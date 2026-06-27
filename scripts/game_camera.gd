extends Camera2D

const DEFAULT_POS := Vector2(640, 360)
const DEFAULT_ZOOM := 1.0
const FACE_ZOOM := 3.6
const MIN_ZOOM := 0.55
const MAX_ZOOM := 6.0
const ZOOM_STEP := 1.12
const FACE_OFFSET := Vector2(4.0, -42.0)

enum Focus { WIDE, PLAYER1, PLAYER2 }

var _focus := Focus.WIDE
var _target_zoom := DEFAULT_ZOOM


func _ready() -> void:
	make_current()


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
				_set_focus(Focus.WIDE)
				get_viewport().set_input_as_handled()
			KEY_EQUAL, KEY_KP_ADD:
				_zoom_by(ZOOM_STEP)
				get_viewport().set_input_as_handled()
			KEY_MINUS, KEY_KP_SUBTRACT:
				_zoom_by(1.0 / ZOOM_STEP)
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var target_pos := DEFAULT_POS
	match _focus:
		Focus.PLAYER1:
			target_pos = _face_anchor(1)
		Focus.PLAYER2:
			target_pos = _face_anchor(2)

	global_position = global_position.lerp(target_pos, 1.0 - exp(-9.0 * delta))
	var target_zoom_vec := Vector2.ONE * _target_zoom
	zoom = zoom.lerp(target_zoom_vec, 1.0 - exp(-12.0 * delta))


func _set_focus(focus: Focus) -> void:
	_focus = focus
	if focus == Focus.WIDE:
		_target_zoom = DEFAULT_ZOOM
	else:
		_target_zoom = maxf(_target_zoom, FACE_ZOOM)


func _zoom_by(factor: float) -> void:
	_target_zoom = clampf(_target_zoom * factor, MIN_ZOOM, MAX_ZOOM)


func _face_anchor(player_id: int) -> Vector2:
	for node in get_tree().get_nodes_in_group("players"):
		if not node.has_method("get_player_id"):
			continue
		if node.get_player_id() != player_id:
			continue
		var upper: Node2D = node.get_node_or_null("Wheel/Pelvis/UpperBody") as Node2D
		if upper:
			var aim := 1.0
			if node.has_method("get_aim_facing"):
				aim = node.get_aim_facing()
			return upper.global_position + Vector2(FACE_OFFSET.x * aim, FACE_OFFSET.y)
		return node.global_position + Vector2(0.0, -110.0)
	return DEFAULT_POS
