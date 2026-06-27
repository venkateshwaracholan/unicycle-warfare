extends Node2D

@export var color := Color.WHITE
@export var is_rider := false
@export var team_color := Color.RED

func _draw() -> void:
	if is_rider:
		_draw_rider()
	else:
		_draw_wheel()

func _draw_wheel() -> void:
	var r := 22.0
	draw_circle(Vector2.ZERO, r, Color(0.15, 0.15, 0.18))
	draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(0.35, 0.35, 0.4), 4.0)
	draw_circle(Vector2.ZERO, 6, Color(0.5, 0.5, 0.55))
	for i in 4:
		var a := float(i) * PI * 0.5
		draw_line(Vector2.ZERO, Vector2(cos(a), sin(a)) * (r - 4), Color(0.4, 0.4, 0.45), 2.0)

func _draw_rider() -> void:
	# Blocky gangster body
	draw_rect(Rect2(-12, -30, 24, 30), team_color)
	# Head
	draw_rect(Rect2(-10, -48, 20, 18), Color(0.85, 0.7, 0.55))
	# Hat
	draw_rect(Rect2(-14, -54, 28, 8), Color(0.15, 0.12, 0.1))
	draw_rect(Rect2(-8, -60, 16, 8), Color(0.15, 0.12, 0.1))
	# Seat post
	draw_line(Vector2(0, 0), Vector2(0, 8), Color(0.25, 0.25, 0.28), 4.0)
	# Legs
	draw_rect(Rect2(-10, 0, 8, 14), Color(0.2, 0.2, 0.25))
	draw_rect(Rect2(2, 0, 8, 14), Color(0.2, 0.2, 0.25))
	# Gun arm
	draw_rect(Rect2(8, -22, 18, 6), Color(0.35, 0.35, 0.38))
