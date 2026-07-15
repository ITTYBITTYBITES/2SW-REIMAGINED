extends Control
class_name MobileSimulator

const MAIN_SCENE := preload("res://scenes/Main.tscn")

var profiles := {
	"compact": Vector2i(360, 800),
	"standard": Vector2i(432, 960),
	"large": Vector2i(480, 1067),
	"tablet": Vector2i(800, 1280)
}
var profile_order := ["compact", "standard", "large", "tablet"]
var profile_index := 1
var profile_name := "standard"
var orientation := 0 # 0 portrait, 1 landscape left, 2 landscape right
var frame_visible := true
var notch_visible := true
var dev_overlay_visible := true
var simulation_enabled := true
var screen_rect := Rect2()
var phone_rect := Rect2()
var main_instance: Node

@onready var phone_display: SubViewportContainer = $PhoneDisplay
@onready var subviewport: SubViewport = $PhoneDisplay/SubViewport
@onready var frame_overlay: MobileFrameOverlay = $FrameOverlay
@onready var touch_indicator: Control = $TouchIndicator
@onready var dev_label: Label = $DeveloperOverlay

func _ready() -> void:
	set_process_input(true)
	set_process(true)
	simulation_enabled = not OS.has_feature("mobile")
	if simulation_enabled:
		main_instance = MAIN_SCENE.instantiate()
		main_instance.name = "Main"
		subviewport.add_child(main_instance)
		await get_tree().process_frame
		_apply_profile()
	else:
		_activate_native_runtime()

func _activate_native_runtime() -> void:
	# Android exports keep Main as the direct full-screen application. The
	# simulator shell is a desktop-only development layer.
	frame_overlay.visible = false
	touch_indicator.visible = false
	dev_label.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	phone_display.queue_free()
	var direct_main := MAIN_SCENE.instantiate()
	direct_main.name = "Main"
	add_child(direct_main)
	main_instance = direct_main

func _process(_delta: float) -> void:
	if simulation_enabled:
		_update_developer_overlay()
		if get_viewport_rect().size != Vector2.ZERO and screen_rect.size == Vector2.ZERO:
			_apply_profile()

func _input(event: InputEvent) -> void:
	if not simulation_enabled:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _handle_shortcut(event.keycode):
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and screen_rect.has_point(event.position):
				touch_indicator.call("show_touch", event.position)
			elif not event.pressed:
				touch_indicator.call("hide_touch")
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			touch_indicator.call("hide_touch")
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT and screen_rect.has_point(event.position):
			touch_indicator.call("move_touch", event.position)

func _handle_shortcut(keycode: int) -> bool:
	match keycode:
		KEY_F1:
			frame_visible = not frame_visible
			_apply_profile()
			return true
		KEY_F2:
			set_simulated_orientation(0)
			return true
		KEY_F3:
			set_simulated_orientation(1)
			return true
		KEY_F4:
			_simulate_back()
			return true
		KEY_F5:
			_restart_session(false)
			return true
		KEY_F6:
			_clear_onboarding_data()
			return true
		KEY_F7:
			_toggle_sound()
			return true
		KEY_F8:
			_cycle_profile()
			return true
		KEY_F9:
			set_simulated_orientation(2)
			return true
		KEY_F10:
			dev_overlay_visible = not dev_overlay_visible
			dev_label.visible = dev_overlay_visible
			return true
		KEY_1:
			_set_profile(0)
			return true
		KEY_2:
			_set_profile(1)
			return true
		KEY_3:
			_set_profile(2)
			return true
		KEY_4:
			_set_profile(3)
			return true
		KEY_5:
			_force_dev_first_launch()
			return true
		KEY_6:
			_force_dev_returning_player()
			return true
		KEY_7:
			_force_dev_reset_progression()
			return true
		KEY_8:
			_force_dev_max_evolution()
			return true
	return false

func _force_dev_first_launch() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("StateManager")
	if manager:
		manager.first_launch = true
		manager.completed_observations = 0
		manager.discovery_count = 0
	if main_instance.has_method("_start_first_launch_intro"):
		main_instance._start_first_launch_intro()

func _force_dev_returning_player() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("StateManager")
	if manager:
		manager.first_launch = false
		manager.completed_observations = 3
		manager.discovery_count = 3
	var iris := main_instance.get_node_or_null("Interface/ScreenRoot/IrisScreen")
	if iris and iris.has_method("_sync_progression"):
		iris._sync_progression()

func _force_dev_reset_progression() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("StateManager")
	if manager:
		manager.completed_observations = 0
		manager.attention_score = 0
		manager.discovery_count = 0
	var iris := main_instance.get_node_or_null("Interface/ScreenRoot/IrisScreen")
	if iris and iris.has_method("_sync_progression"):
		iris._sync_progression()

func _force_dev_max_evolution() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("StateManager")
	if manager:
		manager.completed_observations = 10
	var iris := main_instance.get_node_or_null("Interface/ScreenRoot/IrisScreen")
	if iris:
		iris.progression_level = 4
		iris.glow_strength = 1.0

func _cycle_profile() -> void:
	_set_profile((profile_index + 1) % profile_order.size())

