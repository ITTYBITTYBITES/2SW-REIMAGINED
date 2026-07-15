extends ChallengeFamilyModule
class_name PatternRecallFamily
## Production Pattern Recall with spatial paths, symbol sequences, and cumulative builds.

const FAMILY_ID := "pattern_recall"
const FAMILY_VERSION := "2"
const PRESENTATION_ID := "pattern_recall.production.v1"

var _generator := PatternRecallGenerator.new()
var _validator := PatternRecallValidator.new()
var _difficulty := PatternRecallDifficultyPolicy.new()
var _exposure := PatternRecallExposurePolicy.new()
var _scoring := PatternRecallScoringPolicy.new()
var _templates: Array[ChallengeTemplate] = []
var _family: ChallengeFamily
var _interaction := InteractionProfile.new({
	"profile_id": "interaction.pattern_recall.v1",
	"mode": "sequence_input",
	"adapter_id": "sequence_input",
	"payload_schema": {"type": "Array[String]"}
})
var _presentation := PresentationProfile.new({
	"profile_id": PRESENTATION_ID,
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "pattern_sequence_2d",
	"response_mode": "sequence_input",
	"interaction_profile_id": "interaction.pattern_recall.v1",
	"metadata": {
		"renderer_script": PatternRecallGenerator.RENDERER_SCRIPT,
		"reveal_mode": "numbered_pattern_evidence"
	}
})
var _tutorial := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "pattern_recall_tutorial",
	"tutorial_version": "1",
	"scene_path": "res://src/LegacyMechanics/pattern_recall/tutorial/PatternRecallTutorial.tscn",
	"replay_label": "Replay Pattern Recall Tutorial"
})

func _init() -> void:
	var definitions: Array[Dictionary] = [
		{"id": "grid_path_v1", "title": "Grid Path", "mode": "grid", "style": "single_step"},
		{"id": "shape_sequence_v1", "title": "Shape Sequence", "mode": "shapes", "style": "symbol_pulse"},
		{"id": "pattern_build_v1", "title": "Pattern Build", "mode": "build", "style": "cumulative_build"}
	]
	for definition: Dictionary in definitions:
		_templates.append(ChallengeTemplate.new({
			"template_id": definition.id,
			"template_version": "2",
			"family_id": FAMILY_ID,
			"title": definition.title,
			"rules": {"response_mode": "sequence_input"},
			"layout": {"presentation_mode": "pattern_sequence_2d"},
			"variables": {"symbol_pool_size": PatternRecallGenerator.SYMBOLS.size()},
			"constraints": {"minimum_sequence": 3, "no_immediate_repeat": true},
			"question_types": [definition.mode],
			"distractor_rules": {"all_tokens_available": true},
			"difficulty_ranges": {"tiers": 4},
			"exposure_ranges": {"min": 3.0, "max": 6.0},
			"fallback_rules": {"known_valid": true},
			"metadata": {
				"mode": definition.mode,
				"presentation_style": definition.style,
				"family_version": FAMILY_VERSION
			}
		}))
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Pattern Recall",
		"description": "Watch an abstract pattern unfold, then repeat it in the same order.",
		"gameplay_focus": ["Pattern Recognition", "Sequential Recall", "Spatial Recall"],
		"tutorial_id": "pattern_recall_tutorial",
		"tutorial_version": "1",
		"artwork_profile": {"id": "pattern_recall.geometric_v2"},
		"music_profile": {"id": "pattern_recall.pulse.v1"},
		"sound_profile": {"id": "pattern_recall.sequence.v2"},
		"animation_profile": {"id": "pattern_recall.discrete_steps.v2"},
		"presentation_profile_id": PRESENTATION_ID,
		"template_ids": template_ids,
		"generator_id": "pattern_recall_generator_v2",
		"validator_id": "pattern_recall_validator_v2",
		"difficulty_policy_id": "pattern_recall_difficulty_v2",
		"exposure_policy_id": "pattern_recall_exposure_v2",
		"progress_rules_id": "pattern_recall_progress_v1",
		"accessibility_requirements": {
			"minimum_touch_target": 48,
			"supports_reduced_motion": true,
			"supports_comfortable_timing": true,
			"color_independent": true
		},
		"metadata": {
			"content_role": "production",
			"player_visible": true,
			"witness_level_required": 2,
			"recommendation_weight": 0.95,
			"estimated_round_seconds": 15,
			"preview_image": "res://assets/gameplay/pattern_recall_preview.svg"
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
