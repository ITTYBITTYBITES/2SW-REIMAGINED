extends ExposurePolicy
class_name SceneInvestigationExposurePolicy
## Production exposure timing. Duration is one difficulty axis, not a universal
## ordering of challenge difficulty.

const VERSION: String = "1"

const TIERS := {
	"beginner": {"min": 5.0, "max": 6.0, "default": 5.5},
	"standard": {"min": 3.5, "max": 5.0, "default": 4.25},
	"advanced": {"min": 2.0, "max": 3.5, "default": 2.75},
	"expert": {"min": 1.5, "max": 2.0, "default": 1.75}
}

func get_version() -> String:
	return VERSION

func resolve_exposure(
	_template: ChallengeTemplate,
	difficulty: Dictionary,
	player_state: Dictionary
) -> float:
	var tier := str(difficulty.get("label", "beginner"))
	var timing: Dictionary = TIERS.get(tier, TIERS["beginner"])
	var axes: Dictionary = difficulty.get("axes", {})
	var complexity := float(axes.get("scene_complexity", 0.2))
	var similarity := float(axes.get("similarity", 0.2))
	var question_complexity := float(axes.get("question_complexity", 0.2))
	var compensation := (complexity + similarity + question_complexity) / 3.0
	var duration := lerpf(float(timing.get("default", 5.5)), float(timing.get("max", 6.0)), clampf(compensation - 0.35, 0.0, 0.65))
	if _uses_timing_accommodation(player_state):
		duration *= 1.20
	return clampf(duration, float(timing.get("min", 5.0)), float(timing.get("max", 6.0)) * 1.20)

func _uses_timing_accommodation(player_state: Dictionary) -> bool:
	var preferences: Variant = player_state.get("preferences", {})
	if preferences is Dictionary:
		return bool((preferences as Dictionary).get("comfortable_timing", false))
	return false
