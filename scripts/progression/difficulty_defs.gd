class_name DifficultyDefs

enum Tier { EASY, NORMAL, HARD, HELL }

const TIERS := {
	Tier.EASY: {
		"name": "Easy",
		"stars": 1,
		"enemy_mult": 0.75,
		"hp_mult": 0.85,
		"reward_mult": 0.75,
	},
	Tier.NORMAL: {
		"name": "Normal",
		"stars": 2,
		"enemy_mult": 1.0,
		"hp_mult": 1.0,
		"reward_mult": 1.0,
	},
	Tier.HARD: {
		"name": "Hard",
		"stars": 3,
		"enemy_mult": 1.3,
		"hp_mult": 1.25,
		"reward_mult": 1.35,
	},
	Tier.HELL: {
		"name": "Hell",
		"stars": 4,
		"enemy_mult": 1.65,
		"hp_mult": 1.5,
		"reward_mult": 1.75,
	},
}


static func get_tier(tier: Tier) -> Dictionary:
	return TIERS.get(tier, TIERS[Tier.NORMAL])


static func tier_name(tier: Tier) -> String:
	return get_tier(tier).get("name", "Normal")


static func stars_text(count: int) -> String:
	var filled := clampi(count, 0, 5)
	return "★".repeat(filled) + "☆".repeat(5 - filled)


static func list_tiers() -> Array[Tier]:
	return [Tier.EASY, Tier.NORMAL, Tier.HARD, Tier.HELL]
