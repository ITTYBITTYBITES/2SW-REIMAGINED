extends Control
class_name GenericWitnessGameplay

## Mission 055 active Witness runtime. It preserves the existing definition,
## loader, completion, and reward path while evolving its playable vocabulary.
enum Phase { BRIEFING, OBSERVATION, FRACTURE, SYNCHRONIZATION, CONTEXT, REVELATION, TRUTH_FRAGMENT, REWARD }

signal completion_requested(result: WitnessMomentResult)
signal return_requested
## Keeps Iris personality routing in Application; gameplay never owns the Iris.
signal iris_guidance_requested(event_name: String)

var definition: WitnessMomentDefinition
var phase: Phase = Phase.BRIEFING
var active_fracture: WitnessFracture
var evidence_found: Dictionary = {}
var fracture_missteps := 0
var synchronization_hold := 0.0
var synchronization_holding := false
var memory_stability := 1.0
var memory_collapsed := false
var last_result: WitnessMomentResult
var intro_timer := 0.0
var in_intro_cinematic := false
var showcase_elapsed := 0.0
var showcase_reconstruction := 0.0

var backdrop: ColorRect
var scene_image: TextureRect
var phase_label: Label
var title_label: Label
var body_label: Label
var timer_label: Label
var guidance_label: Label
var action_button: Button
var fracture_button: Button
var synchronization_progress: ProgressBar
var stability_progress: ProgressBar
var evidence_container: VBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	backdrop = ColorRect.new()
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
	phase_label = _label("", 10, Color("#88cbb9"), Vector2(28, 30), Vector2(470, 20), HORIZONTAL_ALIGNMENT_CENTER)
	title_label = _label("", 26, Color("#effff8"), Vector2(28, 55), Vector2(470, 44))
	body_label = _label("", 16, Color("#d3eee5"), Vector2(28, 108), Vector2(470, 96))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	timer_label = _label("", 12, Color("#b7ded1"), Vector2(28, 208), Vector2(470, 24), HORIZONTAL_ALIGNMENT_CENTER)
	guidance_label = _label("", 11, Color("#91c8b9"), Vector2(42, 654), Vector2(456, 22), HORIZONTAL_ALIGNMENT_CENTER)
	var panel := Panel.new()
	panel.position = Vector2(20, 630)
	panel.size = Vector2(500, 286)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.01, 0.05, 0.06, 0.72)
	panel_style.border_color = Color(0.25, 0.85, 0.70, 0.35)
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	action_button = _action_button()
	action_button.pressed.connect(_advance)
	action_button.button_down.connect(_begin_synchronization_hold)
	action_button.button_up.connect(_end_synchronization_hold)
	add_child(action_button)
	fracture_button = _round_button(Vector2(350, 366), Vector2(94, 94))
	fracture_button.pressed.connect(_find_fracture)
	add_child(fracture_button)
	synchronization_progress = _progress_bar(Vector2(42, 786), Color("#8ee9c8"))
	add_child(synchronization_progress)
	stability_progress = _progress_bar(Vector2(42, 814), Color("#e6c77a"))
	add_child(stability_progress)
	evidence_container = VBoxContainer.new()
	evidence_container.position = Vector2(42, 684)
	evidence_container.size = Vector2(456, 128)
	evidence_container.add_theme_constant_override("separation", 8)
	add_child(evidence_container)

func start(value_definition: WitnessMomentDefinition) -> bool:
	if value_definition == null:
		return false
	definition = value_definition
	active_fracture = definition.primary_fracture()
	visible = true
	evidence_found.clear()
	fracture_missteps = 0
	synchronization_hold = 0.0
	synchronization_holding = false
	memory_stability = clampf(float(definition.memory_stability.get("initial", 1.0)), 0.0, 1.0)
	memory_collapsed = false
	last_result = null
	showcase_elapsed = 0.0
	showcase_reconstruction = 0.0
	# The showcase intentionally leaves a little room for the existing Iris
	# watermark/expression layer; legacy moments retain their opaque backdrop.
	if backdrop != null:
		backdrop.color = Color(0.012, 0.035, 0.04, float(definition.showcase.get("iris_presence_alpha", 1.0)))
	var ambient_path: String = definition.asset_manifest.audio_assets.get("ambient", "")
	IrisAudioConsumer.play_ambient_loop(ambient_path)
	in_intro_cinematic = true
	intro_timer = float(definition.showcase.get("intro_seconds", 1.35))
	_set_phase(Phase.BRIEFING)
	return true