func _set_profile(index: int) -> void:
	profile_index = clampi(index, 0, profile_order.size() - 1)
	profile_name = profile_order[profile_index]
	_apply_profile()

func _orientation_label() -> String:
	match orientation:
		1: return "Landscape Left"
		2: return "Landscape Right"
		_: return "Portrait"

func _profile_size() -> Vector2i:
	match profile_name:
		"compact": return Vector2i(360, 800)
		"large": return Vector2i(480, 1067)
		"tablet": return Vector2i(800, 1280)
		_: return Vector2i(432, 960)

func set_simulated_orientation(value: int) -> void:
	orientation = clampi(value, 0, 2)
	_apply_profile()

func _apply_profile() -> void:
	if not simulation_enabled or not is_instance_valid(phone_display):
		return
	var base_size: Vector2i = _profile_size()
	var simulated_size := base_size if orientation == 0 else Vector2i(base_size.y, base_size.x)
	subviewport.size = simulated_size
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var available := get_viewport_rect().size - Vector2(150.0, 110.0)
	var scale_factor := minf(available.x / maxf(float(simulated_size.x), 1.0), available.y / maxf(float(simulated_size.y), 1.0))
	scale_factor = maxf(scale_factor, 0.20)
	var display_size := Vector2(simulated_size) * scale_factor
	var frame_border := 34.0 * scale_factor
	var total_phone_size := display_size + Vector2(frame_border * 2.0, frame_border * 2.0)
	var origin := (get_viewport_rect().size - total_phone_size) * 0.5
	phone_rect = Rect2(origin, total_phone_size)
	screen_rect = Rect2(origin + Vector2(frame_border, frame_border), display_size)
	phone_display.position = screen_rect.position
	phone_display.size = Vector2(simulated_size)
	phone_display.scale = Vector2(scale_factor, scale_factor)
	phone_display.pivot_offset = Vector2.ZERO
	frame_overlay.set_geometry(screen_rect, phone_rect, orientation, frame_visible, notch_visible)
	_sync_simulated_orientation()
	queue_redraw()

func _sync_simulated_orientation() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("OrientationManager")
	if manager and manager.has_method("set_simulated_orientation"):
		manager.set_simulated_orientation(orientation)

func _simulate_back() -> void:
	if is_instance_valid(main_instance) and main_instance.has_method("_handle_back"):
		main_instance._handle_back()

func _restart_session(clear_data: bool) -> void:
	if clear_data:
		_remove_user_file("user://the_iris_state.cfg")
		_remove_user_file("user://the_iris_voice.cfg")
	if not simulation_enabled:
		return
	var old_main := main_instance
	if is_instance_valid(old_main):
		old_main.queue_free()
	await get_tree().process_frame
	main_instance = MAIN_SCENE.instantiate()
	main_instance.name = "Main"
	subviewport.add_child(main_instance)
	await get_tree().process_frame
	_apply_profile()

func _clear_onboarding_data() -> void:
	_restart_session(true)

func _remove_user_file(path: String) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(absolute):
		DirAccess.remove_absolute(absolute)

func _toggle_sound() -> void:
	if not is_instance_valid(main_instance):
		return
	var manager := main_instance.get_node_or_null("StateManager")
	if manager:
		manager.sound_enabled = not manager.sound_enabled
		manager.update_preferences()

func _update_developer_overlay() -> void:
	if not dev_overlay_visible:
		return
	var state_name := "unknown"
	var active := "unknown"
	var manager := main_instance.get_node_or_null("StateManager") if is_instance_valid(main_instance) else null
	if manager:
		var states := ["IDLE", "CURIOUS", "FOCUS", "MEMORY"]
		var state_index := int(manager.current_state)
		state_name = states[state_index] if state_index >= 0 and state_index < states.size() else "unknown"
	if is_instance_valid(main_instance):
		active = str(main_instance.get("active_screen"))
	var orientation_label: String = _orientation_label()
	var display_size: Vector2i = _profile_size()
	if orientation != 0:
		display_size = Vector2i(display_size.y, display_size.x)
	dev_label.text = "SIMULATOR  ·  %s\n%s  %s × %s\n%s  ·  Iris %s\nFPS %d  ·  F1 frame  F2/F3/F9 rotate  F4 back  F5 restart  F6 clear\nDEV KEYS: 5 First Launch  |  6 Returning Player  |  7 Reset Prog  |  8 Max Evolution" % [
		profile_name.to_upper(),
		orientation_label,
		display_size.x,
		display_size.y,
		active,
		state_name,
		Engine.get_frames_per_second()
	]

func _draw() -> void:
	if not simulation_enabled or not frame_visible or phone_rect.size == Vector2.ZERO:
		return
	draw_style_box(_frame_box(), phone_rect)
	draw_circle(phone_rect.position + Vector2(28.0, 28.0), 5.0, Color(0.22, 0.42, 0.44, 0.35))

func _frame_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("#0c141c")
	var radius := int(minf(46.0, minf(phone_rect.size.x, phone_rect.size.y) * 0.07))
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.50)
	box.shadow_size = 18
	return box
