# Chapter 02 Design & Pipeline Validation Overview

This document outlines the detailed creative premise, mechanics, and design metrics for the three new moments of Chapter 02: "The Wider Fractures". Each moment is authored to validate that our dynamic, data-driven content pipeline can scale rapidly without code changes.

---

## 1. WM_006 — The Silent Bell
- **Theme:** Lost Communication / Acoustic Desynchronization
- **Environment:** Stone mountain bell tower overlooking a misty, silent valley.
- **Lore Context:** The bell-ringer pulled the heavy rope, but the booming tone of the massive brass bell echoes across the valley exactly two seconds *before* the hammer strikes the metal rim.
- **Anomaly:** Sound/impact causality inversion.
- **Hotspot Location:** Centered on the bell hammer at `Vector2(200, 300)`, Size: `Vector2(110, 110)`
- **Capture Window:** Opens at `0.50`s, closes at `0.95`s (Hold required: `0.25`s).
- **Evidence Clues:**
  1. `bell_rope` (The Hemp Rope): *The rope stands taut under friction stress.*
  2. `bell_hammer` (The Iron Hammer): *The metal contains no residual impact vibration.*
  3. `misty_valley` (The Misty Valley): *The sound echo returns from the valley before contact.*
- **Resolution Text:** *"What was wrong: the valley echoed with a toll that the bell had not yet rung. Why it mattered: the warning of the coming storm was carried by the wind before the metal could strike."*

---

## 2. WM_007 — The Stopped Chronometer
- **Theme:** Frozen Clockwork / Mechanical Entropy
- **Environment:** Master watchmaker's workshop.
- **Lore Context:** A rare marine chronometer on the workbench has stopped, but its brass balance wheel suddenly oscillates and spins wildly *before* the mainspring uncoils.
- **Anomaly:** Kinetic motion preceding release.
- **Hotspot Location:** Centered on the balance wheel at `Vector2(320, 400)`, Size: `Vector2(95, 95)`
- **Capture Window:** Opens at `1.10`s, closes at `1.50`s (Hold required: `0.30`s).
- **Evidence Clues:**
  1. `mainspring` (The Steel Mainspring): *The mainspring remains fully coiled, holding energy.*
  2. `escapement_gear` (The Escape Wheel): *The gear teeth show zero wear or escape friction.*
  3. `chronometer_face` (The Chronometer Dial): *The second hand counts in reverse, counting future ticks.*
- **Resolution Text:** *"What was wrong: the clockwork gathered momentum while the spring remained locked in stasis. Why it mattered: the chronometer was not measuring the present time. It was measuring the ticking countdown of the watchmaker's final day."*

---

## 3. WM_008 — The Cold Hearth
- **Theme:** Thermodynamic Inversion / Forgotten Warmth
- **Environment:** Fireplace in an abandoned cottage covered in winter ash.
- **Lore Context:** A dry pine log is placed on the cold ashes. Warm heat waves immediately radiate from the hearth and warm the stone floor, exactly three seconds *before* the match is struck.
- **Anomaly:** Thermal emission before combustion.
- **Hotspot Location:** Centered on the pine log at `Vector2(250, 480)`, Size: `Vector2(120, 120)`
- **Capture Window:** Opens at `0.80`s, closes at `1.25`s (Hold required: `0.28`s).
- **Evidence Clues:**
  1. `pine_log` (The Unlit Pine Log): *Waves of dry warmth rise from the cold logs in the grate.*
  2. `struck_match` (The Unstruck Match): *The match remains unburned, holding potential flame.*
  3. `stone_hearth` (The Cold Stones): *The stone floor is warm to the touch, carrying no ash soot.*
- **Resolution Text:** *"What was wrong: the room gathered the warmth of a fire that had not yet been lit. Why it mattered: the hearth was keeping the memory of winter comfort alive, projecting its warmth backward into the cold cottage."*
