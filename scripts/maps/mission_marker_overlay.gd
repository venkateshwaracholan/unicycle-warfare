extends Node2D

## Draws the active mission marker so objectives are visible on any map.

var _pos := Vector2.ZERO
var _kind := ""
var _objective: Dictionary = {}

func set_marker(pos: Vector2, kind: String, objective: Dictionary) -> void:
	_pos = pos
	_kind = kind
	_objective = objective
	queue_redraw()

func clear_marker() -> void:
	_pos = Vector2.ZERO
	_kind = ""
	_objective = {}
	queue_redraw()

func _draw() -> void:
	if _pos == Vector2.ZERO:
		return
	var color := _color_for_kind(_kind)
	draw_circle(_pos, 28.0, Color(color, 0.18))
	draw_arc(_pos, 28.0, 0.0, TAU, 24, color, 3.0)
	_draw_marker_icon(_pos, _kind, color)
	if _objective.get("type") == MissionDefs.ObjectiveType.DEFEND:
		draw_arc(_pos, 52.0, 0.0, TAU, 32, Color(color, 0.35), 2.0)


func _draw_marker_icon(pos: Vector2, kind: String, color: Color) -> void:
	match kind:
		MapDefs.MARKER_DESTROY, MapDefs.MARKER_BOSS:
			draw_line(pos + Vector2(-10, 4), pos + Vector2(10, -4), color, 3.0)
			draw_line(pos + Vector2(-10, -4), pos + Vector2(10, 4), color, 3.0)
		MapDefs.MARKER_PICKUP:
			draw_rect(Rect2(pos.x - 8, pos.y - 8, 16, 16), color, false, 2.0)
		MapDefs.MARKER_EXTRACT, MapDefs.MARKER_ESCORT_END:
			draw_colored_polygon(PackedVector2Array([pos + Vector2(0, -10), pos + Vector2(-8, 8), pos + Vector2(8, 8)]), color)
		MapDefs.MARKER_DEFEND:
			draw_circle(pos, 6.0, color)
		MapDefs.MARKER_ESCORT_START:
			draw_circle(pos, 6.0, color)
			draw_line(pos, pos + Vector2(14, 0), color, 2.0)
		_:
			draw_circle(pos, 6.0, color)

func _color_for_kind(kind: String) -> Color:
	match kind:
		MapDefs.MARKER_DESTROY, MapDefs.MARKER_BOSS:
			return Color(1.0, 0.35, 0.25)
		MapDefs.MARKER_PICKUP:
			return Color(0.35, 0.85, 1.0)
		MapDefs.MARKER_EXTRACT, MapDefs.MARKER_ESCORT_END:
			return Color(0.45, 1.0, 0.55)
		MapDefs.MARKER_DEFEND:
			return Color(1.0, 0.82, 0.25)
		MapDefs.MARKER_ESCORT_START:
			return Color(0.75, 0.55, 1.0)
	return Color(1.0, 0.92, 0.55)
