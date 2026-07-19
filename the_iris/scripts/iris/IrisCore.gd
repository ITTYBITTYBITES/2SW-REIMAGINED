extends Node
class_name IrisCore

## The single behavior authority for the procedural Living Iris.
##
## Owns two cooperating layers (both owned here, so the View/Consumers stay dumb):
##   - State: the 11-phase lifecycle (DORMANT..REFLECTIVE) — when/whether the Iris
##     is present, blinking, saccading, etc.
##   - Mood: the dynamic color identity (DORMANT/AWARE/FOCUSED/SUCCESS + neural
##     bleed). Mood is driven by State by default, and can be forced (e.g. SUCCESS
##     on a witnessed truth). Colors NEVER snap — they lerp every frame toward
##     the active mood profile, producing the "neural bleed" through the fibers.
enum State { DORMANT, CALIBRATING, STIRRING, AWAKENING, WELCOMING, AWARE, ATTENDING, FOCUSED, OBSERVING, SETTLED, REFLECTIVE }

## Mood identity. Maps 1:1 to the protocol's Mood Palette.
enum Mood { DORMANT, AWARE, FOCUSED, SUCCESS }

signal state_changed(state: State)
signal mood_changed(mood: Mood)

var state: State = State.DORMANT
var state_time := 0.0
var life_time := 0.0
var gaze := Vector2.ZERO
var gaze_target := Vector2.ZERO
var pupil := 0.38
var glow := 0.0
var presence := 0.0
var fiber_motion := 0.0
var fiber_density := 0.0
var focus_amount := 0.0
var reflective_amount := 0.0
var calibration_amount := 0.0
var saccade_in := 0.65
var blink_in := 6.0
var blink_elapsed := -1.0
var blink_amount := 0.0
var pulse_in := 7.0
var pulse_amount := 0.0
var simulated_attention_in := 2.4
var simulated_focus_amount := 0.0
var organic_seed := 0.0
var random := RandomNumberGenerator.new()

# ---------------------------------------------------------------------------
# MOOD SYSTEM (Atmospheric Mood / Dynamic Color Identity)
# ---------------------------------------------------------------------------
# Active mood, the live (lerping) color values, and the per-mood profile table.
# `_mood_target_*` are the destination values for the current mood; the
# `mood_*` vars lerp toward them every tick. This is the "neural bleed".
var mood: Mood = Mood.DORMANT
var mood_base_color := Color.BLACK
var mood_glow_color := Color.BLACK
var mood_energy := 0.0
var mood_secondary_color := Color.BLACK  # progression tint (Archivist+)
var mood_secondary_weight := 0.0
var _mood_target_base := Color.BLACK
var _mood_target_glow := Color.BLACK
var _mood_target_energy := 0.0
var _mood_target_secondary := Color.BLACK
var _mood_target_secondary_weight := 0.0
var _mood_bleed_speed := 1.0   # per-second lerp rate; change_mood raises this during a transition
var _mood_forced := false       # when true, State changes do not override the mood

const _MOOD_BLEED_DURATION := 1.8  # seconds — protocol §3 "1.5 to 2.0 seconds"

## Mood Profiles — the protocol's Mood Palette (§2), expressed as exact colors.
## Each profile: base_color, glow_color, energy_intensity, [secondary tint].
static func mood_profile(m: Mood) -> Dictionary:
	match m:
		Mood.DORMANT:
			# Obsidian / deep blue — resting. Low emission, slow breath.
			return {
				"base_color": Color(0.020, 0.030, 0.055),    # deep obsidian-blue
				"glow_color": Color(0.075, 0.12, 0.28),       # faint deep-blue glow
				"energy": 0.18,
			}
		Mood.AWARE:
			# Indigo / neural cyan — the Iris has noticed the player.
			return {
				"base_color": Color(0.030, 0.065, 0.105),     # indigo bed
				"glow_color": Color(0.20, 0.62, 0.78),        # neural cyan glow
				"energy": 0.55,
			}
		Mood.FOCUSED:
			# Electric gold / amber — analyzing a target. High emission.
			return {
				"base_color": Color(0.075, 0.045, 0.020),     # warm dark amber bed
				"glow_color": Color(0.98, 0.74, 0.22),        # electric gold
				"energy": 0.92,
			}
		Mood.SUCCESS:
			# Warm radiant white/gold — a truth witnessed. Flares, then settles.
			return {
				"base_color": Color(0.12, 0.10, 0.07),        # warm pale bed
				"glow_color": Color(1.0, 0.92, 0.74),         # radiant warm white-gold
				"energy": 1.35,
			}
	return {}

