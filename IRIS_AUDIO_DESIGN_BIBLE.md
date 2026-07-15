# Two Second Witness 4.0 — Iris Audio & Sensory Design Bible (`IRIS_AUDIO_DESIGN_BIBLE.md`)

## Executive Summary

Audio in *Two Second Witness 4.0* is not a layer of decorative sound effects tacked onto a visual user interface. It is one half of a **Unified Sensory Organism**. 

The legacy "arcade puzzle" sound identity—sharp button clicks, synthetic countdown timers, and loud triumphal "achievement unlocked" jingles—has been completely decommissioned. In its place, we establish a **Biomimetic & Optical Acoustic Language**: a soundscape born from sub-bass organic respiration, crystalline optical resonance, and acoustic space.

When the Living Iris breathes, the acoustic field expands. When the pupil dilates, stereo width opens. When the observer uncovers a hidden detail, audio does not congratulate them like a slot machine—it synchronizes with reality, producing the profound acoustic sensation:
> *"Reality revealed something hidden."*

---

## 1. Acoustic Philosophy & Core Pillars

### 1. Acoustic Biomimicry (Living Instrument)
Every continuous acoustic element stems from natural physiological rhythms. The primary anchor is the **Hippus Respiration Cycle** (~0.18–0.25 Hz), accompanied by micro-saccadic optical focus clicks and low-frequency muscle tension shifts.

### 2. Optical Crystalline Depth
Because the Iris is an optical lens (`$CorneaLayer`), interaction sounds utilize high-frequency, pristine acoustic materials: bowed glass, singing quartz, crystal singing bowls, and delicate optical frequency sweeps (`6 kHz – 14 kHz`).

### 3. Acoustic Gravitation & Silence
Silence is treated as an active sensory element. During moments of extreme visual focus (`deep_focus = 1.0`), ambient background noise is actively filtered and attenuated (`low-pass filter sweep down to 400 Hz`), drawing the player's acoustic attention into a hyper-focused vacuum before the moment of revelation.

---

## 2. Sensory Language Matrix by Category

### A. Iris Presence (Continuous Life & Idle State)
The Iris must never sit in absolute acoustic silence when idle on the home screen (`active_screen == "home"`). It emits a living, layered acoustic signature:

| Sensory Layer | Frequency / Acoustic Material | Trigger / Modulator | Emotional Sensation |
| :--- | :--- | :--- | :--- |
| **Respiration Sub-Bass** | `38 Hz – 58 Hz` warm sub-sine wave with slow amplitude modulation | Synced precisely to `iris.gdshader` `breathe` parameter (`breath_rate = 1.15`) | The instrument has weight, depth, and internal lung capacity. |
| **Stroma Muscle Flow** | Ultra-soft, low-volume organic fluid rustle (`300 Hz – 800 Hz`) | Modulated by `fiber_speed` and `current_energy` (`ProceduralSound.gd`) | Microscopic muscle fibers shifting as the aperture adapts to light. |
| **Optical Resonance** | Extremely faint, shimmering crystalline drone (`4.2 kHz` fundamental) | Amplitude rises slightly during `invitation_amount` pulses | A clean, pristine optical lens resting in equilibrium. |
| **Saccadic Focus Snap** | Short, 12ms dry acoustic micro-tick (`2.8 kHz`) | Fired on the exact frame `_update_gaze()` initiates ballistic saccadic motion | The eye has snapped its attention to a new spatial coordinate. |

---

### B. Navigation & Perception Cues (Replacing UI Buttons)
Generic UI feedback (`ui_click.wav`, `ui_hover.wav`) is replaced by spatial recognition tones that confirm the instrument's awareness of the player's gaze:

| Navigation Event | Acoustic Replacement | Spatial / Stereo Behavior | Emotional Sensation |
| :--- | :--- | :--- | :--- |
| **Gaze Shift toward Story Mode** | Pure, warm mid-frequency quartz bell (`432 Hz`) | Centered (`Pan 0.0`), reverb tail (`1.8s`) | Clear, centered invitation to primary memory. |
| **Gaze Shift toward Archive (Left)** | Deep, resonant cello/woodwind bowed note (`144 Hz`) | Panned `Left -0.65`, rich low-end resonance | Entering a quiet, historic museum of past light. |
| **Gaze Shift toward Discovery (Right)** | Shiring, upward-sweeping optical prism harmonic (`864 Hz -> 1.2 kHz`) | Panned `Right +0.65`, bright airiness | A mysterious, unopened frequency waiting to be tuned. |
| **Gaze Shift toward Profile (Top)** | Ethereal, golden metallic chime (`528 Hz`) | Panned `Center-Up`, slight high-shelf boost | Observing personal rank and evolutionary history. |
| **Gaze Shift toward Settings (Bottom)** | Subtle, low-mid diagnostic calibration hum (`216 Hz`) | Panned `Center-Down`, dry tactile tone | Precision instrument alignment and sensor diagnostic check. |
| **Deep Focus Hold Calibration** | Continuous low-pass sweep dropdown with gentle haptic rumble (`12ms, 0.08 strength`) | Panned `Center`, bass frequencies tighten | Calibrating the lens to the observer's exact focus frequency. |