func present_reward(award: Dictionary, profile: WitnessProfile) -> void:
	_set_phase(Phase.REWARD)
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/navigation/chapter_complete.ogg")
	var fragment_title := str(definition.truth_fragment.get("title", "Recovered Truth"))
	body_label.text = "%s absorbed by the Iris.\n\n+%d Resonance\nAperture %d · %s" % [fragment_title, int(award.get("total", 0)), profile.aperture_rank, profile.aperture_title]
	guidance_label.text = "THE MEMORY HOLDS IN THE IRIS."
	action_button.text = "RETURN THROUGH THE IRIS"
	action_button.visible = true

func close() -> void:
	visible = false
	evidence_found.clear()
	IrisAudioConsumer.stop_ambient_loop()

func _process(delta: float) -> void:
	if not visible:
		return
	showcase_elapsed += delta
	showcase_reconstruction = maxf(0.0, showcase_reconstruction - delta)
	if in_intro_cinematic:
		intro_timer -= delta
		if intro_timer <= 0.0:
			in_intro_cinematic = false
			_set_phase(Phase.BRIEFING)
		return
	if phase == Phase.OBSERVATION:
		var remaining := maxf(0.0, float(timer_label.get_meta("remaining", definition.observation_duration)) - delta)
		timer_label.set_meta("remaining", remaining)
		timer_label.text = "OBSERVE  ·  %.1f" % remaining
		if remaining <= 0.0:
			_set_phase(Phase.FRACTURE)
	elif phase == Phase.SYNCHRONIZATION:
		_update_synchronization(delta)
	var pulse := sin(Time.get_ticks_msec() * 0.008) * 0.008
	scene_image.scale = Vector2.ONE * (1.0 + pulse)
	scene_image.pivot_offset = scene_image.size * 0.5
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible or phase != Phase.FRACTURE:
		return
	if event is InputEventMouseButton and event.pressed and not fracture_button.get_global_rect().has_point(event.position):
		_register_fracture_misstep()
	elif event is InputEventScreenTouch and event.pressed and not fracture_button.get_global_rect().has_point(event.position):
		_register_fracture_misstep()

