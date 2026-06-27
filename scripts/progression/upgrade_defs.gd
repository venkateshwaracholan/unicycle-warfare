class_name UpgradeDefs

## Garage shop — unlock weapons and cosmetics with coins.

const WEAPONS := [
	{
		"id": "unlock_shotgun",
		"name": "Shotgun",
		"desc": "Massive recoil — brace or fly.",
		"weapon": WeaponDefs.Type.SHOTGUN,
		"cost": 300,
	},
	{
		"id": "unlock_sniper",
		"name": "Sniper",
		"desc": "Launches you off the seat.",
		"weapon": WeaponDefs.Type.SNIPER,
		"cost": 450,
	},
	{
		"id": "unlock_rocket",
		"name": "Rocket Launcher",
		"desc": "Shoot the ground to jump.",
		"weapon": WeaponDefs.Type.ROCKET,
		"cost": 800,
	},
	{
		"id": "unlock_katana",
		"name": "Katana",
		"desc": "Melee lunge on a unicycle.",
		"weapon": WeaponDefs.Type.KATANA,
		"cost": 350,
	},
]

const COSMETICS := [
	{
		"id": "cosmetic_gold_wheel",
		"name": "Gold Wheel",
		"desc": "Flashy rims for your ride.",
		"cost": 500,
	},
	{
		"id": "cosmetic_neon_trail",
		"name": "Neon Trail",
		"desc": "Leave a glow behind you.",
		"cost": 750,
	},
]


static func all_items() -> Array:
	var items: Array = []
	items.append_array(WEAPONS)
	items.append_array(COSMETICS)
	return items
