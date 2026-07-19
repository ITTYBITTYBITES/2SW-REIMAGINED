# Chapter 01 Design — The First Fractures

This document outlines the detailed creative premise, mechanics, and design metrics for the five production Witness Moments of Chapter 01: "The First Fractures". Each moment is fully data-driven, utilizing `WitnessMomentDefinition` and played dynamically under `GenericWitnessGameplay`.

---

## Chapter Overview: "The First Fractures"
Chapter 01 establishes the foundational theme of the series: cause and effect have slipped. The player must use the temporal observation instrument to find the minute discrepancies where consequence precedes actions across multiple human and mechanical systems.

---

## 1. WM_001 — The Unfinished Canvas

### 1.1. Core Premise & Narrative
- **Incident ID:** `INC_UNFINISHED_CANVAS`
- **Theme:** Artistic Hesitation & Temporal Fracture
- **Introduction:** A painter pauses before a sunlit canvas. Do not look for mistakes. Look for what inspired the stroke.
- **Observation Sequence:** The painter's hand lifts the brush, turns toward the studio window, and lowers it untouched as a prism catches the late-afternoon sun.
- **The Two-Second Anomaly:** The sunlit spectrum breaks across the linen canvas *before* the prism is fully struck by the sunlight.

### 1.2. Interactive Parameters & Timing
- **Observation Duration:** 2.0 seconds
- **Anomaly Hotspot:** Centered on the prism at `Vector2(350, 366)`, Size: `Vector2(94, 94)`
- **Capture Window:** Opens at `0.92` seconds, closes at `1.26` seconds (Hold duration required: `0.26` seconds)
- **Misstep warning:** *"Not there. Watch the light, not the painter."*

### 1.3. Evidence Chain & Reconstruction Nodes
1. **The paused brush (`paused_brush`):** *The brush paused before the color could be true.* (Aligns the tactile brushstroke).
2. **The crystal prism (`crystal_prism`):** *The prism had not yet received the sun.* (Maps the light vectors).
3. **The color notes (`color_notes`):** *A note reads: wait for the 5:14 light.* (Provides absolute chronological verification).

### 1.4. Resolution & Rewards
- **Truth Resolution:** *The canvas was not abandoned; it was waiting for the light.* (Cause and effect reversed).
- **Resonance Reward:** Base completion `20`, Accuracy weight `15`, Unassisted bonus `6`.
- **Mastery Condition:** Complete unassisted, achieving $\ge 95\%$ accuracy on replay.

---

## 2. WM_002 — The Forgotten Museum

### 2.1. Core Premise & Narrative
- **Incident ID:** `INC_FORGOTTEN_MUSEUM`
- **Theme:** Ritual Remembrance & Causal Imprinting
- **Introduction:** A night guard crosses a quiet museum corridor and rests his palm on a display case for one deliberate second.
- **Observation Sequence:** The guard slowly approaches, checks his pocket watch, and presses his palm against the mahogany-framed glass.
- **The Two-Second Anomaly:** The warm handprint print appears on the glass surface *before* the guard's palm makes contact.

### 2.2. Interactive Parameters & Timing
- **Observation Duration:** 2.0 seconds
- **Anomaly Hotspot:** Centered on the glass pane at `Vector2(220, 410)`, Size: `Vector2(100, 100)`
- **Capture Window:** Opens at `0.75` seconds, closes at `1.15` seconds (Hold duration required: `0.30` seconds)
- **Misstep warning:** *"Not that. Look at the glass exhibit case."*

### 2.3. Evidence Chain & Reconstruction Nodes
1. **The pocket watch (`pocket_watch`):** *The watch is ticking exactly one second ahead.* (Chronological drift).
2. **The case frame (`case_frame`):** *The mahogany wood shows fresh friction heat.* (Tactile contact).
3. **The exhibition ticket (`ticket`):** *The ticket date shows daily attendance for forty years.* (Long-term emotional resonance).

### 2.4. Resolution & Rewards
- **Truth Resolution:** *The glass collected the warmth of a touch that had not yet occurred. The guard's daily remembrance had worn a groove directly through the passage of time.*
- **Resonance Reward:** Base completion `20`, Accuracy weight `15`, Unassisted bonus `6`.
- **Mastery Condition:** Uncover all 3 evidence clues, complete unassisted on replay with $\ge 95\%$ accuracy.

---

## 3. WM_003 — The Last Performance

### 3.1. Core Premise & Narrative
- **Incident ID:** `INC_LAST_PERFORMANCE`
- **Theme:** Transatlantic Echo & Music Finality
- **Introduction:** Backstage after the final applause, a violinist rests a bow in velvet and notices a telegram on the dressing table.
- **Observation Sequence:** The violinist enters the quiet room, unlatches the case, and lays down the bow while noticing a dry telegram already changing.
- **The Two-Second Anomaly:** The travel case latch unclicks and pops open *before* the violinist reaches out to touch it.

