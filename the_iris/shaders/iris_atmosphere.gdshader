shader_type canvas_item;
render_mode unshaded;

// =============================================================================
// Iris Atmosphere Shader — energy/breath modulation layer for the Living Iris.
//
// IMPORTANT: this MODULATES the procedural _draw() output toward the mood
// glow/base colors. It does NOT add (additive bloom overflows to white when
// combined with the WorldEnvironment's Glow post-process). The bright neural
// parts of the iris are tinted toward glow_color; dark parts toward base_color.
// Output is always <= max(src, tint), so it can never blow out to white.
//
// Uniforms (driven each frame from IrisCore mood values via LivingIris):
//   base_color        — deep base tint of the artifact (mood-driven)
//   glow_color        — bright emissive tint of neural activity (mood-driven)
//   energy_intensity  — controls how strongly the mood tint is applied (0..2)
//   time              — elapsed time (set from LivingIris.elapsed)
// =============================================================================

uniform vec4 base_color : source_color = vec4(0.02, 0.105, 0.105, 1.0);
uniform vec4 glow_color : source_color = vec4(0.14, 0.70, 0.56, 1.0);
uniform float energy_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float time = 0.0;

void vertex() {
	// Default canvas-item vertex transform.
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);

	// Two slow organic modulators — never let the energy feel mechanical.
	float breath = 0.5 + 0.5 * sin(time * 0.46 * TAU);
	float flicker = 0.5 + 0.5 * sin(time * 1.37 + sin(time * 0.27) * 2.0);

	float lum = max(src.r, max(src.g, src.b));

	// The mood tint the iris is pulled toward: glow_color in bright areas,
	// base_color in dark areas. This is a mix, not an add — no overflow.
	vec3 tint = mix(base_color.rgb, glow_color.rgb, smoothstep(0.05, 0.6, lum));

	// Strength of the tint: how much mood color is applied (0 = pure source,
	// 1 = fully tinted). Scaled by energy and a subtle breath.
	float strength = clamp(energy_intensity * 0.5, 0.0, 1.0) * (0.85 + 0.15 * breath);

	vec3 color = mix(src.rgb, tint, strength);

	// Subtle brightness pulse on the bright (neural) parts — keeps the iris
	// alive without exceeding the source luminance by much. Modulated, not added.
	float neural_pulse = 0.5 + 0.5 * sin(time * (3.0 + energy_intensity * 4.0));
	float neural_mask = smoothstep(0.4, 0.9, lum);
	color *= 1.0 + neural_mask * neural_pulse * 0.04 * energy_intensity;

	// Final clamp as a safety net so combined post-processing can never push us
	// past the intended ceiling.
	color = clamp(color, vec3(0.0), vec3(1.0));

	COLOR = vec4(color, src.a);
}
