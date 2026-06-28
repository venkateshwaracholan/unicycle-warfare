class_name MissionEnvironmentBake

const _BakeDrawer := preload("res://scripts/maps/mission_bake_drawer.gd")

const BAKE_Y_MIN := -80.0
const BAKE_Y_MAX := 720.0
const MAX_BAKE_WIDTH := 8192

static var _cache: Dictionary = {}


static func bake(
	parent: Node,
	map_id: MapDefs.MapId,
	level: LevelAssembler,
	surface_y: float,
	platform_color: Color
) -> Sprite2D:
	var cache_key := _cache_key(map_id, level, surface_y, platform_color)
	if _cache.has(cache_key):
		return _duplicate_sprite(_cache[cache_key] as Sprite2D)

	var left := level.world_left
	var right := level.world_right
	var world_w := int(ceil(right - left))
	var world_h := int(ceil(BAKE_Y_MAX - BAKE_Y_MIN))
	if world_w < 1:
		world_w = 1

	var bake_scale_x := minf(1.0, float(MAX_BAKE_WIDTH) / float(world_w))
	var bake_w := maxi(1, int(ceil(float(world_w) * bake_scale_x)))

	var vp := SubViewport.new()
	vp.name = "MissionBakeViewport"
	vp.size = Vector2i(bake_w, world_h)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.disable_3d = true
	vp.transparent_bg = false
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	parent.add_child(vp)

	var drawer: Node2D = _BakeDrawer.new()
	drawer.bake_left = left
	drawer.bake_right = right
	drawer.surface_y = surface_y
	drawer.map_id = map_id
	drawer.level = level
	drawer.platform_color = platform_color
	drawer.bake_scale_x = bake_scale_x
	vp.add_child(drawer)

	for _i in 4:
		await parent.get_tree().process_frame

	var tex := vp.get_texture()
	var image: Image = tex.get_image() if tex else null
	vp.queue_free()

	var sprite := Sprite2D.new()
	sprite.name = "MissionBakeSprite"
	sprite.centered = false
	sprite.position = Vector2(left, BAKE_Y_MIN)
	sprite.z_index = -8
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	if image != null and not image.is_empty():
		sprite.texture = ImageTexture.create_from_image(image)
		if bake_scale_x < 0.999:
			sprite.scale = Vector2(1.0 / bake_scale_x, 1.0)

	_cache[cache_key] = _duplicate_sprite(sprite)
	return _duplicate_sprite(sprite)


static func clear_cache() -> void:
	_cache.clear()


static func _cache_key(
	map_id: MapDefs.MapId,
	level: LevelAssembler,
	surface_y: float,
	platform_color: Color
) -> String:
	return "%d_%d_%d_%s" % [
		int(map_id),
		int(level.world_width),
		int(surface_y * 10.0),
		str(platform_color),
	]


static func _duplicate_sprite(source: Sprite2D) -> Sprite2D:
	var copy := Sprite2D.new()
	copy.name = "MissionBakeSprite"
	copy.centered = source.centered
	copy.position = source.position
	copy.z_index = source.z_index
	copy.scale = source.scale
	copy.texture_filter = source.texture_filter
	copy.texture = source.texture
	return copy