### 3.2. Interactive Parameters & Timing
- **Observation Duration:** 2.0 seconds
- **Anomaly Hotspot:** Centered on the case latch at `Vector2(280, 390)`, Size: `Vector2(110, 110)`
- **Capture Window:** Opens at `0.85` seconds, closes at `1.30` seconds (Hold duration required: `0.35` seconds)
- **Misstep warning:** *"Not there. Watch the velvet case on the dressing table."*

### 3.3. Evidence Chain & Reconstruction Nodes
1. **The horsehair bow (`violin_bow`):** *The bow retains the final note's vibration.* (Acoustic finality).
2. **The telegram message (`telegram_desk`):** *The ink is dry, but the text changes.* (Reception before performance completion).
3. **The brass case (`travel_case`):** *The latch carries safe transatlantic postmarks.* (Verification of spatial journey).

### 3.4. Resolution & Rewards
- **Truth Resolution:** *When the bow settled into velvet, the final note was already safely across the sea.*
- **Resonance Reward:** Base completion `20`, Accuracy weight `15`, Unassisted bonus `6`.
- **Mastery Condition:** Replay, maintain high unassisted record with all 3 evidence nodes collected.

---

## 4. WM_004 — The Faulty Reactor

### 4.1. Core Premise & Narrative
- **Incident ID:** `INC_FAULTY_REACTOR`
- **Theme:** Quantum Shift & Mechanical Failure
- **Introduction:** A cleanroom console waits under diagnostic light. Witness the fraction of a millimeter that must not be missed.
- **Observation Sequence:** The physicist approaches the console, fits the calibration key, and observes the quartz grid line.
- **The Two-Second Anomaly:** The laser diagnostic line bends and curves across the grid screen *before* the key is rotated.

### 4.2. Interactive Parameters & Timing
- **Observation Duration:** 2.0 seconds
- **Anomaly Hotspot:** Centered on the screen grid at `Vector2(190, 320)`, Size: `Vector2(120, 120)`
- **Capture Window:** Opens at `0.60` seconds, closes at `1.05` seconds (Hold duration required: `0.28` seconds)
- **Misstep warning:** *"Not there. Focus on the central quartz grid display."*

### 4.3. Evidence Chain & Reconstruction Nodes
1. **The calibration key (`calibration_key`):** *The key shows a fresh microscopic indentation.* (Pressure stress matches grid offset).
2. **The quartz grid (`quartz_grid`):** *The grid registers a spatial anomaly index.* (Causal console breakdown).
3. **The diagnostic laser (`laser_sensor`):** *The laser wavelength is shifted toward blue.* (Temporal blueshift).

### 4.4. Resolution & Rewards
- **Truth Resolution:** *The console was reading the future pressure of a reactor that had already failed.*
- **Resonance Reward:** Base completion `20`, Accuracy weight `15`, Unassisted bonus `6`.
- **Mastery Condition:** Achieve perfect timing hold with zero missteps ($\ge 95\%$ accuracy).

---

## 5. WM_005 — The Witness

### 5.1. Core Premise & Narrative
- **Incident ID:** `INC_THE_WITNESS`
- **Theme:** Ocular Feedback & Recursive Attention
- **Introduction:** Inside the instrument itself, light moves through the stroma and returns the observer's gaze.
- **Observation Sequence:** Fine strands of colored stroma gather around an aperture, pulsing like a living iris, returning gaze.
- **The Two-Second Anomaly:** The central glint and reflection in the aperture move *before* the observer changes their attention point.

### 5.2. Interactive Parameters & Timing
- **Observation Duration:** 2.0 seconds
- **Anomaly Hotspot:** Centered on the dark aperture lens at `Vector2(250, 450)`, Size: `Vector2(130, 130)`
- **Capture Window:** Opens at `0.90` seconds, closes at `1.35` seconds (Hold duration required: `0.32` seconds)
- **Misstep warning:** *"Not there. Watch the center lens, not the borders."*

### 5.3. Evidence Chain & Reconstruction Nodes
1. **The stroma strands (`internal_stroma`):** *The strands glow with returning light.* (Aesthetic reflection of the Living Iris).
2. **The returning light (`returning_light`):** *The light is blue-shifted, carrying future focus.* (Feedback loop completion).
3. **The central aperture (`central_lens`):** *The lens centers around an empty point of origin.* (Focus alignment complete).

### 5.4. Resolution & Rewards
- **Truth Resolution:** *The instrument and the observer looked into each other and discovered they were holding the same light.*
- **Resonance Reward:** Base completion `20`, Accuracy weight `15`, Unassisted bonus `6`.
- **Mastery Condition:** Perfect unassisted completion (Level 4 Mastery).
