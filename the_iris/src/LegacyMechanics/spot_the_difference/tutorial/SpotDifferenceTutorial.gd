extends Control
## Four-step visual tutorial using the production family renderer.

signal completed(family_id: String, tutorial_version: String)
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

const FAMILY_ID := "spot_the_difference"
const TUTORIAL_VERSION := "1"

var _step: int = 0
var _title: Label
var _description: Label
var _progress: Label
var _next: Button
var _preview: SpotDifferenceView

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#0F0F12")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	ResponsiveLayout.apply_centered_margin(margin, 24.0)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 14)
	scroll.add_child(stack)
	_progress = Label.new()
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(_progress)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(_title)
	_description = Label.new()
	_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_description)
	_preview = SpotDifferenceView.new()
	_preview.custom_minimum_size = Vector2(0, 300)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(_preview)
	_next = Button.new()
	_next.custom_minimum_size = Vector2(0, 64)
	_next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next.pressed.connect(_advance)
	stack.add_child(_next)
	var skip := Button.new()
	skip.text = "Skip Tutorial"
	skip.flat = true
	skip.custom_minimum_size = Vector2(0, 48)
	skip.pressed.connect(_skip)
	stack.add_child(skip)
	_update()

func configure(_family: ChallengeFamily, _profile: TutorialProfile) -> void:
	pass

func reset_tutorial() -> void:
	_step = 0
	if is_inside_tree():
		_update()

func _update() -> void:
	var steps: Array[Array] = [
		["COMPARE A AND B", "Scan the same area in both panels. Every round contains exactly one changed target."],
		["TAP THE LOCATION", "Tap either version of the changed detail. Large fair target regions accept the matching location."],
		["CHECK THE EVIDENCE", "The reveal returns both states and marks the exact area—even when an object disappeared."],
		["YOUR TURN", "Practice starts with fewer, larger objects and comfortable comparison time."]
	]
	_title.text = str(steps[_step][0])
	_description.text = str(steps[_step][1])
	_progress.text = "%d / %d" % [_step + 1, steps.size()]
	_next.text = "START PRACTICE" if _step == steps.size() - 1 else "NEXT  →"
	if ThemeService:
		ThemeService.apply_label_style(_title, "display", "text_primary")
		ThemeService.apply_label_style(_description, "body", "text_secondary")
		ThemeService.apply_label_style(_progress, "label_small", "primary_variant")
		ThemeService.apply_typography(_next, "button")
	_style_primary_button(_next)
	_preview.set_scene_data(_demo_scene(_step == 2), ["obj_2"] if _step == 2 else [])

func _demo_scene(reveal: bool) -> Dictionary:
	var first: Array[Dictionary] = [
		{"instance_id":"obj_0","kind":"cup","color":"#5B7FD0","x":0.22,"y":0.30,"w":0.20,"h":0.20,"state":0,"rotation":0.0},
		{"instance_id":"obj_1","kind":"book","color":"#C96854","x":0.68,"y":0.28,"w":0.20,"h":0.20,"state":0,"rotation":0.0},
		{"instance_id":"obj_2","kind":"star","color":"#C7A548","x":0.25,"y":0.70,"w":0.20,"h":0.20,"state":0,"rotation":0.0},
		{"instance_id":"obj_3","kind":"plant","color":"#4E9A72","x":0.70,"y":0.69,"w":0.20,"h":0.20,"state":0,"rotation":0.0}
	]
	var second: Array[Dictionary] = first.duplicate(true)
	second[2]["state"] = 1
	return {
		"mode": "side_by_side",
		"objects_a": first,
		"objects_b": second,
		"theme": {"background":"#EEE9DE","surface":"#E2D8C5","line":"#766F82","accent":"#B99A62"},
		"target_regions": [
			{"x":0.06,"y":0.55,"w":0.18,"h":0.24},
			{"x":0.55,"y":0.55,"w":0.18,"h":0.24}
		],
		"reveal_mode": reveal
	}

func _advance() -> void:
	if _step >= 3:
		completed.emit(FAMILY_ID, TUTORIAL_VERSION)
		practice_requested.emit(FAMILY_ID, "side_by_side_presence_v1")
		return
	_step += 1
	_update()

func _skip() -> void:
	skipped.emit(FAMILY_ID, TUTORIAL_VERSION)
	practice_requested.emit(FAMILY_ID, "side_by_side_presence_v1")

func _style_primary_button(button: Button) -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("primary", Color("#6A3DFF"))
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	var pressed: StyleBoxFlat = style.duplicate()
	pressed.bg_color = style.bg_color.darkened(0.10)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
