extends Control
class_name ExperienceReadinessScreen

## ExperienceReadinessScreen.gd — Pre-experience readiness gate before Living Iris awakening.
## Recommended not mandatory; remembered after first setup.

signal readiness_finished

@onready var title_label: Label = $MainMargin/Scroll/Content/Hero/TitleLabel
@onready var subtitle_label: Label = $MainMargin/Scroll/Content/Hero/SubtitleLabel
@onready var checklist_container: VBoxContainer = $MainMargin/Scroll/Content/ChecklistContainer
@onready var test_sound_btn: Button = $MainMargin/Scroll/Content/Actions/TestSoundButton
@onready var test_vibe_btn: Button = $MainMargin/Scroll/Content/Actions/TestVibeButton
@onready var continue_btn: Button = $MainMargin/Scroll/Content/ContinueButton

func _ready() -> void:
	_apply_theme()
	_wire_buttons()
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin, 24.0)

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12"))
	if title_label and ThemeService:
		ThemeService.apply_label_style(title_label, "display", "text_primary")
	if subtitle_label and ThemeService:
		ThemeService.apply_label_style(subtitle_label, "body", "text_secondary")
	if test_sound_btn:
		_style_button(test_sound_btn, false, tokens)
	if test_vibe_btn:
		_style_button(test_vibe_btn, false, tokens)
	if continue_btn:
		_style_button(continue_btn, true, tokens)
		continue_btn.text = "CONTINUE"

func _style_button(button: Button, primary: bool, tokens: Dictionary) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("primary", Color("#6A3DFF")) if primary else tokens.get("surface", Color("#1E1E26"))
	normal.border_color = tokens.get("border", Color("#2E2E3A"))
	normal.border_width_left = 0 if primary else 1
	normal.border_width_right = normal.border_width_left
	normal.border_width_top = normal.border_width_left
	normal.border_width_bottom = normal.border_width_left
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 14
	normal.content_margin_bottom = 14
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))

func _wire_buttons() -> void:
	if not test_sound_btn.pressed.is_connected(_on_test_sound):
		test_sound_btn.pressed.connect(_on_test_sound)
	if not test_vibe_btn.pressed.is_connected(_on_test_vibe):
		test_vibe_btn.pressed.connect(_on_test_vibe)
	if not continue_btn.pressed.is_connected(_on_continue):
		continue_btn.pressed.connect(_on_continue)

func _on_test_sound() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")

func _on_test_vibe() -> void:
	if AccessibilityService and AccessibilityService.has_method("vibrate"):
		AccessibilityService.vibrate(30)
	elif Input.has_method("vibrate_handheld"):
		Input.vibrate_handheld(30, 0.2)

func _on_continue() -> void:
	var audio_ok := ExperienceReadinessService.check_audio_available() if ExperienceReadinessService else true
	var vibes_ok := ExperienceReadinessService.check_vibration_available() if ExperienceReadinessService else true
	if ExperienceReadinessService:
		ExperienceReadinessService.mark_readiness_completed(audio_ok, vibes_ok)
	readiness_finished.emit()
	if NavigationService:
		NavigationService.navigate_to("home")
