class_name DifficultyScaling

## Solo/co-op + difficulty tier scaling.


static func player_count() -> int:
	return maxi(1, GameManager.player_count)


static func tier_mult(key: String, default: float = 1.0) -> float:
	if not GameManager.is_play_mode():
		return default
	return float(DifficultyDefs.get_tier(GameManager.difficulty).get(key, default))


static func enemy_count(base: int) -> int:
	var scale := 0.7 + 0.45 * float(player_count() - 1)
	scale *= tier_mult("enemy_mult", 1.0)
	return maxi(1, int(round(float(base) * scale)))


static func enemy_hp(base: float) -> float:
	var hp := base * (1.0 + 0.25 * float(player_count() - 1))
	return hp * tier_mult("hp_mult", 1.0)


static func boss_hp(base: float) -> float:
	var hp := base * (1.0 + 0.35 * float(player_count() - 1))
	return hp * tier_mult("hp_mult", 1.0)


static func projectile_count(base: int) -> int:
	return maxi(1, int(round(float(base) * (0.8 + 0.3 * float(player_count() - 1)))))
