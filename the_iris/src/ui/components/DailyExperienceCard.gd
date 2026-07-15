extends PanelContainer
## Premium focused Daily Experience card for the new Home V2.
## Consumes RecommendationService data only. Reuses styling patterns from ExperienceCard / ThemeService.
## Primary action: "Start Witness Round"

signal start_requested()
var _data: Dictionary = {}
var _is_locked: bool = false

@onready var eye_icon: TextureRect = $Margin/VBox/Header/EyeIcon
@onready var eyebrow: Label = $Margin/VBox/Header/TitleStack/Eyebrow
@onready var title_label: Label = $Margin/VBox/Header/TitleStack/Title
@onready var reason_label: Label = $Margin/VBox/Reason
@onready var scene_preview: PanelContainer = $Margin/VBox/ScenePreview
@onready var preview_label: Label = $Margin/VBox/ScenePreview/PreviewMargin/PreviewLabel
@onready var duration_label: Label = $Margin/VBox/MetaRow/Duration
@onready var mastery_label: Label = $Margin/VBox/MetaRow/Mastery
@onready var start_button: Button = $Margin/VBox/StartButton

func _ready() -> void:
	_apply_theme()
	_wire_signals()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _wire_signals() -> void:
	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)

func set_recommendation(recommendation: Dictionary, available: Array = []) -> void:
	_data = recommendation.duplicate(true)
	
	# Resolve full item for extra metadata (mastery, duration)
	var full_item: Dictionary = _find_full_item(available)
	if not full_item.is_empty():
		_data.merge(full_item, false)
	
	_is_locked = bool(_data.get("locked", _data.get("is_locked", false)))
	_refresh_ui()

func set_continue_recommendation(continue_rec: Dictionary, available: Array = []) -> void:
	# Optional: allow parent to indicate this is primarily a "continue" action
	if not continue_rec.is_empty():
		_data = continue_rec.duplicate(true)
		var full_item: Dictionary = _find_full_item(available)
		if not full_item.is_empty():
			_data.merge(full_item, false)
		_data["is_continue"] = true
		_is_locked = false  # continues are usually unlocked
		_refresh_ui()

func _find_full_item(available: Array) -> Dictionary:
	var family_id: String = str(_data.get("family_id", ""))
	for item in available:
		if item is Dictionary and str(item.get("family_id", "")) == family_id:
			return item.duplicate(true)
	return {}

func _refresh_ui() -> void:
	if _data.is_empty():
		title_label.text = "Witness Experience"
		reason_label.text = "A new challenge is being prepared."
		start_button.text = "BEGIN OBSERVATION"
		start_button.disabled = true
		return

	var title := str(_data.get("title", "Witness Moment"))
	var reason := "Observe what others miss."
	var is_continue := bool(_data.get("is_continue", false))
	var program_title := str(_data.get("program_title", ""))
	
	title_label.text = title
	reason_label.text = reason
	
	# Keep metadata calm and witness-centered. Detailed mastery remains in Record.
	var est: int = int(_data.get("estimated_duration_sec", 120))
	var mins: int = maxi(1, int(round(float(est) / 60.0)))
	duration_label.text = "%d min observation" % mins
	mastery_label.text = "One moment"
	
	# Button + eyebrow state (premium focused copy)
	start_button.disabled = _is_locked
	if _is_locked:
		var req: int = int(_data.get("required_level", 1))
		start_button.text = "LEVEL %d REQUIRED" % req
		eyebrow.text = "TODAY'S WITNESS EXPERIENCE"
	elif is_continue:
		start_button.text = "CONTINUE OBSERVATION"
		eyebrow.text = "TODAY'S WITNESS MOMENT" if program_title.is_empty() else ("RESUME • " + program_title).to_upper()
	else:
		start_button.text = "BEGIN OBSERVATION"
		eyebrow.text = "TODAY'S WITNESS MOMENT"
	
	# Eye icon (reuse brand asset)
	if eye_icon:
		eye_icon.texture = load("res://assets/brand/witness_eye_glow.png") as Texture2D
		eye_icon.modulate = Color(1, 1, 1, 0.9) if not _is_locked else Color(0.6, 0.6, 0.7, 0.6)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	
	# Card style - elevated premium look
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("primary", Color("#6A3DFF"))
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	add_theme_stylebox_override("panel", style)
	
	# Typography
	if ThemeService:
		ThemeService.apply_label_style(eyebrow, "label_small", "text_tertiary")
		eyebrow.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small"))
		
		ThemeService.apply_label_style(title_label, "title", "text_primary")
		title_label.add_theme_font_size_override("font_size", ThemeService.get_font_size("title"))
		
		ThemeService.apply_label_style(reason_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(duration_label, "caption", "text_secondary")
		ThemeService.apply_label_style(mastery_label, "caption", "text_secondary")
	
	if scene_preview:
		var preview_style := StyleBoxFlat.new()
		preview_style.bg_color = tokens.get("witness_surface", Color("#111119"))
		preview_style.border_color = Color(tokens.get("primary", Color("#6A3DFF")), 0.35)
		preview_style.border_width_left = 1
		preview_style.border_width_right = 1
		preview_style.border_width_top = 1
		preview_style.border_width_bottom = 1
		preview_style.corner_radius_top_left = 18
		preview_style.corner_radius_top_right = 18
		preview_style.corner_radius_bottom_left = 18
		preview_style.corner_radius_bottom_right = 18
		scene_preview.add_theme_stylebox_override("panel", preview_style)
	if preview_label and ThemeService:
		ThemeService.apply_label_style(preview_label, "body_small", "text_secondary")
		preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Start button - dominant primary
	_style_start_button(tokens)
	_apply_text_layout_guards()

func _apply_text_layout_guards() -> void:
	for label: Label in [eyebrow, duration_label, mastery_label]:
		if label:
			label.autowrap_mode = TextServer.AUTOWRAP_OFF
			label.clip_text = true
			label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _style_start_button(tokens: Dictionary) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("primary", Color("#6A3DFF"))
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 16
	normal.content_margin_bottom = 16
	
	var hover := normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.1)
	var pressed := normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.12)
	
	start_button.add_theme_stylebox_override("normal", normal)
	start_button.add_theme_stylebox_override("hover", hover)
	start_button.add_theme_stylebox_override("pressed", pressed)
	start_button.add_theme_stylebox_override("focus", hover)
	start_button.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE))
	start_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("button") if ThemeService else 18)
	start_button.custom_minimum_size.y = 72

func _on_start_pressed() -> void:
	if _data.is_empty() or start_button.disabled:
		return
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(35)
	if AudioService:
		AudioService.play_ui("ui_click")
	start_requested.emit()

func set_disabled(disabled: bool) -> void:
	if start_button:
		start_button.disabled = disabled or _is_locked
	if disabled:
		start_button.text = "PREPARING..."
	else:
		# Restore correct text
		if _data.is_empty():
			start_button.text = "START"
		elif _is_locked:
			var req: int = int(_data.get("required_level", 1))
			start_button.text = "LEVEL %d REQUIRED" % req
		elif bool(_data.get("is_continue", false)):
			start_button.text = "CONTINUE OBSERVATION"
		else:
			start_button.text = "BEGIN OBSERVATION"

func _on_theme_changed(_name: String, _tokens: Dictionary) -> void:
	_apply_theme()
	_refresh_ui()

func get_family_id() -> String:
	return str(_data.get("family_id", ""))
