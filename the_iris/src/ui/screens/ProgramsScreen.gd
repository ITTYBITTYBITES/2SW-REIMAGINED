extends Control
## Premium browser for curated challenge journeys. Program cards launch the
## existing Challenge Runtime through ChallengeSessionService.

@onready var title_label: Label = $MainMargin/Scroll/Content/Header/Title
@onready var subtitle_label: Label = $MainMargin/Scroll/Content/Header/Subtitle
@onready var summary_label: Label = $MainMargin/Scroll/Content/Summary
@onready var program_list: VBoxContainer = $MainMargin/Scroll/Content/ProgramList

var _launch_pending: bool = false

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_refresh()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService and not ProfileService.profile_saved.is_connected(_on_profile_saved):
		ProfileService.profile_saved.connect(_on_profile_saved)
	if ProgramService:
		if not ProgramService.program_progress_updated.is_connected(_on_program_progress):
			ProgramService.program_progress_updated.connect(_on_program_progress)

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin)

func _apply_theme() -> void:
	var background: ColorRect = $Background
	if ThemeService:
		background.color = ThemeService.get_color("background", Color("#0F0F12"))
		ThemeService.apply_label_style(title_label, "display", "text_primary")
		ThemeService.apply_label_style(subtitle_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(summary_label, "label_small", "text_tertiary")

func _refresh() -> void:
	for child: Node in program_list.get_children():
		child.queue_free()
	if not ProgramService:
		return
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var programs: Array[Dictionary] = ProgramService.get_programs(player_state)
	if programs.is_empty():
		var empty := Label.new()
		empty.text = "Choose an individual Challenge Type in the Library, or return here for curated runs."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_label_style(empty, "body", "text_secondary")
		program_list.add_child(empty)
		summary_label.text = "No curated runs available"
		return
	var available_count: int = 0
	for program: Dictionary in programs:
		if bool(program.get("available", false)):
			available_count += 1
		var scene: PackedScene = load("res://src/ui/components/ProgramCard.tscn")
		var card: Control = scene.instantiate() as Control
		card.name = "Program_%s" % str(program.get("id", ""))
		card.call("set_program", program)
		card.connect("program_selected", _on_program_selected)
		program_list.add_child(card)
	summary_label.text = "%d available · %d curated runs" % [available_count, programs.size()]

func on_navigated_to(_params: Dictionary) -> void:
	_launch_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh()

func _on_program_selected(program_id: String) -> void:
	if _launch_pending:
		return
	_launch_pending = true
	if AppState:
		AppState.set_loading(true, "Preparing your curated run…")
	await get_tree().process_frame
	var started: bool = ChallengeSessionService.start_program_session(program_id, "program") if ChallengeSessionService else false
	if AppState:
		AppState.set_loading(false)
	_launch_pending = false
	if not started:
		_refresh()

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh()

func _on_profile_saved(_profile: Dictionary) -> void:
	if is_visible_in_tree():
		call_deferred("_refresh")

func _on_program_progress(_program_id: String, _progress: Dictionary) -> void:
	if is_visible_in_tree():
		call_deferred("_refresh")
