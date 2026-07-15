extends Control
class_name ObjectRecallView
## Illustrated, label-reinforced object tray with explicit result evidence.
##
## Asset pipeline: uses VisualStyleSystem to render sprite textures for known
## visual_kinds, with full vector fallback for kinds without assets yet.

var _scene: Dictionary = {}
var _highlights: Array[String] = []
var _reveal_elapsed: float = 0.0
var _style: VisualStyleSystem
var _family_id: String = "object_recall"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(false)
	_style = VisualStyleSystem.new()
	_style.scan_assets()
	_setup_background()

func _setup_background() -> void:
	var bg_path: String = "res://assets/gameplay/object_recall/background.png"
	if ResourceLoader.exists(bg_path):
		var bg := TextureRect.new()
		bg.name = "Background"
		bg.texture = load(bg_path)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.show_behind_parent = true
		add_child(bg)
	else:
		# Fallback is already in _draw
		pass

func set_scene_data(data: Dictionary, highlight_ids: Array = []) -> void:
	_scene = data.duplicate(true)
	_highlights.clear()
	for value: Variant in highlight_ids:
		_highlights.append(str(value))
	_reveal_elapsed = 0.0
	var animate: bool = not _highlights.is_empty()
	if AccessibilityService and not AccessibilityService.should_animate():
		animate = false
	set_process(animate)
	if _highlights.is_empty() and AudioService:
		AudioService.play_sfx("object_settle", 0.20)
	queue_redraw()

func _process(delta: float) -> void:
	_reveal_elapsed += delta
	queue_redraw()

func _draw() -> void:
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	# Background is now handled by TextureRect
	if high_contrast:
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK, true)
		
	var reveal: bool = not _highlights.is_empty() or bool(_scene.get("reveal_mode", false))
	var missing_evidence := _missing_evidence()
	var tray_bottom: float = 0.72 if reveal and not missing_evidence.is_empty() else 0.93
	var tray := Rect2(size.x * 0.035, size.y * 0.09, size.x * 0.93, size.y * (tray_bottom - 0.09))

	# The tabletop is the environment. A quiet focus boundary replaces the old
	# white tray card while preserving contrast and spatial relationships.
	if high_contrast:
		draw_rect(tray, Color.BLACK, true)
		draw_rect(tray, Color.WHITE, false, 3.0)
	else:
		draw_rect(tray, Color(0.03, 0.02, 0.03, 0.18), true)
		var accent := _style.accent_color(_family_id)
		draw_rect(tray, Color(accent, 0.34), false, 2.0)

	var header := "EVIDENCE" if reveal else "REMEMBER THE SET"
	var header_color := Color.WHITE if high_contrast else Color("#F4E6CF")
	var font_size := ThemeService.get_font_size("label") if ThemeService else 16

	draw_string(
		ThemeDB.fallback_font,
		Vector2(tray.position.x, size.y * 0.058),
		header,
		HORIZONTAL_ALIGNMENT_CENTER,
		tray.size.x,
		font_size,
		header_color
	)
	for value: Variant in _scene.get("objects", []):
		if value is Dictionary:
			_draw_object(tray, value as Dictionary, true)
	if reveal and not missing_evidence.is_empty():
		_draw_missing_evidence(missing_evidence)

