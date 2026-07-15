extends Control
class_name IrisController

@onready var visual: ColorRect = $Visual
@onready var particles: CPUParticles2D = $Particles

var elapsed := 0.0
var target_energy := 0.0
var current_energy := 0.0
var state_mode := 0.0
var pulse := 0.0
var intensity := 1.0
var desktop_mode := false
var orientation_motion := 0.0
var orientation_motion_target := 0.0
var parallax_enabled := true
var sensor_offset_target := Vector2.ZERO
var sensor_offset := Vector2.ZERO
var transition_open := 0.0
var awakening_level := 0.0
var awakening_timer := 0.0

# Living-eye responses.
var neutral_gaze := Vector2(0.5, 0.495)
var gaze_target := neutral_gaze
var gaze_current := neutral_gaze
var gaze_release_at := 0.0
var interaction_active := false
var anticipation_target := Vector2.ZERO
var anticipation_current := Vector2.ZERO
var micro_target := Vector2.ZERO
var micro_current := Vector2.ZERO
var next_saccade_at := 3.2
var blink_amount := 0.0
var blink_target := 0.0
var blink_active := false
var blink_elapsed := 0.0
var next_blink_at := 11.0
var recent_alert_timer := 0.0
var recent_alert := 0.0

# Quiet invitation before first touch.
var invitation_amount := 0.0
var invitation_target := 0.0
var invitation_elapsed := -1.0
var next_invitation_at := 1.8

# Hold becomes a distinct deep-focus/calibration moment.
var deep_focus_level := 0.0
var deep_focus_timer := 0.0

# After a successful Witness return, the Iris teaches its four destinations
# by looking toward them one at a time.
var learning_active := false
var learning_elapsed := 0.0
var learning_focus := Vector2.ZERO
var learning_focus_target := Vector2.ZERO
var learning_amount := 0.0
var learning_amount_target := 0.0

var random := RandomNumberGenerator.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	random.randomize()
	next_saccade_at = random.randf_range(2.2, 4.3)
	next_blink_at = random.randf_range(9.0, 15.0)
	next_invitation_at = random.randf_range(1.4, 2.8)
	var shader_material := visual.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("aspect", get_viewport_rect().size.x / max(get_viewport_rect().size.y, 1.0))
	particles.emitting = true

func _process(delta: float) -> void:
	elapsed += delta * intensity
	_update_gaze(delta)
	_update_micro_saccades(delta)
	_update_blink(delta)
	_update_recent_alert(delta)
	_update_invitation(delta)
	_update_deep_focus(delta)
	_update_learning(delta)
	_update_awakening(delta)
	orientation_motion = lerpf(orientation_motion, orientation_motion_target, minf(1.0, delta * 5.0))
	sensor_offset = sensor_offset.lerp(sensor_offset_target if parallax_enabled else Vector2.ZERO, minf(1.0, delta * 2.8))
	current_energy = lerpf(current_energy, maxf(target_energy * (1.0 - deep_focus_level * 0.50), recent_alert * 0.42), minf(1.0, delta * 3.0))
	pulse = maxf(0.0, pulse - delta * 0.55)
	var viewport_size := get_viewport_rect().size
	particles.position = viewport_size * 0.5
	var shader_material := visual.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("aspect", viewport_size.x / max(viewport_size.y, 1.0))
		shader_material.set_shader_parameter("time", elapsed)
		shader_material.set_shader_parameter("energy", current_energy + pulse)
		shader_material.set_shader_parameter("state_mode", state_mode)
		shader_material.set_shader_parameter("pupil_open", 0.105 if state_mode != 2.0 else 0.078)
		shader_material.set_shader_parameter("transition_open", transition_open)
		shader_material.set_shader_parameter("recent_alert", recent_alert)
		shader_material.set_shader_parameter("blink_amount", blink_amount)
		shader_material.set_shader_parameter("gaze_target", gaze_current)
		shader_material.set_shader_parameter("micro_offset", micro_current)
		shader_material.set_shader_parameter("anticipation", anticipation_current)
		shader_material.set_shader_parameter("invitation", invitation_amount)
		shader_material.set_shader_parameter("deep_focus", deep_focus_level)
		shader_material.set_shader_parameter("learning_focus", learning_focus)
		shader_material.set_shader_parameter("learning_amount", learning_amount)
		shader_material.set_shader_parameter("awakening", awakening_level)
		shader_material.set_shader_parameter("breath_rate", lerpf(1.15, 0.58, awakening_level))
		shader_material.set_shader_parameter("orientation_motion", orientation_motion)
		shader_material.set_shader_parameter("sensor_offset", sensor_offset)
	particles.amount = 18 if intensity > 0.25 else 8
	particles.speed_scale = 0.5 + intensity * 0.5

