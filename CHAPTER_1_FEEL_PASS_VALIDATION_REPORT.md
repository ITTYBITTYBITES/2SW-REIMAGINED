# Two Second Witness 4.0 — Chapter 1 Runtime Feel Pass & Validation Report (`CHAPTER_1_FEEL_PASS_VALIDATION_REPORT.md`)

## Executive Summary

Following our architectural shift that transformed Chapter 1 (`WM_001` through `WM_005`) from handcrafted standalone demos into a universal **Witness Moment Runtime Machine**, we executed the **Runtime Feel Pass & Player Experience Validation**.

Our primary focus was answering the foundational question:
> *"Does the player experience actually feel like a game, or are they just watching a movie? Does the first 60 seconds communicate the magic of witnessing across all five phases?"*

We conducted an end-to-end feel pass beginning with `WM_001: The Unfinished Canvas` as our primary template, systematically auditing and tuning every friction point, timeout, audio response, and visual indicator across our five shared runtime phases (`WitnessObservationScreen.gd`, `WitnessReconstructionScreen.gd`, `WitnessInvestigationScreen.gd`, `WitnessRevelationScreen.gd`, and `WitnessMomentOrchestrator.gd`).

---

## 1. Five-Phase Runtime Feel Audit & Tuning Matrix

### Phase 1: Arrival & Observation (`WitnessObservationScreen.gd` + `ObservationMomentShader.gdshader`)
- **Pre-Tuning Risk**: Rushed introduction timing. If `narrative_introduction` was long (~7–8s audio reading time), `_intro_duration = 1.5s` forced the 2-second observation window to open and close *while* the introduction narration was still halfway through playing.
- **Runtime Feel Fix**:
  1. **Adaptive Breathing Pause**: `_intro_duration` now dynamically scales to `maxf(3.2, len * 0.055)`, giving the observer a calm, unhurried moment to absorb the introduction (`"Do not look for mistakes. Look for what inspired the stroke."`).
  2. **Optical Pre-Field Attunement**: While `_phase_state == 0` plays, `ObservationMomentShader.gdshader` renders golden dust motes in a locked pre-field (`progress = 0.0`) alongside the breathing prompt:
     > **`PREPARING OPTICAL FIELD... STAY WITH IT. DO NOT NAME WHAT YOU SEE. ONLY NOTICE.`**
  3. **The Two-Second Event**: When `_begin_observation()` (`_phase_state = 1`) initiates, a distinct acoustic focus marker (`sound.focus_notice_tone()`) and haptic pulse (`35ms`) mark the exact start and end of the 2-second window (`_duration = 2.0s`).
  4. **Dissolve Handoff**: Replaced the `0.15s` hard cut with a `0.35s` optical dissolve, giving the physical sensation of closing one's eyes to hold a memory before stepping to Reconstruction.

---

### Phase 2: Memory Reconstruction (`WitnessReconstructionScreen.gd`)
- **Pre-Tuning Risk**: Blind placement guesswork. When dragging a sensory fragment card across the desk/scene (`_update_drag`), the ghost outlines gave zero feedback on hover. Furthermore, dropping a fragment removed the card but left the desk background desaturated and flat.
- **Runtime Feel Fix**:
  1. **Magnetic Target Hover (`_update_drag`)**: As a dragged fragment moves across the scene, `_get_ghost_at_position` continuously checks intersections. When hovering over a valid target (`_hovered_ghost`), that specific outline illuminates with magnetic cyan light (`modulate = Color(0.35, 0.98, 0.88, 1.0)`, `scale = 1.06x`) alongside a 15ms haptic tick and micro acoustic hum (`sound.focus_notice_tone()`).
  2. **Crystalline Placement & Background Restoration (`_place_fragment_on_ghost`)**: Dropping a card onto its ghost triggers our crystalline quartz bell (`432 Hz`) and `35ms` haptic confirmation. Crucially, as more fragments are placed (`_placed_fragments.size()`), the desaturated desk background (`desk_bg`) gradually regains its full warm golden color and sharpness:
     ```gdscript
     var progress_ratio := clampf(float(_placed_fragments.size()) / maxf(float(_ghost_outlines.size()), 1.0), 0.0, 1.0)
     desk_bg.modulate = Color(1, 1, 1, lerpf(0.12, 0.88, progress_ratio))
     ```
     The player physically experiences: *"As I reconstruct what stayed with me, the room's memory comes back to life."*
  3. **Agency & Progress CTA**: Once at least one fragment is placed, `continue_btn` updates dynamically to `[ PROCEED TO INVESTIGATION (%d PLACED) ]`, giving the observer complete agency over when they feel ready to advance.

---

