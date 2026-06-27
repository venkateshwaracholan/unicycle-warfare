class_name DrawShapes

static func clamp_radius(rect: Rect2, radius: float) -> float:
	return minf(radius, minf(rect.size.x, rect.size.y) * 0.5)


static func rounded_rect(
	target: CanvasItem,
	rect: Rect2,
	radius: float,
	fill: Color,
	outline: Color = Color.TRANSPARENT,
	outline_width: float = 0.0
) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(int(clamp_radius(rect, radius)))
	if outline.a > 0.0 and outline_width > 0.0:
		style.border_color = outline
		style.set_border_width_all(maxi(1, int(outline_width)))
	style.draw(target.get_canvas_item(), rect)


static func capsule(
	target: CanvasItem,
	from: Vector2,
	to: Vector2,
	thickness: float,
	fill: Color,
	outline: Color = Color.TRANSPARENT,
	outline_width: float = 0.0
) -> void:
	var delta := to - from
	var length := delta.length()
	if length < 0.01:
		return
	var dir := delta / length
	var radius := thickness * 0.5
	var angle := dir.angle()
	target.draw_set_transform(from, angle, Vector2.ONE)
	target.draw_rect(Rect2(0.0, -radius, length, thickness), fill)
	target.draw_circle(Vector2.ZERO, radius, fill)
	target.draw_circle(Vector2(length, 0.0), radius, fill)
	if outline.a > 0.0 and outline_width > 0.0:
		target.draw_arc(Vector2.ZERO, radius, PI * 0.5, PI * 1.5, 10, outline, outline_width)
		target.draw_arc(Vector2(length, 0.0), radius, -PI * 0.5, PI * 0.5, 10, outline, outline_width)
		target.draw_line(Vector2(0.0, -radius), Vector2(length, -radius), outline, outline_width)
		target.draw_line(Vector2(0.0, radius), Vector2(length, radius), outline, outline_width)
	target.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
