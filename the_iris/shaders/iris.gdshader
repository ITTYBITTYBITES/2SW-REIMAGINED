shader_type canvas_item;

// Procedural iris: radial fibers, translucent limbal layers, moisture and a
// slowly breathing aperture. Everything is generated in the fragment shader.
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

    // 4–6 second biological breathing cycle, with a smaller harmonic.
    float breathe = sin(time * breath_rate) * 0.006 + sin(time * (breath_rate + 0.76)) * 0.002;
    float motion = (state_mode == 2.0 ? 0.0015 : 0.0045) * sin(time * 0.31);
    vec2 gaze_delta = gaze_target - center;
    gaze_delta.x *= aspect;
    vec2 optical_focus = gaze_delta + learning_focus * learning_amount * 0.045;
    q += vec2(motion, sin(time * 0.47) * 0.0015);
    q += optical_focus * 0.022 + micro_offset + anticipation * 0.022 + sensor_offset;
    q += vec2(sin(orientation_motion * PI) * 0.004, cos(orientation_motion * PI) * 0.002) * orientation_motion;
    d = length(q);
    ang = atan(q.y, q.x);

    // Deep atmospheric field behind the eye.
    float bg_vignette = 1.0 - smoothstep(0.10, 0.80, length((uv - vec2(0.5)) * vec2(0.80, 0.70)));
    vec3 bg = mix(vec3(0.006, 0.012, 0.022), vec3(0.020, 0.057, 0.065), bg_vignette);
    float halo = exp(-d * 18.0) * 0.10;
    bg += vec3(0.12, 0.42, 0.38) * halo;

    // Outer glass/lens volume and soft scleral ring.
    float lens = 1.0 - smoothstep(0.325, 0.37, d);
    float sclera = smoothstep(0.31, 0.245, d);
    float sclera_light = pow(max(0.0, 1.0 - d / 0.34), 1.8);
    vec3 sclera_col = mix(vec3(0.03, 0.09, 0.11), vec3(0.21, 0.37, 0.34), sclera_light * 0.55);
    sclera_col += vec3(0.08, 0.30, 0.25) * pow(max(0.0, 1.0 - d / 0.34), 7.0);

    // Iris body.
    float iris_r = 0.245 + breathe + (state_mode == 2.0 ? -0.002 : 0.0);
    float iris_mask = 1.0 - smoothstep(iris_r - 0.012, iris_r + 0.012, d);
    float inner = smoothstep(0.052, 0.12, d);
    float radial = smoothstep(0.245, 0.12, d);
    float grain = fbm(vec2(cos(ang) * 3.0 + 9.0, sin(ang) * 3.0 - 5.0) + q * 16.0);
    float fiber_a = sin(ang * 54.0 + d * 76.0 + sin(ang * 7.0) * 2.0 + grain * 8.0);
    float fiber_b = sin(ang * 113.0 - d * 125.0 + noise(q * 31.0) * 5.0);
    float fibers = smoothstep(-0.12, 0.82, fiber_a * 0.65 + fiber_b * 0.35);
    float radial_ridges = smoothstep(0.15, 0.9, sin(d * 165.0 + ang * 8.0 + grain * 4.0) * 0.5 + 0.5);
    vec3 teal = mix(vec3(0.035, 0.15, 0.17), vec3(0.18, 0.59, 0.54), fibers * 0.78 + grain * 0.28);
    teal = mix(teal, vec3(0.40, 0.70, 0.57), radial_ridges * radial * 0.27);
    teal += vec3(0.11, 0.33, 0.28) * pow(radial, 2.0);
    teal *= 0.72 + 0.30 * inner;

    // Aperture: layered pupil and animated edge.
    float aperture = pupil_open + transition_open * 0.205 + recent_alert * 0.018 + awakening * 0.012 - deep_focus * 0.022 + breathe * 0.5 + (state_mode == 1.0 ? 0.014 : 0.0);
    float pupil = 1.0 - smoothstep(aperture, aperture + 0.009, d);
    float pupil_edge = 1.0 - smoothstep(aperture - 0.013, aperture + 0.004, d);
    vec3 pupil_col = vec3(0.001, 0.004, 0.007) + vec3(0.012, 0.035, 0.034) * (1.0 - d / max(aperture, 0.01));
    teal += vec3(0.22, 0.55, 0.40) * pupil_edge * 0.9;

    vec3 col = bg;
    col = mix(col, sclera_col, sclera * lens * 0.65);
    col = mix(col, teal, iris_mask);
    col = mix(col, pupil_col, pupil);

    // Translucent limbal ring and fine outer refraction.
    float limbal = smoothstep(0.267, 0.238, d) * (1.0 - smoothstep(0.238, 0.215, d));
    col += vec3(0.13, 0.50, 0.45) * limbal * (0.65 + energy * 0.3);
    float edge = smoothstep(0.34, 0.29, d) - smoothstep(0.29, 0.255, d);
    col += vec3(0.15, 0.55, 0.51) * edge * 0.45;

    // Two soft reflections make the surface feel wet and optical.
    vec2 highlight_shift = optical_focus * 0.13;
    vec2 hi = q - (vec2(-0.075, -0.095) + highlight_shift);
    float reflection = exp(-dot(hi, hi) * 420.0);
    vec2 lo = q - (vec2(0.11, 0.15) + highlight_shift * 0.55);
    reflection += exp(-dot(lo, lo) * 800.0) * 0.32;
    float arc = smoothstep(0.012, 0.0, abs(length(q - vec2(0.0, -0.005)) - 0.218));
    col += vec3(0.74, 0.98, 0.91) * reflection * (0.58 + energy * 0.35 + awakening * 0.18);
    col += vec3(0.23, 0.68, 0.58) * arc * 0.11;

    // The eye invites a first touch without presenting a button: a quiet
    // gathering of light toward the pupil during idle moments.
    float invitation_glow = exp(-d * 34.0) * invitation;
    float invitation_ring = exp(-abs(d - (aperture + 0.028)) * 90.0) * invitation;
    col += vec3(0.28, 0.82, 0.70) * invitation_glow * 0.24;
    col += vec3(0.25, 0.74, 0.64) * invitation_ring * 0.14;

    // A partial blink: a narrow central slit remains visible instead of
    // abruptly replacing the instrument with a black screen.
    float blink_slit = mix(0.30, 0.045, blink_amount);
    float eyelid = smoothstep(blink_slit, blink_slit + 0.045, abs(q.y)) * iris_mask * blink_amount;
    col = mix(col, vec3(0.008, 0.022, 0.026), eyelid * 0.94);

    // Four rim lights are the non-verbal navigation cues. Their intensity
    // gently leans toward the direction of an in-progress drag.
    float cue_left = exp(-dot(q - vec2(-0.275, 0.0), q - vec2(-0.275, 0.0)) * 1100.0) * (1.0 + max(-anticipation.x, 0.0) * 8.0 + max(-learning_focus.x, 0.0) * learning_amount * 4.0);
    float cue_right = exp(-dot(q - vec2(0.275, 0.0), q - vec2(0.275, 0.0)) * 1100.0) * (1.0 + max(anticipation.x, 0.0) * 8.0 + max(learning_focus.x, 0.0) * learning_amount * 4.0);
    float cue_up = exp(-dot(q - vec2(0.0, -0.275), q - vec2(0.0, -0.275)) * 1100.0) * (1.0 + max(-anticipation.y, 0.0) * 8.0 + max(-learning_focus.y, 0.0) * learning_amount * 4.0);
    float cue_down = exp(-dot(q - vec2(0.0, 0.275), q - vec2(0.0, 0.275)) * 1100.0) * (1.0 + max(anticipation.y, 0.0) * 8.0 + max(learning_focus.y, 0.0) * learning_amount * 4.0);
    float cue_light = cue_left + cue_right + cue_up + cue_down;
    col += vec3(0.25, 0.78, 0.67) * cue_light * (0.10 + energy * 0.16 + recent_alert * 0.12 + learning_amount * 0.08);
    float directional_flow = max(abs(anticipation.x), abs(anticipation.y));
    float flow_streak = sin(ang * 18.0 + d * 105.0) * 0.5 + 0.5;
    col += vec3(0.12, 0.45, 0.38) * flow_streak * directional_flow * iris_mask * 0.08;

    // A restrained focus shimmer.
    float shimmer = sin(ang * 9.0 + d * 45.0 + time * (state_mode == 2.0 ? 0.9 : 0.22));
    col += vec3(0.10, 0.30, 0.25) * smoothstep(0.82, 0.98, shimmer) * iris_mask * 0.10;
    col += vec3(0.12, 0.38, 0.34) * orientation_motion * exp(-abs(d - 0.31) * 38.0) * 0.12;

    float alpha = max(bg_vignette, lens * 0.92);
    COLOR = vec4(col, alpha);
}
