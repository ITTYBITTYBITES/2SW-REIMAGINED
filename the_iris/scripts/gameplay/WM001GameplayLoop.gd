extends Control
class_name WM001GameplayLoop

## Reference Witness gameplay loop for the existing WM_001 authored moment.
## It drives presentation only and completes through the existing orchestrator.
enum Phase { BRIEFING, OBSERVATION, DISCOVERY, CONTEXT, RESOLUTION, REWARD }

signal completion_requested(result: WitnessMomentResult)
signal return_requested

var director: WitnessExperienceDirector
var orchestrator: WitnessMomentOrchestrator
var moment_data: Dictionary = {}
var phase: Phase = Phase.BRIEFING
var observation_remaining := 0.0
var discovery_missteps := 0
var anomaly_found := false
var evidence_found: Dictionary = {}

var scene_image: TextureRect
var phase_label: Label
var title_label: Label
var body_label: Label
var timer_label: Label
var action_button: Button
var hotspot_button: Button
var evidence_container: VBoxContainer

func configure(value_director: WitnessExperienceDirector, value_orchestrator: WitnessMomentOrchestrator) -> void:
	director = value_director
	orchestrator = value_orchestrator

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
	scene_image.modulate = Color(0.64, 0.78, 0.72, 0.46)
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

	var panel := ColorRect.new()
	panel.position = Vector2(20, 630)
	panel.size = Vector2(500, 286)
	panel.color = Color(0.016, 0.084, 0.087, 0.94)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	action_button = _action_button()
	action_button.pressed.connect(_advance)

	evidence_container = VBoxContainer.new()
	evidence_container.position = Vector2(42, 660)
	evidence_container.size = Vector2(456, 140)
	evidence_container.add_theme_constant_override("separation", 8)
	add_child(evidence_container)

	hotspot_button = Button.new()
	hotspot_button.name = "PrismAnomaly"
	hotspot_button.text = ""
	hotspot_button.position = Vector2(350, 366)
	hotspot_button.size = Vector2(94, 94)
	hotspot_button.flat = true
	var hotspot_style := StyleBoxFlat.new()
	hotspot_style.bg_color = Color(0.30, 0.92, 0.74, 0.08)
	hotspot_style.border_color = Color(0.55, 1.0, 0.84, 0.72)
	hotspot_style.set_border_width_all(1)
	hotspot_style.corner_radius_top_left = 47
	hotspot_style.corner_radius_top_right = 47
	hotspot_style.corner_radius_bottom_left = 47
	hotspot_style.corner_radius_bottom_right = 47
	hotspot_button.add_theme_stylebox_override("normal", hotspot_style)
	hotspot_button.add_theme_stylebox_override("hover", hotspot_style)
	hotspot_button.pressed.connect(_find_anomaly)
	add_child(hotspot_button)

func start() -> bool:
	if director == null or orchestrator == null:
		return false
	var launch := director.launch("WM_001")
	if launch.is_empty():
		return false
	moment_data = launch.get("moment", {}).duplicate(true)
	if moment_data.is_empty() or not orchestrator.start(launch):
		return false
	visible = true
	discovery_missteps = 0
	anomaly_found = false
	evidence_found.clear()
	_set_phase(Phase.BRIEFING)
	return true

func present_reward(award: Dictionary, profile: WitnessProfile) -> void:
	_set_phase(Phase.REWARD)
	var total := int(award.get("total", 0))
	body_label.text = "Memory restored.\n\n+%d Resonance\nAperture %d · %s" % [total, profile.aperture_rank, profile.aperture_title]
	action_button.text = "RETURN TO IRIS HUB"
	action_button.visible = true

func close() -> void:
	visible = false
	moment_data.clear()
	evidence_found.clear()

func _process(delta: float) -> void:
	if not visible or phase != Phase.OBSERVATION:
		return
	observation_remaining = maxf(0.0, observation_remaining - delta)
	timer_label.text = "WATCH  ·  %.1f" % observation_remaining
	if observation_remaining <= 0.0:
		_set_phase(Phase.DISCOVERY)