func _draw_object(tray: Rect2, data: Dictionary, use_position: bool) -> void:
	var center: Vector2
	if use_position:
		center = tray.position + Vector2(
			float(data.get("x", 0.5)) * tray.size.x,
			float(data.get("y", 0.5)) * tray.size.y
		)
	else:
		center = Vector2(float(data.get("draw_x", size.x * 0.5)), float(data.get("draw_y", size.y * 0.82)))
	var card_size := Vector2(
		clampf(tray.size.x * 0.18, 70.0, 132.0),
		clampf(tray.size.y * 0.28, 78.0, 138.0)
	)
	if not use_position:
		card_size = Vector2(clampf(size.x * 0.24, 90.0, 150.0), clampf(size.y * 0.18, 78.0, 120.0))
	var card := Rect2(center - card_size * 0.5, card_size)
	var selected := _is_highlighted(data)
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var pulse: float = 0.78 + 0.22 * sin(_reveal_elapsed * 5.0)
	var icon_center := card.position + Vector2(card.size.x * 0.5, card.size.y * 0.42)
	var icon_extent := minf(card.size.x, card.size.y) * 0.25

	# Objects sit directly in the environment. A soft halo preserves legibility
	# without turning every item into an independent UI card.
	if high_contrast:
		draw_rect(card, Color.WHITE, true)
		draw_rect(card, Color.BLACK, false, 2.0)
	else:
		draw_circle(icon_center, icon_extent * 1.55, Color(0.03, 0.02, 0.04, 0.72))
		var accent := _style.accent_color(_family_id)
		draw_arc(
			icon_center,
			icon_extent * 1.55,
			0,
			TAU,
			28,
			Color(accent, 0.24),
			1.5
		)
	if selected:
		var accent := _style.accent_color(_family_id)
		draw_rect(
			card.grow(4.0 + pulse * 2.0),
			Color(accent, pulse * 0.5),
			false,
			4.0
		)

	var kind := str(data.get("kind", "circle"))
	var kind_color := Color(str(data.get("color", "#5B7FD0")))

	# ── ASSET PIPELINE: try sprite texture first ──
	if _style.has_sprite(kind):
		var icon_size := Vector2(icon_extent * 2.0, icon_extent * 2.0)
		var sprite_rect := Rect2(icon_center - icon_size * 0.5, icon_size)
		# Draw shadow under sprite
		if not high_contrast:
			_style.draw_shadow(self, icon_center, icon_size, size)
		_style.draw_sprite_object(self, kind, sprite_rect)
	else:
		# ── VECTOR FALLBACK ──
		_draw_icon(icon_center, icon_extent, kind, kind_color)

	var label_text := str(data.get("label", "Object"))
	var label_color := Color.BLACK if high_contrast else Color("#FFF4E2")
	var label_size := ThemeService.get_font_size("caption") if ThemeService else 14

	draw_string(
		ThemeDB.fallback_font,
		card.position + Vector2(4.0, card.size.y - 11.0),
		label_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		card.size.x - 8.0,
		label_size,
		label_color
	)

func _draw_missing_evidence(items: Array[Dictionary]) -> void:
	var accent := _style.accent_color(_family_id)
	var band := Rect2(size.x * 0.05, size.y * 0.74, size.x * 0.90, size.y * 0.22)
	draw_rect(band, Color("#24212D"), true)
	draw_rect(band, accent, false, 3.0)
	draw_string(
		ThemeDB.fallback_font,
		band.position + Vector2(0, 22),
		"NOT SHOWN",
		HORIZONTAL_ALIGNMENT_CENTER,
		band.size.x,
		16,
		Color(accent, 0.85)
	)
	var spacing: float = band.size.x / float(items.size() + 1)
	for index: int in range(items.size()):
		var item: Dictionary = items[index].duplicate(true)
		item["draw_x"] = band.position.x + spacing * float(index + 1)
		item["draw_y"] = band.position.y + band.size.y * 0.62
		_draw_object(band, item, false)

func _missing_evidence() -> Array[Dictionary]:
	var visible_values: Dictionary = {}
	for value: Variant in _scene.get("objects", []):
		if value is Dictionary:
			visible_values[str((value as Dictionary).get("response_value", ""))] = true
	var output: Array[Dictionary] = []
	for value: Variant in _scene.get("option_objects", []):
		if value is Dictionary:
			var data: Dictionary = value
			var response_value := str(data.get("response_value", data.get("label", "")))
			if _highlights.has(response_value) and not visible_values.has(response_value):
				output.append(data)
	return output

func _is_highlighted(data: Dictionary) -> bool:
	return (
		_highlights.has(str(data.get("id", "")))
		or _highlights.has(str(data.get("response_value", data.get("label", ""))))
	)

