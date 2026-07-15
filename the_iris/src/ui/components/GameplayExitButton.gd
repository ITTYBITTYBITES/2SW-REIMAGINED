extends Button
class_name GameplayExitButton
## Compact, safe exit control for immersive challenge phases.

var _dialog: ConfirmationDialog

func _ready() -> void:
	text = "×"
	tooltip_text = "Leave challenge"
	custom_minimum_size = Vector2(48, 48)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_theme()
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var normal := StyleBoxFlat.new()
	normal.bg_color = _with_alpha(tokens.get("background", Color("#0F0F12")), 0.72)
	normal.border_color = _with_alpha(tokens.get("text_secondary", Color("#B8B8CC")), 0.38)
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 24
	normal.corner_radius_top_right = 24
	normal.corner_radius_bottom_left = 24
	normal.corner_radius_bottom_right = 24
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = _with_alpha(tokens.get("surface_elevated", Color("#2A2A36")), 0.94)
	var pressed_style: StyleBoxFlat = hover.duplicate()
	pressed_style.bg_color = tokens.get("surface", Color("#1E1E26"))
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("focus", hover)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_color_override("font_color", tokens.get("text_secondary", Color("#B8B8CC")))
	add_theme_color_override("font_hover_color", tokens.get("text_primary", Color.WHITE))
	if ThemeService:
		ThemeService.apply_typography(self, "title")

func _on_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	_ensure_dialog()
	var viewport_width := int(get_viewport_rect().size.x)
	_dialog.popup_centered(Vector2i(mini(420, maxi(viewport_width - 24, 280)), 230))

func _ensure_dialog() -> void:
	if is_instance_valid(_dialog):
		return
	_dialog = ConfirmationDialog.new()
	_dialog.name = "LeaveChallengeDialog"
	_dialog.title = "Leave this challenge?"
	_dialog.dialog_text = "This round will end. Your existing Witness Progress is safe."
	_dialog.ok_button_text = "LEAVE CHALLENGE"
	_dialog.cancel_button_text = "KEEP PLAYING"
	_dialog.confirmed.connect(_leave_challenge)
	add_child(_dialog)

func _leave_challenge() -> void:
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.return_home()
	elif NavigationService:
		NavigationService.navigate_to("home")

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color