---

### C. Witness Moment Entry ("The Threshold")
When the observer touches the central focus point to enter Story Mode (`WM_001`), the transition (`TransitionController.play_enter` Mode `0.0`) is accompanied by a three-part cinematic acoustic arc:

1. **Anticipation (`0.0s – 0.25s`)**:
   - As the pupil begins to dilate (`pupil_open: 0.105 -> 0.40`), ambient respiration sub-bass instantly cuts out.
   - A high-tension, rising acoustic suction tone (`60 Hz -> 800 Hz`) pulls inward, mirroring the physical dilation of the aperture.
2. **Threshold Crossing (`0.25s – 0.55s`)**:
   - As `portal_container.scale` expands past `1.8x` and radial chromatic aberration sweeps the display, a deep, multidimensional low-end impact (`first_touch.mp3` sub-boom) detonates.
   - Stereo width instantly widens from `100%` to `150%` (`AudioBusLayout`), giving the visceral sensation of stepping out of a narrow hallway into an open atmospheric environment.
3. **Memory Synchronization (`0.55s – 0.72s`)**:
   - As `WitnessObservationScreen` mounts and attunement begins, the acoustic impact dissolves into the specific environmental ambience of the crime scene (`dust motes, distant room tone, subtle ceramic heat resonance`).

---

### D. Discovery & Revelation (Replacing Arcade Achievements)
When the observer successfully identifies a critical observation detail or completes a reconstruction/investigation phase, the acoustic response must reinforce observation and truth:

| Legacy Arcade Approach (Decommissioned) | Living Lens Acoustic Revelation (`result_settle.wav` / `ProceduralSound`) |
| :--- | :--- |
| Loud, brassy fanfare or bright 8-bit coin/chime jingle (`ui_success.wav`). | **Atmospheric Phase Lock**: A pristine, multi-octave acoustic harmonic (`C-G-E chord at 256 Hz fundamental`) rings out cleanly with zero synthetic distortion. |
| Pop-up banner slide-in sound with jarring UI swoosh. | **Acoustic Clarity**: Background environmental noise momentarily drops (`-6 dB for 0.8s`) while a high-frequency crystalline resonance (`hidden_detail.mp3` tail) sustains. |
| "You Win / Level Complete" voiceover or scoreboard counter tally ding. | **Memory Collapse & Synchronization**: The discovered detail emits a physical acoustic resonance that perfectly matches its material (e.g., warm ceramic thrum for `kitchen_mug`), settling permanently into the observer's awareness. |

---

## 3. Visual + Audio Synchronization Architecture

To ensure the player perceives **one unified organism**, `IrisController.gd`, `MainController.gd`, and `ProceduralSound.gd` operate on strict frame-and-phase synchronization:

```
[iris.gdshader Uniforms]                 [Audio & Haptic Pipeline]
 ├── time & breath_rate (1.15) ────────> Controls Sub-Bass LFO Amplitude & Pitch
 ├── pupil_open / dilation ────────────> Modulates Stereo Width & Reverb Wet Mix
 ├── micro_offset / saccade ───────────> Triggers 12ms Acoustic Saccadic Tick
 ├── glow_strength & energy ───────────> Scales High-Frequency Shimmer Gain (4.2 kHz)
 └── progression_level (0 -> 4) ───────> Unlocks Sub-Harmonic Overtones in Idle Drone
```

### Parameter-to-Audio Mapping Table
- **`pupil_open` (`float`)**: Directly drives the cut-off frequency of the master low-pass filter (`aperture = 0.105 -> 800 Hz LPF`; `aperture = 1.0 -> 20 kHz open full spectrum`).
- **`fiber_speed` (`float`)**: Directly controls the playback rate and grain density of the stroma fluid rustle audio loop.
- **`glow_strength` (`float`)**: Directly sets the gain of the `4.2 kHz` crystalline optical resonance layer (`0.4 -> -18 dB`; `1.0 -> -6 dB`).
- **`progression_level` (`int 0-4`)**: Each rank gained adds one additional acoustic sub-harmonic to the idle respiration chord (Rank 0 = Root note; Rank 1 = +Fifth; Rank 2 = +Octave; Rank 3 = +Major Tenth; Rank 4 = Full Luminous Optical Chord).

---

## 4. Technical Audio Routing & Bus Layout (`default_bus_layout.tres`)

- **Bus 0 (`Master`)**: Full dynamic range, brickwall peak limiter (`-0.3 dBFS`), subtle stereo field widener.
- **Bus 1 (`Iris_Respiration`)**: Dedicated low-frequency sub-bass and stroma muscle bus, routed through soft analog tape saturation and 3-band parametric EQ (`boost at 48 Hz`).
- **Bus 2 (`Optical_Cues`)**: Dedicated high-frequency crystal bell and navigation cue bus, routed through algorithmic hall reverb (`Pre-delay 24ms, Decay 2.1s, High Damping 4.5 kHz`).
- **Bus 3 (`Witness_Environment`)**: Dedicated spatial environment and crime scene audio bus, featuring dynamic ducking sidechained to `Optical_Cues` so navigation and revelation tones always cut through with pristine clarity.
