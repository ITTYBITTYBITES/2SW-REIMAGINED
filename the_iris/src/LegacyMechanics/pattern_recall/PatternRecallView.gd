extends Control
class_name PatternRecallView
## Discrete pattern presentation and complete numbered evidence reveal.
##
## Asset pipeline: uses VisualStyleSystem to render sprite textures for known
## symbol kinds, with full vector fallback for kinds without assets yet.

var _scene: Dictionary = {}
var _elapsed: float = 0.0
var _highlights: Array[String] = []
var _last_step: int = -1
var _style: VisualStyleSystem
var _family_id: String = "pattern_recall"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_style = VisualStyleSystem.new()
	_style.scan_assets()
	set_process(not _scene.is_empty() and _highlights.is_empty())
	_setup_background()

func _setup_background() -> void:
	var bg_path: String = "res://assets/gameplay/pattern_recall/background.png"
	if ResourceLoader.exists(bg_path):
		var bg := TextureRect.new()
		bg.name = "Background"
		bg.texture = load(bg_path)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.modulate = Color(0.34, 0.43, 0.54, 0.52)
		bg.show_behind_parent = true
		add_child(bg)
	else:
		pass

func set_scene_data(data: Dictionary, highlight_ids: Array = []) -> void:
	_scene = data.duplicate(true)
	_elapsed = 0.0
	_last_step = -1
	_highlights.clear()
	for value: Variant in highlight_ids:
		_highlights.append(str(value))
	set_process(_highlights.is_empty() and not bool(_scene.get("reveal_mode", false)))
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var sequence_value: Variant = _scene.get("sequence", [])
	var sequence: Array = sequence_value if sequence_value is Array else []
	if not sequence.is_empty():
		var interval := maxf(float(_scene.get("interval", 0.8)), 0.15)
		var step := mini(int(_elapsed / interval), sequence.size() - 1)
		if step != _last_step:
			_last_step = step
			if AudioService:
				AudioService.play_sfx("pattern_step", 0.28)
	queue_redraw()

func _draw() -> void:
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	# Background is now handled by TextureRect
	if high_contrast:
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK, true)
	var sequence_value: Variant = _scene.get("sequence", [])
	var sequence: Array = sequence_value if sequence_value is Array else []
	if sequence.is_empty():
		return
	var reveal := not _highlights.is_empty() or bool(_scene.get("reveal_mode", false))
	var mode := str(_scene.get("mode", "grid"))
	if reveal:
		_draw_reveal(sequence, mode)
	elif mode == "shapes":
		_draw_shape_presentation(sequence)
	else:
		_draw_grid_presentation(sequence)

func _draw_grid_presentation(sequence: Array) -> void:
	var grid_size := int(_scene.get("grid_size", 3))
	var geometry := _grid_geometry(grid_size)
	var origin: Vector2 = geometry.origin
	var cell: float = float(geometry.cell)
	var interval := maxf(float(_scene.get("interval", 0.8)), 0.15)
	var index := mini(int(_elapsed / interval), sequence.size() - 1)
	var style := str(_scene.get("presentation_style", "single_step"))
	var revealed_tokens: Array[String] = []
	if style == "cumulative_build":
		for step: int in range(index + 1):
			revealed_tokens.append(str(sequence[step]))
	for row: int in range(grid_size):
		for column: int in range(grid_size):
			var token := "%s%d" % [char(65 + row), column + 1]
			var cell_rect := Rect2(origin + Vector2(column * cell, row * cell), Vector2(cell, cell)).grow(-6.0)
			var active := token == str(sequence[index])
			var accumulated := revealed_tokens.has(token)
			var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
			
			# Grounded palette: warm earth tones replace purple blueprint
			var accent := _style.accent_color(_family_id)
			var fill := Color("#BFAEFF") if active and high_contrast else Color(accent) if active else Color("#5B2CCB") if accumulated and high_contrast else Color("#6B5D4F") if accumulated else Color("#111111") if high_contrast else Color("#3D3630")
			draw_rect(cell_rect, fill, true)
			draw_rect(cell_rect, Color.WHITE if high_contrast else Color(accent, 0.72), false, 2.0 if high_contrast else 1.5)
			
			var text_color := Color.WHITE if not active else Color("#FDFCFB")
			draw_string(ThemeDB.fallback_font, cell_rect.position + Vector2(0, cell_rect.size.y * 0.64), token, HORIZONTAL_ALIGNMENT_CENTER, cell_rect.size.x, 18, text_color)
	if style == "cumulative_build" and index > 0:
		var points := PackedVector2Array()
		for step: int in range(index + 1):
			points.append(_token_center(str(sequence[step]), grid_size, origin, cell))
		var accent := _style.accent_color(_family_id)
		draw_polyline(points, Color(accent), 4.0)
	_draw_step_counter(index + 1, sequence.size())