func _set_phase(next_phase: Phase) -> void:
	phase = next_phase
	fracture_button.visible = false
	action_button.visible = false
	synchronization_progress.visible = false
	stability_progress.visible = false
	evidence_container.visible = false
	timer_label.text = ""
	guidance_label.text = ""
	for child in evidence_container.get_children():
		child.queue_free()
	match phase:
		Phase.BRIEFING:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.asset_manifest.environment_asset, definition.background_path)
			phase_label.text = "IRIS BRIEFING  ·  %s" % definition.moment_id
			title_label.text = definition.title
			body_label.text = definition.description
			guidance_label.text = "THE IRIS HOLDS A MEMORY FOR YOU."
			action_button.text = "BEGIN OBSERVATION"
			action_button.visible = true
		Phase.OBSERVATION:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.action_path, definition.action_path)
			phase_label.text = "OBSERVE"
			title_label.text = "Let the moment happen"
			body_label.text = str(definition.showcase.get("observation_prompt", definition.description))
			guidance_label.text = "WATCH THE LIGHT. DO NOT HURRY IT."
			timer_label.set_meta("remaining", definition.observation_duration)
			IrisAudioConsumer.play_manifest_sound("res://assets/audio/witness/observation_start.ogg")
			_emit_guidance("observation_event")
		Phase.FRACTURE:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.asset_manifest.environment_asset, definition.background_path)
			phase_label.text = "LOCATE FRACTURE"
			title_label.text = "What arrived out of order?"
			body_label.text = str(definition.showcase.get("fracture_prompt", "Find the point where the memory cannot hold its shape."))
			guidance_label.text = "SOMETHING IS OUT OF SEQUENCE."
			_emit_guidance("fracture_prompt_event")
			fracture_button.position = Vector2(float(active_fracture.location.get("x", 350.0)), float(active_fracture.location.get("y", 366.0)))
			fracture_button.size = Vector2(float(active_fracture.size.get("x", 94.0)), float(active_fracture.size.get("y", 94.0)))
			fracture_button.visible = true
		Phase.SYNCHRONIZATION:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.action_path, definition.action_path)
			phase_label.text = "SYNCHRONIZE"
			title_label.text = "Hold the fracture in focus"
			body_label.text = str(definition.showcase.get("synchronization_prompt", "Maintain attention while the Iris aligns the unstable memory."))
			guidance_label.text = "HOLD THE LIGHT STEADY."
			_emit_guidance("synchronization_event")
			action_button.text = "HOLD FOCUS"
			action_button.visible = true
			synchronization_progress.visible = true
			stability_progress.visible = true
			synchronization_progress.value = 0.0
			stability_progress.value = memory_stability * 100.0
			IrisAudioConsumer.play_manifest_sound(str(active_fracture.synchronization.get("audio", "res://assets/audio/iris/iris_focus.ogg")))
			IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Fracture Synchronization Begins")
		Phase.CONTEXT:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.reveal_path, definition.reveal_path)
			phase_label.text = "REVEAL TRUTH"
			title_label.text = "Gather what the fracture concealed"
			body_label.text = "Each detail returns a piece of the memory to order."
			guidance_label.text = "THE PIECES EXPLAIN EACH OTHER."
			evidence_container.visible = true
			for node in definition.evidence_nodes:
				_add_evidence(node)
			IrisAudioConsumer.play_manifest_sound("res://assets/audio/witness/reveal.ogg")
		Phase.REVELATION:
			scene_image.texture = WitnessAssetResolver.resolve_texture(definition.reveal_path, definition.reveal_path)
			showcase_reconstruction = float(definition.showcase.get("reconstruction_seconds", 1.5))
			phase_label.text = "REVELATION"
			title_label.text = definition.title
			body_label.text = definition.resolution_text
			guidance_label.text = "THE MEMORY REMEMBERS WHY IT BROKE."
			action_button.text = "RECEIVE THE TRUTH"
			action_button.visible = true
			_emit_guidance("revelation_event")
			IrisAudioConsumer.play_manifest_sound(str(definition.asset_manifest.audio_assets.get("reconstruction", "res://assets/audio/iris/iris_transition.ogg")))
			IrisAudioConsumer.play_manifest_sound(str(definition.truth_fragment.get("revelation_audio_hook", "res://assets/audio/witness/resolution.ogg")))
		Phase.TRUTH_FRAGMENT:
			phase_label.text = "TRUTH FRAGMENT"
			title_label.text = str(definition.truth_fragment.get("title", "Recovered Truth"))
			body_label.text = str(definition.truth_fragment.get("summary", "Something hidden has returned."))
			guidance_label.text = "LET THE IRIS ABSORB WHAT RETURNED."
			action_button.text = "OFFER TO THE IRIS"
			action_button.visible = true
			IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_confirm.ogg")
			IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Truth Fragment Recovered")
		Phase.REWARD:
			phase_label.text = "TRUTH ABSORBED"
			title_label.text = "The memory holds"

func _find_fracture() -> void:
	if phase != Phase.FRACTURE:
		return
	active_fracture.discovery_state = true
	fracture_button.visible = false
	body_label.text = active_fracture.discovery_text
	guidance_label.text = "THE IRIS RECOGNIZES THE FRACTURE."
	action_button.text = "BEGIN SYNCHRONIZATION"
	action_button.visible = true
	_emit_guidance("fracture_discovered_event")
	IrisAudioConsumer.play_manifest_sound(str(definition.asset_manifest.audio_assets.get("fracture_discovery", "res://assets/audio/witness/correct_detection.ogg")))
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Fracture Located")

# Compatibility hook for legacy callers/tests that still use anomaly vocabulary.
func _find_anomaly() -> void:
	_find_fracture()

func _register_fracture_misstep() -> void:
	fracture_missteps += 1
	memory_stability = maxf(float(definition.memory_stability.get("collapse_at", 0.0)), memory_stability - float(definition.memory_stability.get("misstep_cost", 0.15)))
	var false_leads = definition.showcase.get("false_leads", [])
	if false_leads is Array and not false_leads.is_empty():
		body_label.text = str(false_leads[(fracture_missteps - 1) % false_leads.size()])
	else:
		body_label.text = active_fracture.misstep_text
	guidance_label.text = "THE MEMORY DESTABILIZES."
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/witness/incorrect_detection.ogg")
	if not IrisAccessibilityConsumer.is_reduced_motion():
		scene_image.position = Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
	if memory_stability <= float(definition.memory_stability.get("collapse_at", 0.0)):
		memory_collapsed = true
		memory_stability = maxf(0.25, float(definition.memory_stability.get("initial", 1.0)) * 0.5)
		body_label.text = "The memory collapses, then reforms around the Iris. Try again."
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Memory Collapse")

