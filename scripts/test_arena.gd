extends "res://scripts/main.gd"

func _ready() -> void:
	if GameManager.session_type != GameManager.SessionType.ARENA:
		GameManager.start_arena()
	super._ready()

func _session_title() -> String:
	return "ARENA"

func _session_message() -> String:
	return "PvP arena — fall drops your gun · weapons from the sky · Tab=mode  M=map  F5=restart"