func _draw_shape_presentation(sequence: Array) -> void:
	var interval := maxf(float(_scene.get("interval", 0.8)), 0.15)
	var index := mini(int(_elapsed / interval), sequence.size() - 1)
	var token := str(sequence[index])
	var panel := Rect2(size.x * 0.10, size.y * 0.10, size.x * 0.80, size.y * 0.76)
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	draw_rect(panel, Color("#111111") if high_contrast else Color("#3D3630"), true)
	var accent := _style.accent_color(_family_id)
	draw_rect(panel, Color.WHITE if high_contrast else Color(accent, 0.55), false, 4.0 if high_contrast else 3.0)
	_draw_symbol(panel.get_center(), minf(panel.size.x, panel.size.y) * 0.28, token, Color(accent) if not high_contrast else Color("#BFAEFF"))
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(0, panel.size.y - 28), token, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 22, Color("#F5F3FA"))
	_draw_step_counter(index + 1, sequence.size())

func _draw_reveal(sequence: Array, mode: String) -> void:
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var accent := _style.accent_color(_family_id)
	draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.10, size.y * 0.09), "THE PATTERN, IN ORDER", HORIZONTAL_ALIGNMENT_CENTER, size.x * 0.80, 18, Color(accent, 0.85))
	if mode == "shapes":
		var columns: int = mini(sequence.size(), 3)
		var rows: int = ceili(float(sequence.size()) / float(columns))
		var card_width: float = size.x * 0.80 / float(columns)
		var card_height: float = size.y * 0.68 / float(rows)
		for index: int in range(sequence.size()):
			var row: int = floori(float(index) / float(columns))
			var column: int = index % columns
			var card := Rect2(size.x * 0.10 + column * card_width, size.y * 0.16 + row * card_height, card_width, card_height).grow(-7.0)
			draw_rect(card, Color("#111111") if high_contrast else Color("#3D3630"), true)
			draw_rect(card, Color.WHITE if high_contrast else Color(accent, 0.50), false, 3.0 if high_contrast else 2.0)
			_draw_symbol(card.get_center(), minf(card.size.x, card.size.y) * 0.24, str(sequence[index]), Color(accent))
			_draw_number_badge(card.position + Vector2(20, 20), index + 1)
			draw_string(ThemeDB.fallback_font, card.position + Vector2(4, card.size.y - 12), str(sequence[index]), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 8, 14, Color.WHITE)
		return
	var grid_size := int(_scene.get("grid_size", 3))
	var geometry := _grid_geometry(grid_size)
	var origin: Vector2 = geometry.origin
	var cell: float = float(geometry.cell)
	var points := PackedVector2Array()
	for token_value: Variant in sequence:
		points.append(_token_center(str(token_value), grid_size, origin, cell))
	if points.size() > 1:
		draw_polyline(points, Color(accent, 0.82), 7.0)
	for row: int in range(grid_size):
		for column: int in range(grid_size):
			var token := "%s%d" % [char(65 + row), column + 1]
			var cell_rect := Rect2(origin + Vector2(column * cell, row * cell), Vector2(cell, cell)).grow(-6.0)
			var sequence_index: int = sequence.find(token)
			draw_rect(cell_rect, Color("#352254") if sequence_index >= 0 and high_contrast else Color("#6B5D4F") if sequence_index >= 0 else Color("#111111") if high_contrast else Color("#2A2520"), true)
			draw_rect(cell_rect, Color.WHITE if high_contrast else Color(accent, 0.48), false, 3.0 if high_contrast else 2.0)
			draw_string(ThemeDB.fallback_font, cell_rect.position + Vector2(0, cell_rect.size.y * 0.64), token, HORIZONTAL_ALIGNMENT_CENTER, cell_rect.size.x, 18, Color.WHITE)
			if sequence_index >= 0:
				_draw_number_badge(cell_rect.position + Vector2(20, 20), sequence_index + 1)

