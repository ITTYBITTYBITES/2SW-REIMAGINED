extends PanelContainer
## Data-driven card for curated challenge journeys.

signal program_selected(program_id: String)

var program: Dictionary = {}

@onready var artwork: TextureRect = $Margin/VBox/Artwork
@onready var title_label: Label = $Margin/VBox/Header/Title
@onready var status_label: Label = $Margin/VBox/Header/Status
@onready var description_label: Label = $Margin/VBox/Description
@onready var detail_label: Label = $Margin/VBox/Detail
@onready var progress_bar: ProgressBar = $Margin/VBox/ProgressBar
@onready var action_button: Button = $Margin/VBox/ActionButton

func _ready() -> void:
	if not action_button.pressed.is_connected(_on_action):
		action_button.pressed.connect(_on_action)
	_apply_theme()
	_refresh()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func set_program(value: Dictionary) -> void:
	program = value.duplicate(true)
	if is_inside_tree():
		_apply_theme()
		_refresh()

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var accent: Color = Color(str(program.get("accent", "#6A3DFF"))) if not program.is_empty() else tokens.get("primary", Color("#6A3DFF"))
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = accent if bool(program.get("available", false)) else tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_color = Color(0, 0, 0, 0.26)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	add_theme_stylebox_override("panel", style)
	if ThemeService:
		ThemeService.apply_label_style(title_label, "title", "text_primary")
		ThemeService.apply_label_style(status_label, "label_small", "text_tertiary")
		status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		status_label.custom_minimum_size.x = 120.0
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ThemeService.apply_label_style(description_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(detail_label, "caption", "text_secondary")
		ThemeService.apply_typography(action_button, "button")
	action_button.custom_minimum_size.y = 64
	action_button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(accent, 0.28) if bool(program.get("available", false)) else tokens.get("background_tertiary", Color("#24242C"))
	button_style.corner_radius_top_left = 12
	button_style.corner_radius_top_right = 12
	button_style.corner_radius_bottom_left = 12
	button_style.corner_radius_bottom_right = 12
	var hover_style: StyleBoxFlat = button_style.duplicate()
	hover_style.bg_color = button_style.bg_color.lightened(0.08)
	var pressed_style: StyleBoxFlat = button_style.duplicate()
	pressed_style.bg_color = button_style.bg_color.darkened(0.10)
	action_button.add_theme_stylebox_override("normal", button_style)
	action_button.add_theme_stylebox_override("hover", hover_style)
	action_button.add_theme_stylebox_override("pressed", pressed_style)
	action_button.add_theme_stylebox_override("focus", hover_style)
	action_button.focus_mode = Control.FOCUS_ALL
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = tokens.get("background_tertiary", Color("#24242C"))
	bar_background.corner_radius_top_left = 99
	bar_background.corner_radius_top_right = 99
	bar_background.corner_radius_bottom_left = 99
	bar_background.corner_radius_bottom_right = 99
	progress_bar.add_theme_stylebox_override("background", bar_background)
	var bar_fill: StyleBoxFlat = bar_background.duplicate()
	bar_fill.bg_color = accent
	progress_bar.add_theme_stylebox_override("fill", bar_fill)

func _refresh() -> void:
	if program.is_empty():
		return
	var progress: Dictionary = program.get("progress", {})
	var current_round: int = int(progress.get("current_run_round", 0))
	var round_count: int = int(program.get("round_count", 1))
	title_label.text = str(program.get("title", "Program"))
	description_label.text = str(program.get("description", ""))
	if not bool(program.get("scheduled", true)):
		status_label.text = "WEEKEND"
	elif bool(program.get("locked", false)):
		status_label.text = "LEVEL %d" % int(program.get("required_level", 1))
	else:
		status_label.text = "%d ROUNDS" % round_count
	progress_bar.max_value = float(round_count)
	progress_bar.value = float(current_round)
	progress_bar.show_percentage = false
	detail_label.text = "%d of %d current rounds · %d completed runs · %d%% best" % [
		current_round,
		round_count,
		int(progress.get("completed_runs", 0)),
		int(round(float(progress.get("best_run_accuracy", 0.0)) * 100.0))
	]
	var artwork_path := str(program.get("artwork", ""))
	if artwork:
		artwork.texture = null
		if not artwork_path.is_empty() and ResourceLoader.exists(artwork_path):
			artwork.texture = load(artwork_path) as Texture2D
	action_button.disabled = not bool(program.get("available", false))
	action_button.text = str(program.get("action_label", "START RUN")) if bool(program.get("available", false)) else "UNAVAILABLE"

func _on_action() -> void:
	var program_id: String = str(program.get("id", ""))
	if program_id.is_empty() or action_button.disabled:
		return
	if AudioService:
		AudioService.play_ui("ui_click")
	if AccessibilityService:
		AccessibilityService.vibrate(25)
	program_selected.emit(program_id)

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()
