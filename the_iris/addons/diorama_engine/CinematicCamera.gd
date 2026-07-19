extends Camera3D
class_name CinematicCamera

## CinematicCamera — authored camera behavior for Diorama experiences.
##
## Provides:
##   1. Iris transition (circular pupil dilation/contraction).
##   2. Keyframe-based camera paths (orbit, pan, dolly, static).
##   3. 35mm-equivalent focal length with depth of field.
##   4. Smooth ease-in/ease-out interpolation.
##   5. Subtle idle drift (breathing) when no path is active.

signal path_started(path_id: String)
signal path_finished(path_id: String)
signal iris_transition_complete

# --- Configuration (set by DioramaPlayer from camera_def) ---

var base_fov: float = 45.0               # ~35mm equivalent in portrait
var dof_enabled: bool = true
var dof_distance: float = 5.0            # focus distance (meters)
var dof_blur_amount: float = 0.8         # far blur intensity
var idle_drift_enabled: bool = true
var idle_drift_amplitude: Vector3 = Vector3(0.015, 0.008, 0.01)
var idle_drift_speed: float = 0.35

# --- Path animation state ---

var path_keyframes: Array = []            # [{time, position, look_at, fov}]
var path_duration: float = 15.0
var path_loop: bool = true
var path_elapsed: float = 0.0
var path_active: bool = false
var path_id: String = ""

# --- Iris transition state ---

enum IrisState { READY, OPENING, OPEN, CLOSING }
var iris_state: IrisState = IrisState.READY
var iris_progress: float = 0.0           # 0.0 = closed, 1.0 = open
var iris_target: float = 0.0
var iris_speed: float = 1.8              # seconds for full open/close
var _iris_callback: Callable = Callable()

# --- Internal ---

var _idle_elapsed: float = 0.0
var _base_position: Vector3 = Vector3.ZERO
var _base_look_at: Vector3 = Vector3(0.0, 1.5, 0.0)

func _ready() -> void:
	fov = base_fov
	_base_position = global_position

	# Set up depth of field via CameraAttributesPractical
	if dof_enabled:
		var attrs := CameraAttributesPractical.new()
		attrs.dof_blur_far_enabled = true
		attrs.dof_blur_far_distance = dof_distance
		attrs.dof_blur_far_transition = 2.0
		attrs.dof_blur_near_enabled = false
		attrs.dof_blur_near_distance = 0.5
		attributes = attrs

# ---------------------------------------------------------------------------
# Public API — configure from JSON camera_def
# ---------------------------------------------------------------------------

func configure_from_def(cam_def: Dictionary) -> void:
	base_fov = float(cam_def.get("fov", 45.0))
	fov = base_fov

	# Focal length override (converts mm to FOV for portrait viewport)
	if cam_def.has("focal_length_mm"):
		var fl := float(cam_def["focal_length_mm"])
		# Portrait viewport (540x960): sensor height ~24mm equivalent
		base_fov = rad_to_deg(2.0 * atan(12.0 / fl))
		fov = base_fov

	# Depth of field
	var dof_def: Dictionary = cam_def.get("dof", {})
	if dof_def.size() > 0:
		dof_enabled = bool(dof_def.get("enabled", true))
		dof_distance = float(dof_def.get("distance", 5.0))
		dof_blur_amount = float(dof_def.get("blur_amount", 0.8))
		if dof_enabled:
			var attrs := CameraAttributesPractical.new()
			attrs.dof_blur_far_enabled = true
			attrs.dof_blur_far_distance = dof_distance
			attrs.dof_blur_far_transition = float(dof_def.get("far_transition", 2.0))
			attrs.dof_blur_near_enabled = bool(dof_def.get("near_enabled", false))
			attrs.dof_blur_near_distance = float(dof_def.get("near_distance", 0.5))
			attributes = attrs

	# Initial position
	if cam_def.has("position"):
		var pos := _vec3(cam_def["position"])
		global_position = pos
		_base_position = pos

	if cam_def.has("look_at"):
		_base_look_at = _vec3(cam_def["look_at"])
		look_at(_base_look_at)

	# Camera path
	var path_def: Dictionary = cam_def.get("path", {})
	if path_def.size() > 0:
		path_duration = float(path_def.get("duration", cam_def.get("duration", 15.0)))
		path_loop = bool(path_def.get("loop", true))
		path_id = String(path_def.get("id", "default"))

		# Predefined path types
		var path_type := String(path_def.get("type", "keyframes"))
		match path_type:
			"orbit_slow":
				_build_orbit_path(path_def)
			"pan":
				_build_pan_path(path_def)
			"dolly":
				_build_dolly_path(path_def)
			"keyframes":
				path_keyframes = path_def.get("keyframes", [])

	# Idle drift
	idle_drift_enabled = bool(cam_def.get("idle_drift", true))