func _ready() -> void:
	random.randomize()
	organic_seed = random.randf_range(0.0, TAU)
	blink_in = random.randf_range(4.8, 9.6)
	pulse_in = random.randf_range(5.5, 11.0)
	simulated_attention_in = random.randf_range(1.4, 3.6)
	# Initialize mood colors to the dormant profile so the first frame is not black.
	_apply_mood_profile(Mood.DORMANT, true)

func transition_to(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_time = 0.0
	saccade_in = random.randf_range(0.06, 0.22)
	match state:
		State.CALIBRATING, State.STIRRING, State.ATTENDING, State.FOCUSED, State.OBSERVING:
			blink_elapsed = -1.0
			blink_amount = 0.0
			simulated_focus_amount = 0.0
		State.AWAKENING:
			# A single early closure makes the first emergence feel ocular, not loaded.
			blink_in = 0.92
		State.WELCOMING:
			# Recognition lands with a restrained second blink before the idle cadence resumes.
			blink_in = minf(blink_in, 0.68)
		State.AWARE:
			blink_in = maxf(blink_in, 1.8)
	# Auto-map the new state to a mood, unless the mood is currently forced
	# (e.g. mid-SUCCESS flare). This keeps color identity following presence.
	_auto_set_mood_for_state(state)
	state_changed.emit(state)

## Change the Iris mood with a smooth "neural bleed" (1.8s lerp).
## Pass `forced := true` to lock the mood (State changes won't override it) —
## used for the SUCCESS flare. Pass `forced := false` to release the lock.
func change_mood(new_mood: Mood, forced := false) -> void:
	if new_mood == mood and not forced:
		return
	_mood_forced = forced
	# Set the destination profile; the per-tick bleed moves the live values toward it.
	var profile := mood_profile(new_mood)
	_mood_target_base = profile["base_color"]
	_mood_target_glow = profile["glow_color"]
	_mood_target_energy = float(profile["energy"])
	_mood_target_secondary = mood_secondary_color
	_mood_target_secondary_weight = mood_secondary_weight
	# Bleed rate tuned so the transition completes in ~_MOOD_BLEED_DURATION.
	_mood_bleed_speed = 4.5 / _MOOD_BLEED_DURATION
	# Haptic sync: an increase in energy intensity gets a stronger pulse (protocol §4).
	var prev_energy := mood_energy
	mood = new_mood
	mood_changed.emit(new_mood)
	var energy_delta := float(profile["energy"]) - prev_energy
	if energy_delta > 0.2:
		IrisHapticConsumer.trigger_pattern(
			IrisHapticConsumer.Pattern.LIGHT if energy_delta < 0.5 else IrisHapticConsumer.Pattern.MEDIUM,
			"Mood energy rise -> %s" % Mood.keys()[int(new_mood)]
		)

## Release a forced mood lock so State can drive the mood again.
func release_mood() -> void:
	_mood_forced = false
	_auto_set_mood_for_state(state)

## Apply a full profile instantly (snap). Used for initialization and tests.
func _apply_mood_profile(m: Mood, snap := false) -> void:
	var profile := mood_profile(m)
	_mood_target_base = profile["base_color"]
	_mood_target_glow = profile["glow_color"]
	_mood_target_energy = float(profile["energy"])
	if snap:
		mood = m
		mood_base_color = _mood_target_base
		mood_glow_color = _mood_target_glow
		mood_energy = _mood_target_energy

## Default State -> Mood mapping (the mood "follows" presence unless forced).
func _auto_set_mood_for_state(s: State) -> void:
	if _mood_forced:
		return
	var mapped: Mood = Mood.DORMANT
	match s:
		State.DORMANT, State.CALIBRATING:
			mapped = Mood.DORMANT
		State.STIRRING, State.AWAKENING, State.WELCOMING, State.AWARE, State.SETTLED, State.REFLECTIVE:
			mapped = Mood.AWARE
		State.ATTENDING, State.FOCUSED, State.OBSERVING:
			mapped = Mood.FOCUSED
	change_mood(mapped, false)

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
	_update_simulated_attention(delta, float(profile["saccade"]))
	_update_mood_bleed(delta)

	var primary_breath := sin(life_time * float(profile["breath_primary"]) * TAU + organic_seed) * 0.5 + 0.5
	var secondary_breath := sin(life_time * float(profile["breath_secondary"]) * TAU + organic_seed * 2.17) * 0.5 + 0.5
	var breath_wave := clampf(0.5 + (primary_breath - 0.5) * 0.72 + (secondary_breath - 0.5) * 0.28, 0.0, 1.0)
	var pupil_target := float(profile["pupil"]) + (breath_wave - 0.5) * float(profile["pupil_breath"])
	var transition_speed := float(profile["transition_speed"])
	pupil = lerpf(pupil, pupil_target, minf(1.0, delta * float(profile["pupil_response"])))
	glow = lerpf(glow, float(profile["glow"]), minf(1.0, delta * 2.35))
	presence = lerpf(presence, float(profile["presence"]), minf(1.0, delta * transition_speed))
	fiber_motion = lerpf(fiber_motion, float(profile["fiber_motion"]), minf(1.0, delta * transition_speed))
	fiber_density = lerpf(fiber_density, float(profile["fiber_density"]), minf(1.0, delta * transition_speed * 1.4))
	var authored_focus := clampf(float(profile["focus"]) + simulated_focus_amount, 0.0, 1.0)
	focus_amount = lerpf(focus_amount, authored_focus, minf(1.0, delta * transition_speed * 1.35))
	reflective_amount = lerpf(reflective_amount, float(profile["reflective"]), minf(1.0, delta * transition_speed * 0.85))
	calibration_amount = lerpf(calibration_amount, float(profile["calibration"]), minf(1.0, delta * transition_speed * 1.8))

	var energy_drift := sin(life_time * 0.093 + organic_seed) * 0.5 + 0.5
	energy_drift = clampf(energy_drift * 0.65 + (sin(life_time * 0.027 + organic_seed * 1.6) * 0.5 + 0.5) * 0.35, 0.0, 1.0)
	return {
		"breath_primary": float(profile["breath_primary"]),
		"breath_secondary": float(profile["breath_secondary"]),
		"breath_wave": breath_wave,
		"glow": glow,
		"pupil": pupil,
		"gaze": gaze,
		"fiber_motion": fiber_motion,
		"fiber_density": roundi(fiber_density),
		"focus": focus_amount,
		"reflective": reflective_amount,
		"presence": presence,
		"calibration": calibration_amount,
		"blink": blink_amount,
		"pulse": pulse_amount,
		"drift": energy_drift,
		"asymmetry": organic_seed,
		"mood": int(mood),
		"mood_base_color": mood_base_color,
		"mood_glow_color": mood_glow_color,
		"mood_energy": mood_energy,
		"mood_secondary_color": mood_secondary_color,
		"mood_secondary_weight": mood_secondary_weight
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

func _update_simulated_attention(delta: float, amplitude: float) -> void:
	simulated_focus_amount = move_toward(simulated_focus_amount, 0.0, delta * 0.55)
	if not (state in [State.WELCOMING, State.AWARE, State.SETTLED, State.REFLECTIVE]):
		return
	simulated_attention_in -= delta
	if simulated_attention_in > 0.0:
		return
	# Authored, low-amplitude attention changes: not camera/eye tracking, just a living scan.
	var direction := Vector2(random.randf_range(-1.0, 1.0), random.randf_range(-0.58, 0.58))
	if direction.length_squared() < 0.01:
		direction = Vector2.LEFT
	gaze_target = direction.normalized() * random.randf_range(amplitude * 0.34, amplitude * 1.18)
	saccade_in = random.randf_range(0.04, 0.16)
	simulated_focus_amount = random.randf_range(0.045, 0.16)
	simulated_attention_in = random.randf_range(2.2, 6.4)

## Per-tick neural bleed: lerp the live mood values toward the target profile.
## Called every tick so colors NEVER snap (protocol §3).
func _update_mood_bleed(delta: float) -> void:
	var rate := minf(1.0, delta * _mood_bleed_speed)
	mood_base_color = mood_base_color.lerp(_mood_target_base, rate)
	mood_glow_color = mood_glow_color.lerp(_mood_target_glow, rate)
	mood_energy = lerpf(mood_energy, _mood_target_energy, rate)
	mood_secondary_color = mood_secondary_color.lerp(_mood_target_secondary, rate)
	mood_secondary_weight = lerpf(mood_secondary_weight, _mood_target_secondary_weight, rate)
	# Settle the bleed rate back toward the idle drift speed so post-transition
	# values keep breathing subtly instead of locking the moment the bleed ends.
	_mood_bleed_speed = lerpf(_mood_bleed_speed, 0.6, minf(1.0, delta * 0.7))

func _profile() -> Dictionary:
	var profile := _base_profile()
	match state:
		State.DORMANT:
			profile.merge({"presence": 0.0, "glow": 0.0, "pupil": 0.42, "fiber_motion": 0.0, "fiber_density": 0, "pulse_enabled": false, "blink_enabled": false, "transition_speed": 1.6}, true)
		State.CALIBRATING:
			var calibration_rise := _ease_out(clampf(state_time / 0.62, 0.0, 1.0))
			profile.merge({"presence": 0.08 + calibration_rise * 0.13, "glow": 0.10 + calibration_rise * 0.10, "pupil": 0.40, "fiber_motion": 0.14, "fiber_density": 22, "calibration": 0.8, "blink_enabled": false, "transition_speed": 2.2}, true)
		State.STIRRING:
			var stirring_rise := _ease_out(clampf(state_time / 1.05, 0.0, 1.0))
			profile.merge({"presence": 0.22 + stirring_rise * 0.25, "glow": 0.16 + stirring_rise * 0.17, "pupil": 0.38 - stirring_rise * 0.04, "fiber_motion": 0.25 + stirring_rise * 0.18, "fiber_density": 32, "calibration": 0.18, "blink_enabled": false, "transition_speed": 2.2}, true)
		State.AWAKENING:
			var opening := _ease_out(clampf(state_time / 1.72, 0.0, 1.0))
			profile.merge({"presence": 0.50 + opening * 0.42, "glow": 0.34 + opening * 0.48, "pupil": 0.35 - opening * 0.08, "pupil_breath": 0.020, "pupil_response": 5.2, "fiber_motion": 0.40 + opening * 0.45, "fiber_density": 46, "focus": opening * 0.42, "calibration": 0.0, "blink_enabled": true, "transition_speed": 2.3}, true)
		State.WELCOMING:
			profile.merge({"presence": 1.0, "glow": 0.76, "pupil": 0.268, "fiber_motion": 0.74, "fiber_density": 54, "focus": 0.34, "saccade": 0.024, "blink_enabled": true, "transition_speed": 2.9}, true)
		State.AWARE:
			profile.merge({"presence": 1.0, "glow": 0.60, "pupil": 0.286, "fiber_motion": 0.55, "fiber_density": 48, "focus": 0.16, "saccade": 0.026}, true)
		State.ATTENDING:
			profile.merge({"presence": 1.0, "glow": 0.80, "pupil": 0.245, "pupil_response": 9.0, "fiber_motion": 0.78, "fiber_density": 54, "focus": 0.72, "blink_enabled": false, "transition_speed": 5.2}, true)
		State.FOCUSED:
			profile.merge({"presence": 1.0, "glow": 0.98, "pupil": 0.205, "pupil_response": 8.0, "fiber_motion": 0.90, "fiber_density": 56, "focus": 1.0, "blink_enabled": false, "transition_speed": 5.2}, true)
		State.OBSERVING:
			profile.merge({"presence": 1.0, "glow": 0.80, "pupil": 0.226, "pupil_breath": 0.008, "pupil_response": 6.4, "fiber_motion": 0.74, "fiber_density": 52, "focus": 0.82, "blink_enabled": false, "transition_speed": 3.8}, true)
		State.SETTLED:
			profile.merge({"presence": 1.0, "glow": 0.40, "pupil": 0.307, "fiber_motion": 0.38, "fiber_density": 40, "focus": 0.06, "reflective": 0.24, "saccade": 0.022, "blink_enabled": true, "transition_speed": 1.8}, true)
		State.REFLECTIVE:
			profile.merge({"presence": 1.0, "glow": 0.50, "pupil": 0.314, "fiber_motion": 0.32, "fiber_density": 42, "reflective": 1.0, "saccade": 0.020, "pulse_enabled": true, "blink_enabled": true, "transition_speed": 1.7}, true)
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
		"transition_speed": 2.6,
		"blink_enabled": true,
		"pulse_enabled": true
	}

func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)
