extends ChallengeFamilyModule
class_name SpotDifferenceFamily
## Production comparative change detection with paired and sequential templates.

const FAMILY_ID := "spot_the_difference"
const FAMILY_VERSION := "2"
const PRESENTATION_ID := "spot_the_difference.production.v1"

var _generator := SpotDifferenceGenerator.new()
var _validator := SpotDifferenceValidator.new()
var _difficulty := SpotDifferenceDifficultyPolicy.new()
var _exposure := SpotDifferenceExposurePolicy.new()
var _scoring := SpotDifferenceScoringPolicy.new()
var _templates: Array[ChallengeTemplate] = []
var _family: ChallengeFamily
var _interaction := InteractionProfile.new({
	"profile_id": "interaction.spot_difference.v1",
	"mode": "spatial_tap",
	"adapter_id": "spatial_tap",
	"accessible_adapter_id": "single_choice",
	"payload_schema": {"type": "normalized_point_or_target"}
})
var _presentation := PresentationProfile.new({
	"profile_id": PRESENTATION_ID,
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "paired_change_scene_2d",
	"response_mode": "spatial_tap",
	"interaction_profile_id": "interaction.spot_difference.v1",
	"metadata": {
		"renderer_script": SpotDifferenceGenerator.RENDERER_SCRIPT,
		"reveal_mode": "paired_change_evidence"
	}
})
var _tutorial := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "spot_difference_tutorial",
	"tutorial_version": "1",
	"scene_path": "res://src/LegacyMechanics/spot_the_difference/tutorial/SpotDifferenceTutorial.tscn",
	"replay_label": "Replay Spot the Difference Tutorial"
})

func _init() -> void:
	var definitions: Array[Dictionary] = [
		{"id": "side_by_side_presence_v1", "title": "Presence Change", "mode": "presence"},
		{"id": "side_by_side_attribute_v1", "title": "Attribute Change", "mode": "attribute"},
		{"id": "sequential_switch_v1", "title": "Sequential Switch", "mode": "sequential"},
		{"id": "arrangement_shift_v1", "title": "Arrangement Shift", "mode": "arrangement"}
	]
	for definition: Dictionary in definitions:
		_templates.append(ChallengeTemplate.new({
			"template_id": definition.id,
			"template_version": "2",
			"family_id": FAMILY_ID,
			"title": definition.title,
			"rules": {"response_mode": "spatial_tap"},
			"layout": {"presentation_mode": "paired_change_scene_2d"},
			"variables": {"object_pool_size": SpotDifferenceGenerator.OBJECTS.size()},
			"constraints": {"exact_change_count": 1, "non_overlapping_slots": true},
			"question_types": [definition.mode],
			"distractor_rules": {"accessible_options": 4},
			"difficulty_ranges": {"tiers": 4},
			"exposure_ranges": {"min": 4.5, "max": 12.0},
			"fallback_rules": {"known_valid": true},
			"metadata": {"mode": definition.mode, "family_version": FAMILY_VERSION}
		}))
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Spot the Difference",
		"description": "Compare two visual moments and tap the one detail that changed.",
		"gameplay_focus": ["Observation", "Change Detection", "Attention", "Visual Search", "Spatial Matching"],
		"tutorial_id": "spot_difference_tutorial",
		"tutorial_version": "1",
		"artwork_profile": {"id": "spot_difference.editorial_pairs.v2"},
		"music_profile": {"id": "spot_difference.quiet_focus.v1"},
		"sound_profile": {"id": "spot_difference.compare.v2"},
		"animation_profile": {"id": "spot_difference.one_pass.v2"},
		"presentation_profile_id": PRESENTATION_ID,
		"template_ids": template_ids,
		"generator_id": "spot_difference_generator_v2",
		"validator_id": "spot_difference_validator_v2",
		"difficulty_policy_id": "spot_difference_difficulty_v2",
		"exposure_policy_id": "spot_difference_exposure_v2",
		"progress_rules_id": "spot_difference_progress_v1",
		"accessibility_requirements": {
			"spatial_tap": true,
			"accessible_target_choice": true,
			"color_assistance": true,
			"minimum_touch_target": 48,
			"supports_reduced_motion": true
		},
		"metadata": {
			"content_role": "production",
			"player_visible": true,
			"witness_level_required": 1,
			"recommendation_weight": 1.0,
			"estimated_round_seconds": 16,
			"preview_image": "res://assets/gameplay/spot_difference_preview.svg"
		}
	})

func get_family() -> ChallengeFamily:
	return _family

func get_templates() -> Array[ChallengeTemplate]:
	return _templates

func get_generator() -> ChallengeGenerator:
	return _generator

func get_validator() -> ChallengeValidator:
	return _validator

func get_difficulty_policy() -> DifficultyPolicy:
	return _difficulty

func get_exposure_policy() -> ExposurePolicy:
	return _exposure

func get_scoring_policy() -> ScoringPolicy:
	return _scoring

func get_tutorial_profile() -> TutorialProfile:
	return _tutorial

func get_presentation_profile() -> PresentationProfile:
	return _presentation

func get_interaction_profile() -> InteractionProfile:
	return _interaction