# ---------------------------------------------------------------------------
# Path builders — generate keyframes from simple path definitions
# ---------------------------------------------------------------------------

func _build_orbit_path(def: Dictionary) -> void:
	var center := _vec3(def.get("center", [0.0, 1.5, 0.0]))
	var radius: float = float(def.get("radius", 5.0))
	var height: float = float(def.get("height", 1.6))
	var start_angle: float = float(def.get("start_angle_deg", -15.0))
	var end_angle: float = float(def.get("end_angle_deg", 15.0))
	var steps: int = int(def.get("steps", 8))
	var focus := _vec3(def.get("look_at", [0.0, 1.5, -1.0]))

	path_keyframes.clear()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var angle := deg_to_rad(lerpf(start_angle, end_angle, t))
		var pos := Vector3(
			center.x + radius * sin(angle),
			height,
			center.z + radius * cos(angle)
		)
		path_keyframes.append({
			"time": t * path_duration,
			"position": [pos.x, pos.y, pos.z],
			"look_at": [focus.x, focus.y, focus.z],
			"fov": base_fov
		})

func _build_pan_path(def: Dictionary) -> void:
	var start := _vec3(def.get("start", [-2.0, 1.6, 5.0]))
	var end := _vec3(def.get("end", [2.0, 1.6, 5.0]))
	var focus := _vec3(def.get("look_at", [0.0, 1.5, 0.0]))
	var steps: int = int(def.get("steps", 6))

	path_keyframes.clear()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var pos := start.lerp(end, t)
		path_keyframes.append({
			"time": t * path_duration,
			"position": [pos.x, pos.y, pos.z],
			"look_at": [focus.x, focus.y, focus.z],
			"fov": base_fov
		})

func _build_dolly_path(def: Dictionary) -> void:
	var start := _vec3(def.get("start", [0.0, 1.6, 8.0]))
	var end := _vec3(def.get("end", [0.0, 1.6, 3.5]))
	var focus := _vec3(def.get("look_at", [0.0, 1.5, 0.0]))
	var steps: int = int(def.get("steps", 6))

	path_keyframes.clear()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var pos := start.lerp(end, t)
		path_keyframes.append({
			"time": t * path_duration,
			"position": [pos.x, pos.y, pos.z],
			"look_at": [focus.x, focus.y, focus.z],
			"fov": base_fov
		})

# ---------------------------------------------------------------------------
# Path playback
# ---------------------------------------------------------------------------

func start_path(id_override: String = "") -> void:
	if path_keyframes.size() < 2:
		return
	path_elapsed = 0.0
	path_active = true
	if id_override != "":
		path_id = id_override
	path_started.emit(path_id)

func stop_path() -> void:
	path_active = false

func _process(delta: float) -> void:
	# Camera path animation
	if path_active and path_keyframes.size() >= 2:
		path_elapsed += delta
		var t := path_elapsed
		if path_loop:
			t = fmod(t, path_duration)
		elif t >= path_duration:
			t = path_duration
			path_active = false
			path_finished.emit(path_id)
		_apply_path_at_time(t)

	# Idle drift (subtle breathing)
	elif idle_drift_enabled:
		_idle_elapsed += delta
		_apply_idle_drift(delta)

	# Iris transition
	if iris_state != IrisState.READY:
		_update_iris(delta)

