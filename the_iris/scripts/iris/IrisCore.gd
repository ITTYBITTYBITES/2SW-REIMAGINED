extends Node
class_name IrisCore

## The single behavior authority for the procedural Living Iris.
enum State { DORMANT, CALIBRATING, STIRRING, AWAKENING, WELCOMING, AWARE, ATTENDING, FOCUSED, OBSERVING, SETTLED, REFLECTIVE }

signal state_changed(state: State)

var state: State = State.DORMANT
var state_time := 0.0
var life_time := 0.0
var gaze := Vector2.ZERO
var gaze_target := Vector2.ZERO
var pupil := 0.38
var glow := 0.0
var saccade_in := 0.65
var blink_in := 6.0
var blink_elapsed := -1.0
var blink_amount := 0.0
var pulse_in := 7.0
var pulse_amount := 0.0
var organic_seed := 0.0
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()
	organic_seed = random.randf_range(0.0, TAU)
	blink_in = random.randf_range(4.8, 9.6)
	pulse_in = random.randf_range(5.5, 11.0)

func transition_to(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_time = 0.0
	saccade_in = random.randf_range(0.06, 0.22)
	state_changed.emit(state)

func acquire_attention(normalized_target: Vector2) -> void:
	gaze_target = normalized_target.limit_length(0.035)
	saccade_in = 0.42
	transition_to(State.ATTENDING)

func tick(delta: float) -> Dictionary:
	state_time += delta
	life_time += delta
	_advance_lifecycle()

	var profile := _profile()
	_update_gaze(delta, float(profile["saccade"]))
	_update_blink(delta, bool(profile["blink_enabled"]))
	_update_energy_pulse(delta, bool(profile["pulse_enabled"]))

	var primary_breath := sin(life_time * float(profile["breath_primary"]) * TAU + organic_seed) * 0.5 + 0.5
	var secondary_breath := sin(life_time * float(profile["breath_secondary"]) * TAU + organic_seed * 2.17) * 0.5 + 0.5
	var breath_wave := clampf(0.5 + (primary_breath - 0.5) * 0.72 + (secondary_breath - 0.5) * 0.28, 0.0, 1.0)
	var pupil_target := float(profile["pupil"]) + (breath_wave - 0.5) * float(profile["pupil_breath"])
	pupil = lerpf(pupil, pupil_target, minf(1.0, delta * float(profile["pupil_response"])))
	glow = lerpf(glow, float(profile["glow"]), minf(1.0, delta * 2.35))

	var energy_drift := sin(life_time * 0.093 + organic_seed) * 0.5 + 0.5
	energy_drift = clampf(energy_drift * 0.65 + (sin(life_time * 0.027 + organic_seed * 1.6) * 0.5 + 0.5) * 0.35, 0.0, 1.0)
	return {
		"breath_primary": float(profile["breath_primary"]),
		"breath_secondary": float(profile["breath_secondary"]),
		"breath_wave": breath_wave,
		"glow": glow,
		"pupil": pupil,
		"gaze": gaze,
		"fiber_motion": float(profile["fiber_motion"]),
		"fiber_density": int(profile["fiber_density"]),
		"focus": float(profile["focus"]),
		"reflective": float(profile["reflective"]),
		"presence": float(profile["presence"]),
		"calibration": float(profile["calibration"]),
		"blink": blink_amount,
		"pulse": pulse_amount,
		"drift": energy_drift,
		"asymmetry": organic_seed
	}

func _advance_lifecycle() -> void:
	match state:
		State.CALIBRATING:
			if state_time >= 0.62:
				transition_to(State.STIRRING)
		State.STIRRING:
			if state_time >= 1.05:
				transition_to(State.AWAKENING)
		State.AWAKENING:
			if state_time >= 1.72:
				transition_to(State.WELCOMING)
		State.WELCOMING:
			if state_time >= 2.25:
				transition_to(State.AWARE)
		State.ATTENDING:
			if state_time >= 0.34:
				transition_to(State.FOCUSED)

func _update_gaze(delta: float, amplitude: float) -> void:
	saccade_in -= delta
	if saccade_in <= 0.0:
		var direction := Vector2(random.randf_range(-1.0, 1.0), random.randf_range(-0.72, 0.72))
		if direction.length_squared() < 0.01:
			direction = Vector2.RIGHT
		gaze_target = direction.normalized() * random.randf_range(amplitude * 0.24, amplitude)
		saccade_in = random.randf_range(0.62, 2.45)
	gaze = gaze.lerp(gaze_target, minf(1.0, delta * 7.2))

func _update_blink(delta: float, enabled: bool) -> void:
	blink_amount = 0.0
	if not enabled:
		blink_elapsed = -1.0
		return
	if blink_elapsed >= 0.0:
		blink_elapsed += delta
		var progress := blink_elapsed / 0.18
		blink_amount = sin(clampf(progress, 0.0, 1.0) * PI)
		if progress >= 1.0:
			blink_elapsed = -1.0
			blink_in = random.randf_range(5.8, 14.6)
		return
	blink_in -= delta
	if blink_in <= 0.0:
		blink_elapsed = 0.0

func _update_energy_pulse(delta: float, enabled: bool) -> void:
	pulse_amount = move_toward(pulse_amount, 0.0, delta * 0.38)
	if not enabled:
		return
	pulse_in -= delta
	if pulse_in <= 0.0:
		pulse_amount = random.randf_range(0.24, 0.55)
		pulse_in = random.randf_range(7.0, 17.0)

func _profile() -> Dictionary:
	var profile := _base_profile()
	match state:
		State.DORMANT:
			profile.merge({"presence": 0.0, "glow": 0.0, "pupil": 0.42, "fiber_motion": 0.0, "fiber_density": 0, "pulse_enabled": false}, true)
		State.CALIBRATING:
			var calibration_rise := _ease_out(clampf(state_time / 0.62, 0.0, 1.0))
			profile.merge({"presence": 0.08 + calibration_rise * 0.13, "glow": 0.10 + calibration_rise * 0.10, "pupil": 0.40, "fiber_motion": 0.14, "fiber_density": 26, "calibration": 0.8, "blink_enabled": false}, true)
		State.STIRRING:
			var stirring_rise := _ease_out(clampf(state_time / 1.05, 0.0, 1.0))
			profile.merge({"presence": 0.22 + stirring_rise * 0.25, "glow": 0.16 + stirring_rise * 0.17, "pupil": 0.38 - stirring_rise * 0.04, "fiber_motion": 0.25 + stirring_rise * 0.18, "fiber_density": 38, "calibration": 0.18}, true)
		State.AWAKENING:
			var opening := _ease_out(clampf(state_time / 1.72, 0.0, 1.0))
			profile.merge({"presence": 0.50 + opening * 0.42, "glow": 0.34 + opening * 0.48, "pupil": 0.35 - opening * 0.08, "pupil_breath": 0.020, "pupil_response": 5.2, "fiber_motion": 0.40 + opening * 0.45, "fiber_density": 56, "focus": opening * 0.42, "calibration": 0.0}, true)
		State.WELCOMING:
			profile.merge({"presence": 1.0, "glow": 0.76, "pupil": 0.268, "fiber_motion": 0.74, "fiber_density": 64, "focus": 0.34}, true)
		State.AWARE:
			profile.merge({"presence": 1.0, "glow": 0.60, "pupil": 0.286, "fiber_motion": 0.55, "fiber_density": 58, "focus": 0.16}, true)
		State.ATTENDING:
			profile.merge({"presence": 1.0, "glow": 0.80, "pupil": 0.245, "pupil_response": 9.0, "fiber_motion": 0.78, "fiber_density": 64, "focus": 0.72}, true)
		State.FOCUSED:
			profile.merge({"presence": 1.0, "glow": 0.98, "pupil": 0.205, "pupil_response": 8.0, "fiber_motion": 0.90, "fiber_density": 68, "focus": 1.0}, true)
		State.OBSERVING:
			profile.merge({"presence": 1.0, "glow": 0.80, "pupil": 0.226, "pupil_breath": 0.008, "pupil_response": 6.4, "fiber_motion": 0.74, "fiber_density": 62, "focus": 0.82}, true)
		State.SETTLED:
			profile.merge({"presence": 1.0, "glow": 0.40, "pupil": 0.307, "fiber_motion": 0.38, "fiber_density": 50, "focus": 0.06, "reflective": 0.24}, true)
		State.REFLECTIVE:
			profile.merge({"presence": 1.0, "glow": 0.50, "pupil": 0.314, "fiber_motion": 0.32, "fiber_density": 48, "reflective": 1.0, "pulse_enabled": true}, true)
	return profile

func _base_profile() -> Dictionary:
	return {
		"breath_primary": 0.46,
		"breath_secondary": 0.118,
		"glow": 0.12,
		"pupil": 0.36,
		"pupil_breath": 0.012,
		"pupil_response": 3.6,
		"saccade": 0.017,
		"fiber_motion": 0.24,
		"fiber_density": 42,
		"focus": 0.0,
		"reflective": 0.0,
		"presence": 1.0,
		"calibration": 0.0,
		"blink_enabled": true,
		"pulse_enabled": true
	}

func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)
