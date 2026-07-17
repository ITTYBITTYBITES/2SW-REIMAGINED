extends Node2D
class_name IrisMainController

@onready var state_manager: IrisStateManager = $StateManager
@onready var navigation: IrisNavigationController = $NavigationController
@onready var back_navigation: IrisBackNavigationController = $BackNavigationController
@onready var production_bridge: TwoSecondWitnessProductionBridge = $ProductionBridge
@onready var witness_director: WitnessExperienceDirector = $WitnessExperienceDirector
@onready var witness_runtime: WitnessMomentOrchestrator = $WitnessMomentRuntime
@onready var input_intents: IrisInputIntentController = $InputIntentController
@onready var device: DeviceCapabilityManager = $DeviceCapabilityManager
@onready var orientation: OrientationManager = $OrientationManager
@onready var transition: IrisTransitionController = $Interface/TransitionController
@onready var iris: IrisController = $Interface/ScreenRoot/IrisScreen
@onready var witness: WitnessModeScreen = $Interface/ScreenRoot/WitnessMode
@onready var archive: ArchiveScreen = $Interface/ScreenRoot/Archive
@onready var discovery: DiscoveryScreen = $Interface/ScreenRoot/Discovery
@onready var profile: ProfileScreen = $Interface/ScreenRoot/Profile
@onready var settings: SettingsScreen = $Interface/ScreenRoot/Settings
@onready var daily_witness: FuturePlaceholder = $Interface/ScreenRoot/DailyWitness
@onready var weekly_investigation: FuturePlaceholder = $Interface/ScreenRoot/WeeklyInvestigation
@onready var calibration: FuturePlaceholder = $Interface/ScreenRoot/Calibration
@onready var tutorial_awakening: TutorialAwakeningScreen = $Interface/ScreenRoot/TutorialAwakening
@onready var edge_glow: EdgeGlow = $Interface/HUD/EdgeGlow
@onready var sound: ProceduralIrisSound = $ProceduralSound
@onready var voice_guide: VoiceGuide = $Interface/VoiceGuide
@onready var caption_overlay: IrisCaptionOverlay = $Interface/CaptionOverlay
@onready var accessibility_panel: IrisAccessibilityPanel = $Interface/AccessibilityPanel
@onready var production_startup: ProductionStartup = $Interface/ProductionStartup
@onready var readiness_screen: ExperienceReadinessScreen = $Interface/ExperienceReadiness

var active_screen := "home"
var hud_labels: Dictionary = {}
var intro_elapsed := 0.0
var intro_running := false
var pending_after_return := Callable()
var pending_return_from_witness := false
var pending_return_from_tutorial := false

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        _handle_back()

