# VISUAL_CALIBRATION_GUIDE.md

**Iris V4.0 — The Sentient Archivist**
**3D Reconstruction Calibration Guide**

This document lists the `@export` parameters on `Iris3DHub` and their recommended values for the "World-Class" look on Android (Forward+ / Mobile renderer, 540×960 portrait).

---

## Stroma (The Muscle)

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `stroma_color` | `(0.02, 0.045, 0.075)` | Mood-driven | Deep base color of the iris bed. Driven by IrisCore mood (DORMANT=obsidian-blue, AWARE=indigo, FOCUSED=amber, SUCCESS=white-gold). Do NOT set manually — the mood system overrides this. |
| `glow_color` | `(0.20, 0.62, 0.78)` | Mood-driven | Emissive fiber color. Same — driven by mood. |
| `glow_energy` | `0.8` | `0.6–1.2` | Controls fiber brightness and bloom intensity. Higher = more "alive." Mood energy maps to this range. |
| `fiber_density` | `40.0` | `35–50` | Number of fiber bands in the Simplex-noise shader. Higher = denser fringe (more "neural" look). Performance: each increment adds shader complexity. 50 is the mobile ceiling. |
| `fiber_swim` | `0.6` | `0.4–0.8` | Noise undulation speed. The "swim" — how much fibers move independently. Higher = more restless/alive. |
| `depth_intensity` | `0.8` | `0.6–1.0` | Concave depth shadow strength. Higher = deeper "bowl" look. |

**Tuning for "World-Class":** Start at defaults. If the iris looks flat, increase `fiber_density` to 45 and `depth_intensity` to 0.9. If it looks noisy, drop `fiber_swim` to 0.4.

---

## Pupil (The Void)

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `base_dilation` | `0.30` | `0.25–0.35` | Resting pupil size (fraction of iris radius). Lower = more intense/focused look. |
| `dilation_speed` | `3.0` | `2.0–4.0` | How fast the pupil responds to state changes. Higher = more reactive/twitchy. |
| `hippus_amplitude` | `0.02` | `0.01–0.03` | Pupil heartbeat fluctuation. The "Hippus" pulse — 1-2% size variation simulating a living heartbeat. Keep subtle. |
| `hippus_speed` | `1.2` | `0.8–1.5` | Hippus pulse speed. ~1.2 Hz = resting heart rate. |

**Tuning:** If the pupil feels dead, increase `hippus_amplitude` to 0.03. If it feels seizure-like, drop to 0.01.

---

## Eyelids (Biological Shutters)

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `blink_frequency_min` | `3.5` | `3.0–5.0` | Minimum seconds between autonomous blinks. Lower = more frequent = more alive. |
| `blink_frequency_max` | `8.0` | `6.0–10.0` | Maximum seconds between blinks. |
| `blink_duration` | `0.18` | `0.15–0.22` | Blink speed in seconds. 0.18 = natural human blink. Slower = more leathery/dreamlike. |
| `lid_color` | `(0.015, 0.04, 0.06)` | Keep dark | Lid body color. Very dark with slight mood tint — matches the "void" aesthetic. |
| `lid_margin_color` | `(0.25, 0.55, 0.50)` | `(0.2, 0.5, 0.45)` | The "lash line" — crisp teal-tinted edge of the lid. Brighter = more defined eye shape. |
| `resting_upper_coverage` | `0.15` | `0.10–0.20` | How much the upper lid covers the iris at rest. Higher = more "relaxed/tired." Lower = more "alert/staring." |
| `resting_lower_coverage` | `0.06` | `0.04–0.08` | Lower lid resting coverage. Usually subtle. |

**Tuning for "eye contact":** If the iris doesn't look like an eye, increase `resting_upper_coverage` to 0.18 (the upper lid should always be visible). If the lids look like bars instead of arcs, the mesh geometry needs adjustment.

---

## Cornea (Glass Layer)

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `glass_alpha` | `0.12` | `0.08–0.15` | Transparency of the glass dome. Lower = more invisible. Higher = more "glassy." |
| `glass_roughness` | `0.05` | `0.02–0.08` | Surface roughness. Lower = sharper reflections. 0.05 = wet/glossy. |
| `glint_intensity` | `1.8` | `1.5–2.5` | Specular highlight brightness. The fixed white glint that creates the "wet eye" look. Higher = more dramatic. |