# ---------------------------------------------------------------------------
# Path interpolation
# ---------------------------------------------------------------------------

func _apply_path_at_time(t: float) -> void:
	if path_keyframes.size() < 2:
		return

	# Find the two keyframes surrounding t
	var kf_a: Dictionary = path_keyframes[0]
	var kf_b: Dictionary = path_keyframes[path_keyframes.size() - 1]

	for i in range(path_keyframes.size() - 1):
		var ka: Dictionary = path_keyframes[i]
		var kb: Dictionary = path_keyframes[i + 1]
		if t >= float(ka["time"]) and t <= float(kb["time"]):
			kf_a = ka
			kf_b = kb
			break

	var segment_dur := float(kf_b["time"]) - float(kf_a["time"])
	var local_t := 0.0
	if segment_dur > 0.0:
		local_t = (t - float(kf_a["time"])) / segment_dur

	# Smooth ease-in/ease-out
	var smooth_t := _smoothstep(local_t)

	var pos_a := _vec3(kf_a["position"])
	var pos_b := _vec3(kf_b["position"])
	var look_a := _vec3(kf_a["look_at"])
	var look_b := _vec3(kf_b["look_at"])
	var fov_a := float(kf_a.get("fov", base_fov))
	var fov_b := float(kf_b.get("fov", base_fov))

	global_position = pos_a.lerp(pos_b, smooth_t)
	var look_target := look_a.lerp(look_b, smooth_t)
	look_at(look_target)
	fov = lerpf(fov_a, fov_b, smooth_t)

# ---------------------------------------------------------------------------
# Idle drift (subtle cinematic breathing)
# ---------------------------------------------------------------------------

func _apply_idle_drift(_delta: float) -> void:
	var dx := sin(_idle_elapsed * idle_drift_speed) * idle_drift_amplitude.x
	var dy := sin(_idle_elapsed * idle_drift_speed * 0.7 + 1.2) * idle_drift_amplitude.y
	var dz := cos(_idle_elapsed * idle_drift_speed * 0.5 + 2.4) * idle_drift_amplitude.z
	global_position = _base_position + Vector3(dx, dy, dz)
	look_at(_base_look_at)

# ---------------------------------------------------------------------------
# Iris transition (circular pupil dilation)
# ---------------------------------------------------------------------------

func open_iris(duration: float = -1.0, callback: Callable = Callable()) -> void:
	if duration > 0.0:
		iris_speed = duration
	iris_target = 1.0
	iris_state = IrisState.OPENING
	_iris_callback = callback

func close_iris(duration: float = -1.0, callback: Callable = Callable()) -> void:
	if duration > 0.0:
		iris_speed = duration
	iris_target = 0.0
	iris_state = IrisState.CLOSING
	_iris_callback = callback

func _update_iris(delta: float) -> void:
	var rate := delta / maxf(iris_speed, 0.01)
	if iris_state == IrisState.OPENING:
		iris_progress = move_toward(iris_progress, 1.0, rate)
		if iris_progress >= 1.0:
			iris_state = IrisState.OPEN
			iris_transition_complete.emit()
			if _iris_callback.is_valid():
				_iris_callback.call()
				_iris_callback = Callable()
	elif iris_state == IrisState.CLOSING:
		iris_progress = move_toward(iris_progress, 0.0, rate)
		if iris_progress <= 0.0:
			iris_state = IrisState.READY
			iris_transition_complete.emit()
			if _iris_callback.is_valid():
				_iris_callback.call()
				_iris_callback = Callable()

# For external rendering of the iris circle mask (DioramaPlayer draws this)
func get_iris_progress() -> float:
	return iris_progress

func get_iris_radius(viewport_size: Vector2) -> float:
	var max_radius := viewport_size.length() * 0.5
	return iris_progress * max_radius * 1.2  # overshoot to fully clear

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _smoothstep(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _vec3(arr: Variant) -> Vector3:
	if arr is Array and arr.size() >= 3:
		return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))
	return Vector3.ZERO
