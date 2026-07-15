extends ChallengeFamilyModule
class_name SceneInvestigationFixtureFamily
## Internal deterministic regression family. It is not player-visible content.

const FAMILY_ID: String = "scene_investigation_fixtures"
const FAMILY_VERSION: String = "1"
const PRESENTATION_PROFILE_ID: String = "scene_investigation.fixtures"

var _family: ChallengeFamily
var _templates: Array[ChallengeTemplate] = []
var _generator := FixtureSceneInvestigationGenerator.new()
var _validator := FixtureSceneInvestigationValidator.new()
var _difficulty_policy := FixtureSceneInvestigationDifficultyPolicy.new()
var _exposure_policy := FixtureSceneInvestigationExposurePolicy.new()
var _scoring_policy := FixtureSceneInvestigationScoringPolicy.new()
var _tutorial_profile := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "fixture_tutorial",
	"tutorial_version": "1",
	"scene_path": "res://src/LegacyMechanics/scene_investigation/tutorial/SceneInvestigationFixtureTutorial.tscn",
	"replay_label": "Replay Regression Tutorial"
})
var _presentation_profile := PresentationProfile.new({
	"profile_id": PRESENTATION_PROFILE_ID,
	"profile_version": "1",
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "scene_image",
	"response_mode": "single_choice"
})

func _init() -> void:
	_build_fixture_templates()
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Scene Investigation Fixtures",
		"description": "Deterministic internal regression content.",
		"gameplay_focus": ["Regression"],
		"tutorial_id": "fixture_tutorial",
		"tutorial_version": "1",
		"presentation_profile_id": PRESENTATION_PROFILE_ID,
		"template_ids": template_ids,
		"generator_id": "fixture_scene_investigation_generator",
		"validator_id": "fixture_scene_investigation_validator",
		"difficulty_policy_id": "fixture_scene_investigation_difficulty",
		"exposure_policy_id": "fixture_scene_investigation_exposure",
		"progress_rules_id": "fixture_scene_investigation_progress",
		"metadata": {
			"content_role": "regression_compatibility",
			"player_visible": false
		}
	})

func _build_fixture_templates() -> void:
	var challenges: Array[Dictionary] = ChallengeRegistry.get_all_challenges() if ChallengeRegistry else []
	for challenge: Dictionary in challenges:
		var challenge_id := str(challenge.get("id", ""))
		if challenge_id.is_empty():
			continue
		_templates.append(ChallengeTemplate.new({
			"template_id": challenge_id,
			"template_version": "1",
			"family_id": FAMILY_ID,
			"title": challenge.get("title", challenge_id.capitalize()),
			"rules": {"response_mode": "single_choice"},
			"layout": {"presentation_mode": "scene_image"},
			"constraints": {"deterministic_fixture": true},
			"question_types": ["single_choice"],
			"distractor_rules": {"source": "fixture"},
			"difficulty_ranges": {"fixture_axes": {"content_locked": true}},
			"exposure_ranges": {"minimum_sec": 2.0, "maximum_sec": 2.0, "default_sec": 2.0},
			"accessibility_requirements": {"minimum_touch_target": 48},
			"scoring_modifiers": {"correct_score": 100},
			"metadata": {
				"fixture_data": challenge,
				"family_version": FAMILY_VERSION,
				"validator_version": _validator.get_version(),
				"exposure_policy_version": _exposure_policy.get_version(),
				"content_role": "regression_fixture"
			}
		}))

func get_family() -> ChallengeFamily:
	return _family

func get_templates() -> Array[ChallengeTemplate]:
	return _templates

func get_generator() -> ChallengeGenerator:
	return _generator

func get_validator() -> ChallengeValidator:
	return _validator

func get_difficulty_policy() -> DifficultyPolicy:
	return _difficulty_policy

func get_exposure_policy() -> ExposurePolicy:
	return _exposure_policy

func get_scoring_policy() -> ScoringPolicy:
	return _scoring_policy

func get_tutorial_profile() -> TutorialProfile:
	return _tutorial_profile

func get_presentation_profile() -> PresentationProfile:
	return _presentation_profile
