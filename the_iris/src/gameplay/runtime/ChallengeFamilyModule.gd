extends RefCounted
class_name ChallengeFamilyModule
## Behavior contract implemented by each internal ChallengeFamily module.
## Shared runtime code calls these methods without inspecting family identity.

func get_family() -> ChallengeFamily:
	push_error("ChallengeFamilyModule.get_family must be implemented")
	return null

func get_templates() -> Array[ChallengeTemplate]:
	return []

func get_template(template_id: String) -> ChallengeTemplate:
	for template: ChallengeTemplate in get_templates():
		if template.template_id == template_id:
			return template
	return null

func get_default_template_id() -> String:
	var templates := get_templates()
	return templates[0].template_id if not templates.is_empty() else ""

func get_generator() -> ChallengeGenerator:
	push_error("ChallengeFamilyModule.get_generator must be implemented")
	return null

func get_validator() -> ChallengeValidator:
	push_error("ChallengeFamilyModule.get_validator must be implemented")
	return null

func get_difficulty_policy() -> DifficultyPolicy:
	push_error("ChallengeFamilyModule.get_difficulty_policy must be implemented")
	return null

func get_exposure_policy() -> ExposurePolicy:
	push_error("ChallengeFamilyModule.get_exposure_policy must be implemented")
	return null

func get_scoring_policy() -> ScoringPolicy:
	push_error("ChallengeFamilyModule.get_scoring_policy must be implemented")
	return null

func get_tutorial_profile() -> TutorialProfile:
	push_error("ChallengeFamilyModule.get_tutorial_profile must be implemented")
	return null

func get_presentation_profile() -> PresentationProfile:
	push_error("ChallengeFamilyModule.get_presentation_profile must be implemented")
	return null

func get_interaction_profile() -> InteractionProfile:
	return InteractionProfile.default_single_choice()

func get_fallback_instance(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	var generator := get_generator()
	return generator.generate(template, difficulty, exposure_duration_sec, seed_value) if generator else null
