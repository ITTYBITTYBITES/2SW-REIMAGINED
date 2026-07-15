extends Node
## ThemeService - UI theming, design tokens, light/dark, dynamic theming
## Independent and reusable, exposes tokens for UI

signal theme_changed(theme_name: String, tokens: Dictionary)
signal theme_tokens_updated()

enum ThemeMode { DARK, LIGHT, SYSTEM }

var current_mode: int = ThemeMode.DARK
var current_theme_name: String = "dark"
var tokens: Dictionary = {}

const DARK_TOKENS := {
	"name": "dark",
	"background": Color("#0B0B10"),
	"background_secondary": Color("#14141B"),
	"background_tertiary": Color("#20202A"),
	"surface": Color("#181820"),
	"surface_elevated": Color("#242430"),
	"witness_surface": Color("#111119"),
	"evidence_surface": Color("#1F1A12"),
	"primary": Color("#6A3DFF"),
	"primary_variant": Color("#9B7CFF"),
	"secondary": Color("#2EE6A6"),
	"evidence": Color("#D6A84F"),
	"accent": Color("#D6A84F"),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#B8B8CC"),
	"text_tertiary": Color("#8A8AA3"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#2E2E3A"),
	"border_strong": Color("#3D3D4D"),
	"error": Color("#FF4D5E"),
	"error_container": Color("#3A1A1E"),
	"success": Color("#2EE6A6"),
	"warning": Color("#FFC84D"),
	"shadow": Color(0,0,0,0.4),
	"overlay": Color(0,0,0,0.6),
	"font_family": "default",
	"radius_sm": 8,
	"radius_md": 12,
	"radius_lg": 20,
	"radius_full": 9999,
	"spacing_xs": 4,
	"spacing_sm": 8,
	"spacing_md": 16,
	"spacing_lg": 24,
	"spacing_xl": 32,
	"touch_target_min": 56,
	"safe_area_top": 0,
	"safe_area_bottom": 0,
	"typography": {
		"display": {"size": 38, "weight": 700},
		"headline": {"size": 30, "weight": 700},
		"title": {"size": 25, "weight": 600},
		"body": {"size": 20, "weight": 400},
		"body_small": {"size": 18, "weight": 400},
		"caption": {"size": 15, "weight": 500},
		"label": {"size": 17, "weight": 600},
		"label_small": {"size": 15, "weight": 600},
		"button": {"size": 20, "weight": 600}
	}
}

const LIGHT_TOKENS := {
	"name": "light",
	"background": Color("#F8F8FB"),
	"background_secondary": Color("#FFFFFF"),
	"background_tertiary": Color("#F0F0F5"),
	"surface": Color("#FFFFFF"),
	"surface_elevated": Color("#FFFFFF"),
	"primary": Color("#5A3EDC"),
	"primary_variant": Color("#7C5CFF"),
	"secondary": Color("#0ABF86"),
	"accent": Color("#FF4D5E"),
	"text_primary": Color("#111113"),
	"text_secondary": Color("#4A4A5E"),
	"text_tertiary": Color("#6B6B80"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#E8E8EF"),
	"border_strong": Color("#D4D4DF"),
	"error": Color("#E53945"),
	"error_container": Color("#FFEBEE"),
	"success": Color("#0ABF86"),
	"warning": Color("#FF9F1C"),
	"shadow": Color(0,0,0,0.1),
	"overlay": Color(0,0,0,0.4),
	"font_family": "default",
	"radius_sm": 8,
	"radius_md": 12,
	"radius_lg": 20,
	"radius_full": 9999,
	"spacing_xs": 4,
	"spacing_sm": 8,
	"spacing_md": 16,
	"spacing_lg": 24,
	"spacing_xl": 32,
	"touch_target_min": 56,
	"safe_area_top": 0,
	"safe_area_bottom": 0,
	"typography": {
		"display": {"size": 38, "weight": 700},
		"headline": {"size": 30, "weight": 700},
		"title": {"size": 25, "weight": 600},
		"body": {"size": 20, "weight": 400},
		"body_small": {"size": 18, "weight": 400},
		"caption": {"size": 15, "weight": 500},
		"label": {"size": 17, "weight": 600},
		"label_small": {"size": 15, "weight": 600},
		"button": {"size": 20, "weight": 600}
	}
}

func _ready() -> void:
	if SettingsService:
		SettingsService.setting_changed.connect(_on_setting_changed)

func initialize() -> void:
	# Load theme preference from settings
	var preferred: String = "dark"
	if SettingsService:
		preferred = SettingsService.get_value("theme_mode", "dark")

	match preferred:
		"light":
			set_theme_mode(ThemeMode.LIGHT)
		"dark":
			set_theme_mode(ThemeMode.DARK)
		_:
			set_theme_mode(ThemeMode.DARK)


func set_theme_mode(mode: int) -> void:
	current_mode = mode
	match mode:
		ThemeMode.DARK:
			tokens = DARK_TOKENS.duplicate(true)
			current_theme_name = "dark"
		ThemeMode.LIGHT:
			tokens = LIGHT_TOKENS.duplicate(true)
			current_theme_name = "light"
		ThemeMode.SYSTEM:
			# Detect system theme - default dark for now
			tokens = DARK_TOKENS.duplicate(true)
			current_theme_name = "dark"

	_apply_accessibility_tokens()
	theme_changed.emit(current_theme_name, tokens)
	EventBus.publish_theme_changed(current_theme_name)

func get_color(token_name: String, fallback: Color = Color.WHITE) -> Color:
	return tokens.get(token_name, fallback)

func get_spacing(size_name: String) -> int:
	return tokens.get(size_name, 16)

func get_radius(size_name: String) -> int:
	return tokens.get(size_name, 12)

func get_typography(style: String) -> Dictionary:
	var typo: Dictionary = tokens.get("typography", {})
	return typo.get(style, {"size": 18, "weight": 400})

func get_scaled_size(base_size: int) -> int:
	var scale: float = float(SettingsService.get_value("font_scale", 1.0)) if SettingsService else 1.0
	return maxi(1, int(round(float(base_size) * clampf(scale, 0.8, 1.4))))

func get_font_size(style: String) -> int:
	var base_size: int = int(get_typography(style).get("size", 18))
	return get_scaled_size(base_size)

func apply_typography(control: Control, style: String) -> void:
	if not control:
		return
	control.add_theme_font_size_override("font_size", get_font_size(style))

func apply_label_style(label: Label, style: String, color_token: String = "text_primary") -> void:
	if not label:
		return
	apply_typography(label, style)
	label.add_theme_color_override("font_color", get_color(color_token))
	# Preserve each label's scene/code wrapping choice. Forcing autowrap on every
	# label made short home-screen labels wrap awkwardly in narrow containers.
	# Long copy that has not opted into wrapping still gets a safe default.
	if label.autowrap_mode == TextServer.AUTOWRAP_OFF and label.text.length() > 80:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func get_safe_area() -> Rect2i:
	# Returns safe area insets for notches / gesture bars
	var area := DisplayServer.get_display_safe_area()
	var window_size := DisplayServer.window_get_size()
	var top := area.position.y
	var bottom := window_size.y - (area.position.y + area.size.y)
	var left := area.position.x
	var right := window_size.x - (area.position.x + area.size.x)
	# Fallback minimums for desktop / editor
	if top < 24 and OS.get_name() in ["Android", "iOS"]:
		top = 32
	if bottom < 16 and OS.get_name() in ["Android", "iOS"]:
		bottom = 24
	return Rect2i(left, top, right, bottom)

func apply_theme_to_control(control: Control) -> void:
	if not control:
		return
	# Can be extended to apply theme dynamically
	theme_tokens_updated.emit()

func _apply_accessibility_tokens() -> void:
	var high_contrast: bool = bool(SettingsService.get_value("high_contrast", false)) if SettingsService else false
	if not high_contrast:
		return
	if current_theme_name == "light":
		tokens["background"] = Color("#FFFFFF")
		tokens["background_secondary"] = Color("#F4F4F7")
		tokens["background_tertiary"] = Color("#E8E8EE")
		tokens["surface"] = Color("#FFFFFF")
		tokens["surface_elevated"] = Color("#F4F4F7")
		tokens["primary"] = Color("#3B16C7")
		tokens["primary_variant"] = Color("#4B24DA")
		tokens["text_primary"] = Color("#000000")
		tokens["text_secondary"] = Color("#24242C")
		tokens["text_tertiary"] = Color("#3D3D4D")
		tokens["border"] = Color("#5A5A6A")
		tokens["border_strong"] = Color("#202028")
	else:
		tokens["background"] = Color("#000000")
		tokens["background_secondary"] = Color("#08080C")
		tokens["background_tertiary"] = Color("#181820")
		tokens["surface"] = Color("#111118")
		tokens["surface_elevated"] = Color("#20202A")
		tokens["primary"] = Color("#9D83FF")
		tokens["primary_variant"] = Color("#B9A8FF")
		tokens["secondary"] = Color("#38F0B8")
		tokens["text_primary"] = Color("#FFFFFF")
		tokens["text_secondary"] = Color("#F1F1F7")
		tokens["text_tertiary"] = Color("#D2D2DE")
		tokens["border"] = Color("#77778A")
		tokens["border_strong"] = Color("#A0A0B0")

func _on_setting_changed(key: String, value: Variant) -> void:
	match key:
		"theme_mode":
			match str(value):
				"dark":
					set_theme_mode(ThemeMode.DARK)
				"light":
					set_theme_mode(ThemeMode.LIGHT)
				_:
					set_theme_mode(ThemeMode.DARK)
		"high_contrast", "font_scale":
			# Rebuild derived tokens and notify every cached screen to restyle.
			set_theme_mode(current_mode)
