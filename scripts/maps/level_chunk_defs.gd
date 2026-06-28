class_name LevelChunkDefs

## Reusable mission chunk templates — flat platforms, gentle steps, wide bridges.
## All geometry is chunk-local; LevelAssembler offsets into world space.

enum ChunkRole {
	SPAWN,
	TRAVERSAL,
	COMBAT,
	OBJECTIVE,
	LARGE_COMBAT,
	BOSS,
	ESCAPE,
	EXTRACT,
	SECRET,
}

const PLATFORM_H := 14.0

const ROLE_WIDTH := {
	ChunkRole.SPAWN: 720.0,
	ChunkRole.TRAVERSAL: 1180.0,
	ChunkRole.COMBAT: 980.0,
	ChunkRole.OBJECTIVE: 1040.0,
	ChunkRole.LARGE_COMBAT: 1320.0,
	ChunkRole.BOSS: 1240.0,
	ChunkRole.ESCAPE: 1080.0,
	ChunkRole.EXTRACT: 760.0,
	ChunkRole.SECRET: 860.0,
}


static func chunk_width(role: ChunkRole) -> float:
	return float(ROLE_WIDTH.get(role, 1000.0))


static func build(role: ChunkRole, label: String, opts: Dictionary = {}) -> Dictionary:
	var width := float(opts.get("width", chunk_width(role)))
	var chunk := {
		"role": role,
		"label": label,
		"width": width,
		"platforms": _platforms_for_role(role, width, opts),
		"props": opts.get("props", []),
		"hazards": opts.get("hazards", []),
		"enemy_zone": opts.get("enemy_zone", _default_enemy_zone(role)),
		"markers": opts.get("markers", {}),
		"visual": opts.get("visual", ""),
	}
	return chunk


static func _default_enemy_zone(role: ChunkRole) -> Dictionary:
	match role:
		ChunkRole.SPAWN, ChunkRole.EXTRACT:
			return {}
		ChunkRole.COMBAT, ChunkRole.OBJECTIVE, ChunkRole.LARGE_COMBAT, ChunkRole.BOSS:
			return {"x0": 0.12, "x1": 0.88}
		_:
			return {"x0": 0.35, "x1": 0.65}


static func _platforms_for_role(role: ChunkRole, width: float, opts: Dictionary) -> Array:
	if opts.has("platforms"):
		return opts.platforms
	match role:
		ChunkRole.SECRET:
			return _secret_path(width)
		ChunkRole.TRAVERSAL, ChunkRole.ESCAPE:
			return _traversal_terrain(width, opts)
		ChunkRole.BOSS:
			return _arena_bowl(width)
		_:
			return _flat(width)


static func _flat(width: float, y_offset: float = 0.0) -> Array:
	return [{"x": 0.0, "y": y_offset, "w": width, "h": PLATFORM_H}]


static func _traversal_terrain(width: float, opts: Dictionary) -> Array:
	var style := str(opts.get("terrain", "flat"))
	match style:
		"step_up":
			var step_at := width * 0.55
			return [
				{"x": 0.0, "y": 0.0, "w": step_at + 80.0, "h": PLATFORM_H},
				{"x": step_at, "y": -36.0, "w": width - step_at, "h": PLATFORM_H},
			]
		"step_down":
			var step_at := width * 0.45
			return [
				{"x": 0.0, "y": 0.0, "w": step_at + 80.0, "h": PLATFORM_H},
				{"x": step_at, "y": 36.0, "w": width - step_at, "h": PLATFORM_H},
			]
		"bridge":
			var gap := width * 0.22
			var left_w := (width - gap) * 0.42
			var right_x := width - left_w
			return [
				{"x": 0.0, "y": 0.0, "w": left_w, "h": PLATFORM_H},
				{"x": right_x, "y": 0.0, "w": left_w, "h": PLATFORM_H},
				{"x": left_w - 20.0, "y": -8.0, "w": gap + 40.0, "h": PLATFORM_H},
			]
		"dual_lane":
			return [
				{"x": 0.0, "y": 0.0, "w": width, "h": PLATFORM_H},
				{"x": width * 0.08, "y": -28.0, "w": width * 0.84, "h": PLATFORM_H},
			]
		_:
			return _flat(width)


static func _arena_bowl(width: float) -> Array:
	var inset := width * 0.08
	return [
		{"x": 0.0, "y": 0.0, "w": width, "h": PLATFORM_H},
		{"x": inset, "y": -24.0, "w": width - inset * 2.0, "h": PLATFORM_H},
	]


static func _secret_path(width: float) -> Array:
	return [
		{"x": 0.0, "y": -32.0, "w": width * 0.35, "h": PLATFORM_H},
		{"x": width * 0.28, "y": -16.0, "w": width * 0.44, "h": PLATFORM_H},
		{"x": width * 0.65, "y": 0.0, "w": width * 0.35, "h": PLATFORM_H},
	]


static func prop(type: String, norm_x: float, scale: float = 1.0) -> Dictionary:
	return {"type": type, "nx": norm_x, "scale": scale}


static func hazard(type: String, x0: float, x1: float, extra: Dictionary = {}) -> Dictionary:
	var h := {"type": type, "x0": x0, "x1": x1}
	h.merge(extra, true)
	return h
