# Witness Sensory Production Plan

This plan outlines the design strategy, technical pipelines, and progressive phases to integrate loopable atmospheres, tactile vibrations, and vocal feedback into the stable framework of **Two Second Witness** (Mission 043).

---

## 1. Product Readiness & Sensory Status

- **Current Player-Facing Readiness: ~55% Complete**
  The skeletal mechanics, loading routines, and local database storage are in a perfect, production-ready engineering state. However, the lack of local `.ogg` audio assets and reliance on flat 2D panel layouts results in a silent and vector-drawn experience.
- **The Core Objective:**
  Add the **emotional, auditory, and haptic skin** to the complete technical framework. When completed, the player should immediately feel guided, rewarded, and immersed in a living perception instrument.

---

## 2. Decoupled Sensory Integration Pipeline

Auditory and haptic events execute cleanly through the decoupled manifest architecture with **zero side-effects or hardcoding**:

```text
Moment JSON (wm_001.json - wm_005.json)
          ↓
WitnessAssetManifest (audio_assets)
          ↓
GenericWitnessGameplay (Phase Transitions)
          ↓
IrisAudioConsumer / IrisHapticConsumer (Sensory Trigger)
```

If any file is missing locally, the fallback resolver layer catches the event, prints soft warning notifications to the console, and prevents any runtime crashes.

---

## 3. Recommended Implementation Order

To build the complete sensory experience efficiently, we recommend the following phased deployment schedule:

### Phase 1 — UI & Hub Navigation Cues (Estimated: 1 Week)
- Author high-fidelity feedback sound effects for standard touch components:
  - `ui_neutral_click.wav` (soft mechanical feedback tap).
  - `ui_transition_swoosh.wav` (fluid wind sound for screen swaps).
  - `ui_shard_hover.ogg` (subtle electrical humming loop for memory shard focusing).
- Link these directly to button triggers and the `MemoryField.gd` hover signals.

### Phase 2 — Chapter 1 Ambient Loops (Estimated: 2 Weeks)
- Author five distinct, loopable, loop-continuous Vorbis `.ogg` files setting the unique background atmospheres of `WM_001` through `WM_005`.
- Map them dynamically inside the moment JSON asset manifests.

### Phase 3 — Discovered & Resolved Chimes (Estimated: 2 Weeks)
- Author five satisfying, high-frequency anomaly discovery sound cues.
- Author five swelling, loop-closing resolution chords.
- Connect them to active gameplay completion signals inside `GenericWitnessGameplay.gd`.

### Phase 4 — Iris Voice & Responses (Estimated: 1 Week)
- Author specific abstract hums, melodic swells, or soft whispers representing the Iris's vocal expressions (IDLE, CURIOUS, GUIDING, REFLECTIVE).
- Connect these keys directly to `IrisAudioConsumer` inside `IrisController.present_response_intent()`.
