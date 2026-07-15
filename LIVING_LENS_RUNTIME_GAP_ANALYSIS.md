# Two Second Witness 4.0 — Living Lens Runtime Gap Analysis (`LIVING_LENS_RUNTIME_GAP_ANALYSIS.md`)

## Executive Summary

As required by Phase 1 of the Living Lens Runtime Integration Pass, we conducted an empirical evaluation of the current runtime behavior (`Main.tscn`, `IrisController.gd`, `ProceduralSound.gd`, `VoiceGuide.gd`, `TransitionController.gd`, and `MainController.gd`) against the five core emotional and perception criteria defined in our design bibles.

This document inventories every identified runtime gap where the current implementation falls short of the intended "Living Instrument" feeling or exhibits mechanical/gamified behavior.

---

## 1. Evaluation Against Core Criteria

### Criterion 1: Does the player feel they are looking through the Iris?
- **Status**: Partially Implemented / Scale Interaction Gap
- **Empirical Finding**: While `$CorneaLayer` and `$PupilPortalLayer` (`memory_portal.gdshader`) provide 2.5D glass reflection and edge warping, there is a mathematical scaling conflict between `portal_container.scale` and `memory_portal.gdshader` `aperture` parameter during threshold expansion. When `pupil_open` dilates wide, both the node container (`scale = total_aperture / 0.105`) AND the shader mask radius (`aperture * 1.6`) scale simultaneously, causing the portal window to double-scale and lose fixed optical perspective.
- **Root Cause**: `IrisController._update_visual_layers()` multiplies container scale while `memory_portal.gdshader` also scales mask radius.

### Criterion 2: Does the pupil portal reveal meaningful previews?
- **Status**: Partially Implemented / Resting Center Visibility Gap
- **Empirical Finding**: When `active_destination_key` changes (`story_mode`, `archive`, `profile`, `daily_witness`, `calibration`), the texture inside `DestinationPreview` (`$PupilPortalLayer/PortalContainer/DestinationPreview`) switches properly. However, when the eye rests centered on Story Mode (`dist_to_center < 0.14`) without active pointer touch (`interaction_active == false` and `state_mode == 0.0`), `memory_visibility_target` drops to `0.45`. The primary memory inside the pupil appears half-transparent and washed out against the dark portal void (`PortalVoid`), rather than looking like a vivid, living memory scene waiting inside the lens.
- **Root Cause**: `IrisController._update_destination_lens()` clamps center idle visibility to `0.45` instead of maintaining a radiant `0.75+` resting memory window.

### Criterion 3: Does gaze movement reveal destinations naturally?
- **Status**: Visual Implemented / Acoustic Recognition Tone Missing
- **Empirical Finding**: Gaze exploration across cardinal zones (`dist_to_center < 0.14`, `x < 0.28`, `x > 0.72`, `y < 0.28`, `y > 0.72`) correctly updates `active_destination_key` and cross-fades titles (`STORY MODE`, `MEMORY ARCHIVE`, etc.). However, **there is zero acoustic spatial feedback when the Iris recognizes destination attention**. `ProceduralSound.gd` pushes only basic `67 Hz` breath and `184 Hz` focus sine waves; it has no knowledge of `active_destination_key` transitions (`432 Hz` Story bell, `144 Hz` Archive cello, `864 Hz` Discovery prism, `528 Hz` Profile chime, `216 Hz` Calibration hum).
- **Root Cause**: `IrisController` does not emit signals or call `ProceduralSound.emit_destination_recognition()` when `active_destination_key` changes.

### Criterion 4: Does entering Story Mode feel like crossing into memory?
- **Status**: Critical Flow Fragmentation Gap (`StoryModePlaceholder` Bounce-Back)
- **Empirical Finding**: When the player taps Story Mode (`Center`) on the home screen (`IrisScreen`), `MainController._on_tap()` calls `_show_screen("story_mode")`. This initiates "The Threshold" (`transition.play_enter`) but lands the player on a static text screen (`StoryModePlaceholder.tscn`). When the player then taps "TOUCH THE FOCUS POINT TO BEGIN" on that placeholder screen to enter `WM_001`, `_show_screen("witness")` executes `_return_to_iris(func(): _enter_experience("witness"))`—forcing the camera to **play "The Blink" (`play_return`) backwards out of the pupil onto the home screen** before playing "The Threshold" (`play_enter`) a second time into the Witness Moment!
- **Root Cause**: `MainController._show_screen()` forces any non-home screen transition to return through `home` (`_return_to_iris`) before entering the next screen, turning a single continuous memory entry into a 3-part rubber-banding transition.

### Criterion 5: Does returning from a Witness Moment feel like returning to the Iris?
- **Status**: Visual Implemented / Reflection Audio Gap
- **Empirical Finding**: Returning from `witness` (`show_home()`) correctly triggers `transition.play_return` ("The Blink") and calls `iris.remember_recent_activity()` (`recent_alert = 0.65`, directional teaching pulse, and `_sync_progression()`). However, no harmonic reflection resonance audio plays (`ProceduralSound` does not emit a return chord when `remember_recent_activity` occurs), leaving the physical transformation of the eye acoustically unsupported.
- **Root Cause**: `ProceduralSound.gd` lacks a `reflection_tone()` and `awakening_tone()` synthesis pipeline.

---

## 2. Summary of Identified Runtime Gaps

| Gap ID | Category | Description | Target Resolution Phase |
| :--- | :--- | :--- | :--- |
| **GAP-01** | Optical Perspective | `portal_container.scale` and `memory_portal.gdshader` `aperture` double-scale during threshold expansion. | Phase 4 (`IrisController.gd` & `memory_portal.gdshader` refinement) |
| **GAP-02** | Portal Visibility | Center resting memory window (`Story Mode`) is half-transparent (`0.45`) during idle observation. | Phase 4 (`_update_destination_lens` visibility tuning) |
| **GAP-03** | Sensory Audio | No spatial recognition tones (`432 Hz`, `144 Hz`, `864 Hz`, `528 Hz`, `216 Hz`) when gaze shifts to destinations. | Phase 2 (`ProceduralSound.gd` & `IrisController.gd` acoustic binding) |
| **GAP-04** | Threshold Audio | No sweeping anticipation or threshold crossing audio when Story Mode / Witness Moment is entered. | Phase 2 (`ProceduralSound.gd` & `TransitionController.gd` integration) |
| **GAP-05** | Reflection Audio | No harmonic acoustic resonance when returning from a Witness Moment (`remember_recent_activity`). | Phase 2 (`ProceduralSound.gd` return reflection tone) |
| **GAP-06** | Dialogue Foundation | `VoiceGuide.gd` lacks centralized dialogue trigger structure (`NEW_PLAYER`, `IDLE`, `FOCUS`, `WITNESS_COMPLETE`, `RETURN`) with strict cooldown protection. | Phase 3 (`VoiceGuide.gd` & `VoiceProfile.gd` foundation upgrade) |
| **GAP-07** | Emotional Loop (`WM_001`) | Story Mode entry bounces through `StoryModePlaceholder` and plays return blink before launching `WM_001`. | Phase 5 (`MainController.gd` continuous threshold loop) |
