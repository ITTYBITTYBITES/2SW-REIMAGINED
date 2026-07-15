extends Control
## Generic family tutorial host. Mechanic-specific tutorial behavior lives inside
## the selected ChallengeFamily module.

@onready var tutorial_host: Control = $TutorialHost
@onready var loading_label: Label = $LoadingLabel

var _family_id: String = ""
var _tutorial_profile: TutorialProfile = null
var _tutorial_instance: Control = null
var _completion_persisted: bool = false
var _pending_template_id: String = ""
var _session_context: Dictionary = {}

func _ready() -> void:
	var background := get_node_or_null("Background") as ColorRect
	if background:
		background.color = ThemeService.get_color("background", Color("#0F0F12")) if ThemeService else Color("#0F0F12")
	if loading_label and ThemeService:
		ThemeService.apply_label_style(loading_label, "body", "text_secondary")

func on_navigated_to(params: Dictionary) -> void:
	_completion_persisted = false
	_pending_template_id = str(params.get("pending_template_id", ""))
	var context_value: Variant = params.get("session_context", {})
	_session_context = (context_value as Dictionary).duplicate(true) if context_value is Dictionary else {}
	_family_id = str(params.get("family_id", ""))
	if _family_id.is_empty():
		_family_id = _recommended_family_id()
	_load_family_tutorial()

func _recommended_family_id() -> String:
	if not RecommendationService or not PlayerProgressService:
		return ""
	var recommendation: Dictionary = RecommendationService.recommend_start(PlayerProgressService.get_player_state())
	return str(recommendation.get("family_id", ""))

func _load_family_tutorial() -> void:
	_clear_tutorial()
	if _family_id.is_empty() or not ChallengeFamilyRegistry:
		_fail_to_home("No Challenge Type is available for tutorial")
		return
	var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module(_family_id)
	if module == null:
		_fail_to_home("Tutorial family is not registered: %s" % _family_id)
		return
	var family := module.get_family()
	_tutorial_profile = module.get_tutorial_profile()
	if _tutorial_profile == null or not ResourceLoader.exists(_tutorial_profile.scene_path):
		_fail_to_home("Tutorial profile is unavailable for %s" % _family_id)
		return
	var scene: PackedScene = load(_tutorial_profile.scene_path)
	if scene == null:
		_fail_to_home("Tutorial scene could not be loaded")
		return
	_tutorial_instance = scene.instantiate() as Control
	if _tutorial_instance == null:
		_fail_to_home("Tutorial scene root must be a Control")
		return
	_tutorial_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_host.add_child(_tutorial_instance)
	if _tutorial_instance.has_signal("completed"):
		_tutorial_instance.connect("completed", _on_tutorial_completed)
	if _tutorial_instance.has_signal("skipped"):
		_tutorial_instance.connect("skipped", _on_tutorial_skipped)
	if _tutorial_instance.has_signal("practice_requested"):
		_tutorial_instance.connect("practice_requested", _on_practice_requested)
	if _tutorial_instance.has_method("configure"):
		_tutorial_instance.call("configure", family, _tutorial_profile)
	if loading_label:
		loading_label.visible = false
	if AnalyticsService:
		AnalyticsService.log_event("family_tutorial_opened", {
			"family_id": _family_id,
			"tutorial_id": _tutorial_profile.tutorial_id,
			"tutorial_version": _tutorial_profile.tutorial_version
		})

func _on_tutorial_completed(family_id: String, tutorial_version: String) -> void:
	_persist_completion(family_id, tutorial_version, false)

func _on_tutorial_skipped(family_id: String, tutorial_version: String) -> void:
	_persist_completion(family_id, tutorial_version, true)

func _persist_completion(family_id: String, tutorial_version: String, was_skipped: bool) -> void:
	if _completion_persisted or family_id != _family_id or not ProfileService:
		return
	var preferences: Dictionary = ProfileService.profile.get("preferences", {})
	var versions: Dictionary = preferences.get("family_tutorial_versions", {})
	versions[family_id] = tutorial_version
	preferences["family_tutorial_versions"] = versions
	preferences["tutorial_seen"] = true
	ProfileService.profile["preferences"] = preferences
	ProfileService.save()
	_completion_persisted = true
	if AnalyticsService:
		AnalyticsService.log_event("family_tutorial_completed", {
			"family_id": family_id,
			"tutorial_version": tutorial_version,
			"skipped": was_skipped
		})

func _on_practice_requested(family_id: String, template_id: String) -> void:
	if family_id != _family_id:
		_fail_to_home("Tutorial requested practice for a different family")
		return
	if not _completion_persisted and _tutorial_profile:
		_persist_completion(family_id, _tutorial_profile.tutorial_version, false)
	var resolved_template_id := _pending_template_id if not _pending_template_id.is_empty() else template_id
	if ChallengeSessionService:
		ChallengeSessionService.start_family_session(family_id, resolved_template_id, "tutorial", -1, _session_context)
	elif NavigationService:
		NavigationService.navigate_to("home")

func _clear_tutorial() -> void:
	if is_instance_valid(_tutorial_instance):
		_tutorial_instance.queue_free()
	_tutorial_instance = null
	if loading_label:
		loading_label.visible = true

func _fail_to_home(reason: String) -> void:
	ErrorHandler.handle("TUTORIAL_LOAD_FAILED", reason, {"family_id": _family_id}, ErrorHandler.Severity.WARNING)
	if NavigationService:
		NavigationService.navigate_to("home")
