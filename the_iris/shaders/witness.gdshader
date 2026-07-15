shader_type canvas_item;

uniform float time = 0.0;
uniform float focus = 0.0;
uniform float reveal = 0.0;
uniform float aspect = 0.5625;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    return mix(mix(hash21(i), hash21(i+vec2(1.0,0.0)), f.x), mix(hash21(i+vec2(0.0,1.0)), hash21(i+vec2(1.0,1.0)), f.x), f.y);
}

void fragment() {
    vec2 uv = UV;
    vec2 p = uv - vec2(0.5, 0.50);
    p.x *= aspect;
    float d = length(p);
    float vignette = smoothstep(0.50, 0.12, d);
    // A quiet optical field: cyan shadows, silver center, warm discovery bias.
    vec3 col = mix(vec3(0.015, 0.023, 0.033), vec3(0.11, 0.22, 0.23), vignette);
    col += vec3(0.10, 0.17, 0.16) * exp(-d * 5.5);
    float glass = sin((uv.y + time * 0.02) * 120.0) * 0.006;
    col += glass;

    // Distorted concentric field lines.
    float ring = sin(d * 160.0 + sin(uv.x * 15.0) * 2.2) * 0.5 + 0.5;
    col += vec3(0.04, 0.18, 0.17) * smoothstep(0.68, 0.95, ring) * vignette * 0.22;

    // Scan beam and focus pulse.
    float scan_y = fract(time * 0.075);
    float scan = exp(-abs(uv.y - scan_y) * 120.0);
    col += vec3(0.18, 0.75, 0.62) * scan * (0.07 + focus * 0.14);
    float pulse = exp(-abs(d - fract(time * 0.055) * 0.42) * 30.0);
    col += vec3(0.10, 0.40, 0.34) * pulse * 0.10;

    // Reveal washes a small amber frequency through the instrument.
    float hidden = smoothstep(0.0, 1.0, reveal) * exp(-length(uv - vec2(0.68, 0.40)) * 13.0);
    col += vec3(0.50, 0.32, 0.13) * hidden;

    // Lens vignetting / chromatic edge approximation.
    col *= 0.73 + vignette * 0.38;
    float grain = noise(uv * 180.0 + time) - 0.5;
    col += grain * 0.012;
    COLOR = vec4(col, 1.0);
}
