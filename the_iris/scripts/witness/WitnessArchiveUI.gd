extends Control
class_name WitnessArchiveUI

## Dynamic player-facing Archive UI for 2SW.
## Flow: Iris Hub → Archive → Moment Collection → Moment Details → Replay.

signal back_to_hub_requested
signal replay_requested(moment_id: String)

var profile: WitnessProfile
var registry: IncidentRegistry

var background: TextureRect
var panel: ColorRect
var phase_label: Label
var title_label: Label
var subtitle_label: Label
var body_label: Label

var list_container: VBoxContainer
var scroll_container: ScrollContainer
var details_view: Control
var list_view: Control

var back_button: Button
var selected_moment_id := ""

func configure(val_profile: WitnessProfile, val_registry: IncidentRegistry) -> void:
	profile = val_profile
	registry = val_registry

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	# Background styling consistent with Living Iris
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.52, 0.70, 0.66, 0.42)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	
	var veil := ColorRect.new()
	veil.color = Color(0.01, 0.05, 0.06, 0.62)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	back_button = _button("‹  IRIS HUB", Vector2(25, 28), Vector2(130, 36), Color("#143e3b"), 12)
	back_button.pressed.connect(_on_back_pressed)
	
	phase_label = _label("WITNESS ARCHIVE", 11, Color("#88cbb9"), Vector2(33, 86), Vector2(440, 24))
	title_label = _label("Memory Restorations", 27, Color("#f1fff9"), Vector2(32, 115), Vector2(460, 47))
	subtitle_label = _label("Your collection of aligned experiences", 14, Color("#b7dcd1"), Vector2(33, 164), Vector2(460, 27))
	
	body_label = _label("Align attention to reconstruct past timeline anomalies and achieve full mastery over restored patterns.", 15, Color("#d7eee7"), Vector2(33, 207), Vector2(470, 100))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel = ColorRect.new()
	panel.position = Vector2(20, 320)
	panel.size = Vector2(500, 590)
	panel.color = Color(0.025, 0.105, 0.11, 0.92)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	# List View setup
	list_view = Control.new()
	list_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(list_view)

	scroll_container = ScrollContainer.new()
	scroll_container.position = Vector2(38, 345)
	scroll_container.size = Vector2(464, 540)
	list_view.add_child(scroll_container)

	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", 11)
	scroll_container.add_child(list_container)

	# Details View setup
	details_view = Control.new()
	details_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	details_view.visible = false
	add_child(details_view)

func open() -> void:
	visible = true
	show_collection()

func show_collection() -> void:
	selected_moment_id = ""
	list_view.visible = true
	details_view.visible = false
	back_button.text = "‹  IRIS HUB"
	
	title_label.text = "Memory Restorations"
	subtitle_label.text = "Your collection of aligned experiences"
	body_label.text = "Track your timeline restoration progress. Revisit completed moments to uncover deeper insights and master cause and effect."
	background.texture = null
	
	for child in list_container.get_children():
		child.queue_free()
		
	for moment in registry.chapter_moments():
		var id: String = moment.get("id", "")
		var is_completed := profile.completed_moment_ids.has(id)
		var record: Dictionary = profile.moment_records.get(id, {})
		
		var button_text := "%s  ·  %s" % [id, str(moment.get("title", "Untitled"))]
		var status_text := "LOCKED"
		var details_subtext := "Select to explore"
		
		if is_completed:
			var level := WitnessArchive.calculate_mastery(record)
			status_text = "✓ %s" % WitnessArchive.mastery_title_for(level).to_upper()
			details_subtext = "%d Resonance  ·  Accuracy: %d%%" % [
				record.get("highest_resonance", record.get("best_resonance_award", 20)),
				roundi(float(record.get("best_accuracy", 1.0)) * 100.0)
			]
			
		var card := _button(button_text + "\n   " + details_subtext, Vector2.ZERO, Vector2(440, 70), Color("#174943") if is_completed else Color("#122a28"), 13, false)
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var status_label := _label(status_text, 10, Color("#88cbb9") if is_completed else Color("#557371"), Vector2(310, 22), Vector2(110, 26))
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(status_label)
		
		card.pressed.connect(show_details.bind(id))
		list_container.add_child(card)

