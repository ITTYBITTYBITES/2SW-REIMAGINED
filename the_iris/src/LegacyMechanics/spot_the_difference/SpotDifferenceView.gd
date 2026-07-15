extends Control
class_name SpotDifferenceView
## Themed paired renderer with one-pass sequential comparison and evidence regions.
##
## Asset pipeline: uses VisualStyleSystem to render sprite textures for known
## visual_kinds, with full vector fallback for kinds without assets yet.

var _scene: Dictionary = {}
var _highlights: Array[String] = []
var _elapsed: float = 0.0
var _last_state: int = 0
var _style: VisualStyleSystem
var _family_id: String = "spot_the_difference"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_style = VisualStyleSystem.new()
	_style.scan_assets()
	_configure_process()

func set_scene_data(scene_data: Dictionary, highlight_ids: Array = []) -> void:
	_scene = scene_data.duplicate(true)
	_highlights.clear()
	for value: Variant in highlight_ids:
		_highlights.append(str(value))
	_elapsed = 0.0
	_last_state = 0
	_configure_process()
	queue_redraw()

func _configure_process() -> void:
	var sequential_observation := (
		str(_scene.get("mode", "side_by_side")) == "sequential"
		and str(_scene.get("interaction_phase", "presentation")) != "response"
		and _highlights.is_empty()
		and not bool(_scene.get("reveal_mode", false))
	)
	var reveal_animation := not _highlights.is_empty() or bool(_scene.get("reveal_mode", false))
	if AccessibilityService and not AccessibilityService.should_animate():
		reveal_animation = false
	set_process(sequential_observation or reveal_animation)

func _process(delta: float) -> void:
	_elapsed += delta
	if (
		str(_scene.get("mode", "side_by_side")) == "sequential"
		and _highlights.is_empty()
		and not bool(_scene.get("reveal_mode", false))
	):
		var state_duration := maxf(float(_scene.get("state_duration", 2.5)), 0.1)
		var state := 0 if _elapsed < state_duration else 1
		if state != _last_state:
			_last_state = state
			if AudioService:
				AudioService.play_sfx("difference_switch", 0.32)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var backdrop := Color.BLACK if high_contrast else _style.canvas_background(_family_id)
	draw_rect(Rect2(Vector2.ZERO, size), backdrop, true)
	if not high_contrast:
		# Subtle warm ambient glow replacing old purple/orange blobs
		draw_circle(Vector2(size.x * 0.18, size.y * 0.18), maxf(size.x, size.y) * 0.26, Color(0.78, 0.65, 0.42, 0.08))
		draw_circle(Vector2(size.x * 0.84, size.y * 0.82), maxf(size.x, size.y) * 0.30, Color(0.72, 0.58, 0.38, 0.08))
	var reveal := not _highlights.is_empty() or bool(_scene.get("reveal_mode", false))
	var response := str(_scene.get("interaction_phase", "presentation")) == "response"
	var mode := str(_scene.get("mode", "side_by_side"))
	if mode == "sequential" and not reveal and not response:
		_draw_title_band("WATCH FOR THE CHANGE")
		var margin: float = size.x * 0.035
		var panel_rect := Rect2(margin, size.y * 0.08, size.x - margin * 2.0, size.y * 0.88)
		var state_duration := maxf(float(_scene.get("state_duration", 2.5)), 0.1)
		var showing_first := _elapsed < state_duration
		_draw_panel(panel_rect, _scene.get("objects_a", []) if showing_first else _scene.get("objects_b", []), "FIRST" if showing_first else "SECOND")
		return
	_draw_paired(reveal)

func _draw_paired(reveal: bool) -> void:
	_draw_title_band("SPOT THE DIFFERENCE" if not reveal else "CHANGE REVEALED")
	var panel_gap: float = size.x * 0.025
	var panel_width: float = (size.x - panel_gap * 3.0) * 0.5
	var top: float = size.y * 0.08
	var panel_height: float = size.y * 0.88
	var rect_a := Rect2(panel_gap, top, panel_width, panel_height)
	var rect_b := Rect2(panel_gap * 2.0 + panel_width, top, panel_width, panel_height)
	_draw_panel(rect_a, _scene.get("objects_a", []), "A")
	_draw_panel(rect_b, _scene.get("objects_b", []), "B")
	if reveal:
		_draw_reveal_regions()

func _draw_title_band(text: String) -> void:
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var title_color := Color.WHITE if high_contrast else Color("#F5F3FA")
	var accent := Color.WHITE if high_contrast else _style.accent_color(_family_id)
	var band := Rect2(size.x * 0.08, size.y * 0.018, size.x * 0.84, maxf(30.0, size.y * 0.045))
	draw_rect(band, Color(0, 0, 0, 0.28), true)
	draw_line(Vector2(band.position.x, band.end.y), Vector2(band.end.x, band.end.y), Color(accent, 0.72), 2.0)
	draw_string(ThemeDB.fallback_font, band.position + Vector2(0, band.size.y * 0.68), text, HORIZONTAL_ALIGNMENT_CENTER, band.size.x, 18, title_color)

