shader_type canvas_item;

// The Living Iris 4.0 Master Shader
// Procedural + texture-assisted 2.5D optical lens: radial fibers, Hippus biological pupil
// movement, deep atmospheric void, and dynamic navigation perception cues.

uniform float time = 0.0;
uniform float state_mode = 0.0; // 0 idle, 1 curious, 2 focus, 3 memory
uniform float aspect = 0.5625;
uniform float energy = 0.0;
uniform float pupil_open = 0.105;
uniform float transition_open = 0.0;
uniform float recent_alert = 0.0;
uniform float blink_amount = 0.0;
uniform vec2 gaze_target = vec2(0.5, 0.495);
uniform vec2 micro_offset = vec2(0.0);
uniform vec2 anticipation = vec2(0.0);
uniform float invitation = 0.0;
uniform float deep_focus = 0.0;
uniform vec2 learning_focus = vec2(0.0);
uniform float learning_amount = 0.0;
uniform float awakening = 0.0;
uniform float breath_rate = 1.15;
uniform float orientation_motion = 0.0;
uniform vec2 sensor_offset = vec2(0.0);

// New Living Iris exported adjustments
uniform float progression_level = 0.0;
uniform float fiber_speed = 1.0;
uniform float glow_strength = 0.5;
uniform float has_textures = 0.0;
uniform sampler2D base_tex;
uniform sampler2D fibers_tex;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += noise(p) * a;
        p = p * 2.03 + 17.1;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.495);
    vec2 p = uv - center;
    vec2 q = vec2(p.x * aspect, p.y);
    float d = length(q);
    float ang = atan(q.y, q.x);

    // Biological Hippus Effect & Breathing rhythm
    float hippus = sin(time * 3.6 * fiber_speed + fbm(q * 6.0)) * 0.0035 + cos(time * 1.9 * fiber_speed) * 0.002;
    float breathe = sin(time * breath_rate) * 0.006 + sin(time * (breath_rate + 0.76)) * 0.002;
    float motion = (state_mode == 2.0 ? 0.0015 : 0.0045) * sin(time * 0.31 * fiber_speed);
    
    vec2 gaze_delta = gaze_target - center;
    gaze_delta.x *= aspect;
    vec2 optical_focus = gaze_delta + learning_focus * learning_amount * 0.045;
    q += vec2(motion, sin(time * 0.47 * fiber_speed) * 0.0015);
    q += optical_focus * 0.024 + micro_offset + anticipation * 0.022 + sensor_offset;
    q += vec2(sin(orientation_motion * PI) * 0.004, cos(orientation_motion * PI) * 0.002) * orientation_motion;
    d = length(q);
    ang = atan(q.y, q.x);

    // Deep atmospheric field behind the eye
    float bg_vignette = 1.0 - smoothstep(0.10, 0.80, length((uv - vec2(0.5)) * vec2(0.80, 0.70)));
    vec3 bg = mix(vec3(0.006, 0.012, 0.022), vec3(0.016, 0.048, 0.058), bg_vignette);
    float halo = exp(-d * 18.0) * (0.10 + glow_strength * 0.12);
    bg += vec3(0.12, 0.42, 0.38) * halo;

    // Outer glass/lens volume and soft scleral ring
    float lens = 1.0 - smoothstep(0.325, 0.37, d);
    float sclera = smoothstep(0.31, 0.245, d);
    float sclera_light = pow(max(0.0, 1.0 - d / 0.34), 1.8);
    vec3 sclera_col = mix(vec3(0.03, 0.09, 0.11), vec3(0.21, 0.37, 0.34), sclera_light * 0.55);
    sclera_col += vec3(0.08, 0.30, 0.25) * pow(max(0.0, 1.0 - d / 0.34), 7.0);

    // Iris stroma body and dynamic aperture
    float iris_r = 0.245 + breathe + (state_mode == 2.0 ? -0.002 : 0.0);
    float iris_mask = 1.0 - smoothstep(iris_r - 0.012, iris_r + 0.012, d);
    float inner = smoothstep(0.052, 0.12, d);
    float radial = smoothstep(0.245, 0.12, d);
    float grain = fbm(vec2(cos(ang) * 3.0 + 9.0, sin(ang) * 3.0 - 5.0) + q * 16.0);
    float fiber_a = sin(ang * 54.0 + d * 76.0 + sin(ang * 7.0 * fiber_speed) * 2.0 + grain * 8.0);
    float fiber_b = sin(ang * 113.0 - d * 125.0 + noise(q * 31.0) * 5.0);
    float fibers = smoothstep(-0.12, 0.82, fiber_a * 0.65 + fiber_b * 0.35);
    float radial_ridges = smoothstep(0.15, 0.9, sin(d * 165.0 + ang * 8.0 + grain * 4.0) * 0.5 + 0.5);
    
    vec3 teal = mix(vec3(0.035, 0.15, 0.17), vec3(0.18, 0.59, 0.54), fibers * 0.78 + grain * 0.28);
    teal = mix(teal, vec3(0.40, 0.70, 0.57), radial_ridges * radial * 0.27);
    teal += vec3(0.11, 0.33, 0.28) * pow(radial, 2.0);
    teal *= 0.72 + 0.30 * inner;

    // Progression evolution: richer fibers, golden/emerald rings for experienced players
    if (progression_level > 0.5) {
        float starlight = sin(ang * 24.0 - time * 0.5) * 0.5 + 0.5;
        float collarette = exp(-abs(d - 0.14) * 80.0);
        vec3 gold_highlight = vec3(0.85, 0.72, 0.38) * collarette * starlight * min(progression_level * 0.25, 0.8);
        teal += gold_highlight;
        teal += vec3(0.10, 0.35, 0.45) * min(progression_level * 0.12, 0.35) * radial;
    }

    // Aperture: layered pupil and animated optical edge
    float aperture = pupil_open + transition_open * 0.205 + recent_alert * 0.018 + awakening * 0.012 - deep_focus * 0.022 + breathe * 0.5 + hippus + (state_mode == 1.0 ? 0.014 : 0.0);

    // Blend with production fiber and base textures when available
    if (has_textures > 0.5) {
        vec2 stroma_uv = q / (iris_r * 2.05) + vec2(0.5);
        if (stroma_uv.x > 0.01 && stroma_uv.x < 0.99 && stroma_uv.y > 0.01 && stroma_uv.y < 0.99) {
            vec4 b_col = texture(base_tex, stroma_uv);
            vec2 fibers_uv = (stroma_uv - vec2(0.5)) * vec2(1.0, 1.0) + vec2(0.5);
            vec4 f_col = texture(fibers_tex, clamp(fibers_uv, vec2(0.01), vec2(0.99)));
            float tex_blend = smoothstep(iris_r + 0.005, iris_r - 0.025, d) * smoothstep(aperture - 0.005, aperture + 0.015, d);
            vec3 combined_tex = mix(b_col.rgb, f_col.rgb * 1.3, f_col.a * 0.65);
            teal = mix(teal, combined_tex, max(b_col.a, f_col.a) * tex_blend * 0.85);
        }
    }

    float pupil = 1.0 - smoothstep(aperture, aperture + 0.009, d);
    float pupil_edge = 1.0 - smoothstep(aperture - 0.013, aperture + 0.004, d);
    vec3 pupil_col = vec3(0.001, 0.004, 0.007) + vec3(0.012, 0.035, 0.034) * (1.0 - d / max(aperture, 0.01));
    teal += vec3(0.22, 0.55, 0.40) * pupil_edge * (0.8 + glow_strength * 0.4);

    vec3 col = bg;
    col = mix(col, sclera_col, sclera * lens * 0.65);
    col = mix(col, teal, iris_mask);
    col = mix(col, pupil_col, pupil);

    // Translucent limbal ring and fine outer refraction
    float limbal = smoothstep(0.267, 0.238, d) * (1.0 - smoothstep(0.238, 0.215, d));
    col += vec3(0.13, 0.50, 0.45) * limbal * (0.65 + energy * 0.3 + glow_strength * 0.2);
    float edge = smoothstep(0.34, 0.29, d) - smoothstep(0.29, 0.255, d);
    col += vec3(0.15, 0.55, 0.51) * edge * 0.45;

    // Two soft optical glass reflections
    vec2 highlight_shift = optical_focus * 0.13;
    vec2 hi = q - (vec2(-0.075, -0.095) + highlight_shift);
    float reflection = exp(-dot(hi, hi) * 420.0);
    vec2 lo = q - (vec2(0.11, 0.15) + highlight_shift * 0.55);
    reflection += exp(-dot(lo, lo) * 800.0) * 0.32;
    float arc = smoothstep(0.012, 0.0, abs(length(q - vec2(0.0, -0.005)) - 0.218));
    col += vec3(0.74, 0.98, 0.91) * reflection * (0.58 + energy * 0.35 + awakening * 0.18 + glow_strength * 0.25);
    col += vec3(0.23, 0.68, 0.58) * arc * 0.11;

    // Quiet invitation before touch
    float invitation_glow = exp(-d * 34.0) * invitation;
    float invitation_ring = exp(-abs(d - (aperture + 0.028)) * 90.0) * invitation;
    col += vec3(0.28, 0.82, 0.70) * invitation_glow * 0.24;
    col += vec3(0.25, 0.74, 0.64) * invitation_ring * 0.14;

    // Partial blink: narrow central slit remains visible
    float blink_slit = mix(0.30, 0.045, blink_amount);
    float eyelid = smoothstep(blink_slit, blink_slit + 0.045, abs(q.y)) * iris_mask * blink_amount;
    col = mix(col, vec3(0.008, 0.022, 0.026), eyelid * 0.94);

    // Rim lights: non-verbal navigation perception cues
    float cue_left = exp(-dot(q - vec2(-0.275, 0.0), q - vec2(-0.275, 0.0)) * 1100.0) * (1.0 + max(-anticipation.x, 0.0) * 8.0 + max(-learning_focus.x, 0.0) * learning_amount * 4.0);
    float cue_right = exp(-dot(q - vec2(0.275, 0.0), q - vec2(0.275, 0.0)) * 1100.0) * (1.0 + max(anticipation.x, 0.0) * 8.0 + max(learning_focus.x, 0.0) * learning_amount * 4.0);
    float cue_up = exp(-dot(q - vec2(0.0, -0.275), q - vec2(0.0, -0.275)) * 1100.0) * (1.0 + max(-anticipation.y, 0.0) * 8.0 + max(-learning_focus.y, 0.0) * learning_amount * 4.0);
    float cue_down = exp(-dot(q - vec2(0.0, 0.275), q - vec2(0.0, 0.275)) * 1100.0) * (1.0 + max(anticipation.y, 0.0) * 8.0 + max(learning_focus.y, 0.0) * learning_amount * 4.0);
    
    // Gaze focus cue: brighten rim in direction of gaze
    vec2 gaze_dir = gaze_target - center;
    float gaze_dist = length(gaze_dir);
    if (gaze_dist > 0.05) {
        vec2 norm_gaze = normalize(gaze_dir);
        float gaze_align = dot(normalize(q + vec2(0.0001)), norm_gaze);
        float gaze_rim = smoothstep(0.18, 0.26, d) * smoothstep(0.6, 1.0, gaze_align) * min(gaze_dist * 3.0, 1.0);
        col += vec3(0.35, 0.88, 0.78) * gaze_rim * 0.25;
    }

    float cue_light = cue_left + cue_right + cue_up + cue_down;
    col += vec3(0.25, 0.78, 0.67) * cue_light * (0.10 + energy * 0.16 + recent_alert * 0.12 + learning_amount * 0.08 + glow_strength * 0.15);
    float directional_flow = max(abs(anticipation.x), abs(anticipation.y));
    float flow_streak = sin(ang * 18.0 + d * 105.0) * 0.5 + 0.5;
    col += vec3(0.12, 0.45, 0.38) * flow_streak * directional_flow * iris_mask * 0.08;

    // Restrained focus shimmer
    float shimmer = sin(ang * 9.0 + d * 45.0 + time * (state_mode == 2.0 ? 0.9 : 0.22) * fiber_speed);
    col += vec3(0.10, 0.30, 0.25) * smoothstep(0.82, 0.98, shimmer) * iris_mask * (0.10 + glow_strength * 0.1);
    col += vec3(0.12, 0.38, 0.34) * orientation_motion * exp(-abs(d - 0.31) * 38.0) * 0.12;

    float alpha = max(bg_vignette, lens * 0.92);
    COLOR = vec4(col, alpha);
}
