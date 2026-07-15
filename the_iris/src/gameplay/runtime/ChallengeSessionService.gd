extends Node
## Shared Challenge Runtime orchestrator.
##
## The service executes registered family contracts and never branches on a
## concrete family ID. Gate 1 routes deterministic fixtures through the entire
## session, result, progress, recommendation, and return pipeline.

signal session_started(session_id: String, family_id: String, template_id: String)
signal instance_ready(instance: ChallengeInstance)
signal validation_rejected(attempt: int, validation: ChallengeValidationResult)
signal response_captured(response: Variant)
signal session_result_ready(result: ChallengeResult)
signal session_failed(reason: String)
signal session_completed(session_id: String)

const MAX_GENERATION_ATTEMPTS: int = 3

var _initialized: bool = false
var _active_session: Dictionary = {}
var _pipeline_trace: Array[String] = []
var _last_pipeline_trace: Array[String] = []

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_initialized = true

func start_recommended_session(source: String = "play_now", seed_override: int = -1) -> bool:
	var player_state := PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var recommendation := RecommendationService.recommend_start(player_state) if RecommendationService else {}
	if recommendation.is_empty():
		return _fail("No Challenge Type is available")
	return _request_family_session(
		str(recommendation.get("family_id", "")),
		str(recommendation.get("template_id", "")),
		source,
		seed_override
	)

func start_continue_session(source: String = "continue") -> bool:
	var player_state := PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var recommendation := RecommendationService.recommend_continue(player_state) if RecommendationService else {}
	if recommendation.is_empty():
		return start_recommended_session(source)
	var context: Dictionary = {}
	var program_id: String = str(recommendation.get("program_id", ""))
	if not program_id.is_empty():
		context = {"program_id": program_id, "program_title": recommendation.get("program_title", "Program")}
	return _request_family_session(
		str(recommendation.get("family_id", "")),
		str(recommendation.get("template_id", "")),
		source,
		-1,
		context
	)

func start_program_session(program_id: String, source: String = "program") -> bool:
	if not ProgramService or not PlayerProgressService:
		return _fail("Programs are unavailable")
	if not ProgramService.begin_program(program_id):
		return _fail("Program is locked or unavailable")
	var recommendation: Dictionary = ProgramService.recommend_for_program(
		program_id,
		PlayerProgressService.get_player_state()
	)
	if recommendation.is_empty():
		return _fail("Program has no available Challenge Type")
	return _request_family_session(
		str(recommendation.get("family_id", "")),
		str(recommendation.get("template_id", "")),
		source,
		-1,
		{"program_id": program_id, "program_title": recommendation.get("program_title", "Program")}
	)

func start_template_session(template_id: String, source: String = "challenge_library", seed_override: int = -1) -> bool:
	var family_id := ChallengeFamilyRegistry.find_family_id_for_template(template_id) if ChallengeFamilyRegistry else ""
	if family_id.is_empty():
		return _fail("No registered family owns template %s" % template_id)
	return _request_family_session(family_id, template_id, source, seed_override)

func _request_family_session(
	family_id: String,
	template_id: String,
	source: String,
	seed_override: int,
	session_context: Dictionary = {}
) -> bool:
	if source != "tutorial" and needs_tutorial(family_id):
		if NavigationService:
			return NavigationService.navigate_to("tutorial", {
				"family_id": family_id,
				"pending_template_id": template_id,
				"launch_source": source,
				"session_context": session_context.duplicate(true)
			})
		return false
	return start_family_session(family_id, template_id, source, seed_override, session_context)

func needs_tutorial(family_id: String) -> bool:
	if SettingsService and not bool(SettingsService.get_value("show_tutorials", true)):
		return false
	if not ChallengeFamilyRegistry or not ProfileService:
		return false
	var family := ChallengeFamilyRegistry.get_family(family_id)
	if family == null:
		return false
	var preferences: Dictionary = ProfileService.profile.get("preferences", {})
	var versions: Dictionary = preferences.get("family_tutorial_versions", {})
	return str(versions.get(family_id, "")) != family.tutorial_version