func _draw_panel(rect: Rect2, objects_value: Variant, label: String) -> void:
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var template_id := str(_scene.get("template_id", ""))
	# Use grounded palette for panel backgrounds
	var palette := _style.ground_background(template_id, _scene.get("theme", {}))
	var background := Color.WHITE if high_contrast else Color(str(palette.get("top", "#B0B8BF")))
	var surface := Color("#D8D8D8") if high_contrast else Color(str(palette.get("surface", "#8B7355")))
	var border := Color.BLACK if high_contrast else Color(str(palette.get("line", "#5C4A3D")))
	var accent := Color.BLACK if high_contrast else _style.accent_color(_family_id)
	draw_rect(Rect2(rect.position + Vector2(0, 6), rect.size), Color(0, 0, 0, 0.28), true)
	draw_rect(rect, background, true)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y * 0.78), Vector2(rect.size.x, rect.size.y * 0.22)), surface, true)
	draw_rect(rect, border, false, 3.0)
	draw_rect(rect.grow(4.0), Color(accent, 0.18), false, 2.0)
	_draw_panel_texture(rect, accent)
	var pill := Rect2(rect.position + Vector2(10, 10), Vector2(76, 28))
	draw_rect(pill, Color(accent, 0.22), true)
	draw_string(ThemeDB.fallback_font, pill.position + Vector2(0, 20), label, HORIZONTAL_ALIGNMENT_CENTER, pill.size.x, 17, border)
	if not (objects_value is Array):
		return
	for value: Variant in objects_value:
		if value is Dictionary:
			_draw_object(rect, value as Dictionary)

func _draw_panel_texture(rect: Rect2, accent: Color) -> void:
	var texture_color := Color(accent, 0.12)
	for column: int in range(1, 4):
		var x := rect.position.x + rect.size.x * float(column) / 4.0
		draw_line(Vector2(x, rect.position.y + rect.size.y * 0.08), Vector2(x, rect.end.y - rect.size.y * 0.06), texture_color, 1.0)
	for row: int in range(1, 4):
		var y := rect.position.y + rect.size.y * float(row) / 4.0
		draw_line(Vector2(rect.position.x + rect.size.x * 0.05, y), Vector2(rect.end.x - rect.size.x * 0.05, y), texture_color, 1.0)

