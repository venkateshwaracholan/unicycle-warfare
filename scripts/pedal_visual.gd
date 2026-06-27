extends Node2D

const CRANK_LENGTH := 16.0
const PEDAL_HALF_WIDTH := 6.0
const HUB_RADIUS := 5.0

var spin_angle := 0.0
var pedaling_intensity := 0.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, HUB_RADIUS, Color(0.42, 0.42, 0.48))
	# Front crank pedal only — back pedal is drawn behind the wheel on LegBack.
	_draw_pedal(0)

func _draw_pedal(index: int) -> void:
	var angle := spin_angle + float(index) * PI
	var dir := Vector2(cos(angle), sin(angle))
	var foot_pos := dir * CRANK_LENGTH
	var tangent := Vector2(-dir.y, dir.x)
	var kick := 1.0 + pedaling_intensity * 0.1
	var pp1 := foot_pos - tangent * PEDAL_HALF_WIDTH * kick
	var pp2 := foot_pos + tangent * PEDAL_HALF_WIDTH * kick
	draw_line(pp1, pp2, Color(0.55, 0.5, 0.15), 4.0)
	draw_line(pp1, pp2, Color(0.92, 0.86, 0.35), 2.0)

func get_pedal_positions_global() -> Array[Vector2]:
	var out: Array[Vector2] = []
	for i in 2:
		var angle := spin_angle + float(i) * PI
		var dir := Vector2(cos(angle), sin(angle))
		var kick := dir * pedaling_intensity * 1.5
		out.append(global_position + dir * CRANK_LENGTH + kick)
	return out

func get_hub_global() -> Vector2:
	return global_position
