# Witness Cinematic Asset and Emotional Pass Audit

## 1. Cinematic Opening Sequence Design
- **Goal:** Transform the instant panel pop of raw loading into an immersive opening sequence: `Darkness` ↓ `Iris awakens` ↓ `Memory forms` ↓ `Player enters moment`.
- **Planned Flow:**
  - **State 1 (Darkness - [0.0s to 1.0s]):** The entire screen remains black. Modulations are `0.0`, and the Iris core rests.
  - **State 2 (Iris Awakens - [1.0s to 2.0s]):** The Iris watermark flares up on screen. The overlay speaks: *"The Iris senses a fractured memory..."*
  - **State 3 (Memory Forms - [2.0s to 3.0s]):** The background environment backdrop procedurally dissolves and materializes under a smooth alpha lerp.
  - **State 4 (Player Enters - [3.0s]):** The cinematic completes. The UI panel and text labels slide into view, and the `"BEGIN OBSERVATION"` button is unlocked.

---

## 2. Investigation Atmosphere & Breathing
- **Biological Memory Pulsations:** Introduce low-frequency sinusoidal breathing on the backdrop `scene_image.self_modulate` and size scale (e.g., `1.0 + sin(Time.get_ticks_msec() * 0.001) * 0.015`), giving the memory an unstable, organic, and lifelike quality.
- **Enhanced Success Ripple:** Tapping the correct anomaly hotspot will trigger a bright, high-frequency white strobe ripple on the environment, paired with a bright pulse on the Living Iris.

---

## 3. Resolution Emotional Payoff
- **The Resonance Swell:** When moving to the `RESOLUTION` phase, the background Iris watermark flares with a brilliant concentric aura.
- **Sustained Reflection Caption:** Displays a sustained, emotionally resonant caption on screen from the Iris: *"The loop has closed. What was broken is now whole."*

---

## 4. Platform-Safe Audio / Lighting Polish
- **Audio Contracts Integration:** Trigger corresponding procedural chimes inside `IrisAudioConsumer` for `evolution_detected`, `anomaly_found`, and `capture_succeeded`.
- **Vignette Lighting:** Modulate vignette intensities dynamically to draw player focus toward the central anomaly.
