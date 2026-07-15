# Two Second Witness 4.0 — First Visit Experience & Rank 1 Progression Arc (`FIRST_EXPERIENCE_DESIGN.md`)

## Executive Summary

The distinction between onboarding and gameplay is foundational to *Two Second Witness 4.0*:
> *"The tutorial must teach the player how to become a Witness. Rank 1 must prove they have become one."*

To avoid traditional pop-ups, arrows, and patronizing software instructions that destroy the Living Lens fantasy, our first visit onboarding—**"The Awakening"** (~60–90 seconds)—is structured as an organic, 4-scene miniature Witness Moment. 

The player discovers how to orient perception, how exact details alter reality, and how the physical eye absorbs memory before any numerical rank is awarded. Only after successfully storing their first observation in the Archive does the observer earn **Rank 1: Observer** and unlock **Chapter 1: Learning to Notice (`WM_001`)**.

---

## 1. The Four-Scene First Visit Progression Arc

```
[Cold Launch: Rank 0 New Observer]
                 │
                 ▼
[Scene 1: Iris Awakening] ──────────────> "Attention is the beginning of memory."
                 │
                 ▼
[Scene 2: Looking Through the Lens] ────> "Something was missed." (Look, don't tap menus)
                 │
                 ▼
[Scene 3: Mini Witness Moment] ─────────> "What changed?" (The reflection shifted)
                 │                                 │
                 │                                 ▼
                 │                         "The smallest detail can change the whole story."
                 ▼
[Scene 4: Return to Iris & Archive] ────> "The Archive has accepted your first observation."
                 │
                 ▼
[Rank 1: Observer Unlocks] ─────────────> Golden Collarette Ignites + Orbiting Shard Spawns
                 │
                 ▼
[Chapter 1: Learning to Notice] ────────> Center Pupil Portal opens to WM_001 & Five Major Moments
```

---

## Scene 1: Iris Awakening (`0s – ~15s`)
### Purpose: *Teach that the Iris is alive and responds to attention.*
- **Visual & Sensory State**: The screen opens from pure atmospheric darkness (`awakening_level = 0.0`). The radial stroma (`base.png` + `fibers.png`) slowly forms and expands as sub-bass respiration (`48 Hz`) swells.
- **Iris Voice**: As the instrument stabilizes, `VoiceGuide` triggers the foundational truth:
  > **"Attention is the beginning of memory."**
- **Discovery Mechanics**: The player is not given written instructions or blinking arrows. As they naturally tilt their device or shift their finger/cursor across the screen (`_on_cursor_moved`), the pupil executes ballistic saccadic snaps (`lerpf` at `14.0x`) toward their pointer, confirming: *The Iris responds to your attention.*

---

## Scene 2: Looking Through the Lens (`~15s – ~30s`)
### Purpose: *Teach that the pupil is a window into hidden moments, not a menu.*
- **Visual & Sensory State**: As the observer moves their gaze toward the center of the eye (`dist_to_center < 0.22`), the dark pupil void clears to reveal a miniature memory preview (`tutorial_memory` / `featured_desk_scene.png`): a small room with a clock and a painter's desk.
- **Iris Voice**: The instrument quietly acknowledges what lies inside the viewfinder:
  > **"Something was missed."**
- **Discovery Mechanics**: The optical title **`THE AWAKENING`** and prompt **`TOUCH TO ENTER FIRST OBSERVATION`** illuminate right below the lens (`destination_title` & `destination_prompt`). The player learns: *Look through the lens to discover destinations; do not search for UI buttons.*

---

