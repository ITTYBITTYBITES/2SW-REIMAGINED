shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_front;

// =============================================================================
// CORNEA GLASS SHADER — the transparent glossy cap over the iris.
// Creates the "wet/glass" look. Has a FIXED specular highlight that doesn't
// move with the iris — creating the parallax "glass bottle" effect.
//
// The specular glint is driven by SCREEN_UV (stays relative to the camera,
// not the mesh), so when the eye looks around the glint stays put.
// =============================================================================

uniform float glass_roughness : hint_range(0.0, 1.0) = 0.05;
uniform float glass_alpha : hint_range(0.0, 1.0) = 0.15;
uniform vec4 tint : source_color = vec4(0.8, 0.95, 1.0, 1.0);
uniform float glint_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float glint_size : hint_range(0.01, 0.2) = 0.05;

void fragment() {
    // Specular glint: positioned relative to SCREEN coordinates, not UV.
    // This creates the parallax effect — the glint stays fixed to the camera
    // while the iris mesh moves beneath it.
    vec2 screen_center = vec2(0.42, 0.38);  // upper-left, like a key light
    float glint_dist = length(SCREEN_UV - screen_center);
    float glint = smoothstep(glint_size, 0.0, glint_dist) * glint_intensity;

    // Subtle glass tint.
    vec3 color = tint.rgb * 0.5 + vec3(glint * 0.8);

    ALBEDO = color;
    ALPHA = glass_alpha + glint * 0.5;
    ROUGHNESS = glass_roughness;
    METALLIC = 0.0;
    EMISSION = vec3(glint * 0.3);  // the glint self-emits slightly
}