func _draw_object(panel: Rect2, data: Dictionary) -> void:
	var center := panel.position + Vector2(float(data.get("x", 0.5)) * panel.size.x, float(data.get("y", 0.5)) * panel.size.y)
	var object_size := Vector2(float(data.get("w", 0.14)) * panel.size.x, float(data.get("h", 0.14)) * panel.size.y)
	var color := Color(str(data.get("color", "#5B7FD0")))
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var outline := Color.BLACK if high_contrast else Color("#292631")
	var kind := str(data.get("kind", "box"))

	# Draw grounding shadow under object
	if not high_contrast:
		_style.draw_shadow(self, center, object_size, size)

	# ── ASSET PIPELINE: try sprite texture first ──
	var rotation_rad := deg_to_rad(float(data.get("rotation", 0.0)))
	if _style.has_sprite(kind):
		draw_set_transform(center, rotation_rad, Vector2.ONE)
		var sprite_rect := Rect2(-object_size * 0.5, object_size)
		_style.draw_sprite_object(self, kind, sprite_rect)
		if high_contrast:
			draw_rect(sprite_rect.grow(4.0), Color.BLACK, false, 3.0)
		if int(data.get("state", 0)) == 1:
			var extent := minf(object_size.x, object_size.y) * 0.44
			draw_circle(Vector2.ZERO, maxf(5.0, extent * 0.24), Color("#FFF7DB"))
			draw_arc(Vector2.ZERO, maxf(5.0, extent * 0.24), 0, TAU, 16, outline, 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	# ── VECTOR FALLBACK: original rendering for kinds without sprites ──

	draw_set_transform(center, rotation_rad, Vector2.ONE)
	var rect := Rect2(-object_size * 0.5, object_size)
	var extent := minf(object_size.x, object_size.y) * 0.44
	match kind:
		"circle", "clock", "compass", "ring", "button":
			draw_circle(Vector2.ZERO, extent, color, kind != "ring")
			draw_arc(Vector2.ZERO, extent, 0, TAU, 20, outline, 2.0)
			if kind in ["clock", "compass"]:
				draw_line(Vector2.ZERO, Vector2(0, -extent * 0.62), outline, 2.0)
		"star", "flower":
			var points := PackedVector2Array()
			var count: int = 10 if kind == "star" else 12
			for index: int in range(count):
				var radius := extent if index % 2 == 0 else extent * 0.48
				points.append(Vector2.UP.rotated(TAU * float(index) / float(count)) * radius)
			draw_colored_polygon(points, color)
		"diamond", "leaf", "shell", "kite", "gem", "acorn":
			draw_colored_polygon(PackedVector2Array([Vector2(0,-extent),Vector2(extent,0),Vector2(0,extent),Vector2(-extent,0)]), color)
			draw_line(Vector2(0, -extent * 0.65), Vector2(0, extent * 0.65), outline, 2.0)
		"cup", "bottle", "vase", "pill", "candle", "bell":
			draw_rect(rect.grow(-object_size.x * 0.18), color, true)
			draw_rect(rect.grow(-object_size.x * 0.18), outline, false, 2.0)
			if kind == "cup":
				draw_arc(Vector2(rect.end.x - object_size.x * 0.08, 0), extent * 0.34, -PI * 0.5, PI * 0.5, 12, outline, 3.0)
		"line", "key", "comb", "scissors":
			draw_line(Vector2(-object_size.x * 0.46, 0), Vector2(object_size.x * 0.46, 0), outline, maxf(6.0, object_size.y * 0.20))
			draw_line(Vector2(-object_size.x * 0.46, 0), Vector2(object_size.x * 0.46, 0), color, maxf(3.0, object_size.y * 0.10))
			if kind == "key":
				draw_circle(Vector2(-object_size.x * 0.36, 0), extent * 0.32, color, false, 3.0)
		"glasses":
			draw_circle(Vector2(-extent * 0.55, 0), extent * 0.48, color, false, 3.0)
			draw_circle(Vector2(extent * 0.55, 0), extent * 0.48, color, false, 3.0)
			draw_line(Vector2(-extent * 0.08, 0), Vector2(extent * 0.08, 0), outline, 2.0)
		"plant":
			draw_rect(Rect2(-extent * 0.45, extent * 0.15, extent * 0.90, extent * 0.72), Color("#A98768"), true)
			for offset: Vector2 in [Vector2(-0.42,-0.20),Vector2(0,-0.52),Vector2(0.42,-0.18)]:
				draw_circle(offset * extent, extent * 0.40, color)
		"moon":
			draw_circle(Vector2.ZERO, extent, color)
			draw_circle(Vector2(extent * 0.42, -extent * 0.10), extent * 0.82, Color("#EEE9DE"))
		"cloud":
			for offset: Vector2 in [Vector2(-0.46,0.12),Vector2(0,-0.18),Vector2(0.46,0.12)]:
				draw_circle(offset * extent, extent * 0.56, color)
		"camera":
			draw_rect(rect, color, true)
			draw_rect(rect, outline, false, 2.0)
			draw_circle(Vector2.ZERO, extent * 0.48, Color("#E5E0D8"))
			draw_arc(Vector2.ZERO, extent * 0.48, 0, TAU, 18, outline, 2.0)
		"umbrella", "boat", "hat", "glove", "boot", "anchor", "ribbon", "magnet", "basket", "drum", "flag":
			draw_colored_polygon(PackedVector2Array([Vector2(0,-extent),Vector2(extent,extent*0.58),Vector2(0,extent*0.34),Vector2(-extent,extent*0.58)]), color)
			draw_polyline(PackedVector2Array([Vector2(0,-extent),Vector2(extent,extent*0.58),Vector2(0,extent*0.34),Vector2(-extent,extent*0.58),Vector2(0,-extent)]), outline, 2.0)
		_:
			_draw_curio_shape(rect, color, outline)
	if high_contrast:
		draw_rect(rect.grow(4.0), Color.BLACK, false, 3.0)
	if int(data.get("state", 0)) == 1:
		draw_circle(Vector2.ZERO, maxf(5.0, extent * 0.24), Color("#FFF7DB"))
		draw_arc(Vector2.ZERO, maxf(5.0, extent * 0.24), 0, TAU, 16, outline, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_curio_shape(rect: Rect2, color: Color, outline: Color) -> void:
	var center := rect.get_center()
	var extent := minf(rect.size.x, rect.size.y) * 0.44
	var points := PackedVector2Array([
		center + Vector2(0, -extent),
		center + Vector2(extent * 0.78, -extent * 0.16),
		center + Vector2(extent * 0.48, extent * 0.82),
		center + Vector2(-extent * 0.48, extent * 0.82),
		center + Vector2(-extent * 0.78, -extent * 0.16),
	])
	draw_colored_polygon(points, color)
	var outline_points := PackedVector2Array(points)
	outline_points.append(points[0])
	draw_polyline(outline_points, outline, 2.0)
	draw_circle(center, extent * 0.30, Color("#FFF7DB"), false, 2.0)
	draw_line(center + Vector2(-extent * 0.18, 0), center + Vector2(extent * 0.18, 0), outline, 2.0)

func _draw_reveal_regions() -> void:
	var pulse := 0.72 + 0.28 * sin(_elapsed * 4.5)
	var accent := _style.accent_color(_family_id)
	for value: Variant in _scene.get("target_regions", []):
		if value is Dictionary:
			var region: Dictionary = value
			var region_rect := Rect2(
				float(region.get("x", 0.0)) * size.x,
				float(region.get("y", 0.0)) * size.y,
				float(region.get("w", 0.1)) * size.x,
				float(region.get("h", 0.1)) * size.y
			)
			draw_rect(region_rect.grow(4.0 + pulse * 3.0), Color(accent, pulse), false, 5.0)