## Scene 3: Mini Witness Moment (`~30s – ~60s`)
### Purpose: *Teach the Two Second Witness gameplay loop without penalty or anxiety.*
- **Cinematic Entry ("The Threshold")**: Tapping Center while `onboarding_tutorial_completed == false` dilates the pupil (`0.105 -> 1.40`) and sweeps the camera straight through the portal (`transition.play_enter`) into `TutorialAwakeningScreen.tscn`.
- **The Observation**: A clean, 10-second memory unfolds: a painter places a brush down near a clock and canvas. Two seconds of exact optical detail are highlighted.
- **The Question**: The screen presents one simple, optical inquiry without cartoon answer boxes or timers:
  > **WHAT CHANGED?**
  > `[ THE BRUSH MOVED ]`
  > `[ THE LIGHT CHANGED ]`
  > `[ THE REFLECTION SHIFTED ]`
- **The Revelation**:
  - Selecting `[ THE BRUSH MOVED ]` or `[ THE LIGHT CHANGED ]` emits a soft, gentle acoustic pulse (`focus_notice_tone()`) and subtly dims the incorrect option, guiding the player without "game over" punishment.
  - Selecting **`[ THE REFLECTION SHIFTED ]`** detonates an **Atmospheric Phase Lock chord** (`256 Hz C-G-E resonance`). A luminous golden highlight reveals the hidden reflection on the room canvas, confirming: *The painter noticed a hidden reflection that completed the idea.*
- **Iris Voice**:
  > **"The smallest detail can change the whole story."**

---

## Scene 4: Return to Iris & Rank 1 Unlock (`~60s – ~75s`)
### Purpose: *Embed the memory inside the physical eye and begin Chapter 1.*
- **Cinematic Return ("The Blink")**: After 3.8 seconds of reflection, `TutorialAwakeningScreen` emits `request_return_to_iris`. The eyelid sweeps closed (`transition.play_return` Mode `1.0`), collapses the tutorial scene, and re-opens onto the Living Iris (`"home"`).
- **Archive Acceptance**: `StateManager.complete_onboarding_tutorial()` marks `onboarding_tutorial_completed = true` and elevates `progression_level = 1`.
- **Iris Voice**:
  > **"The Archive has accepted your first observation."**
- **Physical Eye Transformation (Rank 1: Observer Unlocks)**:
  1. The first golden collarette starlight filaments ignite around the inner pupil (`starlight > 0.0`).
  2. `$MemoryFragmentsContainer` spawns `MemoryFragment_0`: a glowing crystalline shard that permanently orbits the aperture at `radius = 162.0 px`.
  3. The optical rank reveal banner (`_show_rank_reveal`) announces:
     > **`RANK 1 : OBSERVER`**
     > *Chapter 1: Learning to Notice unlocked.*
- **Seamless Continuation into `WM_001`**:
  - The central pupil portal (`DestinationPreview`) updates automatically from "The Awakening" to **`CHAPTER 1: LEARNING TO NOTICE`** with the prompt **`TOUCH TO ENTER WITNESS MOMENT`**.
  - Touching Center now dilates the pupil straight into **Witness Moment 001 (`WM_001`)** and the five major challenges of Rank 1!

---

## 2. Summary of Onboarding vs. Chapter 1 Architecture

| Progression Tier | Scene / Screen Anchor | Primary Objective | Numerical Rank Status | Physical Iris Appearance (`progression_level`) |
| :--- | :--- | :--- | :--- | :--- |
| **First Visit (`onboarding == false`)** | `TutorialAwakeningScreen.tscn` | Learn saccadic gaze, lens focusing, and exact observation (`The reflection shifted`). | **Rank 0 (New Observer)** | Clean stroma, pure cyan portal void, `glow_strength = 0.40`. |
| **Rank 1 Unlocked (`onboarding == true`)** | `Main.tscn` -> `IrisScreen` | Absorb first memory fragment into the physical eye and unlock Chapter 1. | **Rank 1: Observer** | Golden collarette ring ignites, 1 orbiting memory shard circling at `162 px`. |
| **Chapter 1 (`completed_obs >= 1`)** | `WitnessMomentRuntime` (`WM_001`) | Complete the five major observation challenges of Chapter 1. | **Rank 1 -> Rank 2** | Multi-spectral stroma enrichment, `glow_strength = 0.70+`, 2–4 orbiting shards. |
