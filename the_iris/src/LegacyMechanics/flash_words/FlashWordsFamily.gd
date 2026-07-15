extends ChallengeFamilyModule
class_name FlashWordsFamily
## Production Flash Words Challenge Type.

const FAMILY_ID: String = "flash_words"
const FAMILY_VERSION: String = "2"
const PRESENTATION_PROFILE_ID: String = "flash_words.production.v1"
const WORDS_PATH: String = "res://src/LegacyMechanics/flash_words/content/words_v1.json"
const TEMPLATES_PATH: String = "res://src/LegacyMechanics/flash_words/content/templates_v1.json"

var _family: ChallengeFamily
var _templates: Array[ChallengeTemplate] = []
var _word_entries: Array = []
var _generator := FlashWordsGenerator.new()
var _validator := FlashWordsValidator.new()
var _difficulty := FlashWordsDifficultyPolicy.new()
var _exposure := FlashWordsExposurePolicy.new()
var _scoring := FlashWordsScoringPolicy.new()
var _tutorial_profile := TutorialProfile.new({
	"family_id": FAMILY_ID,
	"tutorial_id": "flash_words_tutorial",
	"tutorial_version": "1",
	"scene_path": "res://src/LegacyMechanics/flash_words/tutorial/FlashWordsTutorial.tscn",
	"replay_label": "Replay Flash Words Tutorial"
})
var _presentation := PresentationProfile.new({
	"profile_id": PRESENTATION_PROFILE_ID,
	"profile_version": "1",
	"presentation_route": "observation",
	"response_route": "memory_question",
	"result_route": "result",
	"presentation_mode": "flash_typography_sequence",
	"response_mode": "single_choice",
	"interaction_profile_id": "interaction.single_choice.v1",
	"metadata": {"renderer_script": FlashWordsGenerator.RENDERER_SCRIPT, "reveal_mode": "word_sequence_comparison"}
})

func _init() -> void:
	_load_content()
	_build_templates()
	var template_ids: Array[String] = []
	for template: ChallengeTemplate in _templates:
		template_ids.append(template.template_id)
	_family = ChallengeFamily.new({
		"family_id": FAMILY_ID,
		"family_version": FAMILY_VERSION,
		"title": "Flash Words",
		"description": "Catch a word or short sequence in a quick flash.",
		"gameplay_focus": ["Recognition", "Recall", "Focus", "Sequence Order"],
		"tutorial_id": "flash_words_tutorial",
		"tutorial_version": "1",
		"artwork_profile": {"id": "flash_words.typography.v1"},
		"music_profile": {"id": "flash_words.rhythmic.v1"},
		"sound_profile": {"id": "flash_words.rhythmic.v1"},
		"animation_profile": {"id": "flash_words.opacity.v1"},
		"presentation_profile_id": PRESENTATION_PROFILE_ID,
		"template_ids": template_ids,
		"generator_id": "flash_words_generator_v1",
		"validator_id": "flash_words_validator_v1",
		"difficulty_policy_id": "flash_words_difficulty_v1",
		"exposure_policy_id": "flash_words_exposure_v1",
		"progress_rules_id": "flash_words_progress_v1",
		"accessibility_requirements": {
			"minimum_touch_target": 48,
			"supports_reduced_motion": true,
			"supports_reading_comfort": true,
			"color_independent": true
		},
		"metadata": {
			"content_role": "production",
			"player_visible": true,
			"witness_level_required": 1,
			"recommendation_weight": 1.05,
			"estimated_round_seconds": 12,
			"preview_image": "res://assets/gameplay/flash_words/flash_words_preview.svg"
		}
	})

func _load_content() -> void:
	var data := _load_json(WORDS_PATH)
	var words_value: Variant = data.get("words", [])
	_word_entries = words_value if words_value is Array else []

func _build_templates() -> void:
	var data := _load_json(TEMPLATES_PATH)
	var templates_value: Variant = data.get("templates", [])
	if not (templates_value is Array):
		return
	for value: Variant in templates_value:
		if not (value is Dictionary):
			continue
		var definition: Dictionary = value
		var template_id := str(definition.get("id", ""))
		var mode := str(definition.get("mode", "single"))
		_templates.append(ChallengeTemplate.new({
			"template_id": template_id,
			"template_version": "1",
			"family_id": FAMILY_ID,
			"title": definition.get("title", template_id.capitalize()),
			"rules": {"response_mode": "single_choice", "mode": mode},
			"layout": {"presentation_mode": "flash_typography_sequence"},
			"variables": {"word_count": _word_entries.size()},
			"constraints": {"letters_only": true, "maximum_word_length": 10},
			"question_types": definition.get("question_types", []),
			"distractor_rules": {"allowed": definition.get("allowed_distractors", [])},
			"difficulty_ranges": {"word_length": {"min": 3, "max": 10}, "sequence_length": {"min": 1, "max": 5}},
			"exposure_ranges": {"minimum_sec": 0.75, "maximum_sec": 4.0},
			"accessibility_requirements": {"reading_comfort_mode": true, "color_independent": true},
			"scoring_modifiers": {"maximum_score": 1000},
			"metadata": {
				"mode": mode,
				"description": definition.get("description", ""),
				"word_entries": _word_entries,
				"family_version": FAMILY_VERSION,
				"validator_version": _validator.get_version(),
				"exposure_policy_version": _exposure.get_version(),
				"content_role": "production"
			}
		}))

func _load_json(path: String) -> Dictionary:
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
	return _difficulty

func get_exposure_policy() -> ExposurePolicy:
	return _exposure

func get_scoring_policy() -> ScoringPolicy:
	return _scoring

func get_tutorial_profile() -> TutorialProfile:
	return _tutorial_profile

func get_presentation_profile() -> PresentationProfile:
	return _presentation

func get_fallback_instance(template: ChallengeTemplate, _difficulty_data: Dictionary, _exposure_duration_sec: float, seed_value: int) -> ChallengeInstance:
	var mode := str(template.metadata.get("mode", "single"))
	var safe_axes := {
		"mode": mode,
		"word_length_min": 3,
		"word_length_max": 5,
		"similarity": 0.0,
		"distractor_categories": ["similar_length", "semantic"],
		"sequence_length": 1 if mode == "single" else 2 if mode == "pair" else 3,
		"reading_comfort_mode": true,
		"recent_words": []
	}
	var safe_difficulty := {"label": "beginner", "policy_version": _difficulty.get_version(), "axes": safe_axes}
	var exposure := _exposure.resolve_exposure(template, safe_difficulty, {})
	for attempt: int in range(50):
		var instance := _generator.generate(template, safe_difficulty, exposure, seed_value + 100000 + attempt)
		if _validator.validate(instance).is_valid:
			return instance
	return null
