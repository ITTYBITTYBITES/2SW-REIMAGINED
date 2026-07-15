extends ChallengeFamilyModule
class_name SceneInvestigationFamily
## Production Scene Investigation Challenge Type: Office, Kitchen, Workshop.

const FAMILY_ID: String = "scene_investigation"
const FAMILY_VERSION: String = "3"
const PRESENTATION_PROFILE_ID: String = "scene_investigation.production.v1"

const CONTENT_PATHS := [
	"res://src/LegacyMechanics/scene_investigation/content/office_v1.json",
	"res://src/LegacyMechanics/scene_investigation/content/kitchen_v1.json",
	"res://src/LegacyMechanics/scene_investigation/content/workshop_v1.json",
	"res://src/LegacyMechanics/scene_investigation/content/travel_desk_v1.json",
	"res://src/LegacyMechanics/scene_investigation/content/garden_bench_v1.json"
]

var _family: ChallengeFamily
var _templates: Array[ChallengeTemplate] = []
var _generator := SceneInvestigationGenerator.new()
var _validator := SceneInvestigationValidator.new()
var _difficulty_policy := SceneInvestigationDifficultyPolicy.new()
var _exposure_policy := SceneInvestigationExposurePolicy.new()
var _scoring_policy := SceneInvestigationScoringPolicy.new()
var _tutorial_profile := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "scene_investigation_tutorial",
	"tutorial_version": "2",
	"scene_path": "res://src/LegacyMechanics/scene_investigation/tutorial/SceneInvestigationTutorial.tscn",
	"replay_label": "Replay Scene Investigation Tutorial"
})
var _presentation_profile := PresentationProfile.new({
	"profile_id": PRESENTATION_PROFILE_ID,
	"profile_version": "1",
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "generated_scene_2d",
	"response_mode": "single_choice",
	"interaction_profile_id": "interaction.single_choice.v1",
	"metadata": {
		"renderer_script": SceneInvestigationGenerator.RENDERER_SCRIPT,
		"reveal_mode": "scene_evidence_highlight"
	}
})

func _init() -> void:
	_build_templates()
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Scene Investigation",
		"description": "Study a scene, then answer one question about what you noticed.",
		"gameplay_focus": ["Observation", "Recall", "Attention", "Spatial Reasoning"],
		"tutorial_id": "scene_investigation_tutorial",
		"tutorial_version": "2",
		"artwork_profile": {
			"id": "scene_investigation.editorial_2d.v1",
			"style_guide": "res://../docs/product/challenge-types/SCENE_INVESTIGATION_STYLE_GUIDE.md"
		},
		"music_profile": {"id": "scene_investigation.audio.v1"},
		"sound_profile": {"id": "scene_investigation.audio.v1"},
		"animation_profile": {"id": "scene_investigation.restrained.v1"},
		"presentation_profile_id": PRESENTATION_PROFILE_ID,
		"template_ids": template_ids,
		"generator_id": "scene_investigation_generator_v1",
		"validator_id": "scene_investigation_validator_v1",
		"difficulty_policy_id": "scene_investigation_difficulty_v1",
		"exposure_policy_id": "scene_investigation_exposure_v1",
		"accessibility_requirements": {
			"minimum_touch_target": 48,
			"supports_reduced_motion": true,
			"supports_comfortable_timing": true,
			"color_independent_reveal": true
		},
		"progress_rules_id": "scene_investigation_progress_v1",
		"metadata": {
			"content_role": "production",
			"player_visible": true,
			"witness_level_required": 1,
			"recommendation_weight": 1.10,
			"estimated_round_seconds": 15,
			"preview_image": "res://assets/gameplay/scene_investigation_preview.svg"
		}
	})

func _build_templates() -> void:
	for path: String in CONTENT_PATHS:
		var content := _load_content(path)
		if content.is_empty():
			continue
		var template_id := str(content.get("id", ""))
		var question_types_value: Variant = content.get("question_types", [])
		var question_types: Array = question_types_value if question_types_value is Array else []
		_templates.append(ChallengeTemplate.new({
			"template_id": template_id,
			"template_version": str(content.get("version", "1")),
			"family_id": FAMILY_ID,
			"title": content.get("title", template_id.capitalize()),
			"rules": {"response_mode": "single_choice", "question_count": 1},
			"layout": {"presentation_mode": "generated_scene_2d", "grid": "5x4"},
			"variables": {"object_pool_size": (content.get("objects", []) as Array).size()},
			"constraints": {
				"safe_inset": 0.05,
				"maximum_overlap_ratio": 0.18,
				"minimum_question_types": 4
			},
			"question_types": question_types,
			"distractor_rules": {"unique": true, "context_relevant": true},
			"difficulty_ranges": {
				"object_count": {"min": 8, "max": 18},
				"exposure_sec": {"min": 1.5, "max": 6.0}
			},
			"exposure_ranges": {
				"beginner": {"min": 5.0, "max": 6.0},
				"standard": {"min": 3.5, "max": 5.0},
				"advanced": {"min": 2.0, "max": 3.5},
				"expert": {"min": 1.5, "max": 2.0}
			},
			"accessibility_requirements": {
				"minimum_touch_target": 48,
				"color_independent_reveal": true
			},
			"scoring_modifiers": {"maximum_score": 1000},
			"metadata": {
				"content_data": content,
				"content_path": path,
				"content_role": "production",
				"family_version": FAMILY_VERSION,
				"validator_version": _validator.get_version(),
				"exposure_policy_version": _exposure_policy.get_version()
			}
		}))

func _load_content(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return (parsed as Dictionary) if parsed is Dictionary else {}

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

func get_fallback_instance(
	template: ChallengeTemplate,
	_difficulty: Dictionary,
	_exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	var safe_difficulty := {
		"label": "beginner",
		"policy_version": _difficulty_policy.get_version(),
		"axes": {
			"object_count_min": 8,
			"object_count_max": 8,
			"decorative_count": 0,
			"similarity": 0.0,
			"target_scale": 1.1,
			"distractor_similarity": 0.0,
			"question_complexity": 0.1,
			"scene_complexity": 0.1
		}
	}
	return _generator.generate(template, safe_difficulty, 6.0, seed_value + 100000)