func start_family_session(
	family_id: String,
	template_id: String = "",
	source: String = "direct",
	seed_override: int = -1,
	session_context: Dictionary = {}
) -> bool:
	var preparation_started_at: int = Time.get_ticks_usec()
	if not _initialized:
		initialize()
	_pipeline_trace = []
	_trace(source)
	_trace("challenge_session")

	var module := ChallengeFamilyRegistry.get_module(family_id) if ChallengeFamilyRegistry else null
	if not module:
		return _fail("ChallengeFamily is not registered: %s" % family_id)
	_trace("challenge_family")
	var family := module.get_family()
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	if RecommendationService and not RecommendationService.is_family_unlocked(family_id, player_state):
		return _fail("Challenge Type requires a higher Witness Level")

	var resolved_template_id := template_id if not template_id.is_empty() else module.get_default_template_id()
	var template := module.get_template(resolved_template_id)
	if not template:
		return _fail("ChallengeTemplate is not registered: %s" % resolved_template_id)
	_trace("challenge_template")

	var difficulty_policy := module.get_difficulty_policy()
	var difficulty := difficulty_policy.resolve_difficulty(player_state, family, template)
	_trace("difficulty_policy")

	var exposure_policy := module.get_exposure_policy()
	var exposure_duration_sec := exposure_policy.resolve_exposure(template, difficulty, player_state)
	_trace("exposure_policy")

	var generator := module.get_generator()
	var validator := module.get_validator()
	var initial_seed := seed_override if seed_override >= 0 else _new_seed()
	var accepted_instance: ChallengeInstance = null
	var accepted_validation: ChallengeValidationResult = null
	var generation_attempts: int = 0

	for attempt: int in range(MAX_GENERATION_ATTEMPTS):
		generation_attempts = attempt + 1
		var attempt_seed := initial_seed + attempt
		var candidate := generator.generate(template, difficulty, exposure_duration_sec, attempt_seed)
		_trace_once("generator")
		var validation := validator.validate(candidate)
		_trace_once("validator")
		if validation.is_valid and candidate != null:
			var signature := str(candidate.metadata.get("scene_signature", ""))
			if PlayerProgressService and PlayerProgressService.has_recent_signature(family.family_id, signature):
				validation = ChallengeValidationResult.rejected(
					"Scene signature appeared in recent history",
					"history.duplicate_signature",
					{"scene_signature": signature}
				)
		if validation.is_valid:
			accepted_instance = candidate
			accepted_validation = validation
			break
		validation_rejected.emit(attempt + 1, validation)
		if AnalyticsService:
			AnalyticsService.log_event("challenge_candidate_rejected", {
				"family_id": family.family_id,
				"template_id": template.template_id,
				"attempt": attempt + 1,
				"rule_id": validation.rule_id,
				"reason": validation.reason
			})

	if accepted_instance == null:
		accepted_instance = module.get_fallback_instance(template, difficulty, exposure_duration_sec, initial_seed)
		accepted_validation = validator.validate(accepted_instance)
		if accepted_validation != null and accepted_validation.is_valid and accepted_instance != null:
			var fallback_signature := str(accepted_instance.metadata.get("scene_signature", ""))
			if PlayerProgressService and PlayerProgressService.has_recent_signature(family.family_id, fallback_signature):
				accepted_validation = ChallengeValidationResult.rejected(
					"Fallback scene appeared in recent history",
					"history.duplicate_signature"
				)
		if accepted_validation == null or not accepted_validation.is_valid:
			return _fail("Generation and fallback validation failed")

	accepted_instance.validation_metadata = accepted_validation.to_dictionary()
	_trace("challenge_instance")
	var presentation := module.get_presentation_profile()
	var interaction := module.get_interaction_profile()
	var session_id := "session_%d" % Time.get_ticks_usec()
	_active_session = {
		"session_id": session_id,
		"source": source,
		"context": session_context.duplicate(true),
		"module": module,
		"family": family,
		"template": template,
		"difficulty": difficulty.duplicate(true),
		"exposure_duration_sec": exposure_duration_sec,
		"instance": accepted_instance,
		"presentation": presentation,
		"interaction": interaction,
		"result": null,
		"recommendation": {}
	}
	_set_transient_instance(accepted_instance)
	session_started.emit(session_id, family.family_id, template.template_id)
	instance_ready.emit(accepted_instance)
	_trace("presentation")
	if AnalyticsService:
		AnalyticsService.log_event("challenge_prepared", {
			"family_id": family.family_id,
			"template_id": template.template_id,
			"duration_ms": snappedf(float(Time.get_ticks_usec() - preparation_started_at) / 1000.0, 0.01),
			"attempts": generation_attempts
		})
	if NavigationService:
		NavigationService.navigate_to(presentation.presentation_route, _build_route_params(accepted_instance))
	return true

