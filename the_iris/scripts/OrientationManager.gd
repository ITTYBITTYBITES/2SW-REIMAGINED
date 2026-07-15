extends Node
class_name OrientationManager

signal orientation_will_change(previous: int, next: int)
signal orientation_changed(current: int, previous: int)
signal transition_progress(progress: float, current: int, previous: int)

enum Orientation { PORTRAIT, LANDSCAPE_LEFT, LANDSCAPE_RIGHT }

const STABILITY_THRESHOLD := 0.75
const TRANSITION_DURATION := 0.48

var current_orientation: int = Orientation.PORTRAIT
var pending_orientation: int = Orientation.PORTRAIT
var pending_time := 0.0
var transition_time := 1.0
var transition_from: int = Orientation.PORTRAIT
var transition_to: int = Orientation.PORTRAIT
var orientation_locked := false
var simulated_orientation := -1
var initialized := false

func _ready() -> void:
	set_process(true)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	current_orientation = _detect_orientation()
	pending_orientation = current_orientation
	initialized = true

func _process(delta: float) -> void:
	var detected: int = _detect_orientation()
	if detected != current_orientation and detected != pending_orientation:
		pending_orientation = detected
		pending_time = 0.0
	elif detected == pending_orientation and detected != current_orientation:
		pending_time += delta
		if pending_time >= STABILITY_THRESHOLD and not orientation_locked:
			_commit_orientation(pending_orientation)
	if transition_time < 1.0:
		transition_time = minf(1.0, transition_time + delta / TRANSITION_DURATION)
		var eased := transition_time * transition_time * (3.0 - 2.0 * transition_time)
		transition_progress.emit(eased, transition_to, transition_from)

func _on_viewport_size_changed() -> void:
	# Android reports several intermediate aspect ratios while rotating. The
	# stable commit remains debounced in _process.
	pending_time = 0.0

func _viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size

func set_simulated_orientation(value: int) -> void:
	simulated_orientation = clampi(value, 0, 2)
	pending_orientation = simulated_orientation
	pending_time = 0.0

func _detect_orientation() -> int:
	if simulated_orientation >= 0:
		return simulated_orientation
	var size: Vector2 = _viewport_size()
	var landscape_view := size.x > size.y * 1.12
	if not landscape_view:
		return Orientation.PORTRAIT
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		var raw: int = DisplayServer.screen_get_orientation()
		if raw == DisplayServer.SCREEN_REVERSE_LANDSCAPE:
			return Orientation.LANDSCAPE_RIGHT
	return Orientation.LANDSCAPE_LEFT

func _commit_orientation(next_orientation: int) -> void:
	if next_orientation == current_orientation:
		return
	var previous := current_orientation
	current_orientation = next_orientation
	transition_from = previous
	transition_to = next_orientation
	transition_time = 0.0
	pending_time = 0.0
	orientation_will_change.emit(previous, next_orientation)
	orientation_changed.emit(next_orientation, previous)

func set_orientation_lock(value: bool) -> void:
	orientation_locked = value
	if not orientation_locked or not DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		return
	match current_orientation:
		Orientation.PORTRAIT:
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		Orientation.LANDSCAPE_LEFT:
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
		Orientation.LANDSCAPE_RIGHT:
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_REVERSE_LANDSCAPE)

func is_landscape() -> bool:
	return current_orientation != Orientation.PORTRAIT

func orientation_name(value: int = -1) -> String:
	var actual := current_orientation if value < 0 else value
	match actual:
		Orientation.LANDSCAPE_LEFT: return "Landscape Left"
		Orientation.LANDSCAPE_RIGHT: return "Landscape Right"
		_: return "Portrait"