func _update_gaze(delta: float) -> void:
	if not interaction_active and elapsed >= gaze_release_at:
		gaze_target = neutral_gaze
	gaze_current = gaze_current.lerp(gaze_target, minf(1.0, delta * 3.6))
	anticipation_current = anticipation_current.lerp(anticipation_target, minf(1.0, delta * 5.0))

func _update_micro_saccades(delta: float) -> void:
	if interaction_active:
		micro_target = Vector2.ZERO
	elif elapsed >= next_saccade_at:
		micro_target = Vector2(random.randf_range(-0.010, 0.010), random.randf_range(-0.007, 0.007))
		next_saccade_at = elapsed + random.randf_range(2.8, 5.5)
	micro_current = micro_current.lerp(micro_target, minf(1.0, delta * 4.5))
	if not interaction_active and micro_current.length() < 0.0015:
		micro_target = Vector2.ZERO

func _update_blink(delta: float) -> void:
	if interaction_active or deep_focus_timer > 0.0:
		blink_active = false
		blink_elapsed = 0.0
		blink_target = 0.0
	else:
		if not blink_active and elapsed >= next_blink_at:
			blink_active = true
			blink_elapsed = 0.0
		if blink_active:
			blink_elapsed += delta
			if blink_elapsed < 0.12:
				blink_target = 0.72 * (blink_elapsed / 0.12)
			elif blink_elapsed < 0.22:
				blink_target = 0.72
			elif blink_elapsed < 0.46:
				blink_target = 0.72 * (1.0 - (blink_elapsed - 0.22) / 0.24)
			else:
				blink_active = false
				blink_target = 0.0
				next_blink_at = elapsed + random.randf_range(10.0, 18.0)
	blink_amount = lerpf(blink_amount, blink_target, minf(1.0, delta * 18.0))

func _update_recent_alert(delta: float) -> void:
	if recent_alert_timer > 0.0:
		recent_alert_timer -= delta
	var alert_target := clampf(recent_alert_timer / 4.5, 0.0, 1.0)
	recent_alert = lerpf(recent_alert, alert_target, minf(1.0, delta * 2.4))
	if recent_alert_timer <= 0.0:
		var resting_energy := 0.35 if state_mode == 1.0 else (0.18 if state_mode == 3.0 else 0.05)
		target_energy = lerpf(target_energy, resting_energy, minf(1.0, delta * 0.9))

func _update_invitation(delta: float) -> void:
	if interaction_active or deep_focus_timer > 0.0 or learning_active:
		invitation_target = 0.0
	else:
		if invitation_elapsed < 0.0 and elapsed >= next_invitation_at:
			invitation_elapsed = 0.0
		if invitation_elapsed >= 0.0:
			invitation_elapsed += delta
			if invitation_elapsed < 1.25:
				invitation_target = sin((invitation_elapsed / 1.25) * PI) * 0.72
			else:
				invitation_target = 0.0
				invitation_elapsed = -1.0
				next_invitation_at = elapsed + random.randf_range(3.5, 6.5)
	invitation_amount = lerpf(invitation_amount, invitation_target, minf(1.0, delta * 4.0))

func _update_deep_focus(delta: float) -> void:
	if deep_focus_timer > 0.0:
		deep_focus_timer -= delta
	var focus_target := 1.0 if deep_focus_timer > 0.0 else 0.0
	deep_focus_level = lerpf(deep_focus_level, focus_target, minf(1.0, delta * 3.4))