func _begin_synchronization_hold() -> void:
	if phase == Phase.SYNCHRONIZATION:
		synchronization_holding = true

func _end_synchronization_hold() -> void:
	if phase == Phase.SYNCHRONIZATION:
		synchronization_holding = false

func _update_synchronization(delta: float) -> void:
	var hold_required := maxf(0.25, float(active_fracture.synchronization.get("hold_duration", 1.0)))
	if synchronization_holding:
		synchronization_hold += delta
		memory_stability = minf(1.0, memory_stability + delta * 0.30)
		guidance_label.text = "THE IRIS IS ALIGNING WITH YOU."
	else:
		memory_stability = maxf(0.0, memory_stability - delta * float(definition.memory_stability.get("idle_drain_per_second", 0.08)))
	guidance_label.text = guidance_label.text if synchronization_holding else "KEEP THE FRACTURE IN FOCUS."
	synchronization_progress.value = clampf(synchronization_hold / hold_required, 0.0, 1.0) * 100.0
	stability_progress.value = memory_stability * 100.0
	timer_label.text = "STABILITY  ·  %d%%" % roundi(memory_stability * 100.0)
	if memory_stability <= float(definition.memory_stability.get("collapse_at", 0.0)):
		memory_collapsed = true
		memory_stability = 0.35
		synchronization_hold = 0.0
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Synchronization Reset")
	if synchronization_hold >= hold_required:
		synchronization_holding = false
		memory_stability = clampf(float(active_fracture.synchronization.get("stability_recovery", definition.memory_stability.get("recovery_on_synchronization", 1.0))), 0.0, 1.0)
		active_fracture.synchronization_state = true
		_emit_guidance("synchronization_complete_event")
		IrisAudioConsumer.play_manifest_sound(str(definition.asset_manifest.audio_assets.get("synchronization_complete", "res://assets/audio/iris/iris_confirm.ogg")))
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Fracture Stabilized")
		_set_phase(Phase.CONTEXT)

func _add_evidence(node: Dictionary) -> void:
	var button := Button.new()
	var key := str(node.get("identifier", "detail"))
	button.name = "Evidence_%s" % key
	button.text = "  %s" % str(node.get("description", "Detail"))
	button.custom_minimum_size = Vector2(456, 36)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", WitnessAssetResolver.resolve_color(str(node.get("color_modulation", "#dff8ef")), Color("#dff8ef")))
	button.pressed.connect(_toggle_evidence.bind(node, button))
	evidence_container.add_child(button)

func _toggle_evidence(node: Dictionary, button: Button) -> void:
	var key := str(node.get("identifier", ""))
	if evidence_found.has(key):
		return
	evidence_found[key] = true
	button.text = "✓  %s" % str(node.get("description", "Detail"))
	button.disabled = true
	guidance_label.text = str(node.get("relevance", ""))
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/witness/memory_lock.ogg")
	if evidence_found.size() >= definition.evidence_nodes.size():
		action_button.text = "REVEAL THE TRUTH"
		action_button.visible = true

func _advance() -> void:
	match phase:
		Phase.BRIEFING:
			_set_phase(Phase.OBSERVATION)
		Phase.FRACTURE:
			if active_fracture.discovery_state:
				_set_phase(Phase.SYNCHRONIZATION)
		Phase.CONTEXT:
			if evidence_found.size() >= definition.evidence_nodes.size():
				active_fracture.reveal_state = true
				_set_phase(Phase.REVELATION)
		Phase.REVELATION:
			_set_phase(Phase.TRUTH_FRAGMENT)
		Phase.TRUTH_FRAGMENT:
			_emit_completion()
		Phase.REWARD:
			return_requested.emit()

