# Witness Sensory Audio Asset Requirements

This document registers the strict technical, structural, and creative specifications for all future audio assets in Chapter 01: "The First Fractures".

---

## 1. Technical Audio Specifications

To ensure optimal, high-fidelity playback and platform-safe performance on both desktop and mobile (Android) systems, all authored sound files must adhere to these technical parameters:

| Asset Type | File Format | Sample Rate | Bit Depth | Loop Behavior | Loudness Target |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Ambient loops** | Vorbis `.ogg` | 44.1 kHz | 16-bit | Seamlessly loopable | -24 LKFS / LUFS |
| **SFX / Cues** | WAV / `.ogg` | 44.1 kHz | 16-bit | Single-shot (Non-loop) | -18 LKFS / LUFS |
| **Vocal Cues** | Vorbis `.ogg` | 44.1 kHz | 16-bit | Single-shot (Non-loop) | -20 LKFS / LUFS |

---

## 2. Creative & Atmospheric Requirements

### 2.1. Ambient Atmosphere Loops
- **`wm001_ambient.ogg` (Painter Studio):**
  Warm, low-frequency studio room tone, soft afternoon wind rustling through an open window, and occasional soft wooden easel creaks.
- **`wm002_ambient.ogg` (Museum Corridor):**
  Echoing, hollow corridor acoustics, a slow rhythmic grandfather clock ticking loop, and soft stone footsteps.
- **`wm003_ambient.ogg` (Dressing Room):**
  Backstage dressing room hush with the distant, muffled low-frequency echo of performance applause and stage doors closing.
- **`wm004_ambient.ogg` (Reactor Console):**
  Steady computer-fan cooling hum and high-tech electronic air-conditioning ventilation hiss.
- **`wm005_ambient.ogg` (The Witness Internal):**
  Biological, rhythmic, low-frequency pulse wave resembling an ocular heartbeat.

### 2.2. Anomaly Discovery Cues
- **`wm001_anomaly.ogg` (Prism Flare):** High-frequency glass crystal refraction chime.
- **`wm002_anomaly.ogg` (Palm Warmth):** Soft, dull mahogany wooden touch click.
- **`wm003_anomaly.ogg` (Latch Snap):** Satisfying mechanical brass travel case click.
- **`wm004_anomaly.ogg` (Grid Bend):** Pitch-bending diagnostic laser grid distortion.
- **`wm005_anomaly.ogg` (Reflection Shift):** Rhythmic ocular focus desynchronization sweep.

### 2.3. Truth Resolution Chords
- **`wm001_resolution.ogg`:** Warm cello crescendo chord.
- **`wm002_resolution.ogg`:** Nostalgic string quintet resolution.
- **`wm003_resolution.ogg`:** Vibrato solo violin holding the final note backstage.
- **`wm004_resolution.ogg`:** Satisfying clean reactor diagnostic boot sweep.
- **`wm005_resolution.ogg`:** Majestic stroma orchestral alignment crescendo.

---

## 3. UI Navigation Feedback
- **`ui_neutral_click.wav`:** Clean, soft mechanical click.
- **`ui_transition_swoosh.wav`:** Low-frequency wind swoosh for card screen transitions.
- **`ui_shard_hover.ogg`:** Loopable, low-intensity electric hum for focusing memory shard.
