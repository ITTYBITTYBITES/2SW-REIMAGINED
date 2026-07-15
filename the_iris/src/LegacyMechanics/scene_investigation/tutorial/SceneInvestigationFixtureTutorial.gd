extends Control
## Hidden regression-family tutorial stub. Player-facing UI never lists this family.

signal completed(family_id: String, tutorial_version: String)
@warning_ignore("unused_signal")
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

func configure(family: ChallengeFamily, profile: TutorialProfile) -> void:
	completed.emit(family.family_id, profile.tutorial_version)
	practice_requested.emit(family.family_id, "challenge_01")
