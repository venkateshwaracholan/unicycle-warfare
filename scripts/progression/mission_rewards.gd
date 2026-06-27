class_name MissionRewards

## Coin payout from mission + difficulty.


static func mission_stars(mission_id: String) -> int:
	var def := MissionDefs.get_mission(mission_id)
	if def.has("stars"):
		return int(def.stars)
	return clampi(int(def.get("objectives", []).size()) - 1, 1, 5)


static func base_coins(mission_id: String) -> int:
	var def := MissionDefs.get_mission(mission_id)
	if def.has("base_reward"):
		return int(def.base_reward)
	return 100 + mission_stars(mission_id) * 50


static func calculate(mission_id: String, tier: DifficultyDefs.Tier) -> Dictionary:
	var base := base_coins(mission_id)
	var mult: float = DifficultyDefs.get_tier(tier).get("reward_mult", 1.0)
	var total := int(round(float(base) * mult))
	var def := MissionDefs.get_mission(mission_id)
	return {
		"mission_id": mission_id,
		"mission_name": def.get("name", "Mission"),
		"map_name": MapDefs.map_name(def.get("map", MapDefs.MapId.DESERT)),
		"stars": mission_stars(mission_id),
		"difficulty": DifficultyDefs.tier_name(tier),
		"base_coins": base,
		"coins": total,
		"bonus_coins": maxi(0, total - base),
	}
