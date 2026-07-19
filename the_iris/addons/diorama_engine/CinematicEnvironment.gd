extends RefCounted
class_name CinematicEnvironment

## CinematicEnvironment — factory for pre-configured WorldEnvironment nodes.
##
## Builds a Godot Environment resource with the "Cinematic Stack":
##   - ACES tonemapping (filmic color reproduction)
##   - Glow (bloom on bright surfaces)
##   - SSAO (screen-space ambient occlusion for depth/weight)
##   - SSR (screen-space reflections on glossy surfaces)
##   - Volumetric fog (atmospheric depth)
##   - Moody dark background with optional gradient
##
## Usage:
##   var env := CinematicEnvironment.create_from_def(env_def)
##   var world_env := WorldEnvironment.new()
##   world_env.environment = env

# ---------------------------------------------------------------------------
# Factory methods
# ---------------------------------------------------------------------------

## Create a fully cinematic environment from a JSON definition.
static func create_from_def(env_def: Dictionary) -> Environment:
	var env := Environment.new()

	# --- Background ---
	var bg_mode := String(env_def.get("background_mode", "color"))
	match bg_mode:
		"sky":
			env.background_mode = Environment.BG_SKY
		"canvas":
			env.background_mode = Environment.BG_CANVAS
		"color":
			env.background_mode = Environment.BG_COLOR
		_:
			env.background_mode = Environment.BG_COLOR

	env.background_color = _color(env_def.get("background_color", [0.008, 0.012, 0.021]))

	# --- Tonemapping: ACES (the "film look") ---
	var tonemap := String(env_def.get("tonemap", "aces"))
	match tonemap:
		"linear":
			env.tonemap_mode = Environment.TONE_MAP_LINEAR
		"reinhard":
			env.tonemap_mode = Environment.TONE_MAP_REINHARD
		"aces":
			env.tonemap_mode = Environment.TONE_MAP_ACES
		"aces_fitted":
			env.tonemap_mode = Environment.TONE_MAP_ACES_FITTED
		_:
			env.tonemap_mode = Environment.TONE_MAP_ACES

	env.tonemap_white = float(env_def.get("tonemap_white", 6.0))
	env.tonemap_exposure = float(env_def.get("tonemap_exposure", 1.0))

	# --- Ambient Light ---
	var ambient_source := String(env_def.get("ambient_source", "color"))
	match ambient_source:
		"sky":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		"disabled":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
		"color":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		_:
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR

	env.ambient_light_color = _color(env_def.get("ambient_color", [0.15, 0.18, 0.25]))
	env.ambient_light_energy = float(env_def.get("ambient_energy", 0.6))

	# --- SSAO (screen-space ambient occlusion) ---
	var ssao_def: Dictionary = env_def.get("ssao", {})
	env.ssao_enabled = bool(ssao_def.get("enabled", true))
	env.ssao_radius = float(ssao_def.get("radius", 1.0))
	env.ssao_intensity = float(ssao_def.get("intensity", 2.0))
	env.ssao_power = float(ssao_def.get("power", 1.5))
	env.ssao_detail = float(ssao_def.get("detail", 0.5))
	env.ssao_light_affect = float(ssao_def.get("light_affect", 0.0))

	# --- SSR (screen-space reflections) ---
	var ssr_def: Dictionary = env_def.get("ssr", {})
	env.ssr_enabled = bool(ssr_def.get("enabled", true))
	env.ssr_max_steps = int(ssr_def.get("max_steps", 64))
	env.ssr_fade_in = float(ssr_def.get("fade_in", 0.15))
	env.ssr_fade_out = float(ssr_def.get("fade_out", 2.0))
	env.ssr_depth_tolerance = float(ssr_def.get("depth_tolerance", 0.2))

	# --- Glow (bloom) ---
	var glow_def: Dictionary = env_def.get("glow", {})
	env.glow_enabled = bool(glow_def.get("enabled", true))
	env.glow_intensity = float(glow_def.get("intensity", 0.8))
	env.glow_bloom = float(glow_def.get("bloom", 0.1))
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.glow_hdr_threshold = float(glow_def.get("hdr_threshold", 0.8))
	env.glow_hdr_scale = float(glow_def.get("hdr_scale", 2.0))

	# --- Fog ---
	var fog_def: Dictionary = env_def.get("fog", {})
	env.fog_enabled = bool(fog_def.get("enabled", false))
	if env.fog_enabled:
		env.fog_light_color = _color(fog_def.get("color", [0.04, 0.06, 0.1]))
		env.fog_light_energy = float(fog_def.get("energy", 0.4))
		env.fog_density = float(fog_def.get("density", 0.015))
		env.fog_sky_affect = float(fog_def.get("sky_affect", 0.5))

	# --- Volumetric Fog (if requested, overrides basic fog) ---
	var vfog_def: Dictionary = env_def.get("volumetric_fog", {})
	env.volumetric_fog_enabled = bool(vfog_def.get("enabled", false))
	if env.volumetric_fog_enabled:
		env.volumetric_fog_density = float(vfog_def.get("density", 0.03))
		env.volumetric_fog_albedo = _color(vfog_def.get("albedo", [0.8, 0.85, 0.9]))
		env.volumetric_fog_emission = _color(vfog_def.get("emission", [0.0, 0.0, 0.0]))
		env.volumetric_fog_gi_inject = float(vfog_def.get("gi_inject", 0.5))

	# --- Adjustments (color grading) ---
	env.adjustment_enabled = bool(env_def.get("adjustment_enabled", true))
	env.adjustment_brightness = float(env_def.get("adjustment_brightness", 1.0))
	env.adjustment_contrast = float(env_def.get("adjustment_contrast", 1.1))
	env.adjustment_saturation = float(env_def.get("adjustment_saturation", 0.95))

	return env

