extends Control
class_name GenericWitnessGameplay

## Fully data-driven Generic Witness Experience Flow.
## Loads any WitnessMomentDefinition dynamically to configure the entire gameplay loop.

enum Phase { BRIEFING, OBSERVATION, ANOMALY, CAPTURE, REVIEW, CONTEXT, RESOLUTION, REWARD }

signal completion_requested(result: WitnessMomentResult)
signal return_requested

var definition: WitnessMomentDefinition
var phase: Phase = Phase.BRIEFING

var observation_remaining := 0.0
var anomaly_missteps := 0
var capture_elapsed := 0.0
var capture_hold := 0.0
var capture_misses := 0
var capture_holding := false
var review_unlocked := false
var evidence_found: Dictionary = {}

var scene_image: TextureRect
var phase_label: Label
var title_label: Label
var body_label: Label
var timer_label: Label
var guidance_label: Label
var action_button: Button
var anomaly_button: Button
var capture_button: Button
var capture_progress: ProgressBar
var review_slider: HSlider
var review_legend: Label
var evidence_container: VBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var backdrop := ColorRect.new()
	backdrop.color = Color("#030a0d")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	scene_image = TextureRect.new()
	scene_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	scene_image.modulate = Color(0.68, 0.80, 0.74, 0.48)
	scene_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scene_image)

	var veil := ColorRect.new()
	veil.color = Color(0.002, 0.012, 0.016, 0.48)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	phase_label = _label("", 10, Color("#88cbb9"), Vector2(28, 30), Vector2(470, 20))
	title_label = _label("", 26, Color("#effff8"), Vector2(28, 55), Vector2(470, 44))
	body_label = _label("", 16, Color("#d3eee5"), Vector2(28, 108), Vector2(470, 90))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	timer_label = _label("", 12, Color("#b7ded1"), Vector2(28, 202), Vector2(470, 24), HORIZONTAL_ALIGNMENT_CENTER)
	guidance_label = _label("", 11, Color("#91c8b9"), Vector2(42, 654), Vector2(456, 22), HORIZONTAL_ALIGNMENT_CENTER)

	var panel := ColorRect.new()
	panel.position = Vector2(20, 630)
	panel.size = Vector2(500, 286)
	panel.color = Color(0.016, 0.084, 0.087, 0.94)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	action_button = _action_button()
	action_button.pressed.connect(_advance)

	evidence_container = VBoxContainer.new()
	evidence_container.position = Vector2(42, 684)
	evidence_container.size = Vector2(456, 132)
	evidence_container.add_theme_constant_override("separation", 8)
	add_child(evidence_container)

	anomaly_button = _round_button("", Vector2(350, 366), Vector2(94, 94))
	anomaly_button.pressed.connect(_find_anomaly)
	add_child(anomaly_button)

	capture_button = _action_button()
	capture_button.name = "HoldCapture"
	capture_button.text = "HOLD TO CATCH THE LIGHT"
	capture_button.button_down.connect(_begin_capture_hold)
	capture_button.button_up.connect(_end_capture_hold)
	add_child(capture_button)

	capture_progress = ProgressBar.new()
	capture_progress.position = Vector2(42, 798)
	capture_progress.size = Vector2(456, 18)
	capture_progress.show_percentage = false
	capture_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var progress_background := StyleBoxFlat.new()
	progress_background.bg_color = Color("#0d2929")
	progress_background.corner_radius_top_left = 7
	progress_background.corner_radius_top_right = 7
	progress_background.corner_radius_bottom_left = 7
	progress_background.corner_radius_bottom_right = 7
	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = Color("#8ee9c8")
	progress_fill.corner_radius_top_left = 7
	progress_fill.corner_radius_top_right = 7
	progress_fill.corner_radius_bottom_left = 7
	progress_fill.corner_radius_bottom_right = 7
	capture_progress.add_theme_stylebox_override("background", progress_background)
	capture_progress.add_theme_stylebox_override("fill", progress_fill)
	add_child(capture_progress)

	review_slider = HSlider.new()
	review_slider.name = "TruthTimeline"
	review_slider.position = Vector2(42, 744)
	review_slider.size = Vector2(456, 28)
	review_slider.min_value = 0.0
	review_slider.max_value = 2.0
	review_slider.step = 0.01
	review_slider.value_changed.connect(_review_changed)
	add_child(review_slider)
	review_legend = _label("BEFORE                 FRACTURE                 AFTER", 10, Color("#8cbcae"), Vector2(42, 778), Vector2(456, 18), HORIZONTAL_ALIGNMENT_CENTER)

