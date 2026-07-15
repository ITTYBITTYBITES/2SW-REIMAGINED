extends ChallengeGenerator
class_name FixtureSceneInvestigationGenerator
## Converts a deterministic legacy fixture template into a ChallengeInstance.
## No random content is introduced in Gate 1; the seed remains part of the
## complete reproduction identity and is exercised by the shared runtime.

const VERSION: String = "1"
const CONTENT_VERSION: String = "regression-fixtures-v1"

func get_version() -> String:
	return VERSION

func generate(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	var raw_fixture: Variant = template.metadata.get("fixture_data", {})
	if not (raw_fixture is Dictionary):
		return null
	var fixture: Dictionary = (raw_fixture as Dictionary).duplicate(true)
	var fixture_id := str(fixture.get("id", template.template_id))
	var family_version := str(template.metadata.get("family_version", "1"))
	var instance := ChallengeInstance.new({
		"instance_id": "%s:%s:%d" % [template.family_id, template.template_id, seed_value],
		"family_id": template.family_id,
		"family_version": family_version,
		"template_id": template.template_id,
		"template_version": template.template_version,
		"generator_version": VERSION,
		"validator_version": str(template.metadata.get("validator_version", "1")),
		"difficulty_policy_version": str(difficulty.get("policy_version", "1")),
		"exposure_policy_version": str(template.metadata.get("exposure_policy_version", "1")),
		"content_version": CONTENT_VERSION,
		"seed": seed_value,
		"difficulty_label": str(difficulty.get("label", "fixture")),
		"difficulty_axes": difficulty.get("axes", {}),
		"exposure_duration_sec": exposure_duration_sec,
		"generated_scene": {
			"title": fixture.get("title", "Scene Investigation"),
			"description": fixture.get("description", ""),
			"image_path": fixture.get("image_path", "")
		},
		"question": {
			"type": "single_choice",
			"prompt": fixture.get("question", "What did you notice?")
		},
		"answer_options": fixture.get("options", []),
		"correct_answer": fixture.get("correct", null),
		"explanation": fixture.get("detail", ""),
		"validation_metadata": {
			"source": "deterministic_regression_fixture",
			"fixture_id": fixture_id
		},
		"metadata": {
			"fixture_id": fixture_id,
			"progress_key": fixture_id,
			"short_description": fixture.get("short_description", ""),
			"category": fixture.get("category", "observation")
		}
	})
	return instance
