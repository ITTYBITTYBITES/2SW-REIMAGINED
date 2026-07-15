extends Node
## NavigationService - Central navigation orchestrator
## Updated for ITTYBITTYBITES publisher identity + first-run flow

signal route_changed(route: String, params: Dictionary)
signal route_change_requested(route: String, params: Dictionary)
signal history_updated(history: Array)
@warning_ignore("UNUSED_SIGNAL")
signal deep_link_received(route: String, params: Dictionary)  ## Emitted by handle_deep_link() when a URI deep link is processed.

var current_route: String = "publisher_splash"
var current_params: Dictionary = {}
var history: Array[Dictionary] = []
const MAX_HISTORY := 50

var _initialized: bool = false

const SPLASH_ROUTES := ["publisher_splash", "title_splash", "splash"]
# First-run onboarding is now a modal over the loading screen, not a routed flow.
# Gameplay screens (observation, memory_question, result) are launched from the
# main menu and participate in normal history/back navigation.
const FIRST_RUN_ROUTES: Array[String] = []

func _ready() -> void:
	if EventBus:
		if not EventBus.navigation_requested.is_connected(_on_navigation_requested):
			EventBus.navigation_requested.connect(_on_navigation_requested)

func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	current_route = "publisher_splash"
	current_params = {}
	history.clear()
	await get_tree().process_frame

func navigate_to(route: String, params: Dictionary = {}) -> bool:
	if not _is_valid(route):
		if ErrorHandler:
			ErrorHandler.handle("NAV_INVALID_ROUTE", "Route not found: %s" % route, {"route": route})
		return false

	# Do not push splash or first-run to history to keep back simple, unless going to main tabs
	var should_push = true
	if current_route in SPLASH_ROUTES:
		should_push = false
	if current_route in FIRST_RUN_ROUTES and route in FIRST_RUN_ROUTES:
		should_push = false # linear first-run flow, no history bloat

	if should_push and current_route != route:
		_push_history(current_route, current_params)

	route_change_requested.emit(route, params)
	current_route = route
	current_params = params

	route_changed.emit(route, params)
	if EventBus:
		EventBus.publish_navigation_changed(route, params)

	_update_app_state_phase(route)

	_log_screen_view(route, params)

	_update_bgm_for_route(route)

	return true

func _update_bgm_for_route(route: String) -> void:
	if not AudioService:
		return
	if not AudioService.SCENE_BGM.has(route):
		return
	var track_key: String = AudioService.SCENE_BGM[route]
	AudioService.play_bgm_track(track_key)

func _log_screen_view(route: String, params: Dictionary) -> void:
	# Single source of truth for screen-view analytics so each navigation is
	# logged exactly once. Individual screens must NOT also call
	# AnalyticsService.log_screen_view from their on_navigated_to methods.
	if AnalyticsService:
		AnalyticsService.log_screen_view(route, _sanitize_analytics_params(params))

func _sanitize_analytics_params(params: Dictionary) -> Dictionary:
	var safe: Dictionary = {}
	for key: String in ["family_id", "template_id", "instance_id", "challenge_id", "outcome", "score", "reaction_ms", "runtime_session"]:
		if params.has(key):
			safe[key] = params[key]
	var challenge_value: Variant = params.get("challenge_data", {})
	if challenge_value is Dictionary:
		var challenge: Dictionary = challenge_value
		for key: String in ["family_id", "template_id", "instance_id", "difficulty_label", "seed", "content_version"]:
			if challenge.has(key):
				safe[key] = challenge[key]
	return safe

func go_back() -> bool:
	# Never navigate back into the launch splash sequence.
	if current_route in SPLASH_ROUTES:
		return false
	if history.is_empty():
		if current_route != "home":
			return navigate_to("home")
		return false

	var prev: Dictionary = history.pop_back()
	history_updated.emit(history.duplicate())
	var route: String = prev.get("route", "home")
	var params: Dictionary = prev.get("params", {})

	current_route = route
	current_params = params
	route_changed.emit(route, params)
	if EventBus:
		EventBus.publish_navigation_changed(route, params)
	_update_app_state_phase(route)
	_log_screen_view(route, params)
	_update_bgm_for_route(route)
	return true

func replace(route: String, params: Dictionary = {}) -> bool:
	if not _is_valid(route):
		return false
	current_route = route
	current_params = params
	route_changed.emit(route, params)
	if EventBus:
		EventBus.publish_navigation_changed(route, params)
	_update_app_state_phase(route)
	_log_screen_view(route, params)
	_update_bgm_for_route(route)
	return true

func can_go_back() -> bool:
	return not history.is_empty()

func clear_history() -> void:
	history.clear()
	history_updated.emit(history)

func _push_history(route: String, params: Dictionary) -> void:
	history.append({"route": route, "params": params, "timestamp": Time.get_ticks_msec()})
	if history.size() > MAX_HISTORY:
		history.pop_front()
	history_updated.emit(history.duplicate())

func _is_valid(route: String) -> bool:
	var script = load("res://src/core/navigation/AppRoutes.gd")
	return script.is_valid_route(route)

func _on_navigation_requested(route: String, params: Dictionary) -> void:
	navigate_to(route, params)

func _update_app_state_phase(route: String) -> void:
	if not AppState:
		return
	match route:
		"publisher_splash", "title_splash", "splash":
			AppState.set_phase(AppState.AppPhase.SPLASH)
		"home":
			AppState.set_phase(AppState.AppPhase.HOME)
		"experiences":
			AppState.set_phase(AppState.AppPhase.EXPERIENCES)
		"profile":
			AppState.set_phase(AppState.AppPhase.PROFILE)
		"achievements":
			AppState.set_phase(AppState.AppPhase.ACHIEVEMENTS)
		"programs":
			AppState.set_phase(AppState.AppPhase.PROGRAMS)
		"settings", "about":
			AppState.set_phase(AppState.AppPhase.SETTINGS)
		"observation", "memory_question", "result":
			AppState.set_phase(AppState.AppPhase.EXPERIENCE_PLAYING)

func get_current() -> Dictionary:
	return {"route": current_route, "params": current_params}