func advance_to_response() -> bool:
	if not has_active_session():
		return false
	var presentation: PresentationProfile = _active_session.get("presentation")
	var instance: ChallengeInstance = _active_session.get("instance")
	if NavigationService:
		return NavigationService.navigate_to(presentation.response_route, _build_route_params(instance))
	return false

func submit_response(player_response: Variant, reaction_ms: int) -> Dictionary:
	if not has_active_session():
		_fail("Cannot capture a response without an active session")
		return {}
	var existing_result: Variant = _active_session.get("result")
	if existing_result is ChallengeResult:
		return (existing_result as ChallengeResult).to_dictionary()
	_trace("player_response")
	response_captured.emit(player_response)
	var family: ChallengeFamily = _active_session.get("family")
	var template: ChallengeTemplate = _active_session.get("template")
	var instance: ChallengeInstance = _active_session.get("instance")
	var module: ChallengeFamilyModule = _active_session.get("module")
	var scoring_policy := module.get_scoring_policy()
	var player_state := PlayerProgressService.get_player_state()
	var result := ResultService.build_result(
		str(_active_session.get("session_id", "")),
		family,
		template,
		instance,
		scoring_policy,
		player_state,
		player_response,
		reaction_ms
	)
	_trace("result_contract")
	var session_context: Dictionary = _active_session.get("context", {})
	var program_id: String = str(session_context.get("program_id", ""))
	if not program_id.is_empty():
		result.metadata["program_id"] = program_id
		result.metadata["program_title"] = session_context.get("program_title", "Program")
	PlayerProgressService.record_result(result)
	_trace("player_progress")
	var program_update: Dictionary = {}
	if not program_id.is_empty() and ProgramService:
		program_update = ProgramService.record_result(program_id, result)
		result.metadata["program_progress"] = program_update.duplicate(true)
		if AchievementService:
			var additional_unlocks: Array[String] = AchievementService.evaluate_after_result(result)
			var earned_unlocks: Array = result.progress_earned.get("achievements_unlocked", [])
			for achievement_id: String in additional_unlocks:
				if not earned_unlocks.has(achievement_id):
					earned_unlocks.append(achievement_id)
			result.progress_earned["achievements_unlocked"] = earned_unlocks
	player_state = PlayerProgressService.get_player_state()
	var recommendation: Dictionary
	if bool(program_update.get("run_completed", false)):
		recommendation = {
			"program_id": program_id,
			"program_complete": true,
			"reason": "program_complete",
			"reason_text": "%s complete" % str(program_update.get("program_title", "Program"))
		}
	elif not program_id.is_empty() and ProgramService:
		recommendation = ProgramService.recommend_for_program(program_id, player_state)
	else:
		recommendation = RecommendationService.recommend_next(
			player_state,
			family.family_id,
			template.template_id,
			result
		)
	result.recommendation = recommendation.duplicate(true)
	_active_session["result"] = result
	_active_session["recommendation"] = recommendation
	_trace("recommendation")
	var result_data := result.to_dictionary()
	if AppState:
		AppState.set_transient("last_result", result_data)
	if AnalyticsService:
		AnalyticsService.log_event("challenge_response_captured", {
			"family_id": family.family_id,
			"template_id": template.template_id,
			"outcome": result.outcome,
			"reaction_ms": result.reaction_ms
		})
	session_result_ready.emit(result)
	return result_data

func present_result() -> bool:
	if not has_active_session():
		return false
	var result: ChallengeResult = _active_session.get("result")
	var presentation: PresentationProfile = _active_session.get("presentation")
	if result == null or not NavigationService:
		return false
	return NavigationService.navigate_to(presentation.result_route, result.to_dictionary())

