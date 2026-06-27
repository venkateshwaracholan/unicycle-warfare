extends Area2D

var _occupant := 0

func _ready() -> void:
	add_to_group("hill_zone")
	collision_layer = 16
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func get_occupant() -> int:
	return _occupant

func _on_body_entered(body: Node) -> void:
	var player := _player_from(body)
	if player and player.state == player.State.RIDING:
		_occupant = player.get_player_id()

func _on_body_exited(body: Node) -> void:
	var player := _player_from(body)
	if player and player.get_player_id() == _occupant:
		_occupant = 0

func _player_from(body: Node) -> Node:
	if body.is_in_group("players"):
		return body
	if body.get_parent() and body.get_parent().is_in_group("players"):
		return body.get_parent()
	return null

func _draw() -> void:
	draw_circle(Vector2.ZERO, 80, Color(1, 0.85, 0.2, 0.12))
	draw_arc(Vector2.ZERO, 80, 0, TAU, 32, Color(1, 0.85, 0.2, 0.45), 3.0)