func show_details(moment_id: String) -> void:
	selected_moment_id = moment_id
	list_view.visible = false
	details_view.visible = true
	back_button.text = "‹  COLLECTION"
	
	for child in details_view.get_children():
		child.queue_free()
		
	var moment := registry.moment(moment_id)
	title_label.text = moment.get("title", "Untitled")
	subtitle_label.text = moment.get("subtitle", "Chapter 01")
	body_label.text = moment.get("introduction", "No introduction text.")
	
	var bg_path: String = moment.get("background_path", moment.get("background", ""))
	if not bg_path.is_empty():
		background.texture = load(bg_path)
		
	var is_completed := profile.completed_moment_ids.has(moment_id)
	var record: Dictionary = profile.moment_records.get(moment_id, {})
	
	# Details panel labels
	var y_offset := 345.0
	
	var label_id := _label("MOMENT IDENTIFIER: %s" % moment_id, 11, Color("#88cbb9"), Vector2(38, y_offset), Vector2(440, 20))
	details_view.add_child(label_id)
	y_offset += 30.0
	
	var status_str := "LOCKED"
	var acc_str := "--"
	var res_str := "--"
	var count_str := "0"
	var mastery_str := "None"
	var date_str := "--"
	var clues_list: Array = []
	
	if is_completed:
		status_str = "RESTORED"
		acc_str = "%d%%" % roundi(float(record.get("best_accuracy", 1.0)) * 100.0)
		res_str = "%d Resonance" % record.get("highest_resonance", record.get("best_resonance_award", 20))
		count_str = str(record.get("completion_count", 1))
		date_str = str(record.get("first_completed_date", "Today"))
		clues_list = record.get("discovered_clues", [])
		var level := WitnessArchive.calculate_mastery(record)
		mastery_str = WitnessArchive.mastery_title_for(level)
		
	var stats_title := _label("RECONSTRUCTION TELEMETRY", 10, Color("#7fbcae"), Vector2(38, y_offset), Vector2(440, 18))
	details_view.add_child(stats_title)
	y_offset += 25.0
	
	var stats_text := "Completion Status: %s\nFirst Restored: %s\nBest Accuracy: %s\nHighest Resonance: %s\nTotal completions: %s\nMastery Level: %s" % [
		status_str, date_str, acc_str, res_str, count_str, mastery_str
	]
	
	var stats_body := _label(stats_text, 12, Color("#d7eee7"), Vector2(38, y_offset), Vector2(440, 110))
	stats_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	details_view.add_child(stats_body)
	y_offset += 125.0
	
	# Clues exploration
	var clues_title := _label("DISCOVERED EVIDENCE (%d/3)" % clues_list.size(), 10, Color("#7fbcae"), Vector2(38, y_offset), Vector2(440, 18))
	details_view.add_child(clues_title)
	y_offset += 25.0
	
	var clues_text := ""
	if clues_list.is_empty():
		clues_text = "○ No evidence gathered. Complete the moment to attune to local clues."
	else:
		# Display detailed definitions of clues if we have them, otherwise fallback to index labels
		var evidence_nodes = moment.get("evidence_nodes", [])
		for i in range(clues_list.size()):
			var clue_id: String = clues_list[i]
			var desc := "Evidence node recorded"
			
			if evidence_nodes is Array:
				for node in evidence_nodes:
					if node is Dictionary and node.get("identifier", "") == clue_id:
						desc = node.get("description", desc)
						break
			clues_text += "✓  %s\n" % desc
			
	var clues_body := _label(clues_text, 12, Color("#a9c9be"), Vector2(38, y_offset), Vector2(440, 75))
	clues_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	clues_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_view.add_child(clues_body)
	y_offset += 85.0

	# Replay / Play action button
	var play_button := _button("REPLAY THIS MOMENT" if is_completed else "RESTORE THIS MEMORY", Vector2(38, 820), Vector2(440, 50), Color("#286e61") if is_completed else Color("#174943"), 14, false)
	play_button.pressed.connect(func(): replay_requested.emit(moment_id))
	details_view.add_child(play_button)

func _on_back_pressed() -> void:
	if not selected_moment_id.is_empty():
		show_collection()
	else:
		back_to_hub_requested.emit()

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text_value: String, position_value: Vector2, size_value: Vector2, color: Color, font_size: int, attach := true) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#f3fff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 7
	normal.corner_radius_top_right = 7
	normal.corner_radius_bottom_left = 7
	normal.corner_radius_bottom_right = 7
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	if attach:
		add_child(button)
	return button
