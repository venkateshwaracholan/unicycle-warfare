extends Node

## Persistent coins, unlocks, and mission stats.

signal coins_changed(amount: int)
signal unlock_changed()

const SAVE_PATH := "user://progress.save"

var coins := 0
var missions_completed := 0
var _unlocked_weapons: Array[int] = [
	WeaponDefs.Type.PISTOL,
	WeaponDefs.Type.SMG,
	WeaponDefs.Type.GRENADE,
]
var _unlocked_cosmetics: Array[String] = []

func _ready() -> void:
	load_progress()

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)
	save_progress()

func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	save_progress()
	return true

func record_mission_complete(_mission_id: String, reward: int) -> void:
	missions_completed += 1
	add_coins(reward)
	save_progress()

func is_weapon_unlocked(weapon: WeaponDefs.Type) -> bool:
	return _unlocked_weapons.has(int(weapon))

func unlock_weapon(weapon: WeaponDefs.Type) -> void:
	var key := int(weapon)
	if _unlocked_weapons.has(key):
		return
	_unlocked_weapons.append(key)
	unlock_changed.emit()
	save_progress()

func is_cosmetic_unlocked(cosmetic_id: String) -> bool:
	return _unlocked_cosmetics.has(cosmetic_id)

func unlock_cosmetic(cosmetic_id: String) -> void:
	if _unlocked_cosmetics.has(cosmetic_id):
		return
	_unlocked_cosmetics.append(cosmetic_id)
	unlock_changed.emit()
	save_progress()

func is_upgrade_owned(item: Dictionary) -> bool:
	if item.has("weapon"):
		return is_weapon_unlocked(item.weapon)
	if item.has("id"):
		return is_cosmetic_unlocked(str(item.id))
	return false

func save_progress() -> void:
	var data := {
		"coins": coins,
		"missions_completed": missions_completed,
		"weapons": _unlocked_weapons,
		"cosmetics": _unlocked_cosmetics,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	coins = int(data.get("coins", 0))
	missions_completed = int(data.get("missions_completed", 0))
	_unlocked_weapons.assign(data.get("weapons", _unlocked_weapons))
	_unlocked_cosmetics.assign(data.get("cosmetics", []))
	coins_changed.emit(coins)
