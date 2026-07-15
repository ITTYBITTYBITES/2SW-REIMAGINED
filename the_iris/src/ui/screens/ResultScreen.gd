extends Control
## ResultScreen – Premium result feedback
## Matches Home / Tutorial visual language
## Gameplay / scoring logic unchanged

@onready var result_icon: TextureRect = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/ResultIcon
@onready var result_title: Label = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/Title
@onready var result_desc: Label = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/Description
@onready var reflection_label: Label = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/ReflectionLabel
@onready var detail_label: Label = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/Detail
@onready var progress_summary: Label = $MainMargin/Scroll/Content/ResultCard/Margin/VBox/ProgressSummary
@onready var continue_btn: Button = $MainMargin/Scroll/Content/Actions/ContinueButton
@onready var replay_btn: Button = $MainMargin/Scroll/Content/Actions/ReplayButton
@onready var library_btn: Button = $MainMargin/Scroll/Content/Actions/LibraryButton
@onready var menu_btn: Button = $MainMargin/Scroll/Content/Actions/MenuButton
@onready var result_card: PanelContainer = $MainMargin/Scroll/Content/ResultCard
@onready var background_rect: ColorRect = $Background

var _result_data: Dictionary = {}
var _is_correct: bool = false
var _reveal_view: Control = null
var _reveal_container: Control = null

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_ensure_wired()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin, 20.0)
	ResponsiveLayout.prepare_mobile_scroll(
		$MainMargin/Scroll,
		$MainMargin/Scroll/Content,
		$MainMargin/Scroll/Content/BottomSpacer,
		104.0
	)

func _ensure_wired() -> void:
	if replay_btn and not replay_btn.pressed.is_connected(_on_replay):
		replay_btn.pressed.connect(_on_replay)
	if continue_btn and not continue_btn.pressed.is_connected(_on_continue):
		continue_btn.pressed.connect(_on_continue)
	if library_btn and not library_btn.pressed.is_connected(_on_library):
		library_btn.pressed.connect(_on_library)
	if menu_btn and not menu_btn.pressed.is_connected(_on_menu):
		menu_btn.pressed.connect(_on_menu)

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	var bg_col: Color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")
	if background_rect:
		background_rect.color = bg_col

	# Reflection remains visually grounded without putting the entire result in a
	# dashboard card. Evidence renderers and outcome typography carry hierarchy.
	if result_card:
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		result_card.add_theme_stylebox_override("panel", style)

	if result_title and ThemeService:
		ThemeService.apply_label_style(result_title, "display", "text_primary")
		result_title.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(36))
	if result_desc and ThemeService:
		ThemeService.apply_label_style(result_desc, "body", "text_secondary")
	if reflection_label and ThemeService:
		ThemeService.apply_label_style(reflection_label, "label_small", "primary_variant")
	if detail_label and ThemeService:
		ThemeService.apply_label_style(detail_label, "body_small", "text_secondary")
	if progress_summary and ThemeService:
		ThemeService.apply_label_style(progress_summary, "body_small", "primary_variant")

	_style_button(continue_btn, true, tokens)
	_style_button(replay_btn, false, tokens)
	_style_button(library_btn, false, tokens)
	_style_button(menu_btn, false, tokens, true)

