extends Control
## Data-driven Challenge Library. Internally retains its established route name.

@onready var scroll: ScrollContainer = $MainMargin/Scroll
@onready var brand_label: Label = $MainMargin/Scroll/Content/Header/BrandLabel
@onready var title_label: Label = $MainMargin/Scroll/Content/Header/TitleLabel
@onready var subtitle_label: Label = $MainMargin/Scroll/Content/Header/SubtitleLabel
@onready var count_label: Label = $MainMargin/Scroll/Content/CountLabel
@onready var challenge_list: VBoxContainer = $MainMargin/Scroll/Content/ChallengeList

var _highlight_id: String = ""
var _refresh_pending: bool = false
var _launch_pending: bool = false
# Compatibility inspection map; buttons still live inside each data-driven card.
var _tutorial_buttons: Dictionary = {}

func _ready() -> void:
	_apply_responsive_layout()
	_apply_theme()
	_refresh_list()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService and not ProfileService.profile_saved.is_connected(_on_profile_saved):
		ProfileService.profile_saved.connect(_on_profile_saved)
	if ChallengeFamilyRegistry:
		if not ChallengeFamilyRegistry.family_registered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_registered.connect(_on_family_changed)
		if not ChallengeFamilyRegistry.family_unregistered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_unregistered.connect(_on_family_changed)

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin)
	ResponsiveLayout.prepare_mobile_scroll(scroll, $MainMargin/Scroll/Content, $MainMargin/Scroll/Content/BottomSpacer)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background:
		background.color = tokens.get("background", Color("#0F0F12"))
	if ThemeService:
		ThemeService.apply_label_style(brand_label, "label_small", "text_tertiary")
		ThemeService.apply_label_style(title_label, "display", "text_primary")
		ThemeService.apply_label_style(subtitle_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(count_label, "label_small", "text_tertiary")
	title_label.text = "CHALLENGE LIBRARY"
	subtitle_label.text = "Choose a Challenge Type, track Mastery, or replay its tutorial."

func _refresh_list() -> void:
	for child: Node in challenge_list.get_children():
		child.queue_free()
	_tutorial_buttons.clear()
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var challenges: Array[Dictionary] = (
		RecommendationService.get_available_challenge_types(player_state)
		if RecommendationService
		else []
	)
	var unlocked_count: int = 0
	for challenge: Dictionary in challenges:
		if not bool(challenge.get("locked", false)):
			unlocked_count += 1
	count_label.text = "%d available · %d total Challenge Types" % [unlocked_count, challenges.size()]
	if challenges.is_empty():
		var empty := Label.new()
		empty.name = "ChallengeEmpty"
		empty.text = "No Challenge Types are available right now."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if ThemeService:
			ThemeService.apply_label_style(empty, "body", "text_secondary")
		challenge_list.add_child(empty)
		return
	for challenge: Dictionary in challenges:
		var family_id: String = str(challenge.get("family_id", ""))
		var card: Control = _create_challenge_card(challenge)
		card.name = "Challenge_%s" % family_id
		challenge_list.add_child(card)
		var tutorial_button: Button = card.get_node_or_null("Margin/VBox/BottomRow/TutorialButton") as Button
		if tutorial_button != null:
			_tutorial_buttons[family_id] = tutorial_button
	if not _highlight_id.is_empty():
		call_deferred("_focus_highlighted")

func _create_challenge_card(challenge: Dictionary) -> Control:
	var scene: PackedScene = load("res://src/ui/components/ExperienceCard.tscn")
	var card: Control = scene.instantiate() as Control
	card.call("set_experience", challenge)
	card.connect("experience_selected", _on_challenge_selected)
	card.connect("tutorial_requested", _on_replay_tutorial)
	card.connect("favorite_toggled", _on_favorite_toggled)
	return card

func _focus_highlighted() -> void:
	for child: Node in challenge_list.get_children():
		if child.name == "Challenge_%s" % _highlight_id or str(child.get("experience_id")) == _highlight_id:
			var target: Control = child as Control
			scroll.scroll_vertical = int(target.position.y)
			return

func on_navigated_to(params: Dictionary) -> void:
	_launch_pending = false
	_highlight_id = str(params.get("highlight", ""))
	_refresh_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh_list()

func _on_challenge_selected(template_id: String) -> void:
	if _launch_pending:
		return
	_launch_pending = true
	if AppState:
		AppState.set_loading(true, "Preparing your selected round…")
	await get_tree().process_frame
	var started := ChallengeSessionService.start_template_session(template_id, "challenge_library") if ChallengeSessionService else false
	if AppState:
		AppState.set_loading(false)
	_launch_pending = false
	if not started:
		_refresh_list()

func _on_replay_tutorial(family_id: String) -> void:
	if NavigationService:
		NavigationService.navigate_to("tutorial", {"replay": true, "family_id": family_id})

func _on_favorite_toggled(family_id: String, favorite: bool) -> void:
	if PlayerProgressService and PlayerProgressService.set_family_favorite(family_id, favorite):
		_refresh_list()

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh_list()
	else:
		_refresh_pending = true

func _on_profile_saved(_profile: Dictionary) -> void:
	_request_refresh()

func _on_family_changed(_family_id: String) -> void:
	_request_refresh()

func _request_refresh() -> void:
	if is_visible_in_tree():
		call_deferred("_refresh_list")
	else:
		_refresh_pending = true