func _ready() -> void:
    input_intents.intent_requested.connect(_on_intent)
    input_intents.set_sources(navigation, back_navigation)
    device.capabilities_changed.connect(_on_capabilities_changed)
    device.motion_changed.connect(_on_motion_changed)
    orientation.transition_progress.connect(_on_orientation_transition)
    orientation.orientation_changed.connect(_on_orientation_changed)
    orientation.set_orientation_lock(state_manager.orientation_lock)
    navigation.pointer_started.connect(_on_pointer_started)
    navigation.pointer_moved.connect(_on_pointer_moved)
    navigation.pointer_ended.connect(_on_pointer_ended)
    navigation.dragged.connect(_on_dragged)
    navigation.cursor_moved.connect(_on_cursor_moved)
    accessibility_panel.action_requested.connect(_on_accessibility_action)
    voice_guide.caption_changed.connect(_on_caption_changed)
    voice_guide.set_state_manager(state_manager)
    voice_guide.set_iris(iris)
    transition.transition_finished.connect(_on_transition_finished)
    state_manager.state_changed.connect(_on_state_changed)
    state_manager.progress_changed.connect(_on_progress_changed)
    state_manager.preferences_changed.connect(_on_preferences_changed)
    witness.request_home.connect(show_home)
    witness.request_action.connect(_on_screen_action)
    archive.request_home.connect(show_home)
    archive.request_witness.connect(show_witness)
    discovery.request_home.connect(show_home)
    discovery.request_future_destination.connect(_on_future_destination)
    profile.request_home.connect(show_home)
    daily_witness.request_home.connect(show_home)
    daily_witness.request_witness.connect(show_witness)
    weekly_investigation.request_home.connect(show_home)
    weekly_investigation.request_witness.connect(show_witness)
    calibration.request_home.connect(show_home)
    profile.request_witness.connect(show_witness)
    settings.request_home.connect(show_home)
    settings.request_witness.connect(show_witness)
    if is_instance_valid(tutorial_awakening):
        tutorial_awakening.set_sensory_services(sound, voice_guide)
        tutorial_awakening.request_return_to_iris.connect(_on_tutorial_return)
    profile.set_state_manager(state_manager)
    settings.set_state_manager(state_manager)
    witness.set_production_bridge(production_bridge)
    witness.set_runtime_active(false)
    witness_runtime.set_director(witness_director)
    witness_runtime.set_sensory_services(sound)
    witness_runtime.enter_requested.connect(_on_runtime_enter_requested)
    witness_runtime.phase_started.connect(_on_runtime_phase_started)
    witness_runtime.phase_completed.connect(_on_runtime_phase_completed)
    witness_runtime.moment_completed.connect(_on_runtime_moment_completed)
    witness_runtime.moment_failed.connect(_on_runtime_moment_failed)
    witness_runtime.return_requested.connect(_on_runtime_return_requested)
    archive.set_production_bridge(production_bridge)
    profile.set_production_bridge(production_bridge)
    settings.set_production_bridge(production_bridge)
    iris.set_animation_intensity(0.18 if state_manager.reduced_motion else state_manager.animation_intensity)
    iris.set_desktop_mode(not device.has_touchscreen)
    iris.set_parallax_enabled(state_manager.parallax_enabled and not state_manager.reduced_motion)
    iris.set_sensory_services(sound, voice_guide)
    transition.set_reduced_motion(state_manager.reduced_motion)
    sound.set_enabled(state_manager.sound_enabled and device.has_audio)
    voice_guide.set_enabled(state_manager.sound_enabled and device.has_audio)
    voice_guide.set_captions_enabled(state_manager.captions_enabled)
    accessibility_panel.visible = state_manager.accessible_navigation
    _build_hud()
    _switch_screen("home")
    
    if production_startup and production_startup.is_active():
        production_startup.finished.connect(_on_startup_finished)
    else:
        _on_startup_finished()

func _on_startup_finished() -> void:
    if ExperienceReadinessService and not ExperienceReadinessService.is_readiness_completed():
        readiness_screen.visible = true
        readiness_screen.readiness_finished.connect(_on_readiness_finished)
    else:
        _on_readiness_finished()

func _on_readiness_finished() -> void:
    if is_instance_valid(readiness_screen):
        readiness_screen.visible = false
    
    voice_guide.begin_session()
    if state_manager.first_launch:
        _start_first_launch_intro()

func _process(delta: float) -> void:
    if intro_running:
        intro_elapsed += delta
        if intro_elapsed > 8.4:
            _finish_first_launch_intro()