func _style_button(btn: Button, primary: bool, tokens: Dictionary, ghost: bool = false) -> void:
	if not btn:
		return
	var radius: int = int(tokens.get("radius_lg", 18)) if not tokens.is_empty() else 18
	var normal := StyleBoxFlat.new()
	normal.corner_radius_top_left = radius; normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius; normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 20; normal.content_margin_right = 20
	normal.content_margin_top = 14; normal.content_margin_bottom = 14

	if primary:
		var primary_col: Color = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
		normal.bg_color = primary_col
		btn.add_theme_color_override("font_color", Color.WHITE)
		var hover := normal.duplicate()
		hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		btn.custom_minimum_size.y = 64
	elif ghost:
		normal.bg_color = Color.TRANSPARENT
		btn.add_theme_color_override("font_color", tokens.get("text_tertiary", Color("#8A8AA3")) if not tokens.is_empty() else Color("#8A8AA3"))
		btn.add_theme_stylebox_override("hover", normal)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.custom_minimum_size.y = 56
	else:
		normal.bg_color = tokens.get("surface_elevated", Color("#2A2A36")) if not tokens.is_empty() else Color("#2A2A36")
		normal.border_color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
		normal.border_width_left = 1; normal.border_width_right = 1; normal.border_width_top = 1; normal.border_width_bottom = 1
		btn.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE) if not tokens.is_empty() else Color.WHITE)
		var hover := normal.duplicate()
		hover.bg_color = Color("#333340")
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		btn.custom_minimum_size.y = 56

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("focus", normal)
	if ThemeService:
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _display_result(data: Dictionary) -> void:
	_result_data = data
	_is_correct = bool(data.get("is_correct", str(data.get("outcome", "")) == "correct"))

	var selected := _format_response(data.get("player_response", data.get("selected", "")))
	var correct := _format_response(data.get("correct_answer", data.get("correct", "")))
	var detail := str(data.get("explanation", data.get("detail", "")))
	var title := str(data.get("title", "Challenge"))
	var round_label := ""
	var metadata_value: Variant = data.get("metadata", {})
	if metadata_value is Dictionary:
		var program_value: Variant = (metadata_value as Dictionary).get("program_progress", {})
		if program_value is Dictionary and not (program_value as Dictionary).is_empty():
			var program: Dictionary = program_value
			if not bool(program.get("run_completed", false)):
				round_label = "Round %d of %d" % [
					int(program.get("round", 1)),
					int(program.get("round_count", 1))
				]

	if result_icon:
		var badge_path := "res://assets/results/result_success.svg" if _is_correct else "res://assets/results/result_missed.svg"
		result_icon.texture = null
		if ResourceLoader.exists(badge_path):
			result_icon.texture = load(badge_path) as Texture2D
		result_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		result_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if result_title:
		result_title.text = "CORRECT!" if _is_correct else "I MISSED IT."
		if ThemeService:
			result_title.add_theme_color_override(
				"font_color",
				ThemeService.get_color("success" if _is_correct else "primary_variant")
			)
	if result_desc:
		if _is_correct:
			result_desc.text = "%s\n%s" % [title, round_label] if round_label != "" else title
		else:
			var prefix := "%s\n" % title if title != "" else ""
			var suffix := "\n%s" % round_label if round_label != "" else ""
			var feedback := "You chose %s · Evidence shows %s."
			result_desc.text = "%s%s%s" % [prefix, feedback % [selected, correct], suffix]

	var where_to_look := str((data.get("reveal_data", {}) as Dictionary).get("where_to_look", ""))
	var detail_lines: Array[String] = []
	if not detail.is_empty():
		detail_lines.append(detail)
	if not where_to_look.is_empty():
		detail_lines.append(where_to_look)
	if detail_label:
		detail_label.text = "\n".join(detail_lines)
		detail_label.visible = not detail_label.text.is_empty()
	if reflection_label:
		var reveal_value: Variant = data.get("reveal_data", {})
		var has_reveal: bool = reveal_value is Dictionary and not (reveal_value as Dictionary).is_empty()
		reflection_label.visible = not detail_lines.is_empty() or has_reveal

	var progress_lines: Array[String] = []
	var progress_value: Variant = data.get("progress_earned", {})
	if progress_value is Dictionary:
		var progress: Dictionary = progress_value
		var points := int(progress.get("progress_points", 0))
		var family_progress: Variant = progress.get("family_progress", {})
		var mastery := float((family_progress as Dictionary).get("mastery", 0.0)) if family_progress is Dictionary else 0.0
		if points > 0:
			progress_lines.append("+%d Witness Progress · Mastery %.1f%%" % [points, mastery])
		var unlocked_value: Variant = progress.get("achievements_unlocked", [])
		if unlocked_value is Array:
			for achievement_id: Variant in unlocked_value:
				progress_lines.append("Achievement earned · %s" % _achievement_title(str(achievement_id)))
	var result_metadata_value: Variant = data.get("metadata", {})
	if result_metadata_value is Dictionary:
		var program_value: Variant = (result_metadata_value as Dictionary).get("program_progress", {})
		if program_value is Dictionary and not (program_value as Dictionary).is_empty():
			var program: Dictionary = program_value
			if bool(program.get("run_completed", false)):
				progress_lines.append("%s complete · Run %d" % [
					str(program.get("program_title", "Program")),
					int(program.get("completed_runs", 0))
				])
			else:
				progress_lines.append("%s · Round %d of %d" % [
					str(program.get("program_title", "Program")),
					int(program.get("round", 1)),
					int(program.get("round_count", 1))
				])
	if progress_summary:
		progress_summary.text = "\n".join(progress_lines)
		progress_summary.visible = not progress_summary.text.is_empty()
	_show_reveal(data.get("reveal_data", {}))

	if continue_btn:
		var recommendation_value: Variant = data.get("recommendation", {})
		var program_complete: bool = recommendation_value is Dictionary and bool((recommendation_value as Dictionary).get("program_complete", false))
		continue_btn.text = (
			"FINISH RUN  →"
			if program_complete
			else "NEXT CHALLENGE  →" if ChallengeSessionService and ChallengeSessionService.has_active_session() else "HOME"
		)
	if replay_btn:
		replay_btn.text = "RETRY CHALLENGE"
		replay_btn.visible = true
	if library_btn:
		library_btn.text = "CHALLENGE LIBRARY"
		library_btn.visible = true
	if menu_btn:
		menu_btn.text = "RETURN HOME"
		menu_btn.visible = true

	_play_feedback()
	_animate_in()

