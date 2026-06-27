extends "res://scripts/main.gd"

func _ready() -> void:
	if GameManager.session_type != GameManager.SessionType.ARENA:
		GameManager.start_arena()
	super._ready()

func _session_title() -> String:
	return "ARENA"

func _session_message() -> String:
	return "PvP arena — Q/W pedal · A/D aim · E shoot · Tab=mode · M=map · scroll zoom · 1/2 face · 0 reset"