func _gui_input(event: InputEvent) -> void:
	if not visible or phase != Phase.DISCOVERY:
		return
	if event is InputEventMouseButton and event.pressed and not hotspot_button.get_global_rect().has_point(event.position):
		discovery_missteps += 1
		body_label.text = "Not there. Watch the light, not the painter."
	elif event is InputEventScreenTouch and event.pressed and not hotspot_button.get_global_rect().has_point(event.position):
		discovery_missteps += 1
		body_label.text = "Not there. Watch the light, not the painter."

func _set_phase(next_phase: Phase) -> void:
	phase = next_phase
	hotspot_button.visible = false
	evidence_container.visible = false
	action_button.visible = false
	timer_label.text = ""
	for child in evidence_container.get_children():
		child.queue_free()

	match phase:
		Phase.BRIEFING:
			scene_image.texture = load(str(moment_data.get("background", "")))
			phase_label.text = "IRIS BRIEFING  ·  WM_001"
			title_label.text = str(moment_data.get("title", "The Unfinished Canvas"))
			body_label.text = "The Iris holds a broken moment. Watch carefully. Something does not belong."
			action_button.text = "BEGIN OBSERVATION"
			action_button.visible = true
		Phase.OBSERVATION:
			scene_image.texture = load(str(moment_data.get("action", "")))
			phase_label.text = "OBSERVE"
			title_label.text = "Hold the moment"
			body_label.text = "Watch without touching. The truth only stays for two seconds."
			observation_remaining = 2.0
		Phase.DISCOVERY:
			scene_image.texture = load(str(moment_data.get("background", "")))
			phase_label.text = "NOTICE"
			title_label.text = "What does not belong?"
			body_label.text = "Something is wrong in this memory. Find the detail that changed the whole moment."
			hotspot_button.visible = true
		Phase.CONTEXT:
			scene_image.texture = load(str(moment_data.get("reveal", "")))
			phase_label.text = "UNDERSTAND"
			title_label.text = "Gather the context"
			body_label.text = "The detail matters because of what surrounds it. Carry each piece of the truth."
			evidence_container.visible = true
			_add_evidence("paused_brush", "The paused brush")
			_add_evidence("crystal_prism", "The crystal prism")
			_add_evidence("color_notes", "The color notes")
		Phase.RESOLUTION:
			scene_image.texture = load(str(moment_data.get("reveal", "")))
			phase_label.text = "REVEAL"
			title_label.text = "The truth returns"
			body_label.text = str(moment_data.get("revelation", "The light completed the composition."))
			action_button.text = "RESTORE THIS MEMORY"
			action_button.visible = true
		Phase.REWARD:
			phase_label.text = "RESONANCE RECORDED"
			title_label.text = "The memory holds"

func _find_anomaly() -> void:
	if phase != Phase.DISCOVERY or anomaly_found:
		return
	anomaly_found = true
	hotspot_button.visible = false
	body_label.text = "You found it. The prism is breaking light across the canvas."
	action_button.text = "CAPTURE THE MOMENT"
	action_button.visible = true

func _add_evidence(key: String, label: String) -> void:
	var button := Button.new()
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
	button.pressed.connect(_toggle_evidence.bind(key, label, button))
	evidence_container.add_child(button)

func _toggle_evidence(key: String, label: String, button: Button) -> void:
	if evidence_found.has(key):
		return
	evidence_found[key] = true
	button.text = "✓  %s" % label
	button.disabled = true
	if evidence_found.size() == 3:
		action_button.text = "REVEAL THE TRUTH"
		action_button.visible = true

func _advance() -> void:
	match phase:
		Phase.BRIEFING:
			_set_phase(Phase.OBSERVATION)
		Phase.DISCOVERY:
			if anomaly_found:
				_set_phase(Phase.CONTEXT)
		Phase.CONTEXT:
			if evidence_found.size() == 3:
				_set_phase(Phase.RESOLUTION)
		Phase.RESOLUTION:
			var accuracy := clampf(1.0 - float(discovery_missteps) * 0.20, 0.40, 1.0)
			completion_requested.emit(WitnessMomentResult.new("WM_001", accuracy, 1, 1, false, false, "deliberate"))
		Phase.REWARD:
			return_requested.emit()

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
	add_child(button)
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