## Start the generic loop using a validated WitnessMomentDefinition.
func start(value_definition: WitnessMomentDefinition) -> bool:
	if value_definition == null:
		return false
	definition = value_definition
	visible = true
	anomaly_missteps = 0
	capture_elapsed = 0.0
	capture_hold = 0.0
	capture_misses = 0
	capture_holding = false
	review_unlocked = false
	evidence_found.clear()
	_set_phase(Phase.BRIEFING)
	return true

func present_reward(award: Dictionary, profile: WitnessProfile) -> void:
	_set_phase(Phase.REWARD)
	var total := int(award.get("total", 0))
	body_label.text = "Truth restored.\n\n+%d Resonance\nAperture %d · %s\n\nYour Iris carried this pattern forward." % [total, profile.aperture_rank, profile.aperture_title]
	guidance_label.text = "THE MOMENT HOLDS."
	action_button.text = "RETURN TO IRIS HUB"
	action_button.visible = true

func close() -> void:
	visible = false
	evidence_found.clear()

func _process(delta: float) -> void:
	if not visible:
		return
	if phase == Phase.OBSERVATION:
		observation_remaining = maxf(0.0, observation_remaining - delta)
		timer_label.text = "WATCH  ·  %.1f" % observation_remaining
		if observation_remaining <= 0.0:
			_set_phase(Phase.ANOMALY)
	elif phase == Phase.CAPTURE:
		_update_capture(delta)

func _gui_input(event: InputEvent) -> void:
	if not visible or phase != Phase.ANOMALY:
		return
	if event is InputEventMouseButton and event.pressed and not anomaly_button.get_global_rect().has_point(event.position):
		anomaly_missteps += 1
		var misstep_text: String = definition.anomaly_definition.get("misstep_text", "Not there. Watch closely.")
		body_label.text = misstep_text
	elif event is InputEventScreenTouch and event.pressed and not anomaly_button.get_global_rect().has_point(event.position):
		anomaly_missteps += 1
		var misstep_text: String = definition.anomaly_definition.get("misstep_text", "Not there. Watch closely.")
		body_label.text = misstep_text

