shader_type canvas_item;

uniform float time : hint_range(0, 100) = 0.0;
uniform float progress : hint_range(0, 1) = 0.0;
uniform float dust_mote_phase : hint_range(0, 6.28) = 0.0;
uniform float steam_intensity : hint_range(0, 1) = 1.0;
uniform vec2 viewport_size = vec2(720.0, 1280.0);

varying vec2 uv;

void fragment() {
    uv = UV;
    vec4 color = texture(TEXTURE, uv);
    
    // Subtle vignette for cinematic feel
    float vignette = 1.0 - length(uv - 0.5) * 0.6;
    color.rgb *= vignette;
    
    // Dust mote - single particle in light shaft
    vec2 mote_pos = vec2(0.35, 0.45) + vec2(sin(dust_mote_phase) * 0.002, cos(dust_mote_phase * 0.7) * 0.003);
    float mote_dist = length(uv - mote_pos);
    float mote = smoothstep(0.008, 0.004, mote_dist) * 0.8;
    color.rgb += vec3(1.0, 0.95, 0.85) * mote * (0.5 + 0.5 * sin(time * 3.0));
    
    // Steam near cup area (upper right quadrant)
    float steam_x = uv.x - 0.68;
    float steam_y = uv.y - 0.35;
    float steam_dist = length(vec2(steam_x * 1.5, steam_y));
    float steam_noise = sin(time * 2.0 + uv.y * 40.0 + sin(time * 0.5 + uv.x * 10.0) * 0.5);
    float steam = smoothstep(0.15, 0.05, steam_dist) * max(0.0, steam_noise * 0.5 + 0.5) * steam_intensity * 0.15;
    color.rgb += vec3(0.9, 0.95, 1.0) * steam;
    
    // Specular highlight on cup - moves as "hand approaches"
    float highlight_progress = progress; // 0 to 1 during hand approach/hover
    vec2 highlight_pos = vec2(0.7, 0.4) + vec2(-0.08, 0.02) * highlight_progress;
    float highlight_dist = length(uv - highlight_pos);
    float highlight = smoothstep(0.06, 0.02, highlight_dist) * (1.0 - highlight_progress * 0.3);
    color.rgb += vec3(1.0, 0.95, 0.8) * highlight * 0.6;
    
    // Film grain
    float grain = (sin(uv.x * 1234.5 + time * 10.0) * sin(uv.y * 567.8 + time * 7.0)) * 0.01;
    color.rgb += grain;
    
    // Slight color grade - cool shadows, warm highlights
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(
        color.rgb * vec3(0.95, 0.98, 1.05), // cool shadows
        color.rgb * vec3(1.05, 1.02, 0.95), // warm highlights
        smoothstep(0.2, 0.8, luminance)
    );
    
    COLOR = color;
}