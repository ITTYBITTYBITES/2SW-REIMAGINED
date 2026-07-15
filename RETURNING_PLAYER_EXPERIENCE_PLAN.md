# Two Second Witness 4.0 — Returning Player Experience Plan (`RETURNING_PLAYER_EXPERIENCE_PLAN.md`)

## Executive Summary

A critical requirement of *Two Second Witness 4.0* is that **no observer ever steps into the same Living Iris twice**. While a new observer (`onboarding_tutorial_completed == false`) encounters the 4-scene **"The Awakening"** mini-Witness tutorial before any numerical rank is awarded (`FIRST_EXPERIENCE_DESIGN.md`), a returning observer (`onboarding_tutorial_completed == true`) must immediately experience:
> *"Recognition and continuation. The Living Iris remembers who I am, where I have been, and how much light we have held together."*

This document defines the architectural and emotional blueprint for the **Returning Witness Session**: the exact differentiation between new and returning players, visual rank evolution from **Rank 1: Observer** up to **Rank 3+ Master Observer**, archive memory embedding, and seamless continuation into Chapter 1 (`WM_001` through `WM_005`) and Daily Witness.

---

## 1. New vs. Returning Witness Session Matrix

| Session Dimension | New Witness (`onboarding_tutorial_completed == false`) | Returning Witness (`onboarding_tutorial_completed == true`) |
| :--- | :--- | :--- |
| **Launch Entry Point** | Cold launch into total darkness (`awakening_level = 0.0`), triggering the 4-scene **"The Awakening"** mini-Witness tutorial (`TutorialAwakeningScreen.tscn`). | Instant entry into the fully awake, living instrument (`awakening_level = 1.0`), pulsating softly at biological equilibrium (`target_energy = 0.35`). |
| **Stroma & Fiber Visuals** | Clean, restrained radial stroma (`base.png` + `fibers.png` at `progression_level = 0`), subtle teal and seafoam cyan hues, `glow_strength = 0.40`. | Enriched multi-spectral stroma (`progression_level = 1 to 4`), intricate golden collarette ring highlights (`starlight`), deep emerald reflections (`glow_strength = 0.55 to 1.0`). |
| **Orbiting Memory Fragments** | `$MemoryFragmentsContainer` is empty (`child_count == 0`). No rank banner appears until the tutorial observation (`Scene 3`) is accepted. | `$MemoryFragmentsContainer` contains orbiting luminous shards corresponding directly to completed moments (`Tutorial`, `WM_001`, `WM_002`, etc.) circling the active aperture. |
| **Acoustic Greeting** | Low-frequency inhalation swell (`initializing.mp3` motif) transitioning to quiet optical focus shimmer for **Scene 1: Awakening**. | Warm, multi-harmonic chord (`first_touch.mp3` recognition motif) layered with sub-bass respiration (`Bus 1`) and crystalline optical resonance (`Bus 2`). |
| **Spoken / Captioned Guide** | *"Attention is the beginning of memory."* (`VoiceGuide.trigger_iris_expression("NEW_PLAYER", "awakening")`). | Suppressed spoken voice or clean, ultra-concise recognition: *"Welcome back, Observer."* (`VoiceGuide.trigger_iris_expression("RETURN")`). |
| **Primary Focal Anchor** | Pupil viewfinder displays **`THE AWAKENING`** with the prompt **`TOUCH TO ENTER FIRST OBSERVATION`**, guiding the player into Scene 3 (`TutorialAwakeningScreen`). | Pupil viewfinder smoothly alternates between **`CHAPTER 1: LEARNING TO NOTICE`** (`WM_001`–`WM_005`) and today's **Daily Witness** (`daily_witness.png`). |

---

## 2. Visual & Sensory Rank Evolution Architecture

As the observer completes The Awakening and advances through the five major Witness Moments of Chapter 1 (`WM_001` to `WM_005`), `IrisController._sync_progression()` translates their exact numerical progress into permanent physical transformations of the eye:

```
[StateManager.onboarding_tutorial_completed] and [StateManager.completed_observations]
                                         │
                                         ▼
                          [_sync_progression() Evaluation]
                                         │
     ┌───────────────────┬───────────────┴───────────────┬───────────────────┐
     ▼                   ▼                               ▼                   ▼
[Rank 0: New Observer] [Rank 1: Observer]       [Rank 2: Witness]     [Rank 3+: Master]
 onboarding = false     onboarding = true        completed_obs = 3+    completed_obs >= 6
 progression = 0        progression = 1          progression = 2       progression = 4
 glow_strength = 0.4    glow_strength = 0.55     glow_strength = 0.70  glow_strength = 1.0
 No Memory Shards       1 Orbiting Shard         2-3 Orbiting Shards   Full Luminous Shards
```

### Detailed Rank Specifications

#### Rank 0: New Observer (`onboarding_tutorial_completed == false`)
- **Stroma Character**: Crisp, pure radial teal fibers (`fiber_speed = 1.0`). No internal golden collarette (`starlight = 0.0`).
- **Aperture & Void**: Deep, dark void (`pupil_portal.png`) with subtle cyan edge lensing (`distortion_intensity = 0.35`).
- **Acoustic Character**: Pure fundamental sine/triangle Hippus respiration wave (`48 Hz`).

