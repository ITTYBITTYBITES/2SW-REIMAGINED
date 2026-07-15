shader_type canvas_item;

// The Living Lens Pupil Portal Shader
// Renders the internal memory fragment / destination reflection inside the pupil aperture,
// with 2.5D optical parallax shifting, gravitational edge lensing, and biological breathing.

uniform float time = 0.0;
uniform float aperture = 0.105;
uniform float memory_visibility = 0.0;
uniform vec2 gaze_offset = vec2(0.0, 0.0);
uniform float distortion_intensity = 0.35;
uniform float aspect = 0.5625;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 p = UV - center;
    p.x *= aspect;
    float d = length(p);

    // Dynamic portal radius based on aperture and breathing
    float portal_radius = max(aperture * 1.6, 0.05);

    // Smooth circular portal clipping inside the pupil void
    float mask = 1.0 - smoothstep(portal_radius - 0.015, portal_radius + 0.005, d);
    if (mask <= 0.001) {
        discard;
    }

    // Optical parallax shift and gravitational lensing distortion near the edges
    vec2 uv_offset = gaze_offset * 0.15;
    float edge_warp = pow(clamp(d / portal_radius, 0.0, 1.0), 3.0) * distortion_intensity;
    vec2 warped_uv = UV + uv_offset + normalize(p + vec2(0.0001)) * edge_warp * 0.05;

    // Subtle atmospheric drift inside the memory
    warped_uv += vec2(sin(time * 0.4 + UV.y * 3.0), cos(time * 0.3 + UV.x * 3.0)) * 0.004;

    vec4 tex_color = texture(TEXTURE, clamp(warped_uv, vec2(0.001), vec2(0.999)));

    // Deep void vignetting around the portal rim
    float inner_vignette = smoothstep(0.0, portal_radius * 0.95, d);
    vec3 void_col = vec3(0.002, 0.006, 0.012);
    vec3 final_col = mix(tex_color.rgb, void_col, inner_vignette * 0.65);

    // Ethereal memory highlights and rim refraction
    float rim_glow = smoothstep(portal_radius - 0.025, portal_radius, d) * (1.0 - smoothstep(portal_radius, portal_radius + 0.01, d));
    final_col += vec3(0.35, 0.88, 0.78) * rim_glow * 0.6;

    // Overall visibility modulation
    float alpha = mask * tex_color.a * clamp(memory_visibility, 0.0, 1.0);

    COLOR = vec4(final_col, alpha);
}