func _emit_completion() -> void:
	if last_result != null:
		return
	var accuracy := clampf(memory_stability - float(fracture_missteps) * 0.05, 0.40, 1.0)
	last_result = WitnessMomentResult.new(definition.moment_id, accuracy, 1, 1, false, accuracy >= 0.95, "deliberate", {
		"fractures_found": 1,
		"fractures_total": definition.fractures.size(),
		"synchronization_completed": active_fracture.synchronization_state,
		"synchronization_score": clampf(synchronization_hold / maxf(0.25, float(active_fracture.synchronization.get("hold_duration", 1.0))), 0.0, 1.0),
		"memory_stability": memory_stability,
		"memory_collapsed": memory_collapsed,
		"truth_fragment_id": definition.truth_fragment.get("truth_fragment_id", ""),
		"revelation_text": definition.truth_fragment.get("revelation_text", definition.resolution_text),
		"revelation_audio_hook": definition.truth_fragment.get("revelation_audio_hook", ""),
		"archive_entry": definition.truth_fragment.get("archive_entry", "")
	})
	completion_requested.emit(last_result)

func _emit_guidance(key: String) -> void:
	if definition == null:
		return
	var event_name := str(definition.iris_guidance.get(key, ""))
	if not event_name.is_empty():
		iris_guidance_requested.emit(event_name)

## WM-001 can use existing imagery with procedural atmosphere rather than final art.
func _draw() -> void:
	if definition == null or not bool(definition.showcase.get("enabled", false)) or size.x <= 0.0 or size.y <= 0.0:
		return
	var light_origin := Vector2(size.x * 0.82, size.y * 0.18)
	var warm := Color("#f4d99a")
	for ray in range(4):
		var phase_offset := float(ray) * 0.7
		var end := Vector2(size.x * (0.20 + float(ray) * 0.18), size.y * 0.69)
		var drift := sin(showcase_elapsed * 0.35 + phase_offset) * 12.0
		draw_line(light_origin + Vector2(drift, 0), end + Vector2(-drift, 0), Color(warm, 0.035), 18.0, true)
	# Dust motes make the studio feel suspended in late light.
	for index in range(18):
		var seed := float(index) * 1.73
		var x := fmod(seed * 73.0 + showcase_elapsed * (6.0 + float(index % 3)), maxf(size.x, 1.0))
		var y := fmod(seed * 137.0 + sin(showcase_elapsed * 0.45 + seed) * 28.0 + 280.0, maxf(size.y, 1.0))
		draw_circle(Vector2(x, y), 0.7 + float(index % 3) * 0.35, Color(1.0, 0.90, 0.66, 0.16))
	if phase == Phase.FRACTURE and active_fracture != null:
		var point := fracture_button.position + fracture_button.size * 0.5
		for ring in range(3):
			var radius := 34.0 + float(ring) * 15.0 + sin(showcase_elapsed * 3.0 + ring) * 4.0
			draw_arc(point, radius, 0.0, TAU, 36, Color(0.48, 0.96, 0.80, 0.22 - float(ring) * 0.05), 1.2, true)
	if phase == Phase.SYNCHRONIZATION:
		var coherence := clampf(synchronization_progress.value / 100.0, 0.0, 1.0)
		for ring in range(4):
			var radius := 42.0 + float(ring) * 29.0 - coherence * 15.0
			draw_arc(Vector2(size.x * 0.5, size.y * 0.45), radius, 0.0, TAU, 48, Color(0.56, 0.95, 0.79, (0.05 + coherence * 0.08) * (1.0 - float(ring) * 0.15)), 1.0, true)
	if phase == Phase.REVELATION or phase == Phase.TRUTH_FRAGMENT:
		var amount := clampf(showcase_reconstruction / maxf(0.1, float(definition.showcase.get("reconstruction_seconds", 1.5))), 0.0, 1.0)
		for index in range(6):
			var y := 284.0 + float(index) * 25.0
			draw_line(Vector2(66, y), Vector2(size.x - 66, y - 38.0), Color(0.72, 1.0, 0.84, 0.10 + amount * 0.12), 1.0, true)

func _progress_bar(position_value: Vector2, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = position_value
	bar.size = Vector2(456, 16)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#0d2929")
	background.corner_radius_top_left = 7
	background.corner_radius_top_right = 7
	background.corner_radius_bottom_left = 7
	background.corner_radius_bottom_right = 7
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 7
	fill.corner_radius_top_right = 7
	fill.corner_radius_bottom_left = 7
	fill.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	return bar

func _round_button(position_value: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.name = "FractureTarget"
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
	button.position = Vector2(42, 850)
	button.size = Vector2(456, 48)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#f3fff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#286e61")
	normal.corner_radius_top_left = 9
	normal.corner_radius_top_right = 9
	normal.corner_radius_bottom_left = 9
	normal.corner_radius_bottom_right = 9
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal.duplicate())
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