func _build_hud() -> void:
    var hud := $Interface/HUD
    hud_labels["brand"] = _hud_label(hud, "THE IRIS", 17, Color("#dff4ee"), Vector2(30, 28), Vector2(280, 30))
    hud_labels["descriptor"] = _hud_label(hud, "A LIVING PERCEPTION INSTRUMENT", 10, Color("#557a76"), Vector2(31, 57), Vector2(350, 22))
    hud_labels["archive"] = _hud_label(hud, "←  ARCHIVE", 12, Color("#67938b"), Vector2(18, 612), Vector2(116, 30))
    hud_labels["discovery"] = _hud_label(hud, "DISCOVER  →", 12, Color("#67938b"), Vector2(586, 612), Vector2(116, 30), HORIZONTAL_ALIGNMENT_RIGHT)
    hud_labels["profile"] = _hud_label(hud, "PROFILE  ↑", 11, Color("#67938b"), Vector2(540, 83), Vector2(150, 26), HORIZONTAL_ALIGNMENT_RIGHT)
    hud_labels["settings"] = _hud_label(hud, "SETTINGS  ↓", 11, Color("#67938b"), Vector2(540, 1172), Vector2(150, 26), HORIZONTAL_ALIGNMENT_RIGHT)
    hud_labels["prompt"] = _hud_label(hud, "tap center  ·  look", 14, Color("#9ddbc7"), Vector2(30, 843), Vector2(660, 30), HORIZONTAL_ALIGNMENT_CENTER)
    hud_labels["subprompt"] = _hud_label(hud, "hold  ·  focus", 11, Color("#557a76"), Vector2(30, 875), Vector2(660, 24), HORIZONTAL_ALIGNMENT_CENTER)
    hud_labels["intro_title"] = _hud_label(hud, "", 15, Color("#dff4ee"), Vector2(30, 395), Vector2(660, 34), HORIZONTAL_ALIGNMENT_CENTER)
    hud_labels["intro_line"] = _hud_label(hud, "", 12, Color("#77afa2"), Vector2(30, 432), Vector2(660, 28), HORIZONTAL_ALIGNMENT_CENTER)
    hud_labels["intro_title"].modulate.a = 0.0
    hud_labels["intro_line"].modulate.a = 0.0
    _layout_hud(get_viewport_rect().size, orientation.current_orientation)

