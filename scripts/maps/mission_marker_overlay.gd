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
	draw_circle(_pos, 6.0, color)
	if _objective.get("type") == MissionDefs.ObjectiveType.DEFEND:
		draw_arc(_pos, 52.0, 0.0, TAU, 32, Color(color, 0.35), 2.0)

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
