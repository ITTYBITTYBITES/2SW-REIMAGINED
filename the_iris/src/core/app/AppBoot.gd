extends Node
## AppBoot - Clean startup flow orchestrator
## Phases: Preload configs -> Init systems -> Load saves -> Ready

signal boot_step_started(step: String)
signal boot_step_completed(step: String, duration_ms: int)
signal boot_completed()
signal boot_failed(reason: String)

enum BootStep {
	INIT_CONFIG,
	INIT_THEME,
	INIT_SETTINGS,
	INIT_SAVE,
	INIT_CONTENT,
	INIT_AUDIO,
	INIT_NAV,
	FINALIZE
}

var _is_booting: bool = false
var _boot_start_time: int = 0

func start_boot() -> void:
	if _is_booting:
		return
	_is_booting = true
	_boot_start_time = Time.get_ticks_msec()

	# Keep the dependency order explicit. Settings reads SaveService and the
	# theme reads SettingsService; starting either one too early produces a
	# cascade of null/default errors on a cold Android launch.
	_run_step("config", BootStep.INIT_CONFIG, _boot_config)
	_run_step("save", BootStep.INIT_SAVE, _boot_save)
	_run_step("settings", BootStep.INIT_SETTINGS, _boot_settings)
	_run_step("theme", BootStep.INIT_THEME, _boot_theme)
	_run_step("content", BootStep.INIT_CONTENT, _boot_content)
	_run_step("audio", BootStep.INIT_AUDIO, _boot_audio)
	_run_step("navigation", BootStep.INIT_NAV, _boot_nav)
	_run_step("finalize", BootStep.FINALIZE, _boot_finalize)

	var total := Time.get_ticks_msec() - _boot_start_time
	if AnalyticsService:
		AnalyticsService.log_event("cold_start_services_ready", {
			"duration_ms": total,
			"memory_mb": snappedf(float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0, 0.1)
		})
	_is_booting = false
	boot_completed.emit()
	EventBus.publish_app_initialized()

func _run_step(step_name: String, _step: int, callable: Callable) -> void:
	var start := Time.get_ticks_msec()
	boot_step_started.emit(step_name)
	AppState.set_loading(true, "Loading %s..." % step_name.capitalize())

	var success: bool = true
	var err: String = ""

	# Use try-like pcall via callable
	var result = callable.call()
	if result is Dictionary and result.has("error"):
		success = false
		err = str(result["error"])

	var duration := Time.get_ticks_msec() - start
	boot_step_completed.emit(step_name, duration)

	if not success:
		var error_code := "BOOT_%s_FAILED" % step_name.to_upper()
		var context := {"step": step_name}
		ErrorHandler.handle(error_code, err, context, ErrorHandler.Severity.WARNING)
		boot_failed.emit("[%s] %s" % [error_code, err])
	else:
		pass

func _boot_config() -> Dictionary:
	if ConfigService:
		ConfigService.initialize()
	return {}

func _boot_theme() -> Dictionary:
	if ThemeService:
		ThemeService.initialize()
	return {}

func _boot_settings() -> Dictionary:
	if SettingsService:
		SettingsService.initialize()
	if AnalyticsService:
		AnalyticsService.initialize()
	if AccessibilityService:
		AccessibilityService.initialize()
	return {}

func _boot_save() -> Dictionary:
	if SaveService:
		SaveService.initialize()
	if ProfileService:
		ProfileService.initialize()
	if AchievementService:
		AchievementService.initialize()
	return {}

func _boot_content() -> Dictionary:
	if ContentService:
		ContentService.initialize()
	# Keep deterministic fixture loading first so Product Development family
	# modules can adapt the validated content without duplicating its source.
	if ChallengeRegistry:
		ChallengeRegistry.initialize()
	if InteractionAdapterRegistry:
		InteractionAdapterRegistry.initialize()
	if ChallengeFamilyRegistry:
		ChallengeFamilyRegistry.initialize()
	if PlayerProgressService:
		PlayerProgressService.initialize()
	if RecommendationService:
		RecommendationService.initialize()
	if ProgramService:
		ProgramService.initialize()
	if ResultService:
		ResultService.initialize()
	if ChallengeSessionService:
		ChallengeSessionService.initialize()
	return {}

func _boot_audio() -> Dictionary:
	if AudioService:
		AudioService.initialize()
	return {}

func _boot_nav() -> Dictionary:
	if NavigationService:
		NavigationService.initialize()
	return {}

func _boot_finalize() -> Dictionary:
	AppState.set_loading(false)
	return {}