### Phase 3: Investigation (`WitnessInvestigationScreen.gd`)
- **Pre-Tuning Risk**: Button-clicking checklist psychology. Hotspots rendered as static purple circles (`Color(0.6, 0.4, 1.0)`) that opened a bottom text panel when clicked. Furthermore, upon reaching `discovery_threshold` (3 attunements), the screen locked input and forced transition to Revelation after `3.5s`, cutting off further exploration.
- **Runtime Feel Fix**:
  1. **Optical Anomaly Brackets (No Buttons)**: Hotspots now render as subtle, breathing **Optical Refraction Anomalies** (`Indicator`), drawing delicate concentric starlight brackets (`Color(0.35, 0.92, 0.82, alpha)`) that pulse across the scene (`sin(time * 1.5)`).
  2. **Atmospheric Perspective Attunement**: Tapping an anomaly (`_activate_attunement`) shifts `AttunementShader.gdshader` directly into that object's perspective (`thermal` heat map, `skeletal` x-ray, `text` readability, `forensic` UV stain, `trajectory` particle trail, `spectral` rainbow). When the panel closes (`_close_attunement_panel`), the anomaly bracket turns to a soft golden completed mark (`is_completed = true`).
  3. **Threshold Intervention Agency (`_trigger_iris_intervention`)**: When `_completed_attunements.size() >= 3`, the Living Iris speaks (`"You have seen enough. Or you haven't..."`), and after `3.2s`, `_show_continue_prompt()` mounts a clear, rewarding CTA:
     > **`TRUTH UNCOVERED · TAP TO PROCEED TO REVELATION`**
     The observer remains completely free to tap other unexplored anomalies before tapping to advance!

---

### Phase 4: Discovery, Revelation & Reflection (`WitnessRevelationScreen.gd`)
- **Pre-Tuning Risk**: Mismatched attunement labels. Lookups right now defaulted `forensic` attunements to `"Second Cup (Forensic)"`, causing incorrect text if the object was `pocket_watch` (`WM_002`) or `wooden_bow` (`WM_003`).
- **Runtime Feel Fix**:
  1. **Universal Artifact Formatting (`_create_attunement_item`)**: Dynamically constructs `"Object Name (Type)"` (`att_data.object.replace("_", " ").capitalize() + " (" + att_data.type.capitalize() + ")"`), ensuring exact, pristine formatting across all five moments (`WM_001` through `WM_005`).
  2. **Stepwise Acoustic Grounding**: Each carried fragment (`☑` / `☐`) and attunement pops in with `0.15s` staggered easing accompanied by subtle acoustic confirmation ticks (`ProceduralSound`).

---

### Phase 5: Archive & Physical Evolution Hand-off (`WitnessMomentOrchestrator` -> `MainController`)
- **Shared Hand-off Flow**: When Revelation finishes (`_advance_to_phase("archiving")`), `_commit_to_archive()` permanently writes the entry to `ProfileService.profile.witness_archive`, calls `StateManager.complete_observation()`, and plays "The Blink" (`transition.play_return`) back to the Living Iris (`"home"`).
- **Physical Eye Transformation**: Upon blink completion (`_on_transition_finished("return")`), `IrisController._sync_progression()` evaluates `completed_observations` (`1 -> 2 -> 3 -> 4 -> 5`) and:
  1. Ignites additional golden collarette starlight filaments (`starlight` inside `iris.gdshader`).
  2. Spawns the newly earned environment memory shard (`MemoryFragment_N`) into stable orbital rotation around the central aperture inside `$MemoryFragmentsContainer`.
  3. Elevates `glow_strength` (`0.40 -> 0.52 -> 0.64 -> 0.76 -> 1.0`).
  4. At `completed_observations >= 5`, triggers the **Rank 2: Witness** optical announcement banner.

---

## 2. Chapter 1 Universal Runtime Application Table

With `WM_001` validated end-to-end across all five feel phases, our shared runtime machine (`WitnessObservationScreen`, `WitnessReconstructionScreen`, `WitnessInvestigationScreen`, `WitnessRevelationScreen`, and `ObservationMomentShader`) applies this exact grammar across all five chapter moments without a single line of hardcoding:

