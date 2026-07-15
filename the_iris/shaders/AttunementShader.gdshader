shader_type canvas_item;

uniform float time : hint_range(0, 100) = 0.0;
uniform int attunement_mode : hint_range(0, 5) = 0; // 0=none, 1=thermal, 2=skeletal, 3=text, 4=forensic, 5=trajectory, 6=spectral
uniform float attunement_intensity : hint_range(0, 1) = 0.0;
uniform vec2 hotspot_center = vec2(0.5, 0.5);
uniform float hotspot_radius = 0.15;
uniform vec2 viewport_size = vec2(720.0, 1280.0);

varying vec2 uv;

void fragment() {
    uv = UV;
    vec4 color = texture(TEXTURE, uv);
    
    float dist_from_hotspot = length(uv - hotspot_center) / hotspot_radius;
    float falloff = smoothstep(1.5, 0.0, dist_from_hotspot) * attunement_intensity;
    
    // Base desaturation for non-attuned view
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = vec3(luminance);
    color.rgb = mix(color.rgb, desaturated, 0.3 * (1.0 - attunement_intensity));
    
    // Attunement modes
    if (attunement_mode == 1) { // THERMAL - tea cup
        // Heat map: cold=blue, hot=red/white
        float heat = luminance * 0.5 + 0.5;
        heat = pow(heat, 1.5); // Enhance contrast
        vec3 thermal = mix(
            vec3(0.1, 0.2, 0.8),   // cold blue
            vec3(1.0, 0.9, 0.3),   // hot yellow-white
            heat
        );
        thermal = mix(thermal, vec3(1.0, 0.2, 0.0), smoothstep(0.7, 0.9, heat)); // very hot = red
        color.rgb = mix(color.rgb, thermal, falloff);
        
        // Steam particles visualization
        float steam = sin(time * 5.0 + uv.y * 30.0 + uv.x * 10.0) * 0.5 + 0.5;
        steam = smoothstep(0.6, 0.8, steam) * (1.0 - uv.y) * 2.0;
        color.rgb += vec3(0.8, 0.9, 1.0) * steam * falloff * 0.3;
        
    } else if (attunement_mode == 2) { // SKELETAL - hand
        // X-ray / skeletal view
        vec3 bone = vec3(0.9, 0.85, 0.7);
        vec3 tissue = vec3(0.3, 0.1, 0.1);
        // Edge detection for bone structure
        float edge = length(vec2(
            texture(TEXTURE, uv + vec2(1.0/viewport_size.x, 0.0)).r - texture(TEXTURE, uv - vec2(1.0/viewport_size.x, 0.0)).r,
            texture(TEXTURE, uv + vec2(0.0, 1.0/viewport_size.y)).r - texture(TEXTURE, uv - vec2(0.0, 1.0/viewport_size.y)).r
        ));
        edge = smoothstep(0.05, 0.15, edge);
        vec3 skeletal = mix(tissue, bone, edge);
        color.rgb = mix(color.rgb, skeletal, falloff);
        
        // Pulse visualization at wrist
        float pulse = sin(time * 3.0) * 0.5 + 0.5;
        vec2 wrist_pos = hotspot_center + vec2(0.08, 0.12);
        float wrist_dist = length(uv - wrist_pos) / 0.03;
        float pulse_vis = smoothstep(1.0, 0.0, wrist_dist) * pulse;
        color.rgb += vec3(1.0, 0.3, 0.3) * pulse_vis * falloff;
        
        // Wedding ring highlight
        vec2 ring_pos = hotspot_center + vec2(-0.02, 0.02);
        float ring_dist = length(uv - ring_pos) / 0.015;
        float ring = smoothstep(1.0, 0.0, ring_dist);
        color.rgb += vec3(1.0, 0.85, 0.3) * ring * falloff * 0.8;
        
    } else if (attunement_mode == 3) { // TEXT - notebook
        // Enhance text readability
        float sharp = length(vec2(
            texture(TEXTURE, uv + vec2(1.0/viewport_size.x, 0.0)).r - texture(TEXTURE, uv - vec2(1.0/viewport_size.x, 0.0)).r,
            texture(TEXTURE, uv + vec2(0.0, 1.0/viewport_size.y)).r - texture(TEXTURE, uv - vec2(0.0, 1.0/viewport_size.y)).r
        ));
        sharp = smoothstep(0.02, 0.1, sharp);
        color.rgb = mix(color.rgb, vec3(0.95, 0.95, 0.9), sharp * falloff);
        // Sepia tone for "legible" feel
        color.rgb = mix(color.rgb, color.rgb * vec3(1.1, 1.0, 0.8), falloff);
        
    } else if (attunement_mode == 4) { // FORENSIC - second cup
        // UV/forensic lighting - reveal lipstick stain
        vec3 uv_light = vec3(0.3, 0.05, 0.2); // UV purple base
        float detail = luminance;
        detail = pow(detail, 2.0);
        vec3 forensic = mix(uv_light, vec3(0.8, 0.2, 0.4), detail); // Lipstick red-pink
        color.rgb = mix(color.rgb, forensic, falloff);
        
        // Rim imprint highlight
        float rim = smoothstep(0.3, 0.4, dist_from_hotspot) - smoothstep(0.4, 0.5, dist_from_hotspot);
        color.rgb += vec3(1.0, 0.4, 0.5) * rim * falloff * 0.5;
        
    } else if (attunement_mode == 5) { // TRAJECTORY - dust mote
        // Particle trail visualization
        float trail = 0.0;
        for (int i = 0; i < 8; i++) {
            float t = float(i) / 8.0;
            vec2 trail_pos = hotspot_center + vec2(sin(time * 0.5 + t * 3.14) * 0.002 * float(i), -t * 0.15);
            float d = length(uv - trail_pos);
            trail += smoothstep(0.015, 0.005, d) * (1.0 - t * 0.5);
        }
        color.rgb += vec3(1.0, 0.95, 0.8) * trail * falloff * 0.6;
        
        // Current mote position
        float mote_dist = length(uv - hotspot_center);
        float mote = smoothstep(0.008, 0.004, mote_dist);
        color.rgb += vec3(1.0, 0.95, 0.8) * mote * falloff;
        
    } else if (attunement_mode == 6) { // SPECTRAL - light shaft
        // Spectral breakdown visualization
        float spectral = sin(uv.x * 50.0 + time * 2.0) * 0.5 + 0.5;
        vec3 spectrum = mix(
            vec3(0.5, 0.0, 0.5),  // violet
            vec3(1.0, 0.0, 0.0),  // red
            spectral
        );
        spectrum = mix(spectrum, vec3(1.0, 1.0, 0.0), smoothstep(0.5, 0.7, spectral)); // yellow
        spectrum = mix(spectrum, vec3(0.0, 1.0, 0.0), smoothstep(0.7, 0.9, spectral)); // green
        color.rgb = mix(color.rgb, spectrum, falloff * 0.7);
        
        // Light shaft volumetric
        float shaft = smoothstep(0.3, 0.1, abs(uv.x - hotspot_center.x) / hotspot_radius) * 
                      smoothstep(1.0, 0.0, (uv.y - hotspot_center.y) / hotspot_radius);
        color.rgb += vec3(1.0, 0.95, 0.85) * shaft * falloff * 0.3;
    }
    
    // Vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.5;
    color.rgb *= vignette;
    
    // Film grain
    float grain = (sin(uv.x * 1234.5 + time * 10.0) * sin(uv.y * 567.8 + time * 7.0)) * 0.005;
    color.rgb += grain;
    
    COLOR = color;
}