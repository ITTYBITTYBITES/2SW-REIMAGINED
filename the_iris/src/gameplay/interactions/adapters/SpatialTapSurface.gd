extends Control
class_name SpatialTapSurface

signal payload_collected(payload: Dictionary)

var _renderer: Control
var _disabled: bool = false

func configure(challenge_data: Dictionary) -> void:
	custom_minimum_size = Vector2(0, 420)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	var scene_value: Variant = challenge_data.get("generated_scene", {})
	var scene_data: Dictionary = (scene_value as Dictionary).duplicate(true) if scene_value is Dictionary else {}
	# Generic render context: response surfaces may need a stable evidence state
	# rather than replaying the observation sequence. Renderers can ignore it.
	scene_data["interaction_phase"] = "response"
	var renderer_script: String = str(scene_data.get("renderer_script", ""))
	if not renderer_script.is_empty() and ResourceLoader.exists(renderer_script):
		_renderer = Control.new()
		_renderer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_renderer.set_script(load(renderer_script))
		_renderer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(_renderer)
		if _renderer.has_method("set_scene_data"):
			_renderer.call("set_scene_data", scene_data, [])

func set_disabled(value: bool) -> void:
	_disabled = value

func _gui_input(event: InputEvent) -> void:
	if _disabled or size.x <= 0.0 or size.y <= 0.0:
		return
	var position_value: Vector2
	if event is InputEventScreenTouch and event.pressed:
		position_value = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		position_value = event.position
	else:
		return
	payload_collected.emit({
		"x": clampf(position_value.x / size.x, 0.0, 1.0),
		"y": clampf(position_value.y / size.y, 0.0, 1.0),
		"input": "spatial_tap"
	})
	accept_event()
