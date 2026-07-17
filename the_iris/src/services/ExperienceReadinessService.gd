extends Node
class_name ExperienceReadinessService

## ExperienceReadinessService.gd — Manages audio/haptic readiness checks and first-launch persistence.

const CONFIG_KEY := "experience_readiness_completed"
const AUDIO_ENABLED_KEY := "experience_audio_enabled"
const HAPTICS_ENABLED_KEY := "experience_haptics_enabled"

func is_readiness_completed() -> bool:
	if ProfileService and ProfileService.profile is Dictionary:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if prefs.has(CONFIG_KEY):
			return bool(prefs.get(CONFIG_KEY, false))
	if SettingsService:
		return bool(SettingsService.get_value(CONFIG_KEY, false))
	return false

func mark_readiness_completed(audio_ok: bool, haptics_ok: bool) -> void:
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		prefs[CONFIG_KEY] = true
		prefs[AUDIO_ENABLED_KEY] = audio_ok
		prefs[HAPTICS_ENABLED_KEY] = haptics_ok
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	if SettingsService:
		SettingsService.set_value(CONFIG_KEY, true)
		SettingsService.set_value(AUDIO_ENABLED_KEY, audio_ok)
		SettingsService.set_value(HAPTICS_ENABLED_KEY, haptics_ok)

func check_audio_available() -> bool:
	var master_idx := AudioServer.get_bus_index("Master")
	if master_idx != -1:
		var is_muted := AudioServer.is_bus_mute(master_idx)
		var volume := AudioServer.get_bus_volume_db(master_idx)
		return not is_muted and volume > -50.0
	return true

func check_vibration_available() -> bool:
	return true