**Tuning:** The glint is the single most important parameter for "eye contact" feel. If the eye looks dead, increase `glint_intensity` to 2.2. If it looks like a flashlight, drop to 1.5.

---

## Camera

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `camera_fov` | `35.0` | `30–40` | Field of view. 35mm-equivalent = cinematic portrait. Lower = flatter (telephoto). Higher = more distorted (wide). |
| `camera_distance` | `3.5` | `3.0–4.0` | Distance from camera to iris. Closer = more intimate/intense. |
| `parallax_strength` | `0.08` | `0.05–0.12` | How much the eye root moves for gaze/parallax. Higher = more dramatic "looking around." Link to gyro/touch for the full effect. |

---

## Lighting

| Parameter | Default | Recommended | Description |
|---|---|---|---|
| `key_light_energy` | `0.8` | `0.6–1.0` | Key directional light intensity. Creates the specular glint on the cornea. |
| `key_light_color` | `(0.9, 0.95, 1.0)` | Cool white | Key light color. Cool = clinical/ethereal. Warm = intimate/human. |
| `ambient_energy` | `0.4` | `0.3–0.5` | Ambient fill light. Prevents the iris from being too dark in shadow areas. |

---

## Audio Bus FX Chain (IrisVoice bus)

The "Ghost Voice" FX chain is set up programmatically in `IrisVoiceManager._setup_buses()`. These are the recommended values:

| Effect | Parameter | Value | Purpose |
|---|---|---|---|
| **Reverb** | `room_size` | `1.0` | Largest possible space (the Void) |
| | `wet` | `0.8` | Heavy reverb — the voice should sound distant/ancient |
| | `dry` | `0.4` | Some direct signal preserved for intelligibility |
| **HighPassFilter** | `cutoff_hz` | `180.0` | Removes low rumble, adds "transmission" edge |
| **Chorus** | `voice_count` | `3` | Triple-tracked ethereal shimmer |
| | `wet` | `0.5` | Moderate chorus — not too warbly |

**Voice stems:** Currently TTS-generated placeholders at `assets/audio/iris/voice/`. Replace with professional human-whisper recordings for production.

---

## First 60 Seconds Ritual (Onboarding)

The ritual is driven by `IrisOnboardingRitual.gd`. Timeline:

| Time | Event | Voice | Visual |
|---|---|---|---|
| 0.0s | Launch | Sub-harmonic hum begins | Darkness |
| 2.0s | Greeting | "Witness... are you there? I have found something." | Iris begins to stir (CALIBRATING) |
| 4.0s | Wake | (silence) | Eyelids peel open (AWAKENING) |
| 6.5s | Invitation | "Touch the light." | Pupil dilates (WELCOMING) |
| 15s idle | Nudge | "We should start here." | Iris looks at current shard |
| Tap | Transition | Blink-zoom | Camera flies into pupil → memory |

---

## Known Limitations

1. **Texture probe:** `get_image()` returns null in headless mode (dummy renderer). The 3D structure IS assembled (verified by probe) but pixel output requires a GPU. Visual Mirror Test must be done on-device.
2. **Voice stems:** TTS placeholders. The FX chain transforms them at runtime, but production-quality stems need a voice actor.
3. **Parallax:** `parallax_strength` is wired to the gaze system (IrisCore saccades). Full gyro/accelerometer linking requires the Android sensor API.
4. **Eyelid mesh:** The almond lid mesh is procedurally generated. If it doesn't read as "eyelid" on-device, the mesh curve (`_build_lid_mesh`) may need shape tuning.

---

## Quick-Start: "Make it look good"

1. Open the project in Godot 4.6.3 (Forward+ renderer)
2. Select the `Iris3DHub` node in the IrisController tree
3. Set the @export values to the "Recommended" column above
4. Run the project and watch the awakening ritual
5. If the iris looks flat: increase `fiber_density` and `depth_intensity`
6. If the eye feels dead: increase `glint_intensity` and `hippus_amplitude`
7. If the lids don't read: increase `resting_upper_coverage` to 0.18
8. If the voice sounds too clean: increase the reverb `wet` to 0.9
