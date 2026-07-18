extends Control
class_name IrisExpressionOverlay

## Lightweight visual and text consumer for derived IrisResponseIntent data.
## It does not own Iris state, input, routes, or sensory playback.
var active_intent: IrisResponseIntent
var elapsed := 0.0
var visual_amount := 0.0
var target_amount := 0.0
var home_environment := false
var message_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message_label = Label.new()
	message_label.position = Vector2(30, 132)
	message_label.size = Vector2(480, 28)
	message_label.add_theme_font_size_override("font_size", 11)
	message_label.add_theme_color_override("font_color", Color("#a8d8c9"))
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.modulate.a = 0.0
	add_child(message_label)

func present(intent: IrisResponseIntent) -> void:
	active_intent = intent
	elapsed = 0.0
	target_amount = 1.0
	message_label.text = _message_for(intent.text_key)
	message_label.visible = not home_environment and not message_label.text.is_empty()
	queue_redraw()

func set_home_environment(active: bool) -> void:
	home_environment = active
	message_label.visible = not active and active_intent != null and not message_label.text.is_empty()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if active_intent == null:
		return
	elapsed += delta
	target_amount = 1.0 if elapsed < _duration_for(active_intent.expression_mode) else 0.0
	visual_amount = lerpf(visual_amount, target_amount, minf(1.0, delta * 3.6))
	message_label.modulate.a = visual_amount * (0.88 if not home_environment else 0.0)
	if visual_amount < 0.01 and target_amount <= 0.0:
		message_label.visible = false
	queue_redraw()

func _draw() -> void:
	if active_intent == null or visual_amount <= 0.01 or size.x <= 0.0 or size.y <= 0.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.458)
	var radius := minf(size.x * 0.342, size.y * 0.192)
	var mode := active_intent.expression_mode
	var color := _color_for(mode)

	match mode:
		"INTRODUCING":
			var intro_radius := radius * (0.35 + minf(elapsed / 1.5, 1.0) * 1.08)
			draw_arc(center, intro_radius, 0.0, TAU, 48, Color(color, visual_amount * 0.28), 1.0, true)
		"CURIOUS":
			draw_arc(center, radius * 0.74, -0.8, 0.95, 32, Color(color, visual_amount * 0.36), 1.4, true)
		"ATTENTIVE":
			draw_arc(center, radius * 0.46, 0.0, TAU, 40, Color(color, visual_amount * 0.42), 1.5, true)
		"GUIDING":
			var guide_radius := radius * (0.56 + sin(elapsed * 6.0) * 0.025)
			draw_arc(center, guide_radius, -1.22, 0.48, 32, Color(color, visual_amount * 0.45), 1.6, true)
		"REFLECTIVE":
			for ring in range(2):
				var reflection_radius := radius * (0.56 + float(ring) * 0.19 + sin(elapsed * 0.8 + ring) * 0.018)
				draw_arc(center, reflection_radius, 0.0, TAU, 48, Color(color, visual_amount * (0.20 - float(ring) * 0.06)), 1.0, true)
		"IDLE":
			draw_arc(center, radius * 0.84, 1.8, 2.55, 20, Color(color, visual_amount * 0.10), 0.8, true)

func _duration_for(mode: String) -> float:
	match mode:
		"INTRODUCING": return 2.0
		"CURIOUS": return 0.8
		"ATTENTIVE": return 0.9
		"GUIDING": return 0.75
		"REFLECTIVE": return 2.0
		_: return 0.4

func _color_for(mode: String) -> Color:
	match mode:
		"INTRODUCING": return Color("#8de8c7")
		"CURIOUS": return Color("#9ef2cf")
		"ATTENTIVE": return Color("#c2ffe3")
		"GUIDING": return Color("#80d9c2")
		"REFLECTIVE": return Color("#d5c58f")
		_: return Color("#78bfb0")

func _message_for(text_key: String) -> String:
	if active_intent != null:
		match active_intent.source_event:
			"evolution_detected":
				return "The Iris pattern has evolved."
			"new_aperture_reached":
				return "New Aperture tier reached."
			"iris_pattern_changed":
				return "Aperture alignment adjusted."
			"chapter_restored":
				return "Chapter 01 is fully restored. The fractures are whole."
	
	match text_key:
		"iris_introducing_text": return "I am here."
		"iris_idle_text": return "The field is quiet."
		"iris_curious_text": return "Something has been noticed."
		"iris_attentive_text": return "Attention is held."
		"iris_guiding_text": return "Follow the memory."
		"iris_reflective_text": return "What was noticed remains."
	return ""
