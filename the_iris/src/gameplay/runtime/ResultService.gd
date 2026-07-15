extends Node
## Builds the standard ChallengeResult by executing a family-owned ScoringPolicy.

signal result_created(result: ChallengeResult)

var _initialized: bool = false

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_initialized = true

func build_result(
	session_id: String,
	family: ChallengeFamily,
	template: ChallengeTemplate,
	instance: ChallengeInstance,
	scoring_policy: ScoringPolicy,
	player_state: Dictionary,
	player_response: Variant,
	reaction_ms: int
) -> ChallengeResult:
	var response_context := {
		"reaction_ms": maxi(reaction_ms, 0),
		"difficulty_label": instance.difficulty_label,
		"difficulty_axes": instance.difficulty_axes.duplicate(true),
		"exposure_duration_sec": instance.exposure_duration_sec
	}
	var resolved := scoring_policy.calculate_result(instance, player_response, response_context)
	var score := scoring_policy.calculate_score(resolved, template)
	var progress := scoring_policy.calculate_progress(resolved, score, player_state)
	if str(progress.get("record_key", "")).is_empty():
		progress["record_key"] = str(instance.metadata.get("progress_key", instance.family_id))
	var mastery_change := scoring_policy.calculate_mastery_change(resolved, score, player_state)
	progress["mastery_change"] = mastery_change.duplicate(true)
	var explanation := scoring_policy.explain_outcome(instance, player_response, resolved)

	var result := ChallengeResult.new()
	result.session_id = session_id
	result.instance_id = instance.instance_id
	result.family_id = instance.family_id
	result.template_id = instance.template_id
	result.title = str(instance.generated_scene.get("title", family.title))
	result.player_response = resolved.get("player_response", player_response)
	result.correct_answer = resolved.get("correct_answer", instance.correct_answer)
	result.outcome = str(resolved.get("outcome", "incorrect"))
	result.explanation = str(explanation.get("explanation", instance.explanation))
	result.gameplay_focus = family.gameplay_focus.duplicate()
	result.score = score
	result.progress_earned = progress.duplicate(true)
	result.difficulty_performance = {
		"label": instance.difficulty_label,
		"axes": instance.difficulty_axes.duplicate(true),
		"exposure_duration_sec": instance.exposure_duration_sec,
		"accuracy": float(resolved.get("accuracy", 0.0))
	}
	result.reaction_ms = maxi(reaction_ms, 0)
	var raw_reveal: Variant = explanation.get("reveal_data", {})
	result.reveal_data = (raw_reveal as Dictionary).duplicate(true) if raw_reveal is Dictionary else {}
	if not result.reveal_data.has("generated_scene"):
		result.reveal_data["generated_scene"] = instance.generated_scene.duplicate(true)
	result.reveal_data["summary"] = str(explanation.get("summary", ""))
	result.reveal_data["where_to_look"] = str(explanation.get("where_to_look", ""))
	result.replay_metadata = {
		"family_id": instance.family_id,
		"template_id": instance.template_id,
		"seed": instance.seed,
		"progress_key": str(progress.get("record_key", instance.family_id))
	}
	result.metadata = {
		"content_version": instance.content_version,
		"generator_version": instance.generator_version,
		"validator_version": instance.validator_version,
		"scoring_policy_version": scoring_policy.get_version(),
		"scene_signature": str(instance.metadata.get("scene_signature", "")),
		"resolved_result": resolved.duplicate(true)
	}
	result_created.emit(result)
	return result
