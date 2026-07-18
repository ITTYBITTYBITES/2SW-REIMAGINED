# Chapter 01 Sensory Audio Production Audit

This audit outlines the detailed sensory audio specifications, design goals, and playback contracts for the five production moments of Chapter 01: "The First Fractures".

---

## 1. Chapter 1 Sensory Audio Goals
To deliver a premium, ADA-tier emotional experience, each moment requires three distinct audio layers loaded dynamically from the moment's asset manifest:
1. **Ambient Atmosphere Loop:** Steady loopable track setting the background environment (e.g., quiet hum, canvas rustling, hall applause).
2. **Anomaly Discovery Cue:** High-fidelity sound effect triggered when the correct anomaly hotspot is identified.
3. **Truth Resolution Cue:** Warm, emotionally resonant crescendo playing during the final revelation phase.

---

## 2. Momement-by-Moment Audio Production Specifications

### 2.1. WM_001 — The Unfinished Canvas
- **Ambient Loop (`wm001_ambient.ogg`):** Warm, quiet painter’s studio ambiance with soft afternoon breeze rustling and floorboard creaks.
- **Anomaly Discovery (`wm001_anomaly.ogg`):** Crisp glass refraction chime as the light spectrum bends across the canvas.
- **Truth Resolution (`wm001_resolution.ogg`):** Warm, swelling cello chord signifying composition completion.

### 2.2. WM_002 — The Forgotten Museum
- **Ambient Loop (`wm002_ambient.ogg`):** Low, echoing museum corridor drone with soft, distant clock ticks and wooden resonance.
- **Anomaly Discovery (`wm002_anomaly.ogg`):** Dull, mechanical brass watch click and glass imprinting hum.
- **Truth Resolution (`wm002_resolution.ogg`):** Soft, nostalgic string quintet arrangement for the grandfather's memory.

### 2.3. WM_003 — The Last Performance
- **Ambient Loop (`wm003_ambient.ogg`):** Backstage dressing room hush with the distant, muffled echo of hall applause.
- **Anomaly Discovery (`wm003_anomaly.ogg`):** Sharp, satisfying metallic click of a brass travel case latch snapping open.
- **Truth Resolution (`wm003_resolution.ogg`):** Deep, resonant solo violin vibrato holding the final note.

### 2.4. WM_004 — The Faulty Reactor
- **Ambient Loop (`wm004_ambient.ogg`):** Low-frequency laboratory computer fan hum and sterile air-conditioning hiss.
- **Anomaly Discovery (`wm004_anomaly.ogg`):** Shifting high-frequency sine-wave grid distortion.
- **Truth Resolution (`wm004_resolution.ogg`):** Satisfying digital diagnostic boot sweep indicating system stabilization.

### 2.5. WM_005 — The Witness
- **Ambient Loop (`wm005_ambient.ogg`):** Low, biological pulsing wave replicating a quiet, cosmic heart rate.
- **Anomaly Discovery (`wm005_anomaly.ogg`):** Desynchronizing glass-lens sweep and sweeping taptic rumble.
- **Truth Resolution (`wm005_resolution.ogg`):** Majestic, swelling orchestral crescendo completing the eye-reflection loop.

---

## 3. Playback Pipeline & Fallback Validation
- **Loading Chain:**
  `Witness Moment JSON` -> `WitnessAssetManifest` -> `GenericWitnessGameplay` -> `IrisAudioConsumer`
- **Fallback safety:** If the authored `.ogg` tracks are missing from the build folder, `WitnessAssetResolver.resolve_sound_path()` cleanly catches the file absence, logs a soft warning to the console, and falls back to standard procedural click sounds or logging, completely protecting the runtime from crashes.
