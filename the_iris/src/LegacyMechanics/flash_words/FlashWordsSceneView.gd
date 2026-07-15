extends Control
class_name FlashWordsSceneView
## Family typography renderer for observation sequences and result comparison.
##
## Asset pipeline: Flash Words is text-only, so no sprite rendering is needed.
## The grounded-realistic migration updates the background palette and decorative
## accents from purple/cartoon to warm earth tones.

var _scene_data: Dictionary = {}
var _elapsed: float = 0.0
var _last_index: int = -2
var _word_card: PanelContainer
var _word_label: Label
var _detail_label: Label
var _position_label: Label
var _style: VisualStyleSystem
var _family_id: String = "flash_words"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not resized.is_connected(_on_resized):
		resized.connect(_on_resized)
	_style = VisualStyleSystem.new()
	_build_ui()
	_apply_scene()
	queue_redraw()

func set_scene_data(scene_data: Dictionary, _highlight_ids: Array = []) -> void:
	_scene_data = scene_data.duplicate(true)
	_elapsed = 0.0
	_last_index = -2
	if is_inside_tree():
		_build_ui()
		_apply_scene()

func _build_ui() -> void:
	if _word_label:
		return
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	_word_card = PanelContainer.new()
	_word_card.name = "FlashWordFocusField"
	_word_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.content_margin_left = 8
	focus_style.content_margin_right = 8
	focus_style.content_margin_top = 8
	focus_style.content_margin_bottom = 8
	_word_card.add_theme_stylebox_override("panel", focus_style)
	stack.add_child(_word_card)
	_word_label = Label.new()
	_word_label.custom_minimum_size = Vector2(0, 176)
	_word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_word_label.add_theme_color_override("font_color", Color("#F5F3FA"))
	_word_label.add_theme_color_override("font_shadow_color", Color(0.78, 0.66, 0.42, 0.75))
	_word_label.add_theme_constant_override("shadow_offset_x", 0)
	_word_label.add_theme_constant_override("shadow_offset_y", 3)
	_word_card.add_child(_word_label)
	_detail_label = Label.new()
	_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_color_override("font_color", Color("#C8BFB0"))
	_detail_label.add_theme_font_size_override("font_size", 22)
	stack.add_child(_detail_label)
	_position_label = Label.new()
	_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var accent := _style.accent_color(_family_id) if _style else Color("#C8A96E")
	_position_label.add_theme_color_override("font_color", accent)
	_position_label.add_theme_font_size_override("font_size", 18)
	stack.add_child(_position_label)

func _on_resized() -> void:
	_update_word_size()
	queue_redraw()

func _draw() -> void:
	var canvas_rect := Rect2(Vector2.ZERO, size)
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	# Grounded warm dark canvas replacing old dark purple
	var bg_color := Color.BLACK if high_contrast else (_style.canvas_background(_family_id) if _style else Color("#2A2520"))
	draw_rect(canvas_rect, bg_color, true)
	if high_contrast:
		return
	# Subtle warm ambient glow replacing old purple/orange blobs
	var warm_glow := Color(0.78, 0.65, 0.42, 0.12)
	draw_circle(Vector2(size.x * 0.18, size.y * 0.20), maxf(size.x, size.y) * 0.24, warm_glow)
	draw_circle(Vector2(size.x * 0.86, size.y * 0.78), maxf(size.x, size.y) * 0.30, Color(0.72, 0.58, 0.38, 0.08))
	# Faint horizontal texture lines in warm tone
	for i in range(5):
		var y := size.y * (0.18 + float(i) * 0.15)
		draw_line(Vector2(size.x * 0.08, y), Vector2(size.x * 0.92, y + size.y * 0.04), Color(0.78, 0.68, 0.52, 0.04), 2.0)

func _apply_scene() -> void:
	if not _word_label:
		return
	_update_word_size()
	if bool(_scene_data.get("reveal_mode", false)):
		set_process(false)
		_word_label.text = str(_scene_data.get("correct_display", ""))
		_detail_label.text = "You selected: %s\nCorrect: %s\nDifference: %s" % [
			_scene_data.get("player_display", "—"),
			_scene_data.get("correct_display", "—"),
			_scene_data.get("difference", "Exact match")
		]
		_position_label.text = "REVEAL"
		# ResultScreen owns the single outcome cue so family reveals do not layer
		# a second success/failure sound over it.
		# Animate the reveal: a soft scale-in on the word card.
		if _word_card and not (AccessibilityService and not AccessibilityService.should_animate()):
			_word_card.scale = Vector2(0.85, 0.85)
			_word_card.modulate = Color(1, 1, 1, 0)
			var tween := _word_card.create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(_word_card, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(_word_card, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		return
	_detail_label.text = ""
	_position_label.text = ""
	set_process(true)
	_update_sequence()

func _update_word_size() -> void:
	if not _word_label:
		return
	var reading_comfort := bool(_scene_data.get("reading_comfort_mode", false))
	var target_size: float = 118.0 if reading_comfort else 102.0
	var longest: int = 1
	var words_value: Variant = _scene_data.get("words", [])
	if words_value is Array:
		for value: Variant in words_value:
			longest = maxi(longest, str(value).length())
	longest = maxi(longest, str(_scene_data.get("correct_display", "")).length())
	var available_width := maxf(size.x - 40.0, 240.0)
	var fitted_size := available_width / maxf(float(longest) * 0.58, 1.0)
	_word_label.add_theme_font_size_override(
		"font_size", int(round(clampf(minf(target_size, fitted_size), 46.0, target_size)))
	)

func _process(delta: float) -> void:
	_elapsed += delta
	_update_sequence()

func _update_sequence() -> void:
	if not _word_label or bool(_scene_data.get("reveal_mode", false)):
		return
	var words_value: Variant = _scene_data.get("words", [])
	if not (words_value is Array):
		_word_label.text = ""
		return
	var words: Array = words_value
	var display := maxf(float(_scene_data.get("display_duration", 1.0)), 0.05)
	var interval := maxf(float(_scene_data.get("inter_word_interval", 0.0)), 0.0)
	var span := display + interval
	var index := int(floor(_elapsed / span))
	var local_time := fmod(_elapsed, span)
	if index >= words.size():
		_word_label.text = ""
		_position_label.text = ""
		return
	var showing_word := local_time <= display
	_word_label.text = str(words[index]) if showing_word else ""
	_position_label.text = "%d / %d" % [index + 1, words.size()] if words.size() > 1 else ""
	if showing_word and index != _last_index:
		_last_index = index
		if _word_card:
			_word_card.scale = Vector2(0.985, 0.985)
			if not (AccessibilityService and not AccessibilityService.should_animate()):
				var tween := _word_card.create_tween()
				tween.tween_property(_word_card, "scale", Vector2.ONE, 0.10).set_ease(Tween.EASE_OUT)
		if AudioService:
			AudioService.play_sfx("flash_pulse", 0.45)