func _grid_geometry(grid_size: int) -> Dictionary:
	var side: float = minf(size.x * 0.88, size.y * 0.82)
	return {
		"origin": Vector2((size.x - side) / 2.0, (size.y - side) / 2.0),
		"cell": side / float(grid_size)
	}

func _token_center(token: String, grid_size: int, origin: Vector2, cell: float) -> Vector2:
	if token.length() < 2:
		return origin
	var row := clampi(token.unicode_at(0) - 65, 0, grid_size - 1)
	var column := clampi(int(token.substr(1)) - 1, 0, grid_size - 1)
	return origin + Vector2((float(column) + 0.5) * cell, (float(row) + 0.5) * cell)

func _draw_step_counter(current: int, total: int) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.10, size.y * 0.95), "STEP %d OF %d" % [current, total], HORIZONTAL_ALIGNMENT_CENTER, size.x * 0.80, 17, Color("#D3CCE8"))

func _draw_number_badge(center: Vector2, number: int) -> void:
	var accent := _style.accent_color(_family_id)
	draw_circle(center, 16.0, accent)
	draw_string(ThemeDB.fallback_font, center + Vector2(-12, 6), str(number), HORIZONTAL_ALIGNMENT_CENTER, 24.0, 14, Color("#191720"))

func _draw_symbol(center: Vector2, extent: float, token: String, color: Color) -> void:
	# ── ASSET PIPELINE: try sprite texture first ──
	if _style.has_sprite(token):
		var symbol_size := Vector2(extent * 2.0, extent * 2.0)
		var symbol_rect := Rect2(center - symbol_size * 0.5, symbol_size)
		if _style.draw_sprite_object(self, token, symbol_rect):
			return

	# ── VECTOR FALLBACK ──
	var outline := Color("#F5F3FA")
	match token:
		"Circle":
			draw_circle(center, extent, color)
		"Triangle":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -extent), center + Vector2(extent, extent), center + Vector2(-extent, extent)]), color)
		"Square":
			draw_rect(Rect2(center - Vector2(extent, extent), Vector2(extent * 2, extent * 2)), color, true)
		"Diamond":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -extent), center + Vector2(extent, 0), center + Vector2(0, extent), center + Vector2(-extent, 0)]), color)
		"Plus":
			draw_line(center + Vector2(-extent, 0), center + Vector2(extent, 0), color, extent * 0.42)
			draw_line(center + Vector2(0, -extent), center + Vector2(0, extent), color, extent * 0.42)
		"Star":
			var points := PackedVector2Array()
			for index: int in range(10):
				var radius := extent if index % 2 == 0 else extent * 0.45
				points.append(center + Vector2.UP.rotated(TAU * float(index) / 10.0) * radius)
			draw_colored_polygon(points, color)
		"Ring":
			draw_arc(center, extent, 0, TAU, 32, color, extent * 0.28)
		"Cross":
			draw_line(center + Vector2(-extent * 0.72, -extent * 0.72), center + Vector2(extent * 0.72, extent * 0.72), color, extent * 0.30)
			draw_line(center + Vector2(extent * 0.72, -extent * 0.72), center + Vector2(-extent * 0.72, extent * 0.72), color, extent * 0.30)
		"Hexagon":
			var points := PackedVector2Array()
			for index: int in range(6):
				points.append(center + Vector2.UP.rotated(TAU * float(index) / 6.0) * extent)
			draw_colored_polygon(points, color)
		"Wave":
			var points := PackedVector2Array()
			for index: int in range(17):
				var x := lerpf(-extent, extent, float(index) / 16.0)
				points.append(center + Vector2(x, sin(float(index) / 16.0 * TAU) * extent * 0.42))
			draw_polyline(points, color, extent * 0.22)
		"Bars":
			for offset: float in [-0.55, 0.0, 0.55]:
				draw_line(center + Vector2(extent * offset, -extent), center + Vector2(extent * offset, extent), color, extent * 0.24)
		"Arc":
			draw_arc(center, extent, PI, TAU, 24, color, extent * 0.28)
		_:
			draw_circle(center, extent, color)
	draw_circle(center, extent + 4.0, Color(outline, 0.32), false, 2.0)