func _set_phase(next_phase: Phase) -> void:
	phase = next_phase
	anomaly_button.visible = false
	capture_button.visible = false
	capture_button.modulate = Color.WHITE
	capture_progress.visible = false
	review_slider.visible = false
	review_legend.visible = false
	evidence_container.visible = false
	action_button.visible = false
	timer_label.text = ""
	guidance_label.text = ""
	for child in evidence_container.get_children():
		child.queue_free()

	match phase:
		Phase.BRIEFING:
			scene_image.texture = load(definition.background_path)
			phase_label.text = "IRIS BRIEFING  ·  " + definition.moment_id
			title_label.text = definition.title
			body_label.text = definition.description
			guidance_label.text = "WATCH CAREFULLY."
			action_button.text = "BEGIN OBSERVATION"
			action_button.visible = true
		Phase.OBSERVATION:
			scene_image.texture = load(definition.action_path)
			phase_label.text = "OBSERVE"
			title_label.text = "Let the moment happen"
			body_label.text = "Watch without touching. The truth only stays for a short time."
			guidance_label.text = "LET THE MOMENT ARRIVE."
			observation_remaining = definition.observation_duration
		Phase.ANOMALY:
			scene_image.texture = load(definition.background_path)
			phase_label.text = "NOTICE"
			title_label.text = "What is different?"
			body_label.text = "Find the impossible detail."
			guidance_label.text = "SOMETHING IS NOT RIGHT."
			
			# Configure anomaly button dynamically based on contract location and size
			var loc: Dictionary = definition.anomaly_definition.get("location", {"x": 350.0, "y": 366.0})
			var sz: Dictionary = definition.anomaly_definition.get("size", {"x": 94.0, "y": 94.0})
			anomaly_button.position = Vector2(float(loc.get("x", 350.0)), float(loc.get("y", 366.0)))
			anomaly_button.size = Vector2(float(sz.get("x", 94.0)), float(sz.get("y", 94.0)))
			anomaly_button.visible = true
		Phase.CAPTURE:
			scene_image.texture = load(definition.action_path)
			phase_label.text = "CAPTURE"
			title_label.text = "Catch the exact truth"
			body_label.text = "Hold when the timeline fracture is active."
			guidance_label.text = definition.capture_window.get("guidance_text", "HOLD WHEN YOU SEE THE FRACTURE.")
			capture_elapsed = 0.0
			capture_hold = 0.0
			capture_holding = false
			capture_progress.value = 0.0
			capture_button.visible = true
			capture_progress.visible = true
		Phase.REVIEW:
			scene_image.texture = load(definition.action_path)
			phase_label.text = "REVIEW"
			title_label.text = "Move through the timeline"
			body_label.text = "Scrub to the exact instant of the anomaly."
			guidance_label.text = "FIND THE FRACTURE."
			review_slider.value = 0.0
			review_slider.visible = true
			review_legend.visible = true
		Phase.CONTEXT:
			scene_image.texture = load(definition.reveal_path)
			phase_label.text = "UNDERSTAND"
			title_label.text = "Gather the context"
			body_label.text = "Carry each piece of the truth to complete the memory."
			guidance_label.text = "THE CLUES EXPLAIN EACH OTHER."
			evidence_container.visible = true
			
			# Populate evidence buttons dynamically
			for node in definition.evidence_nodes:
				_add_evidence(node)
		Phase.RESOLUTION:
			scene_image.texture = load(definition.reveal_path)
			phase_label.text = "REVEAL"
			title_label.text = definition.title
			body_label.text = definition.resolution_text
			guidance_label.text = "YOU RESTORED THE ORDER OF THE MOMENT."
			action_button.text = "RESTORE THE TRUTH"
			action_button.visible = true
		Phase.REWARD:
			phase_label.text = "RESONANCE RECORDED"
			title_label.text = "The moment holds"

func _find_anomaly() -> void:
	if phase != Phase.ANOMALY:
		return
	anomaly_button.visible = false
	var success_text: String = definition.anomaly_definition.get("success_text", "You saw it.")
	body_label.text = success_text
	guidance_label.text = "THE FRACTURE DETECTED."
	action_button.text = "REPEAT THE MOMENT"
	action_button.visible = true

func _begin_capture_hold() -> void:
	if phase == Phase.CAPTURE:
		capture_holding = true

func _end_capture_hold() -> void:
	if phase == Phase.CAPTURE:
		capture_holding = false
		capture_hold = 0.0
		capture_progress.value = 0.0

func _update_capture(delta: float) -> void:
	capture_elapsed += delta
	var start_time: float = definition.capture_window.get("start_time", 0.92)
	var end_time: float = definition.capture_window.get("end_time", 1.26)
	var hold_req: float = definition.capture_window.get("hold_duration", 0.26)
	
	var fracture_open := capture_elapsed >= start_time and capture_elapsed <= end_time
	if fracture_open:
		capture_button.text = "HOLD NOW · CATCH THE FRACTURE" if not capture_holding else "HOLDING THE TRUTH"
		capture_button.modulate = Color(1.18, 1.18, 1.10, 1.0)
		guidance_label.text = "THE FRACTURE IS HERE."
	else:
		capture_button.text = "WAIT FOR THE FRACTURE" if not capture_holding else "HOLDING TOO EARLY"
		capture_button.modulate = Color.WHITE
	if capture_holding and fracture_open:
		capture_hold += delta
		capture_progress.value = clampf(capture_hold / hold_req, 0.0, 1.0) * 100.0
		if capture_hold >= hold_req:
			capture_holding = false
			capture_button.modulate = Color.WHITE
			_set_phase(Phase.REVIEW)
			return
	if capture_elapsed >= 2.0:
		capture_elapsed = 0.0
		capture_hold = 0.0
		capture_progress.value = 0.0
		capture_holding = false
		capture_misses += 1
		body_label.text = "The moment repeats. Hold when the timeline is fracturing."
		guidance_label.text = "WAIT FOR THE FRACTURE."
	timer_label.text = "CATCH  ·  %.1f" % capture_elapsed