func replay_current() -> bool:
	if not has_active_session():
		return false
	var instance: ChallengeInstance = _active_session.get("instance")
	var context: Dictionary = _active_session.get("context", {})
	return start_family_session(instance.family_id, instance.template_id, "replay", instance.seed, context)

func continue_recommended() -> bool:
	if not has_active_session():
		return start_recommended_session("continue")
	var recommendation: Dictionary = _active_session.get("recommendation", {})
	if bool(recommendation.get("program_complete", false)):
		return return_home()
	if recommendation.is_empty():
		return start_recommended_session("continue")
	var context: Dictionary = _active_session.get("context", {})
	return start_family_session(
		str(recommendation.get("family_id", "")),
		str(recommendation.get("template_id", "")),
		"continue",
		-1,
		context
	)

func return_home() -> bool:
	if not has_active_session():
		return NavigationService.navigate_to("home") if NavigationService else false
	_trace("home")
	var completed_session_id := str(_active_session.get("session_id", ""))
	_last_pipeline_trace = _pipeline_trace.duplicate()
	_clear_transient_instance()
	_active_session.clear()
	if NavigationService:
		var navigated := NavigationService.navigate_to("home")
		session_completed.emit(completed_session_id)
		return navigated
	return false

func has_active_session() -> bool:
	return not _active_session.is_empty() and _active_session.get("instance") is ChallengeInstance

func get_active_instance() -> ChallengeInstance:
	return _active_session.get("instance") as ChallengeInstance

func get_active_result() -> ChallengeResult:
	return _active_session.get("result") as ChallengeResult

func get_pipeline_trace() -> Array[String]:
	return _pipeline_trace.duplicate() if not _pipeline_trace.is_empty() else _last_pipeline_trace.duplicate()

func get_active_session_snapshot() -> Dictionary:
	if not has_active_session():
		return {}
	var family: ChallengeFamily = _active_session.get("family")
	var template: ChallengeTemplate = _active_session.get("template")
	var instance: ChallengeInstance = _active_session.get("instance")
	return {
		"session_id": _active_session.get("session_id", ""),
		"source": _active_session.get("source", ""),
		"context": (_active_session.get("context", {}) as Dictionary).duplicate(true),
		"program_id": str((_active_session.get("context", {}) as Dictionary).get("program_id", "")),
		"family_id": family.family_id,
		"template_id": template.template_id,
		"instance": instance.to_dictionary(),
		"interaction_profile": ((_active_session.get("interaction") as InteractionProfile).to_dictionary() if _active_session.get("interaction") is InteractionProfile else {}),
		"recommendation": (_active_session.get("recommendation", {}) as Dictionary).duplicate(true),
		"pipeline_trace": _pipeline_trace.duplicate()
	}

func _build_route_params(instance: ChallengeInstance) -> Dictionary:
	var params := {
		"challenge_id": instance.instance_id,
		"challenge_data": instance.to_dictionary(),
		"runtime_session": true
	}
	var interaction: InteractionProfile = _active_session.get("interaction") as InteractionProfile
	if interaction:
		params["interaction_profile"] = interaction.to_dictionary()
	return params

func _set_transient_instance(instance: ChallengeInstance) -> void:
	if not AppState:
		return
	AppState.active_experience_id = instance.family_id
	AppState.set_transient("current_challenge_id", instance.instance_id)
	AppState.set_transient("current_challenge", instance.to_dictionary())
	AppState.set_transient("challenge_runtime_active", true)
	AppState.clear_transient("last_result")
	AppState.clear_transient("question_started_ms")

func _clear_transient_instance() -> void:
	if not AppState:
		return
	AppState.clear_transient("current_challenge_id")
	AppState.clear_transient("current_challenge")
	AppState.clear_transient("challenge_runtime_active")

func _new_seed() -> int:
	return int(Time.get_ticks_usec() & 0x7FFFFFFF)

func _trace(stage: String) -> void:
	_pipeline_trace.append(stage)

func _trace_once(stage: String) -> void:
	if not _pipeline_trace.has(stage):
		_trace(stage)

func _fail(reason: String) -> bool:
	# A rejected or unavailable session is an expected runtime outcome, not an
	# engine fault. Callers observe the signal and decide how to recover.
	session_failed.emit(reason)
	return false
