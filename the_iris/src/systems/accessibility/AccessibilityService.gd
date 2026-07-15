extends Node
## AccessibilityService - Accessibility features
## Font scaling, reduced motion, haptics, screen reader hints

signal accessibility_updated(settings: Dictionary)
signal font_scale_changed(scale: float)
signal reduced_motion_changed(enabled: bool)

var _font_scale: float = 1.0
var _reduced_motion: bool = false
var _high_contrast: bool = false
var _color_assist_mode: bool = false
var _haptics_enabled: bool = true
var _screen_reader_hints: bool = false
var _initialized: bool = false

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return

	if SettingsService:
		_font_scale = float(SettingsService.get_value("font_scale", SettingsService.get_value("accessibility_font_scaling", 1.0)))
		_reduced_motion = bool(SettingsService.get_value("reduced_motion", false)) or bool(SettingsService.get_value("accessibility_reduce_motion", false))
		_high_contrast = SettingsService.get_value("high_contrast", false)
		_color_assist_mode = SettingsService.get_value("color_assist_mode", false)
		_haptics_enabled = SettingsService.get_value("haptics_enabled", true)
		_screen_reader_hints = SettingsService.get_value("accessibility_screen_reader_hints", false)
		SettingsService.setting_changed.connect(_on_setting_changed)

	_initialized = true
	_accessibility_updated()

func _on_setting_changed(key: String, value: Variant) -> void:
	match key:
		"accessibility_font_scaling", "font_scale":
			_font_scale = clamp(float(value), 0.8, 1.5)
			font_scale_changed.emit(_font_scale)
		"accessibility_reduce_motion", "reduced_motion":
			_reduced_motion = (
				bool(SettingsService.get_value("reduced_motion", false))
				or bool(SettingsService.get_value("accessibility_reduce_motion", false))
			)
			reduced_motion_changed.emit(_reduced_motion)
		"high_contrast":
			_high_contrast = bool(value)
		"color_assist_mode":
			_color_assist_mode = bool(value)
		"haptics_enabled":
			_haptics_enabled = bool(value)
		"accessibility_screen_reader_hints":
			_screen_reader_hints = bool(value)
	_accessibility_updated()

func _accessibility_updated() -> void:
	var settings := {
		"font_scale": _font_scale,
		"reduced_motion": _reduced_motion,
		"high_contrast": _high_contrast,
		"color_assist_mode": _color_assist_mode,
		"haptics_enabled": _haptics_enabled,
		"screen_reader_hints": _screen_reader_hints
	}
	accessibility_updated.emit(settings)
	EventBus.publish_accessibility_changed(settings)

func get_font_scale() -> float:
	return _font_scale

func is_reduced_motion_enabled() -> bool:
	return _reduced_motion

func is_high_contrast_enabled() -> bool:
	return _high_contrast

func is_color_assist_enabled() -> bool:
	return _color_assist_mode

func is_haptics_enabled() -> bool:
	return _haptics_enabled

func should_animate() -> bool:
	return not _reduced_motion

func get_animation_duration(base_duration: float) -> float:
	if _reduced_motion:
		return 0.0
	return base_duration

func apply_accessibility_to_control(control: Control) -> void:
	if not control:
		return
	# Apply font scale if labels/buttons
	if _font_scale != 1.0:
		if control is Label:
			var lbl := control as Label
			# Adjust via theme override if possible
			lbl.add_theme_font_size_override("font_size", int(16 * _font_scale))
		elif control is Button:
			var btn := control as Button
			btn.add_theme_font_size_override("font_size", int(16 * _font_scale))

func vibrate(duration_ms: int = 50, _amplitude: float = 0.5) -> void:
	if not _haptics_enabled:
		return
	if OS.has_feature("mobile"):
		# Input.vibrate_handheld exists in Godot 4
		Input.vibrate_handheld(duration_ms)
	else:
		# Desktop fallback: no haptic device is available
		pass

func get_settings_snapshot() -> Dictionary:
	return {
		"font_scale": _font_scale,
		"reduced_motion": _reduced_motion,
		"high_contrast": _high_contrast,
		"color_assist_mode": _color_assist_mode,
		"haptics_enabled": _haptics_enabled,
		"screen_reader_hints": _screen_reader_hints
	}