func _format_response(value: Variant) -> String:
	if value is Array:
		var parts: Array[String] = []
		for item: Variant in value:
			parts.append(str(item))
		return ", ".join(parts) if not parts.is_empty() else "nothing"
	if value is Dictionary:
		var response: Dictionary = value
		if response.has("x") and response.has("y"):
			return "the selected location"
	return str(value)

func _achievement_title(achievement_id: String) -> String:
	if AchievementService:
		for definition: Dictionary in AchievementService.get_definitions():
			if str(definition.get("id", "")) == achievement_id:
				return str(definition.get("title", achievement_id.capitalize()))
	return achievement_id.replace("_", " ").capitalize()

func _show_reveal(reveal_value: Variant) -> void:
	_clear_reveal()
	if not (reveal_value is Dictionary) or result_card == null:
		return
	var reveal: Dictionary = reveal_value
	var scene_value: Variant = reveal.get("generated_scene", {})
	if not (scene_value is Dictionary):
		return
	var scene: Dictionary = scene_value
	var renderer_script := str(scene.get("renderer_script", ""))
	var vbox := result_card.get_node_or_null("Margin/VBox") as VBoxContainer
	if vbox == null:
		return
	_reveal_container = _create_reveal_container()
	vbox.add_child(_reveal_container)
	vbox.move_child(_reveal_container, detail_label.get_index())
	if _reveal_container.has_method("set_heading"):
		_reveal_container.call("set_heading", "Look again.", "EVIDENCE REVEAL")
	if _reveal_container.has_method("set_explanation"):
		_reveal_container.call("set_explanation", "Existing result evidence is shown here. A fuller reveal sequence remains deferred.")
	if not renderer_script.is_empty() and ResourceLoader.exists(renderer_script):
		var script: Script = load(renderer_script)
		_reveal_view = Control.new()
		_reveal_view.name = "RevealSceneView"
		_reveal_view.custom_minimum_size = Vector2(0, clampf(size.y * 0.24, 260.0, 360.0))
		_reveal_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_reveal_view.set_script(script)
		if _reveal_container.has_method("mount_reveal_view"):
			_reveal_container.call("mount_reveal_view", _reveal_view)
		else:
			_reveal_container.add_child(_reveal_view)
		_reveal_view.call("set_scene_data", scene, reveal.get("highlight_ids", []))
		return
	var image_path := str(scene.get("image_path", ""))
	if not image_path.is_empty() and ResourceLoader.exists(image_path):
		var texture_view := TextureRect.new()
		texture_view.name = "RevealTexture"
		texture_view.custom_minimum_size = Vector2(0, 260)
		texture_view.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_view.texture = load(image_path) as Texture2D
		_reveal_view = texture_view
		if _reveal_container.has_method("mount_reveal_view"):
			_reveal_container.call("mount_reveal_view", _reveal_view)
		else:
			_reveal_container.add_child(_reveal_view)