#### Rank 1: Observer (`onboarding_tutorial_completed == true`, `completed_observations == 0–1`)
- **Stroma Character**: First delicate golden collarette filaments ignite along the inner pupillary boundary (`iris.gdshader` gold highlight where `d ~ 0.14`). `glow_strength = 0.55`.
- **Memory Shards**: `$MemoryFragmentsContainer` spawns `MemoryFragment_0` (the tutorial reflection shard), slowly circling at `radius = 162.0 px`.
- **Chapter Unlocked**: **Chapter 1: Learning to Notice (`WM_001` through `WM_005`)** becomes the primary center destination.
- **Acoustic Character**: Respiration wave introduces a clean fifth harmonic (`72 Hz`), enriching the sub-bass foundation.

#### Rank 2: Witness (`completed_observations == 2 to 5`)
- **Stroma Character**: Stroma muscle ridges (`radial_ridges`) deepen, catching dynamic emerald and seafoam light during gyroscopic tilt (`sensor_offset`). `glow_strength` elevates to `0.70`.
- **Memory Shards**: 2 to 3 orbiting memory shards rotate in harmonious phase across the outer ciliary zone (`radius = 162.0 to 180.0 px`).
- **Acoustic Character**: Respiration wave introduces an octave overtone (`96 Hz`), creating a rich, resonant acoustic organ.

#### Rank 3+: Master Observer (`completed_observations >= 6`)
- **Stroma Character**: Full multi-spectral bioluminescent evolution (`progression_level = 4.0`, `glow_strength = 1.0`). The golden collarette ring radiates with continuous, organic starburst shimmer (`starlight = sin(ang * 24.0 - time * 0.5)`).
- **Memory Shards**: A full orbital ring of 4+ glowing crystalline memory shards encircles the pupil portal, physically reflecting every major moment collected inside `ArchiveScreen`.
- **Acoustic Character**: Full Luminous Optical Chord—respiration, muscle rustle, and high-frequency crystal resonance (`4.2 kHz`) blend into an unmistakable, premium acoustic signature.

---

## 3. Archive Influence & Parallax Memory Retrieval

When a returning player explores `ArchiveScreen` (`_show_screen("archive")`) and returns to the home instrument (`_return_to_iris()`):
1. **Recent Alertness Memory (`remember_recent_activity()`)**:
   - The Iris does not drop back into a sluggish idle sleep. It holds `recent_alert = 0.65` for 5.5 seconds, maintaining high stroma energy (`target_energy = 0.42`) and bright rim cues (`cue_light`).
2. **Directional Teaching Pulse (`learning_active = true`)**:
   - For 3.4 seconds immediately following the return, the eye executes a gentle, 4-step directional rim sweep (`learning_focus_target` shifting across Left, Right, Down, Up).
   - This reinforces spatial memory without a single word of spoken instruction, reminding the returning observer where each perception point resides.

---

## 4. Seamless Continuation Flow into Chapter 1 & Daily Witness

Returning observers should never face unnecessary friction when resuming their journey:
1. **Instant Recognition**: Upon cold startup where `onboarding_tutorial_completed == true`, `MainController._ready()` immediately loads `_switch_screen("home")` at resting state (`IrisStateManager.CURIOUS` or `IDLE`), completely bypassing `_start_first_launch_intro()`.
2. **Contextual Viewfinder Priority (`_update_destination_lens`)**:
   - If the player has completed the tutorial but has pending moments in Chapter 1 (`WM_001` to `WM_005`), gazing toward Center (`dist < 0.14`) illuminates **`CHAPTER 1: LEARNING TO NOTICE`** with the prompt **`TOUCH TO ENTER WITNESS MOMENT`**.
   - If the player has completed the five major moments of Chapter 1, the center pupil portal (`$PupilPortalLayer/PortalContainer/DestinationPreview`) automatically alternates to displaying **`DAILY WITNESS`** (`daily_witness.png`) with the prompt **`BEGIN TODAY'S OBSERVATION`**, ensuring there is always a fresh, immediate perceptual objective ready at the center of the eye.

---

## 5. Developer Verification Shortcuts (`KEY_5`, `KEY_6`, `KEY_7`, `KEY_8`)

To verify all onboarding and returning states inside `MobileSimulator.gd`:
- Press **`KEY_5`**: Forces `first_launch = true`, `onboarding_tutorial_completed = false`, `completed_observations = 0`, starting Scene 1 of **The Awakening (Tutorial)** from `time = 0.0`.
- Press **`KEY_6`**: Forces `first_launch = false`, `onboarding_tutorial_completed = true`, `completed_observations = 3`, forcing `progression_level = 2` (**Rank 2: Witness**) with orbiting shards.
- Press **`KEY_7`**: Resets all progress (`completed_observations = 0`, `onboarding_tutorial_completed = false`).
- Press **`KEY_8`**: Previews `completed_observations = 10`, forcing `progression_level = 4` (**Rank 3+ Master Observer**) with full `glow_strength = 1.0` and radiant golden collarette starbursts.
