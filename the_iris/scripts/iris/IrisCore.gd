extends Node
class_name IrisCore

## Behavior-only state model for the procedural Living Iris.
enum State { DORMANT, AWAKENING, WELCOMING, AWARE, FOCUSED, OBSERVING, SETTLED, REFLECTIVE, CALIBRATING }

signal state_changed(state: State)

var state: State = State.DORMANT
var state_time := 0.0
var gaze := Vector2.ZERO
var gaze_target := Vector2.ZERO
var pupil := 0.36
var glow := 0.14
var saccade_in := 0.42
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()

func transition_to(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_time = 0.0
	saccade_in = 0.12
	state_changed.emit(state)

func tick(delta: float) -> Dictionary:
	state_time += delta
	if state == State.CALIBRATING and state_time >= 0.72:
		transition_to(State.AWAKENING)
	elif state == State.AWAKENING and state_time >= 1.35:
		transition_to(State.WELCOMING)
	elif state == State.WELCOMING and state_time >= 2.1:
		transition_to(State.AWARE)

	var profile := _profile()
	_update_gaze(delta, float(profile["saccade"]))
	var breathing := sin(state_time * float(profile["breath"]) * TAU) * 0.5 + 0.5
	var pupil_target := float(profile["pupil"]) + (breathing - 0.5) * float(profile["pupil_breath"])
	pupil = lerpf(pupil, pupil_target, minf(1.0, delta * float(profile["pupil_response"])))
	glow = lerpf(glow, float(profile["glow"]), minf(1.0, delta * 2.8))

	return {
		"breath": float(profile["breath"]),
		"glow": glow,
		"pupil": pupil,
		"gaze": gaze,
		"fiber_motion": float(profile["fiber_motion"]),
		"fiber_density": int(profile["fiber_density"]),
		"focus": float(profile["focus"]),
		"reflective": float(profile["reflective"]),
		"awakening": float(profile["awakening"]),
		"calibration": float(profile["calibration"])
	}

func _update_gaze(delta: float, amplitude: float) -> void:
	saccade_in -= delta
	if saccade_in <= 0.0:
		var direction := Vector2(random.randf_range(-1.0, 1.0), random.randf_range(-0.72, 0.72))
		if direction.length_squared() < 0.01:
			direction = Vector2.RIGHT
		gaze_target = direction.normalized() * random.randf_range(amplitude * 0.35, amplitude)
		saccade_in = random.randf_range(0.48, 1.42)
	gaze = gaze.lerp(gaze_target, minf(1.0, delta * 8.5))

func _profile() -> Dictionary:
	match state:
		State.DORMANT:
			return _make_profile(0.42, 0.14, 0.36, 0.010, 1.8, 0.22, 42, 0.0, 0.0, 0.0, 0.0)
		State.AWAKENING:
			var opening := _ease_out(clampf(state_time / 1.35, 0.0, 1.0))
			return _make_profile(0.66, 0.18 + opening * 0.72, 0.42 - opening * 0.14, 0.018, 5.5, 0.10 + opening * 0.95, 58, opening * 0.76, 0.0, opening, 0.0)
		State.WELCOMING:
			return _make_profile(0.74, 0.78, 0.265, 0.016, 4.8, 0.72, 64, 0.34, 0.0, 1.0, 0.0)
		State.AWARE:
			return _make_profile(0.68, 0.62, 0.285, 0.014, 4.0, 0.58, 60, 0.20, 0.0, 1.0, 0.0)
		State.FOCUSED:
			return _make_profile(1.04, 1.0, 0.205, 0.010, 7.8, 0.88, 68, 1.0, 0.0, 1.0, 0.0)
		State.OBSERVING:
			return _make_profile(0.88, 0.82, 0.225, 0.007, 6.4, 0.76, 64, 0.82, 0.0, 1.0, 0.0)
		State.SETTLED:
			return _make_profile(0.54, 0.42, 0.305, 0.012, 3.0, 0.40, 52, 0.08, 0.25, 1.0, 0.0)
		State.REFLECTIVE:
			return _make_profile(0.48, 0.50, 0.31, 0.009, 2.6, 0.34, 50, 0.0, 1.0, 1.0, 0.0)
		State.CALIBRATING:
			return _make_profile(0.58, 0.52, 0.29, 0.005, 4.4, 0.54, 56, 0.36, 0.0, 1.0, 1.0)
	return _make_profile(0.5, 0.2, 0.34, 0.01, 2.0, 0.3, 48, 0.0, 0.0, 1.0, 0.0)

func _make_profile(breath_value: float, glow_value: float, pupil_value: float, pupil_breath_value: float, pupil_response_value: float, fiber_motion_value: float, fiber_density_value: int, focus_value: float, reflective_value: float, awakening_value: float, calibration_value: float) -> Dictionary:
	return {
		"breath": breath_value,
		"glow": glow_value,
		"pupil": pupil_value,
		"pupil_breath": pupil_breath_value,
		"pupil_response": pupil_response_value,
		"saccade": 0.010 if focus_value > 0.7 else 0.017,
		"fiber_motion": fiber_motion_value,
		"fiber_density": fiber_density_value,
		"focus": focus_value,
		"reflective": reflective_value,
		"awakening": awakening_value,
		"calibration": calibration_value
	}

func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)