func _create_reveal_container() -> Control:
	var script: Script = load("res://src/ui/components/EvidenceRevealContainer.gd")
	var container := PanelContainer.new()
	container.name = "EvidenceRevealContainer"
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if script:
		container.set_script(script)
	return container

func _clear_reveal() -> void:
	if is_instance_valid(_reveal_container):
		_reveal_container.queue_free()
	elif is_instance_valid(_reveal_view):
		_reveal_view.queue_free()
	_reveal_container = null
	_reveal_view = null

func _play_feedback() -> void:
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(50 if _is_correct else 100)
	if AudioService:
		AudioService.play_sfx("reveal_correct" if _is_correct else "reveal_incorrect", 0.75)
		if _is_correct:
			# Soft layered settle + mastery up
			get_tree().create_timer(0.45).timeout.connect(func() -> void:
				if AudioService and is_instance_valid(self):
					AudioService.play_sfx("result_settle", 0.55)
			)
		AudioService.unduck_bgm(0.4)

func _animate_in() -> void:
	if not _should_animate() or not result_icon:
		return
	result_icon.pivot_offset = result_icon.size * 0.5
	result_icon.scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var dur := _get_anim_duration(0.35)
	var scale_tween := tween.tween_property(result_icon, "scale", Vector2.ONE, dur)
	scale_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_replay() -> void:
	if AudioService: AudioService.play_ui("ui_click")
	if AnalyticsService:
		AnalyticsService.log_event("replay_challenge", {
			"challenge_id": _result_data.get("instance_id", _result_data.get("challenge_id", ""))
		})
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.replay_current()
	elif NavigationService:
		NavigationService.navigate_to("home")

func _on_continue() -> void:
	if AudioService: AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if AnalyticsService:
		AnalyticsService.log_event("next_challenge", {
			"challenge_id": _result_data.get("instance_id", _result_data.get("challenge_id", ""))
		})
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.continue_recommended()
	elif NavigationService:
		NavigationService.navigate_to("home")

func _on_library() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.return_home()
	if NavigationService:
		NavigationService.navigate_to("experiences")

func _on_menu() -> void:
	if AudioService: AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.return_home()
	elif NavigationService:
		NavigationService.navigate_to("home")

func _check_first_run_completion() -> void:
	var needs_save := false
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if not prefs.get("onboarding_completed", false):
			prefs["onboarding_completed"] = true
			ProfileService.profile["preferences"] = prefs
			needs_save = true
	if SettingsService:
		if not SettingsService.get_value("first_launch_completed", false):
			SettingsService.set_value("first_launch_completed", true)
	if needs_save and ProfileService:
		ProfileService.save()

func on_navigated_to(params: Dictionary) -> void:
	_result_data = params
	_apply_responsive_layout()
	_apply_theme()
	_display_result(params)
	modulate.a = 1.0