func _review_changed(value: float) -> void:
	if phase != Phase.REVIEW:
		return
	var start_time: float = definition.capture_window.get("start_time", 0.92)
	var end_time: float = definition.capture_window.get("end_time", 1.26)
	var center_time := (start_time + end_time) * 0.5
	
	if value < start_time - 0.15:
		scene_image.texture = load(definition.background_path)
	elif value < end_time + 0.15:
		scene_image.texture = load(definition.action_path)
	else:
		scene_image.texture = load(definition.reveal_path)
		
	if absf(value - center_time) <= 0.12:
		review_unlocked = true
		body_label.text = definition.capture_window.get("success_text", "Timeline fraction isolated.")
		guidance_label.text = "YOU STOPPED THE MOMENT AT THE BREAK."
		action_button.text = "GATHER CONTEXT"
		action_button.visible = true

func _add_evidence(node: Dictionary) -> void:
	var button := Button.new()
	var key: String = node.get("identifier", "")
	var label: String = node.get("description", "Detail")
	
	button.name = "Evidence_%s" % key
	button.text = "○  %s" % label
	button.custom_minimum_size = Vector2(456, 36)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#dff8ef"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#123934")
	normal.corner_radius_top_left = 7
	normal.corner_radius_top_right = 7
	normal.corner_radius_bottom_left = 7
	normal.corner_radius_bottom_right = 7
	button.add_theme_stylebox_override("normal", normal)
	button.pressed.connect(_toggle_evidence.bind(node, button))
	evidence_container.add_child(button)

func _toggle_evidence(node: Dictionary, button: Button) -> void:
	var key: String = node.get("identifier", "")
	if evidence_found.has(key):
		return
	evidence_found[key] = true
	button.text = "✓  %s" % str(node.get("description", ""))
	button.disabled = true
	guidance_label.text = str(node.get("relevance", ""))
	
	if evidence_found.size() == definition.evidence_nodes.size():
		guidance_label.text = "ALL ELEMENTS VERIFIED."
		action_button.text = "REVEAL THE TRUTH"
		action_button.visible = true

func _advance() -> void:
	match phase:
		Phase.BRIEFING:
			_set_phase(Phase.OBSERVATION)
		Phase.ANOMALY:
			_set_phase(Phase.CAPTURE)
		Phase.REVIEW:
			if review_unlocked:
				_set_phase(Phase.CONTEXT)
		Phase.CONTEXT:
			if evidence_found.size() == definition.evidence_nodes.size():
				_set_phase(Phase.RESOLUTION)
		Phase.RESOLUTION:
			var accuracy := clampf(1.0 - float(anomaly_missteps) * 0.15 - float(capture_misses) * 0.10, 0.40, 1.0)
			var base_reward: Dictionary = definition.reward_definition
			completion_requested.emit(WitnessMomentResult.new(
				definition.moment_id, 
				accuracy, 
				1, 
				1, 
				false, 
				accuracy >= 0.95, 
				"deliberate"
			))
		Phase.REWARD:
			return_requested.emit()

func _round_button(text_value: String, position_value: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.flat = true
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.30, 0.92, 0.74, 0.08)
	style.border_color = Color(0.55, 1.0, 0.84, 0.72)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 47
	style.corner_radius_top_right = 47
	style.corner_radius_bottom_left = 47
	style.corner_radius_bottom_right = 47
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	return button

func _action_button() -> Button:
	var button := Button.new()
	button.name = "GameplayAction"
	button.position = Vector2(42, 838)
	button.size = Vector2(456, 48)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#f3fff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#286e61")
	normal.corner_radius_top_left = 9
	normal.corner_radius_top_right = 9
	normal.corner_radius_bottom_left = 9
	normal.corner_radius_bottom_right = 9
	var hover := normal.duplicate()
	hover.bg_color = Color("#368979")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	return button

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label
