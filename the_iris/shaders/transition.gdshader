shader_type canvas_item;

uniform float progress = 0.0;
uniform float transition_mode = 0.0; // 0: travel through pupil, 1: return to pupil
uniform float aspect = 0.5625;

void fragment() {
    vec2 p = UV - vec2(0.5, 0.50);
    p.x *= aspect;
    float d = length(p);
    float aperture = mix(0.24, 0.70, smoothstep(0.0, 0.84, progress));
    float outside = smoothstep(aperture - 0.035, aperture + 0.075, d);
    float travel_fade = smoothstep(0.68, 1.0, progress);
    float return_fade = smoothstep(0.0, 0.82, progress);
    float alpha = transition_mode < 0.5
        ? max(outside * progress * 0.95, travel_fade)
        : return_fade;
    float ring = 1.0 - smoothstep(0.0, 0.014, abs(d - aperture));
    vec3 color = vec3(0.004, 0.010, 0.016);
    color += vec3(0.10, 0.43, 0.37) * ring * (1.0 - progress) * 0.38;
    color += vec3(0.06, 0.16, 0.16) * (1.0 - d / 0.75) * 0.08;
    COLOR = vec4(color, clamp(alpha, 0.0, 1.0));
}