## Create the default "dark cinema" environment (no JSON needed).
static func create_default() -> Environment:
	return create_from_def({
		"background_mode": "color",
		"background_color": [0.008, 0.012, 0.021],
		"tonemap": "aces",
		"ambient_color": [0.15, 0.18, 0.25],
		"ambient_energy": 0.6,
		"ssao": {"enabled": true, "radius": 1.0, "intensity": 2.0},
		"ssr": {"enabled": true, "max_steps": 64},
		"glow": {"enabled": true, "intensity": 0.8, "bloom": 0.1},
		"fog": {"enabled": true, "color": [0.04, 0.06, 0.1], "density": 0.015},
	})

## Create the cinematic key light + fill light pair for any scene.
## Returns [KeyLight: DirectionalLight3D, FillLight: DirectionalLight3D]
static func create_key_fill_pair() -> Array:
	# Key light: bright, warm, from above-right
	var key := DirectionalLight3D.new()
	key.name = "CinematicKeyLight"
	key.rotation_degrees = Vector3(-42.0, 26.0, 0.0)
	key.light_energy = 1.35
	key.light_color = Color(1.0, 0.92, 0.78)   # warm amber
	key.shadow_enabled = true

	# Fill light: dimmer, cool blue/purple, from opposite side
	var fill := DirectionalLight3D.new()
	fill.name = "CinematicFillLight"
	fill.rotation_degrees = Vector3(-30.0, -155.0, 0.0)
	fill.light_energy = 0.45
	fill.light_color = Color(0.55, 0.6, 0.85)  # cool blue-purple
	fill.shadow_enabled = false

	return [key, fill]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

static func _color(arr: Variant) -> Color:
	if arr is Array and arr.size() >= 3:
		if arr.size() >= 4:
			return Color(float(arr[0]), float(arr[1]), float(arr[2]), float(arr[3]))
		return Color(float(arr[0]), float(arr[1]), float(arr[2]))
	return Color.WHITE
