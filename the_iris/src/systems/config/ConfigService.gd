extends Node
## ConfigService - App configuration management
## Handles env, feature flags, remote config ready structure

signal config_loaded(config: Dictionary)
signal config_value_changed(key: String, value: Variant)

var _config: Dictionary = {}
var _is_loaded: bool = false

const DEFAULT_CONFIG := {
	"app_name": "Two Second Witness",
	"app_version": "4.0.0",
	"publisher": "ITTYBITTYBITES",
	"publisher_tagline": "Interactive Experiences",
	"environment": "production", # development / staging / production
	"package_id": "com.ittybittybites.the2secondwitness",
	"privacy_policy_url": "https://ittybittybites.github.io/two-second-witness/privacy",
	"feature_flags": {
		"analytics_enabled": true,
		"ads_enabled": false,
		"iap_enabled": false,
		"debug_overlay": false,
		"experiences_enabled": true,
		"profile_enabled": true,
		"settings_enabled": true
	},
	"content": {
		"content_version": 2,
		"auto_update": false,
		"base_url": ""
	},
	"gameplay": {
		"default_replay_delay_ms": 500,
		"max_session_minutes": 30,
		"haptic_enabled_default": true
	},
	"ui": {
		"animation_duration_ms": 250,
		"default_theme": "dark",
		"reduced_motion_default": false
	}
}

func _ready() -> void:
	pass

func initialize() -> void:
	if _is_loaded:
		return
	_config = DEFAULT_CONFIG.duplicate(true)

	# Try load from user config override (local file)
	var path := "user://app_config_override.json"
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_merge_config(_config, parsed)

	_is_loaded = true
	config_loaded.emit(_config)

func get_value(path: String, default: Variant = null) -> Variant:
	# Supports dot notation: "feature_flags.analytics_enabled"
	var parts := path.split(".")
	var current: Variant = _config
	for p in parts:
		if current is Dictionary and current.has(p):
			current = current[p]
		else:
			return default
	return current

func set_value(path: String, value: Variant) -> void:
	var parts := path.split(".")
	var dict := _config
	for i in range(parts.size() - 1):
		var key: String = parts[i]
		if not dict.has(key) or not (dict[key] is Dictionary):
			dict[key] = {}
		dict = dict[key]
	dict[parts[-1]] = value
	config_value_changed.emit(path, value)

func get_all() -> Dictionary:
	return _config.duplicate(true)

func is_feature_enabled(flag: String) -> bool:
	return get_value("feature_flags.%s" % flag, false)

func _merge_config(target: Dictionary, override: Dictionary) -> void:
	for k in override.keys():
		if override[k] is Dictionary and target.has(k) and target[k] is Dictionary:
			_merge_config(target[k], override[k])
		else:
			target[k] = override[k]