func _draw_icon(center: Vector2, extent: float, kind: String, color: Color) -> void:
	var outline := Color("#292631")
	match kind:
		"star", "flower":
			var points := PackedVector2Array()
			var count: int = 10 if kind == "star" else 12
			for index: int in range(count):
				var radius: float = extent if index % 2 == 0 else extent * (0.44 if kind == "star" else 0.62)
				points.append(center + Vector2.UP.rotated(TAU * float(index) / float(count)) * radius)
			draw_colored_polygon(points, color)
			draw_polyline(points, outline, 2.0)
		"moon":
			draw_circle(center, extent, color)
			draw_circle(center + Vector2(extent * 0.45, -extent * 0.10), extent * 0.82, Color("#FFFDF8"))
		"leaf", "feather", "shell", "acorn", "pear":
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -extent),
				center + Vector2(extent * 0.76, 0),
				center + Vector2(0, extent),
				center + Vector2(-extent * 0.76, 0)
			]), color)
			draw_line(center + Vector2(0, -extent * 0.65), center + Vector2(0, extent * 0.75), outline, 2.0)
		"book", "folder", "map", "flag":
			var icon_rect := Rect2(center - Vector2(extent, extent * 0.72), Vector2(extent * 2.0, extent * 1.44))
			draw_rect(icon_rect, color, true)
			draw_rect(icon_rect, outline, false, 2.0)
			draw_line(Vector2(icon_rect.position.x + icon_rect.size.x * 0.24, icon_rect.position.y), Vector2(icon_rect.position.x + icon_rect.size.x * 0.24, icon_rect.end.y), outline, 2.0)
		"pencil", "brush", "spoon", "key", "comb", "scissors":
			draw_line(center + Vector2(-extent, extent * 0.35), center + Vector2(extent, -extent * 0.35), outline, 7.0)
			draw_line(center + Vector2(-extent, extent * 0.35), center + Vector2(extent, -extent * 0.35), color, 4.0)
			if kind == "key":
				draw_circle(center + Vector2(-extent * 0.78, extent * 0.27), extent * 0.24, color, false, 3.0)
		"glasses", "wheel", "watch", "clock", "compass", "ring":
			if kind == "glasses":
				draw_circle(center + Vector2(-extent * 0.52, 0), extent * 0.45, color, false, 4.0)
				draw_circle(center + Vector2(extent * 0.52, 0), extent * 0.45, color, false, 4.0)
				draw_line(center + Vector2(-extent * 0.08, 0), center + Vector2(extent * 0.08, 0), outline, 3.0)
			else:
				if kind in ["ring", "wheel"]:
					draw_circle(center, extent, color, false, 4.0)
				else:
					draw_circle(center, extent, color)
				draw_arc(center, extent, 0, TAU, 24, outline, 2.0)
				if kind in ["watch", "clock", "compass"]:
					draw_line(center, center + Vector2(0, -extent * 0.62), outline, 3.0)
		"cup", "mug", "bottle", "candle", "whistle", "bell":
			var body := Rect2(center - Vector2(extent * 0.62, extent * 0.72), Vector2(extent * 1.24, extent * 1.44))
			draw_rect(body, color, true)
			draw_rect(body, outline, false, 2.0)
			if kind in ["cup", "mug"]:
				draw_arc(center + Vector2(extent * 0.66, 0), extent * 0.32, -PI * 0.5, PI * 0.5, 12, outline, 3.0)
		"camera", "lamp", "magnet", "drum", "basket":
			var icon_rect := Rect2(center - Vector2(extent, extent * 0.66), Vector2(extent * 2.0, extent * 1.32))
			draw_rect(icon_rect, color, true)
			draw_rect(icon_rect, outline, false, 2.0)
			if kind == "camera":
				draw_circle(center, extent * 0.42, Color("#E9E3D7"))
				draw_arc(center, extent * 0.42, 0, TAU, 20, outline, 2.0)
		"anchor", "umbrella", "kite", "boat", "ribbon", "cloud", "hat", "glove", "boot":
			var points := PackedVector2Array([
				center + Vector2(0, -extent),
				center + Vector2(extent, extent * 0.62),
				center + Vector2(0, extent * 0.35),
				center + Vector2(-extent, extent * 0.62)
			])
			draw_colored_polygon(points, color)
			draw_polyline(points, outline, 2.0)
		_:
			draw_circle(center, extent, color)
			draw_arc(center, extent, 0, TAU, 24, outline, 2.0)
