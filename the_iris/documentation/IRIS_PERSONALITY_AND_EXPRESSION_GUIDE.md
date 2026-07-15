# Two Second Witness 4.0 — Iris Personality & Expression Guide (`IRIS_PERSONALITY_AND_EXPRESSION_GUIDE.md`)

## Executive Summary

The Living Iris (`VoiceGuide.gd`, `IrisController.gd`, and `ProceduralSound.gd`) is the player's perceptual instrument and guide through *Two Second Witness 4.0*. 

To preserve the dignity and premium atmosphere of the product, we establish strict rules for the personality and expression of the Iris:
> *"The Iris is an intelligent, perceptual instrument. It speaks only when perception needs orientation, confirmation, or quiet encouragement. It never chatters, never nags, and never treats the observer like an incompetent user."*

---

## 1. Core Personality Pillars

### 1. Perceptual Instrument, Not a Chatbot
The Iris does not converse in casual colloquialisms, offer trivia, or provide continuous play-by-play commentary. It is an optical and biological instrument that perceives what the player looks at and responds with exact, economical orientation.

### 2. Economy of Expression
If a non-verbal optical cue (`cue_light` rim illumination or saccadic pupil snap) can convey the message with 100% clarity, **spoken voice is suppressed**. Spoken or captioned voice (`VoiceGuide.gd`) is reserved for significant state transitions, orientation shifts, and moments of profound discovery.

### 3. Calm Authority & Restraint
The tone of the Iris is measured, observant, and quietly encouraging. It never uses exclamation points, urgent warning alarms, or artificial urgency ("Quick! Tap the screen now before time runs out!"). It communicates that time inside a memory can be held (`deep_focus`).

---

## 2. When the Iris Communicates (The Communication Matrix)

### A. When to Guide (Orientation)
The Iris guides only when the observer enters a new dimensional threshold or encounters an uncalibrated state:
- **Cold First Launch (`awakening`)**: *"A place is forming. Look through the lens."*
- **First Touch on Center (`on_first_touch`)**: *"Your attention holds the moment. Enter the memory."*
- **Opening Calibration (`on_calibration_opened`)**: *"Sensors aligned to your posture."*

### B. When to React (Saccadic & Acoustic Acknowledgement)
The Iris reacts immediately and non-verbally to physical and optical interaction:
- **Pointer / Gaze Movement (`_update_gaze`)**: Immediate ballistic saccadic snap (`14.0x`) toward the focus target without speaking.
- **Directional Swipe / Tilt (`update_directional_anticipation`)**: Rim light brightens (`cue_light`) and stroma shimmer (`shimmer`) pulses gently.
- **Hold Center (`on_hold` / `start_deep_focus`)**: Pupil constricts (`pulse = 0.08`), audio low-pass filter sweeps down, and subtle haptic vibration (`12ms`) confirms deep calibration.

### C. When to Acknowledge (Progression & Truth)
The Iris acknowledges the successful completion of an observation or investigation phase with profound restraint:
- **Witness Phase Completion (`on_witness_completed`)**: *"The detail is held as light."* (Or clean crystalline acoustic phase lock with zero spoken words for returning players).
- **Return to Iris (`on_return_from_witness`)**: Stroma fibers warm (`recent_alert = 0.65`), orbital memory fragments rotate into position (`_update_memory_fragments`), and the instrument quietly settles without redundant congratulations.

### D. When to Occasionally Surprise (Living Autonomy)
To ensure the Iris never feels like a predictable mechanical state machine, it exhibits rare, autonomous behavioral surprises during prolonged idle observation (`> 45 seconds of continuous exploration without tapping`):
- **Spontaneous Hippus Deep Breath**: The pupil unexpectedly executes a deep, 2.5x respiration dilation cycle while a distant, harmonic cello overtone resonates.
- **Parallax Memory Drift**: Inside the pupil portal (`$PupilPortalLayer`), a dormant memory reflection momentarily cross-fades into a glimpse of a future, unreleased witness chapter (`WM_002` or `WM_003` teaser) before settling back to Story Mode.

---

## 3. What the Iris Must Never Do (Anti-Patterns)

| What the Iris Must Never Do | Why It Violates Product Identity | Correct Living Lens Behavior |
| :--- | :--- | :--- |
| **Never Explain Everything** ("To select Story Mode, place your finger on the center circle and double tap.") | Reduces a premium perceptual instrument to a patronizing software tutorial. | Illuminate the central rim light (`cue_light`) and display the clean optical prompt **`ENTER WITNESS MOMENT`** inside the pupil. |
| **Never Constantly Narrate** ("You are looking at the Archive. Now you are looking at Profile. Now you are looking at Story Mode.") | Creates auditory fatigue and turns the instrument into a nagging screen reader. | Suppress spoken voice during lateral exploration; let unique spatial acoustic tones (`432 Hz`, `144 Hz`, `864 Hz`) confirm perception. |
| **Never Become a Chatbot** ("Hi there! I am your friendly Iris helper! What would you like to investigate today?") | Destroys the mysterious, biological, and cinematic atmosphere of *Two Second Witness*. | Maintain calm authority and economy of expression: *"A living perception instrument."* |
| **Never Scold or Punish** ("Wrong! That is not where the difference is! Try again!") | Breaks the emotional contract of fair, replayable observation. | If an observation miss occurs, emit a soft, neutral acoustic dampening pulse (`conceal.wav`) and allow the observer to re-attune without verbal reprimand. |

---

## 4. Coordination Between `VoiceGuide.gd` and Non-Verbal Cues

`VoiceGuide.gd` is directly coupled to `IrisController.gd` and `StateManager.gd` (`set_state_manager` and `set_iris`), enforcing a **Hierarchical Sensory Priority**:

```
[Level 1: Non-Verbal Optical Cues] (Immediate, Every Frame)
 ├── Saccadic Snap (`gaze_current`)
 ├── Rim Illumination (`cue_light`)
 └── Parallax Viewfinder Glimpse (`memory_portal.gdshader`)
       │
       ▼ (If and only if optical cue requires secondary confirmation)
[Level 2: Spatial Acoustic Tones] (Immediate, Distinct Frequencies)
 ├── Quartz Bell (`Story Mode - 432 Hz`)
 ├── Bowed Cello (`Archive - 144 Hz`)
 └── Prism Harmonic (`Discovery - 864 Hz`)
       │
       ▼ (If and only if major state transition or onboarding step occurs)
[Level 3: Spoken & Captioned Guidance] (`VoiceGuide.gd` / `CaptionOverlay.gd`)
 ├── "Your attention holds the moment."
 └── "The detail is held as light."
```

By strictly adhering to this 3-level hierarchy, the Living Iris remains intelligent, unobtrusive, and deeply alive across thousands of player sessions.
