shader_type canvas_item;

// Universal Observation Moment Shader for Chapter 1 (WM_001 - WM_005)
// Renders distinct 2.5D optical and environmental phenomena during the 2-second cinematic window.

uniform float time : hint_range(0, 100) = 0.0;
uniform float progress : hint_range(0, 1) = 0.0;
uniform float dust_mote_phase : hint_range(0, 6.28) = 0.0;
uniform float steam_intensity : hint_range(0, 1) = 1.0;
uniform float effect_mode : hint_range(1, 5) = 1.0; // 1: WM_001 Studio, 2: WM_002 Museum, 3: WM_003 Dressing Room, 4: WM_004 Reactor, 5: WM_005 Iris
uniform vec2 viewport_size = vec2(720.0, 1280.0);

varying vec2 uv;

void fragment() {
    uv = UV;
    vec4 color = texture(TEXTURE, uv);
    
    // Subtle vignette for cinematic depth
    float vignette = 1.0 - length(uv - 0.5) * 0.55;
    color.rgb *= vignette;
    
    if (effect_mode < 1.5) {
        // Mode 1: WM_001 (The Unfinished Canvas / Studio Loft)
        // Golden dust motes in sun shaft and linseed vapor near brush
        vec2 mote_pos = vec2(0.35, 0.45) + vec2(sin(dust_mote_phase) * 0.002, cos(dust_mote_phase * 0.7) * 0.003);
        float mote = smoothstep(0.008, 0.004, length(uv - mote_pos)) * 0.8;
        color.rgb += vec3(1.0, 0.95, 0.85) * mote * (0.5 + 0.5 * sin(time * 3.0));
        
        // Linseed vapor / steam near easel (stops during hover at progress 0.35-0.85)
        float steam_dist = length(vec2((uv.x - 0.68) * 1.5, uv.y - 0.35));
        float steam_noise = sin(time * 2.0 + uv.y * 40.0 + sin(time * 0.5 + uv.x * 10.0) * 0.5);
        float steam = smoothstep(0.15, 0.05, steam_dist) * max(0.0, steam_noise * 0.5 + 0.5) * steam_intensity * 0.15;
        color.rgb += vec3(0.9, 0.95, 1.0) * steam;
        
        // Specular highlight on prism / brush moving with hand
        vec2 highlight_pos = vec2(0.7, 0.4) + vec2(-0.08, 0.02) * progress;
        float highlight = smoothstep(0.06, 0.02, length(uv - highlight_pos)) * (1.0 - progress * 0.3);
        color.rgb += vec3(1.0, 0.95, 0.8) * highlight * 0.6;
    } 
    else if (effect_mode < 2.5) {
        // Mode 2: WM_002 (The Forgotten Museum)
        // Archival museum dust drifting in halogen security spotlight & parquet floor reflection
        float halogen_shaft = smoothstep(0.4, 0.0, abs(uv.x - 0.5 + (uv.y - 0.5) * 0.2)) * (1.0 - uv.y);
        color.rgb += vec3(0.15, 0.25, 0.35) * halogen_shaft * 0.18;
        
        vec2 dust_pos = vec2(0.5, 0.4) + vec2(sin(time * 0.8 + dust_mote_phase) * 0.1, cos(time * 0.6) * 0.1);
        float dust = smoothstep(0.012, 0.0, length(uv - dust_pos));
        color.rgb += vec3(0.8, 0.9, 1.0) * dust * 0.5;
        
        // Palm touch thermal highlight on glass case during guard pause (progress 0.25-0.75)
        if (progress > 0.25 && progress < 0.75) {
            float palm = smoothstep(0.08, 0.01, length(uv - vec2(0.62, 0.45)));
            color.rgb += vec3(0.95, 0.75, 0.45) * palm * sin(time * 6.0) * 0.25;
        }
    } 
    else if (effect_mode < 3.5) {
        // Mode 3: WM_003 (The Last Performance)
        // Amber rosin dust settling around violin strings & vanity bulb voltage flicker
        float rosin_cloud = sin(uv.x * 35.0 + time * 1.5) * cos(uv.y * 25.0 - time * 0.8);
        float rosin_mask = smoothstep(0.2, 0.0, length(uv - vec2(0.45, 0.55)));
        color.rgb += vec3(0.95, 0.75, 0.35) * max(0.0, rosin_cloud) * rosin_mask * 0.22;
        
        // Vanity mirror bulb voltage flicker
        float bulb_flicker = sin(time * 18.0) * 0.05 + 0.95;
        float bulb_glow = smoothstep(0.3, 0.0, length(uv - vec2(0.75, 0.25)));
        color.rgb += vec3(1.0, 0.85, 0.5) * bulb_glow * bulb_flicker * 0.3;
    } 
    else if (effect_mode < 4.5) {
        // Mode 4: WM_004 (The Faulty Reactor)
        // Monochromatic 488nm teal laser deflection across quartz target grid
        float laser_y = 0.48 + sin(time * 12.0) * 0.001 + (progress > 0.3 ? 0.015 * (progress - 0.3) : 0.0);
        float laser_beam = smoothstep(0.006, 0.001, abs(uv.y - laser_y)) * smoothstep(0.1, 0.3, uv.x) * smoothstep(0.9, 0.7, uv.x);
        color.rgb += vec3(0.1, 0.95, 0.85) * laser_beam * 1.2;
        
        // Cleanroom laminar airflow shimmer
        float air_shimmer = sin(uv.y * 60.0 - time * 4.0) * 0.008;
        color.rgb += vec3(0.05, 0.2, 0.25) * abs(air_shimmer);
    } 
    else {
        // Mode 5: WM_005 (The Witness)
        // Bioluminescent stroma breathing & orbiting starlight reflections inside the eye
        float starlight = smoothstep(0.03, 0.0, abs(length(uv - 0.5) - (0.28 + sin(time * 1.5) * 0.01)));
        color.rgb += vec3(0.3, 0.85, 0.75) * starlight * 0.45;
        
        // Orbiting shard light pulse
        vec2 shard_pos = vec2(0.5) + vec2(cos(time * 0.8), sin(time * 0.8)) * 0.24;
        float shard_glow = smoothstep(0.06, 0.01, length(uv - shard_pos));
        color.rgb += vec3(0.9, 0.8, 0.4) * shard_glow * 0.5;
    }
    
    // Film grain across all modes
    float grain = (sin(uv.x * 1234.5 + time * 10.0) * sin(uv.y * 567.8 + time * 7.0)) * 0.012;
    color.rgb += grain;
    
    COLOR = color;
}
