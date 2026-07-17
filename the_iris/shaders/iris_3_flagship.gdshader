shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 stroma_color : source_color = vec4(0.06, 0.62, 0.55, 0.94);
uniform vec4 limbal_glow : source_color = vec4(0.18, 0.95, 0.82, 1.0);
uniform float time : hint_range(0.0, 10000.0) = 0.0;
uniform float energy : hint_range(0.0, 5.0) = 0.35;
uniform float pupil_open : hint_range(0.0, 1.0) = 0.105;
uniform float transition_open : hint_range(0.0, 1.0) = 0.0;
uniform float progression_level : hint_range(0.0, 8.0) = 0.0;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);
    
    float rays = sin(angle * 16.0 + time * 0.2) * 0.5 + 0.5;
    float rings = sin(dist * 35.0 - time * 0.5) * 0.5 + 0.5;
    
    vec3 col = mix(stroma_color.rgb, limbal_glow.rgb, smoothstep(0.1, 0.45, dist) * (0.5 + rays * 0.5));
    col += vec3(energy * 0.4 * rings);
    
    float pupil_mask = step(pupil_open, dist);
    
    ALBEDO = col;
    EMISSION = col * (0.4 + energy * 0.6 + progression_level * 0.05);
    ALPHA = pupil_mask * stroma_color.a;
}
