shader_type canvas_item;
render_mode unshaded;

// =============================================================================
// Iris Atmosphere Shader — energy/bloom modulation layer for the Living Iris.
// Applied as a CanvasItem material on LivingIris. The procedural _draw() paints
// the fibers/body/pupil in mood-driven colors; this shader layers a subtle
// energy "breath" (bloom + flicker) driven by the Mood system on top.
//
// Uniforms (driven each frame from IrisCore mood values via LivingIris):
//   base_color        — deep base tint of the artifact (mood-driven)
//   glow_color        — bright emissive tint of neural activity (mood-driven)
//   energy_intensity  — controls bloom strength and flicker speed (mood-driven)
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

	// Energy-driven bloom: lift the bright (neural) parts of the drawn iris
	// toward the glow color. More energy = more bloom.
	float lum = max(src.r, max(src.g, src.b));
	float bloom_mask = smoothstep(0.25, 0.95, lum) * energy_intensity;
	vec3 bloom = glow_color.rgb * bloom_mask * (0.6 + 0.4 * breath);

	// Soft global tint toward base_color in the dark regions (the "vibe" bed).
	float darkness = 1.0 - lum;
	vec3 bed = mix(vec3(0.0), base_color.rgb, darkness) * 0.25 * energy_intensity;

	// Subtle flicker on the mid tones — reads as living neural activity.
	float flicker_pulse = 0.5 + 0.5 * sin(time * (3.0 + energy_intensity * 4.0));
	float mid_mask = smoothstep(0.1, 0.5, lum) * smoothstep(0.9, 0.4, lum);
	vec3 flick = glow_color.rgb * mid_mask * flicker_pulse * 0.08 * energy_intensity;

	vec3 color = src.rgb + bloom + bed + flick;
	COLOR = vec4(color, src.a);
}
