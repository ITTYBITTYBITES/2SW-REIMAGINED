# Witness Visual Polish Roadmap

This document outlines the highest-impact visual and cinematic improvements to elevate the existing 2D interfaces of **Two Second Witness** to a premium, Apple Design Award-tier release quality.

---

## 1. High-Impact UI Polish Upgrades

### 1.1. Translucent Glassmorphism Panels
- **Current State:** Overlay panels (Briefing, Context panel, settings, and Archive details) are flat, solid-color dark ColorRects.
- **Planned Upgrade:** Implement a custom 2D screen-reading blur shader in Godot. This turns flat panels into translucent glass overlays, revealing the procedural, watermarked Living Iris breathing and drifting softly beneath.

### 1.2. Textured Memory Field Shard
- **Current State:** The floating memory shard is a flat, procedural vector polygon.
- **Planned Upgrade:** Replace with a custom glowing, rotating 3D-like crystal sprite sheet or particle emitter. This adds high-fidelity depth to the orbit rotation and represents a true "living memory thread".

### 1.3. Hover Glows & Button Shines
- **Current State:** Interactive button components have solid border outlines and static colors.
- **Planned Upgrade:** Implement smooth hover glows, minor border scaling pulsations, and soft particle trails around active clue items during the Context (Understand) phase. This gives high-fidelity visual affirmation of selection.

---

## 2. Living Iris Presentation Polish

- **Current State:** The procedural `LivingIris.gd` is highly responsive and technically complete, using trigonometric ripples and customizable segments.
- **Does it feel alive?** Yes, the procedural breathing and micro-pulsing look lifelike.
- **Does progression visibly affect appearance?** Yes, the `IrisEvolutionVisualConsumer` successfully scales glow and fiber density relative to Aperture Rank.
- **Visual Improvements Planned:**
  - **Evolution Halos:** On stage evolution (e.g. crossing rank 10 into `ATTUNED`), add a slow-growing Concentric Ring Halo flaring outwards.
  - **Dynamic Saccade Drifts:** Smooth the gaze saccadic tracking transitions with custom easing-out curve models to make movement feel completely organic rather than mathematical.
  - **Environmental Vignettes:** Modulate full-screen vignettes dynamically inside `GenericWitnessGameplay` to draw player focus toward the central anomaly coordinates.

---

## 3. Cinematic Transition Polish

- **Screen Transition swooshes:** Create soft cross-dissolve fades and slide-in folder animations when transition screens are swapped (Hub ↓ Chapters ↓ Archive).
- **Strobe Distortion Effects:** On successful anomaly selection, trigger a high-frequency white strobe flare across the environment, coupled with a dramatic taptic vibration feedback.
