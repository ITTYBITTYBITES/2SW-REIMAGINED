extends ChallengeFamilyModule
class_name ObjectRecallFamily
## Production Object Recall with a reviewed object pool and four set/position templates.

const FAMILY_ID := "object_recall"
const FAMILY_VERSION := "2"
const PRESENTATION_ID := "object_recall.production.v1"

var _generator := ObjectRecallGenerator.new()
var _validator := ObjectRecallValidator.new()
var _difficulty := ObjectRecallDifficultyPolicy.new()
var _exposure := ObjectRecallExposurePolicy.new()
var _scoring := ObjectRecallScoringPolicy.new()
var _templates: Array[ChallengeTemplate] = []
var _family: ChallengeFamily
var _interaction := InteractionProfile.new({
	"profile_id": "interaction.object_recall.v1",
	"mode": "multiple_choice",
	"adapter_id": "multiple_choice",
	"payload_schema": {"type": "Array[String]"}
})
var _presentation := PresentationProfile.new({
	"profile_id": PRESENTATION_ID,
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "object_tray_2d",
	"response_mode": "multiple_choice",
	"interaction_profile_id": "interaction.object_recall.v1",
	"metadata": {
		"renderer_script": ObjectRecallGenerator.RENDERER_SCRIPT,
		"reveal_mode": "object_set_evidence"
	}
})
var _tutorial := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "object_recall_tutorial",
	"tutorial_version": "1",
	"scene_path": "res://src/LegacyMechanics/object_recall/tutorial/ObjectRecallTutorial.tscn",
	"replay_label": "Replay Object Recall Tutorial"
})

func _init() -> void:
	var definitions: Array[Dictionary] = [
		{"id": "seen_set_v1", "title": "Seen Set", "mode": "seen"},
		{"id": "missing_set_v1", "title": "Missing Set", "mode": "missing"},
		{"id": "position_group_v1", "title": "Top Row", "mode": "top_row"},
		{"id": "bookends_v1", "title": "Bookends", "mode": "bookends"}
	]
	for definition: Dictionary in definitions:
		_templates.append(ChallengeTemplate.new({
			"template_id": definition.id,
			"template_version": "2",
			"family_id": FAMILY_ID,
			"title": definition.title,
			"rules": {"response_mode": "multiple_choice"},
			"layout": {"presentation_mode": "object_tray_2d"},
			"variables": {"object_pool_size": _generator.get_object_pool_size()},
			"constraints": {"distinct_objects": true, "maximum_shown": 6},
			"question_types": [definition.mode],
			"distractor_rules": {"unique": true, "minimum_distractors": 2},
			"difficulty_ranges": {"tiers": 4},
			"exposure_ranges": {"min": 3.3, "max": 8.0},
			"fallback_rules": {"known_valid": true},
			"metadata": {"mode": definition.mode, "family_version": FAMILY_VERSION}
		}))
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Object Recall",
		"description": "Remember a clean set of objects, then select exactly what belongs.",
		"gameplay_focus": ["Recall", "Recognition", "Set Memory", "Position"],
		"tutorial_id": "object_recall_tutorial",
		"tutorial_version": "1",
		"artwork_profile": {"id": "object_recall.illustrated_tray.v2"},
		"music_profile": {"id": "object_recall.calm.v1"},
		"sound_profile": {"id": "object_recall.objects.v2"},
		"animation_profile": {"id": "object_recall.evidence_focus.v2"},
		"presentation_profile_id": PRESENTATION_ID,
		"template_ids": template_ids,
		"generator_id": "object_recall_generator_v2",
		"validator_id": "object_recall_validator_v2",
		"difficulty_policy_id": "object_recall_difficulty_v2",
		"exposure_policy_id": "object_recall_exposure_v2",
		"progress_rules_id": "object_recall_progress_v1",
		"accessibility_requirements": {
			"minimum_touch_target": 48,
			"supports_reduced_motion": true,
			"supports_comfortable_timing": true,
			"color_independent": true
		},
		"metadata": {
			"content_role": "production",
			"player_visible": true,
			"witness_level_required": 1,
			"recommendation_weight": 1.05,
			"estimated_round_seconds": 14,
			"preview_image": "res://assets/gameplay/object_recall_preview.svg"
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
