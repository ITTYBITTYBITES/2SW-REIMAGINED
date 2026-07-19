shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// =============================================================================
// STROMA FIBERS SHADER — the living muscle of the Iris.
// Renders thousands of organic, noise-driven fibers radiating from the pupil
// on a concave bowl mesh. Driven by mood colors + IrisCore state.
//
// Uniforms (driven each frame from Iris3DHub via IrisCore behavior):
//   stroma_color    — deep base color (mood-driven)
//   glow_color      — emissive fiber color (mood-driven)
//   glow_energy     — fiber brightness / bloom intensity
//   dilation        — pupil radius (0..1 of the iris radius)
//   fiber_density   — number of fiber bands (visual density)
//   fiber_swim      — noise undulation amount (the "swim")
//   depth_intensity — concave shadow strength
//   time            — elapsed time
// =============================================================================

uniform vec4 stroma_color : source_color = vec4(0.02, 0.06, 0.10, 1.0);
uniform vec4 glow_color : source_color = vec4(0.20, 0.62, 0.78, 1.0);
uniform float glow_energy : hint_range(0.0, 3.0) = 0.8;
uniform float dilation : hint_range(0.0, 0.8) = 0.35;
uniform float fiber_density : hint_range(10.0, 80.0) = 40.0;
uniform float fiber_swim : hint_range(0.0, 2.0) = 0.6;
uniform float depth_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float time = 0.0;

// --- Simplex-style noise (hash-based, GPU-friendly) ---
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float b = dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y) * 2.0;
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    // Polar coordinates centered on the iris.
    vec2 uv = UV - 0.5;
    float dist = length(uv) * 2.0;    // 0 = center, 1 = edge
    float angle = atan(uv.y, uv.x);   // -PI..PI

    // Pupil mask: the hole in the stroma (transparent center).
    float pupil_edge = dilation;
    float pupil_mask = smoothstep(pupil_edge, pupil_edge + 0.04, dist);

    // Discard fully outside the iris (alpha = 0 past the limbal ring).
    float iris_mask = smoothstep(1.0, 0.92, dist);

    // --- FIBER PATTERN ---
    // Radial fibers: the angle is quantized into bands, each band gets noise.
    float radial = angle / TAU;  // 0..1 around the circle
    // Multiple fiber layers at different frequencies for organic density.
    float n1 = fbm(vec2(radial * fiber_density, dist * 6.0 + time * fiber_swim));
    float n2 = fbm(vec2(radial * fiber_density * 1.7, dist * 9.0 - time * fiber_swim * 0.6));
    float n3 = fbm(vec2(radial * fiber_density * 2.3, dist * 4.0 + time * fiber_swim * 0.3));

    // Combine: the fiber intensity. Some fibers are bright, others faint.
    float fiber = (n1 * 0.5 + n2 * 0.3 + n3 * 0.2);
    fiber = smoothstep(0.2, 0.8, fiber);

    // Fibers fade toward the pupil edge (collarette effect).
    float collarette = smoothstep(pupil_edge + 0.05, pupil_edge + 0.2, dist);
    fiber *= collarette;

    // --- CONCAVE DEPTH ---
    // Darken toward the pupil (the bowl deepens). This is in addition to the
    // mesh geometry — reinforces the concave read.
    float depth_falloff = mix(1.0, 0.5, smoothstep(0.9, pupil_edge + 0.1, dist));
    depth_falloff = mix(depth_falloff, 1.0, 0.3);  // don't go fully dark

    // --- COLOR MIX ---
    vec3 base = stroma_color.rgb;
    vec3 glow = glow_color.rgb;
    vec3 fiber_color = mix(base, glow, fiber * glow_energy);
    fiber_color *= depth_falloff;

    // Limbal ring: dark, blurry edge blend (the anti-"medical" ring).
    float limbal = smoothstep(0.75, 0.95, dist);
    fiber_color = mix(fiber_color, base * 0.3, limbal * 0.6);

    // Final alpha: pupil hole + iris disc.
    float alpha = pupil_mask * iris_mask;

    ALBEDO = fiber_color;
    EMISSION = glow * fiber * glow_energy * 0.6 * pupil_mask;
    ALPHA = alpha;
    ROUGHNESS = mix(0.35, 0.15, fiber);  // fibers are slightly glossy
    METALLIC = 0.0;
}