func _hud_label(parent: Control, text_value: String, size: int, color: Color, pos: Vector2, box: Vector2, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
    var label := Label.new()
    label.text = text_value
    label.position = pos
    label.size = box
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    label.horizontal_alignment = align
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

# All experience changes pass through this function. The Iris is never
# replaced by a page; it is the optical origin of every destination.
func _show_screen(next_screen: String, animate := true) -> void:
    if next_screen == active_screen:
        return
    if not animate:
        _switch_screen(next_screen)
        return
    if transition.busy:
        return
    if next_screen == "home":
        _return_to_iris()
    elif next_screen == "tutorial_awakening" and active_screen == "home":
        _enter_experience("tutorial_awakening")
    elif next_screen == "witness" and active_screen == "home":
        # Directly enter Witness Moment via The Threshold without returning to home first
        _enter_experience("witness")
    elif active_screen == "home":
        _enter_experience(next_screen)
    else:
        # Even lateral movement between future destinations returns through
        # the anchor first, preserving one coherent mental model.
        _return_to_iris(func(): _enter_experience(next_screen))

func _enter_experience(next_screen: String) -> void:
    if next_screen == "home" or transition.busy:
        return
    if is_instance_valid(sound):
        sound.threshold_transition_tone(true)
    transition.play_enter(iris, func(): _switch_screen(next_screen))

func _return_to_iris(after_return := Callable()) -> void:
    if active_screen == "home":
        if after_return.is_valid():
            after_return.call()
        return
    pending_after_return = after_return
    pending_return_from_witness = active_screen == "witness"
    pending_return_from_tutorial = active_screen == "tutorial_awakening"
    if is_instance_valid(sound):
        sound.threshold_transition_tone(false)
    transition.play_return(iris, func(): _switch_screen("home"))

func _switch_screen(next_screen: String) -> void:
    var target: Control
    match next_screen:
        "home": target = iris
        "witness": target = witness
        "tutorial_awakening": target = tutorial_awakening
        "archive": target = archive
        "discovery": target = discovery
        "profile": target = profile
        "settings": target = settings
        "daily_witness": target = daily_witness
        "weekly_investigation": target = weekly_investigation
        "calibration": target = calibration
        _: target = iris
    for child in $Interface/ScreenRoot.get_children():
        child.visible = child == target
    active_screen = next_screen
    edge_glow.set_mode(next_screen)
    _update_hud(next_screen)
    if next_screen == "home":
        iris.set_transition_open(0.0)
        var home_state := IrisStateManager.CURIOUS if state_manager.discovery_count > state_manager.completed_observations else IrisStateManager.IDLE
        state_manager.set_living_state(home_state)
    elif next_screen == "witness":
        state_manager.set_living_state(IrisStateManager.FOCUS)
        witness.enter()
        if witness_runtime.is_active():
            witness_runtime.notify_witness_surface_ready()
        voice_guide.on_witness_entered()
    elif next_screen == "tutorial_awakening":
        state_manager.set_living_state(IrisStateManager.FOCUS)
        if is_instance_valid(tutorial_awakening):
            tutorial_awakening.enter()
    elif next_screen == "archive":
        state_manager.set_living_state(IrisStateManager.MEMORY)
        archive.enter()
    else:
        state_manager.set_living_state(IrisStateManager.IDLE)
        if next_screen == "discovery":
            discovery.enter()
        elif next_screen == "profile":
            profile.enter()
        elif next_screen == "settings":
            settings.enter()
            voice_guide.on_calibration_opened()

func show_home() -> void:
    witness.set_runtime_active(false)
    _show_screen("home")

func _on_transition_finished(kind: String) -> void:
    if kind != "return":
        return
    if pending_return_from_tutorial:
        pending_return_from_tutorial = false
        state_manager.complete_onboarding_tutorial()
        if is_instance_valid(iris):
            iris._sync_progression()
        if is_instance_valid(voice_guide):
            voice_guide.trigger_iris_expression("NEW_PLAYER", "tutorial_accepted")
        if is_instance_valid(sound):
            sound.reflection_tone()
        _show_rank_reveal("RANK 1 : OBSERVER", "Chapter 1: Learning to Notice unlocked.")
    if pending_return_from_witness:
        iris.remember_recent_activity()
        if is_instance_valid(sound):
            sound.reflection_tone()
        if is_instance_valid(voice_guide):
            voice_guide.trigger_iris_expression("RETURN")
        pending_return_from_witness = false
    if pending_after_return.is_valid():
        var next := pending_after_return
        pending_after_return = Callable()
        next.call()

func _on_tutorial_return() -> void:
    show_home()

func _show_rank_reveal(title: String, subtitle: String) -> void:
    if is_instance_valid(iris) and is_instance_valid(iris.destination_title) and is_instance_valid(iris.destination_prompt):
        iris.destination_title.text = title
        iris.destination_prompt.text = subtitle
        iris.title_alpha_current = 1.0

func _on_intent(intent: int, event_pos: Vector2, _vector: Vector2, source: String) -> void:
    if production_startup and production_startup.is_active():
        return
    match intent:
        IrisInputIntent.ENTER:
            _on_tap(event_pos)
        IrisInputIntent.FOCUS:
            var focus_position := event_pos
            if source == "keyboard" or source == "controller":
                focus_position = get_viewport_rect().size * 0.5
            _on_hold(focus_position)
        IrisInputIntent.RETURN:
            _handle_back()
        IrisInputIntent.EXPLORE_LEFT:
            _on_swipe("left")
        IrisInputIntent.EXPLORE_RIGHT:
            _on_swipe("right")
        IrisInputIntent.EXPLORE_UP:
            _on_swipe("up")
        IrisInputIntent.EXPLORE_DOWN:
            _on_swipe("down")

func _on_capabilities_changed() -> void:
    iris.set_desktop_mode(not device.has_touchscreen)
    if not device.has_audio:
        voice_guide.set_enabled(false)

func _on_motion_changed(acceleration: Vector3) -> void:
    if not state_manager.reduced_motion and state_manager.parallax_enabled:
        iris.set_sensor_offset(acceleration)

func _on_orientation_transition(progress: float, _current: int, _previous: int) -> void:
    var motion := 0.0 if state_manager.reduced_motion else sin(progress * PI)
    iris.set_orientation_motion(motion)

func _on_orientation_changed(current: int, _previous: int) -> void:
    _layout_hud(get_viewport_rect().size, current)
    caption_overlay.set_landscape(get_viewport_rect().size.x > get_viewport_rect().size.y)

func _layout_hud(viewport_size: Vector2, _orientation: int) -> void:
    var landscape := viewport_size.x > viewport_size.y
    var brand: Label = hud_labels.get("brand")
    var descriptor: Label = hud_labels.get("descriptor")
    if not brand or not descriptor:
        return
    if landscape:
        brand.position = Vector2(38, 24)
        brand.size = Vector2(320, 30)
        descriptor.position = Vector2(40, 53)
        descriptor.size = Vector2(420, 22)
    else:
        brand.position = Vector2(30, 28)
        brand.size = Vector2(280, 30)
        descriptor.position = Vector2(31, 57)
        descriptor.size = Vector2(350, 22)

func _on_cursor_moved(event_pos: Vector2) -> void:
    if active_screen == "home" and not transition.busy:
        iris.set_gaze_target(event_pos, get_viewport_rect().size)

func _on_pointer_started(event_pos: Vector2) -> void:
    if active_screen == "home" and not transition.busy:
        iris.set_interaction(true)
        voice_guide.set_interaction_active(true)
        iris.set_gaze_target(event_pos, get_viewport_rect().size)

func _on_pointer_moved(event_pos: Vector2) -> void:
    if active_screen == "home" and not transition.busy:
        iris.set_gaze_target(event_pos, get_viewport_rect().size)

func _on_pointer_ended(_position: Vector2) -> void:
    if active_screen == "home":
        var target := iris.active_destination_key
        iris.set_interaction(false)
        voice_guide.set_interaction_active(false)
        if not transition.busy:
            var view := get_viewport_rect().size
            var normalized := Vector2(_position.x / maxf(view.x, 1.0), _position.y / maxf(view.y, 1.0))
            if target == "story_mode" and normalized.distance_to(Vector2(0.5, 0.5)) > 0.30:
                # Ignore edge taps that haven't given the Iris time to look there
                return
            _navigate_iris_destination(target)

func _navigate_iris_destination(target: String) -> void:
    state_manager.mark_first_launch_seen()
    if intro_running:
        _finish_first_launch_intro()
    match target:
        "story_mode":
            voice_guide.on_first_touch()
            _start_director_selected_witness("story")
        "archive":
            _show_screen("archive")
        "profile":
            _show_screen("profile")
        "daily_witness":
            _show_screen("discovery")
        "calibration":
            _show_screen("settings")
        _:
            iris.focus_pulse()

func _on_dragged(_position: Vector2, delta: Vector2) -> void:
    if active_screen == "home" and not transition.busy:
        iris.update_directional_anticipation(delta, get_viewport_rect().size)

func _on_tap(event_pos: Vector2) -> void:
    if production_startup and production_startup.is_active():
        return
    state_manager.mark_first_launch_seen()
    if intro_running:
        _finish_first_launch_intro()
    if transition.busy:
        return
    if active_screen == "home":
        pass # Navigation is now managed purely by Iris-guided focus in _on_pointer_ended
    elif active_screen == "witness":
        witness.handle_tap(event_pos)
    elif active_screen == "archive":
        archive.handle_tap(event_pos)
    elif active_screen == "discovery":
        discovery.handle_tap(event_pos)
    elif active_screen == "profile":
        if event_pos.y < 100.0:
            show_home()
    elif active_screen == "settings":
        settings.handle_tap(event_pos)
    elif active_screen == "daily_witness":
        daily_witness.handle_tap(event_pos)
    elif active_screen == "weekly_investigation":
        weekly_investigation.handle_tap(event_pos)
    elif active_screen == "calibration":
        calibration.handle_tap(event_pos)

func _on_hold(event_pos: Vector2) -> void:
    if production_startup and production_startup.is_active():
        return
    state_manager.mark_first_launch_seen()
    if transition.busy:
        return
    if active_screen == "home":
        var view := get_viewport_rect().size
        var normalized := Vector2(event_pos.x / maxf(view.x, 1.0), event_pos.y / maxf(view.y, 1.0))
        if normalized.distance_to(Vector2(0.5, 0.50)) < 0.26:
            # Hold is intentionally not a second way to enter Witness. It is
            # a quiet calibration state that can be felt before the next tap.
            iris.start_deep_focus()
    elif active_screen == "witness":
        witness.pulse_focus()
        iris.focus_pulse()

func _on_swipe(direction: String) -> void:
    if production_startup and production_startup.is_active():
        return
    state_manager.mark_first_launch_seen()
    if transition.busy:
        return
    if active_screen == "home":
        # Swipe navigation on the main screen is deprecated in favor of Iris focus.
        return
    match direction:
        "left": _show_screen("archive")
        "right": _show_screen("discovery")
        "down": _show_screen("profile")
        "up": _show_screen("settings")

func show_witness(_from_hold := false) -> void:
    witness.set_runtime_active(false)
    sound.focus_pulse()
    _show_screen("witness")

func _on_accessibility_action(action: String) -> void:
    accessibility_panel.visible = false
    match action:
        "witness": show_witness()
        "archive": _show_screen("archive")
        "discovery": _show_screen("discovery")
        "profile": _show_screen("profile")
        "settings": _show_screen("settings")
        "home": show_home()
        "close": pass

func _handle_back() -> void:
    if accessibility_panel.visible:
        accessibility_panel.visible = false
        return
    if intro_running:
        _finish_first_launch_intro()
    if transition.busy:
        return
    if active_screen == "home":
        get_tree().quit()
    else:
        if active_screen == "witness":
            if witness_runtime.is_active():
                witness_runtime.request_return()
            elif production_bridge:
                production_bridge.return_to_iris()
        show_home()

func _on_story_requested() -> void:
    _start_director_selected_witness("story")

func _on_moment_requested(_moment_id: String) -> void:
    _start_director_selected_witness("story")

func _start_director_selected_witness(mode: String = "story") -> void:
    if witness_director == null or witness_runtime == null:
        return
    var selection := witness_director.get_next_incident({"mode": mode})
    if selection.is_empty():
        return
    witness_runtime.start_incident(selection)

func _incident_registry() -> Node:
    return get_tree().root.get_node_or_null("IncidentRegistry")

func _on_runtime_enter_requested(_moment: WitnessMoment) -> void:
    witness.set_runtime_active(true)
    _show_screen("witness")
    var registry := _incident_registry()
    if registry:
        registry.notify_incident_active()

func _on_runtime_phase_started(phase_name: String, _moment_id: String) -> void:
    # Debug instrumentation for phase transitions
    print("Witness Moment phase started: %s" % phase_name)

func _on_runtime_phase_completed(phase_name: String, _data: Dictionary) -> void:
    # Debug instrumentation for phase completions
    print("Witness Moment phase completed: %s" % phase_name)

func _on_runtime_moment_completed(_moment_id: String, _result: Dictionary) -> void:
    # Progression is recorded by PlayerProgressService through WitnessRuntimeResult.
    var registry := _incident_registry()
    if registry:
        registry.notify_incident_completed(_result)
    sound.reflection_tone()
    voice_guide.trigger_iris_expression("WITNESS_COMPLETE")
    if is_instance_valid(profile):
        profile._refresh_copy()
    if is_instance_valid(iris):
        iris.remember_recent_activity()
    # MISSION 013: Return the player to Iris after completion.
    # The reflection tone plays during the 2.8-second grace window, then
    # the player transitions home through the standard Iris return sequence.
    get_tree().create_timer(2.8).timeout.connect(_return_to_iris_after_completion)

func _return_to_iris_after_completion() -> void:
    if active_screen == "witness" and not witness_runtime.is_active():
        show_home()

func _on_runtime_moment_failed(_moment_id: String, _reason: String) -> void:
    var registry := _incident_registry()
    if registry:
        registry.notify_incident_failed(_reason)
    if active_screen == "witness":
        show_home()

func _on_runtime_return_requested(_moment_id: String) -> void:
    # Orchestrator requests return to iris
    var registry := _incident_registry()
    if registry:
        registry.notify_incident_abandoned()
    show_home()

func _on_future_destination(destination: String) -> void:
    match destination:
        "daily_witness": _show_screen("daily_witness")
        "weekly_investigation": _show_screen("weekly_investigation")
        "archive": _show_screen("archive")
        "calibration": _show_screen("calibration")

func _on_state_changed(new_state: int) -> void:
    iris.set_living_state(new_state)

func _on_progress_changed() -> void:
    profile._refresh_copy()

func _on_caption_changed(text: String, should_show: bool) -> void:
    if should_show and state_manager.captions_enabled:
        caption_overlay.show_caption(text)
    else:
        caption_overlay.hide_caption()

func _on_preferences_changed() -> void:
    sound.set_enabled(state_manager.sound_enabled and device.has_audio)
    voice_guide.set_enabled(state_manager.sound_enabled and device.has_audio)
    voice_guide.set_captions_enabled(state_manager.captions_enabled)
    iris.set_animation_intensity(0.18 if state_manager.reduced_motion else state_manager.animation_intensity)
    iris.set_parallax_enabled(state_manager.parallax_enabled and not state_manager.reduced_motion)
    transition.set_reduced_motion(state_manager.reduced_motion)
    orientation.set_orientation_lock(state_manager.orientation_lock)
    accessibility_panel.visible = state_manager.accessible_navigation
    var visibility_color := Color("#ffffff") if state_manager.high_contrast else Color("#dff4ee")
    for label in hud_labels.values():
        if label is Label:
            label.add_theme_color_override("font_color", visibility_color)

func _on_screen_action(action: String) -> void:
    if action == "completed":
        # Legacy fallback screens may still emit completion, but gameplay
        # progression must only be recorded by PlayerProgressService.
        sound.discovery_tone()
        voice_guide.on_witness_completed()
        profile._refresh_copy()

func _update_hud(screen_name: String) -> void:
    var home := screen_name == "home"
    # Navigation is now encoded in the Iris rim. The old text labels remain
    # instantiated only for compatibility with the original prototype, but
    # never compete with the optical cues.
    hud_labels["archive"].visible = false
    hud_labels["discovery"].visible = false
    hud_labels["profile"].visible = false
    hud_labels["settings"].visible = false
    hud_labels["prompt"].visible = false
    hud_labels["subprompt"].visible = false
    hud_labels["brand"].visible = home
    hud_labels["descriptor"].visible = home

func _start_first_launch_intro() -> void:
    intro_running = true
    intro_elapsed = 0.0
    if is_instance_valid(iris):
        iris.start_awakening()
    if is_instance_valid(voice_guide):
        voice_guide.begin_session()

func _set_intro_explore() -> void:
    hud_labels["intro_title"].text = "SWIPE  ·  EXPLORE"
    hud_labels["intro_line"].text = "move through the instrument"

func _set_intro_focus() -> void:
    hud_labels["intro_title"].text = "HOLD  ·  FOCUS"
    hud_labels["intro_line"].text = "let the field reveal itself"

func _finish_first_launch_intro() -> void:
    if not intro_running:
        return
    intro_running = false
    hud_labels["intro_title"].modulate.a = 0.0
    hud_labels["intro_line"].modulate.a = 0.0
    state_manager.mark_first_launch_seen()
