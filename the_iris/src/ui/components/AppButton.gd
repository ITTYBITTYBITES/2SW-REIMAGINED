extends Button
## AppButton – Premium Witness UI button
## Matches HomeScreen / Tutorial / Result CTA styling
## ThemeService-driven, accessibility-aware
##
## Variants:
##   PRIMARY   – Purple filled, white text – main CTA (Play Now, Continue, Accept)
##   SECONDARY – Surface elevated, border – secondary actions (Replay, Back)
##   GHOST     – Transparent, text_tertiary – tertiary / skip / cancel
##   DANGER    – Error red – destructive (Reset Profile)
##
## Usage (GDScript):
##   var btn = preload("res://src/ui/components/AppButton.gd").new()
##   btn.variant = AppButton.Variant.PRIMARY
##   btn.text = "PLAY NOW\nStart a New Round"
##   btn.full_width = true
##
## Or in a .tscn, set script = ExtResource("AppButton.gd") on a Button node

enum Variant { PRIMARY, SECONDARY, GHOST, DANGER }

@export_enum("Primary", "Secondary", "Ghost", "Danger") var variant: int = Variant.PRIMARY:
	set(v):
		variant = v
		_apply_theme()
@export var full_width: bool = true:
	set(v):
		full_width = v
		_update_sizing()
@export var is_loading: bool = false:
	set(v):
		set_loading(v)

var _base_text: String = ""

func _ready() -> void:
	_base_text = text
	_apply_theme()
	_update_sizing()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if AccessibilityService and not AccessibilityService.accessibility_updated.is_connected(_on_accessibility_updated):
		AccessibilityService.accessibility_updated.connect(_on_accessibility_updated)
	focus_mode = Control.FOCUS_ALL
	if not pressed.is_connected(_on_pressed_feedback):
		pressed.connect(_on_pressed_feedback)

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_apply_theme()

func _apply_theme() -> void:
	if not is_inside_tree():
		return
	var tokens := {}
	if ThemeService:
		tokens = ThemeService.tokens

	var radius := int(tokens.get("radius_lg", 18)) if not tokens.is_empty() else 18
	var touch_min := int(tokens.get("touch_target_min", 48)) if not tokens.is_empty() else 48
	# Primary CTA gets extra height – matches Home Play Now (72dp)
	var min_h: int = 72 if variant == Variant.PRIMARY and full_width else maxi(56, touch_min)
	custom_minimum_size.y = min_h

	# Colors
	var bg := Color("#6A3DFF")
	var bg_hover := Color("#8A68FF")
	var fg := Color.WHITE
	var border_col := Color.TRANSPARENT
	var border_w := 0

	match variant:
		Variant.PRIMARY:
			bg = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
			bg_hover = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
			fg = tokens.get("text_on_primary", Color.WHITE) if not tokens.is_empty() else Color.WHITE
		Variant.SECONDARY:
			bg = tokens.get("surface_elevated", Color("#2A2A36")) if not tokens.is_empty() else Color("#2A2A36")
			bg_hover = bg.lightened(0.08)
			fg = tokens.get("text_primary", Color.WHITE) if not tokens.is_empty() else Color.WHITE
			border_col = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
			border_w = 1
		Variant.GHOST:
			bg = Color.TRANSPARENT
			bg_hover = Color(1,1,1,0.06)
			fg = tokens.get("text_tertiary", Color("#8A8AA3")) if not tokens.is_empty() else Color("#8A8AA3")
		Variant.DANGER:
			bg = Color.TRANSPARENT
			bg_hover = Color(1,0.3,0.35,0.08)
			fg = tokens.get("error", Color("#FF4D5E")) if not tokens.is_empty() else Color("#FF4D5E")
			border_col = fg
			border_w = 1

	# Build styleboxes
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		var col := bg
		match state:
			"hover", "focus":
				col = bg_hover
			"pressed":
				col = bg.darkened(0.12) if bg.a > 0.1 else bg_hover
			"disabled":
				col = Color(bg.r, bg.g, bg.b, bg.a * 0.45)
		sb.bg_color = col
		sb.corner_radius_top_left = radius
		sb.corner_radius_top_right = radius
		sb.corner_radius_bottom_left = radius
		sb.corner_radius_bottom_right = radius
		sb.border_color = border_col
		sb.border_width_left = border_w
		sb.border_width_right = border_w
		sb.border_width_top = border_w
		sb.border_width_bottom = border_w
		# Premium padding – matches Home Play Now
		var px := 24
		var py := 18 if variant == Variant.PRIMARY else 14
		sb.content_margin_left = px
		sb.content_margin_right = px
		sb.content_margin_top = py
		sb.content_margin_bottom = py
		add_theme_stylebox_override(state, sb)

	add_theme_color_override("font_color", fg)
	add_theme_color_override("font_hover_color", fg)
	add_theme_color_override("font_pressed_color", fg)
	add_theme_color_override("font_focus_color", fg)
	add_theme_color_override("font_disabled_color", Color(fg.r, fg.g, fg.b, 0.5))

	var font_size := 18
	if ThemeService:
		font_size = ThemeService.get_font_size("button")
	add_theme_font_size_override("font_size", font_size)

	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_update_sizing()

func _update_sizing() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL if full_width else Control.SIZE_SHRINK_CENTER

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_accessibility_updated(_settings: Dictionary) -> void:
	_apply_theme()
	if AccessibilityService:
		AccessibilityService.apply_accessibility_to_control(self)

func _on_pressed_feedback() -> void:
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")

func set_loading(loading: bool) -> void:
	is_loading = loading
	disabled = loading
	if loading:
		if _base_text == "":
			_base_text = text
		text = "Loading…"
	else:
		if _base_text != "":
			text = _base_text
	_apply_theme()