| Chapter Moment | Phase 1: Arrival (`ObservationMomentShader` Mode) | Phase 2: Reconstruction (`ghost_outlines` -> Palette Snap) | Phase 3: Investigation (`attunement` Anomalies & Shaders) | Phase 4 & 5: Revelation Note & Shard Orbit |
| :--- | :--- | :--- | :--- | :--- |
| **`WM_001`**<br>*The Unfinished Canvas* | Mode 1 (`1.0`): Golden sun motes & mineral spirit vapor near brush. | 7 Desk Outlines (`paused_brush`, `crystal_prism`, `cerulean_tube`, etc.) -> Golden room restore. | `crystal_prism` (Spectral 42° rainbow)<br>`canvas_edge` (Forensic charcoal sketch)<br>`paused_brush` (Trajectory cerulean tip) | *"The brush paused not in hesitation, but in reverence for the light across the linen."*<br>Shard: `wm_001_studio_background.png` |
| **`WM_002`**<br>*The Forgotten Museum* | Mode 2 (`2.0`): Archival dust & halogen security spotlight floor sweep. | 6 Corridor Outlines (`mahogany_case`, `brass_watch`, `palm_imprint`, etc.) -> Museum restore. | `pocket_watch` (Forensic engraved lid)<br>`display_case` (Text bronze plaque)<br>`palm_imprint` (Thermal 80yr warmth) | *"Every night, the guard touched the mahogany frame where his grandfather's name was etched."*<br>Shard: `wm_002_museum_corridor.png` |
| **`WM_003`**<br>*The Last Performance* | Mode 3 (`3.0`): Floating amber rosin dust & vanity mirror bulb voltage flicker. | 6 Dressing Table Outlines (`wooden_bow`, `crimson_case`, `yellow_telegram`, etc.) -> Amber restore. | `yellow_telegram` (Text Western Union)<br>`wooden_bow` (Forensic frayed horsehair)<br>`bach_score` (Spectral circled chord) | *"When the bow settled into the velvet, the final note was already safely across the sea."*<br>Shard: `wm_003_dressing_room.png` |
| **`WM_004`**<br>*The Faulty Reactor* | Mode 4 (`4.0`): Monochromatic `488nm` teal laser deflection & laminar air shimmer. | 6 Cleanroom Console Outlines (`quartz_sensor`, `calibration_key`, `teal_laser`, etc.) -> Cleanroom restore. | `quartz_sensor` (Spectral `0.18mm` lattice strain)<br>`vacuum_gauge` (Thermal `0.04K` spike)<br>`magnetic_seal` (Trajectory `120ms` seal) | *"A fraction of a millimeter on the quartz grid stood between routine calibration and structural loss."*<br>Shard: `wm_004_cleanroom_console.png` |
| **`WM_005`**<br>*The Witness* | Mode 5 (`5.0`): Bioluminescent stroma breathing & orbiting starlight reflections. | 6 Stroma Outlines (`canvas_shard`, `museum_shard`, `performance_shard`, etc.) -> Living Lens restore. | `canvas_shard` (Spectral upper ciliary light)<br>`museum_shard` (Thermal left collarette warmth)<br>`performance_shard` (Trajectory right rim note)<br>`reactor_shard` (Forensic pupil calibration) | *"The instrument and the observer looked into each other and discovered they were holding the same light."*<br>Shard: `wm_005_internal_stroma.png` -> **Rank 2: Witness Unlocks** |

---

## 3. Progression Psychology & Developer Verification Hotkeys (`MobileSimulator.gd`)

Our numeric developer shortcuts (`KEY_5` through `KEY_8`) allow instant verification of the exact psychological state and feel of the observer across all progression tiers:

- **`KEY_5` (Progression Psychology: *"Why should I care?"*)**:
  - Forces New Observer state (`first_launch = true`, `onboarding_tutorial_completed = false`, `completed_obs = 0`).
  - Launches **The Awakening (`TutorialAwakeningScreen.tscn`)**. The observer experiences sub-bass respiration, ballistic saccadic snaps (`14.0x`), and learns how to orient without pop-up boxes before unlocking Rank 1.
- **`KEY_6` (Progression Psychology: *"I understand the loop, give me harder mysteries."*)**:
  - Forces Mid-Chapter 1 state (`onboarding_tutorial_completed = true`, `completed_obs = 3`).
  - Instantly loads **`WM_004: The Faulty Reactor`** (`wm_004_cleanroom_console.png`) onto the center pupil portal with 3 orbiting shards (`WM_001`–`WM_003`). Tapping center sweeps straight through "The Threshold" into our scientific anomaly investigation.
- **`KEY_7` (Progression Psychology: *Full Reset Checklist*)**:
  - Resets all observations and returns stroma to `Rank 0 / Clean`.
- **`KEY_8` (Progression Psychology: *"I changed. The Iris changed."*)**:
  - Previews **Chapter 1 Complete / Rank 2: Witness** (`completed_obs = 10`, `progression_level = 5`, `glow_strength = 1.0`, full orbital shard ring).
  - The center portal displays **`PRESERVED MOMENTS & DAILY ATTUNEMENT`** over `wm_archive_horizon.png`.