func _update_learning(delta: float) -> void:
	if learning_active:
		learning_elapsed += delta
		if learning_elapsed >= 3.4:
			learning_active = false
			learning_amount_target = 0.0
			learning_focus_target = Vector2.ZERO
		else:
			var segment := mini(3, int(learning_elapsed / 0.85))
			var directions := [Vector2(-1.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(0.0, -1.0)]
			learning_focus_target = directions[segment]
			var segment_time := fmod(learning_elapsed, 0.85) / 0.85
			learning_amount_target = sin(segment_time * PI) * 0.95
	learning_focus = learning_focus.lerp(learning_focus_target, minf(1.0, delta * 7.0))
	learning_amount = lerpf(learning_amount, learning_amount_target, minf(1.0, delta * 7.0))

func _update_awakening(delta: float) -> void:
	if awakening_timer > 0.0:
		awakening_timer -= delta
	var target := 1.0 if awakening_timer > 0.0 else 0.0
	awakening_level = lerpf(awakening_level, target, minf(1.0, delta * 2.8))

func start_awakening() -> void:
	awakening_timer = 3.2
	invitation_target = 0.0
	pulse = 0.35

func set_living_state(state: int) -> void:
	state_mode = float(state)
	target_energy = 0.35 if state == 1 else (0.18 if state == 3 else 0.05)
	if state == 2:
		target_energy = 0.62
		pulse = 0.85
	particles.color = Color("#bfede0") if state != 3 else Color("#d4b77b")

func set_gaze_target(screen_position: Vector2, viewport_size: Vector2) -> void:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	gaze_target = Vector2(
		clampf(screen_position.x / viewport_size.x, 0.20, 0.80),
		clampf(screen_position.y / viewport_size.y, 0.20, 0.80)
	)
	gaze_release_at = elapsed + 2.6

func set_interaction(active: bool) -> void:
	interaction_active = active
	if active:
		blink_active = false
		blink_target = 0.0
		learning_active = false
		learning_amount_target = 0.0
	else:
		gaze_release_at = elapsed + 2.6
		anticipation_target = Vector2.ZERO

func update_directional_anticipation(delta: Vector2, viewport_size: Vector2) -> void:
	if not interaction_active:
		return
	var normalized := Vector2(delta.x / maxf(viewport_size.x, 1.0), delta.y / maxf(viewport_size.y, 1.0))
	if normalized.length() < 0.012:
		anticipation_target = Vector2.ZERO
		return
	if absf(normalized.x) > absf(normalized.y):
		anticipation_target = Vector2(sign(normalized.x), 0.0)
	else:
		anticipation_target = Vector2(0.0, sign(normalized.y))

func start_deep_focus() -> void:
	deep_focus_timer = 1.75
	invitation_target = 0.0
	pulse = 0.08
	Input.vibrate_handheld(12, 0.08)

func remember_recent_activity() -> void:
	recent_alert_timer = 5.5
	recent_alert = maxf(recent_alert, 0.65)
	target_energy = maxf(target_energy, 0.42)
	learning_active = true
	learning_elapsed = 0.0
	learning_focus_target = Vector2.ZERO
	learning_amount_target = 0.0

func set_transition_open(value: float) -> void:
	transition_open = clampf(value, 0.0, 1.0)

func focus_pulse() -> void:
	pulse = 1.0
	target_energy = 0.72

func set_desktop_mode(value: bool) -> void:
	desktop_mode = value

func set_orientation_motion(progress: float) -> void:
	orientation_motion_target = clampf(progress, 0.0, 1.0)

func set_parallax_enabled(value: bool) -> void:
	parallax_enabled = value
	if not value:
		sensor_offset_target = Vector2.ZERO

func set_sensor_offset(acceleration: Vector3) -> void:
	if not parallax_enabled:
		sensor_offset_target = Vector2.ZERO
		return
	# Small, damped movement: the lens acknowledges posture without becoming
	# a motion-controlled interface.
	sensor_offset_target = Vector2(
		clampf(-acceleration.x / 90.0, -0.012, 0.012),
		clampf(acceleration.y / 120.0, -0.010, 0.010)
	)

func set_animation_intensity(value: float) -> void:
	intensity = clampf(value, 0.0, 1.0)
