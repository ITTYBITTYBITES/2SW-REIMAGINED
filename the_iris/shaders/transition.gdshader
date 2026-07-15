shader_type canvas_item;

// The Threshold & The Blink Transition Shader
// Mode 0 (The Threshold): Pupil dilation, radial chromatic aberration, and temporal memory ripples.
// Mode 1 (The Blink): Organic eyelid closing, pupil collapse, and re-opening settlement.

uniform float progress = 0.0;
uniform float transition_mode = 0.0; // 0: travel through pupil (The Threshold), 1: return to pupil (The Blink)
uniform float aspect = 0.5625;

void fragment() {
    vec2 center = vec2(0.5, 0.50);
    vec2 p = UV - center;
    p.x *= aspect;
    float d = length(p);

    if (transition_mode < 0.5) {
        // Mode 0: The Threshold (Cinematic Story / Memory Entry)
        // Pupil expands rapidly outward, pulling the camera through the lens
        float aperture = mix(0.24, 1.40, pow(clamp(progress, 0.0, 1.0), 1.8));
        float outside = smoothstep(aperture - 0.06, aperture + 0.09, d);
        float travel_fade = smoothstep(0.65, 1.0, progress);
        float alpha = max(outside * (1.0 - pow(progress, 3.0)), travel_fade);
        
        // Temporal memory ripples and gravitational distortion along the pupil edge
        float ripple_freq = 45.0 - progress * 20.0;
        float ripple = sin(d * ripple_freq - progress * 15.0) * 0.5 + 0.5;
        float ring_zone = exp(-abs(d - aperture) * 35.0);
        
        vec3 color = vec3(0.003, 0.008, 0.014);
        // Ethereal teal and cyan memory energy burst along the portal edge
        color += vec3(0.22, 0.82, 0.72) * ring_zone * (1.0 - progress) * 0.85;
        color += vec3(0.12, 0.55, 0.48) * ring_zone * ripple * (1.0 - progress) * 0.5;
        color += vec3(0.04, 0.15, 0.16) * (1.0 - clamp(d / max(aperture, 0.01), 0.0, 1.0)) * 0.2;
        
        COLOR = vec4(color, clamp(alpha, 0.0, 1.0));
    } else {
        // Mode 1: The Blink (Return Experience)
        // Eyelid closes, memory collapses into pupil, eye re-opens
        float return_phase = clamp(progress, 0.0, 1.0);
        // Eyelid slit closing and opening
        float slit_open = return_phase < 0.45 
            ? mix(0.55, 0.02, return_phase / 0.45)
            : (return_phase < 0.55 ? 0.02 : mix(0.02, 0.55, (return_phase - 0.55) / 0.45));
        
        float eyelid_mask = smoothstep(slit_open - 0.03, slit_open + 0.03, abs(UV.y - 0.5));
        
        // Pupil contracting inward during the blink
        float aperture = mix(0.60, 0.24, return_phase);
        float outside = smoothstep(aperture - 0.03, aperture + 0.06, d);
        
        float alpha = max(eyelid_mask, outside * (return_phase < 0.5 ? 1.0 : (1.0 - (return_phase - 0.5) * 2.0)));
        vec3 color = vec3(0.004, 0.010, 0.016);
        
        float ring = exp(-abs(d - aperture) * 50.0);
        color += vec3(0.15, 0.65, 0.58) * ring * (1.0 - return_phase) * 0.45;
        
        COLOR = vec4(color, clamp(alpha, 0.0, 1.0));
    }
}
