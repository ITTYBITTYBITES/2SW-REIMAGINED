# Living Iris Evolution and Progression Visual System Audit

## 1. Existing `IrisEvolutionData` Analysis
- **Current State:** `IrisEvolutionData` stores profile-derived attributes such as `aperture_rank`, `aperture_title`, `resonance_band`, `resonance`, and `completed_moments`. It provides a basic summary snapshot of rank progression but does not have any direct wiring or authority over `IrisCore` or `LivingIris`.
- **Gaps:** Lacks direct properties for scaling complex geometry, depth offset thresholds, biological pulsing variables, and personality alignment descriptors.
- **Solution:** Designed the companion model `IrisEvolutionProfile` to scale these variables dynamically based on `WitnessProgression` and map them into five progressive visual stages.

---

## 2. `LivingIris` Implementation & Visual Systems
- **Drawing Architecture:** `LivingIris` is a procedural 2D visual system utilizing canvas primitives in Godot. It renders the Iris using several distinct draw methods:
  - `_draw_aura`: Draws multiple concentric glowing rings.
  - `_draw_iris_body`: Uses a polygon silhouette with trigonometric waves (ripples) to draw the complex iris shell.
  - `_draw_fibers`: Dynamically generates lines using organic wave bends to simulate muscle fibers.
  - `_draw_pupil`: Draws the dark center and glossy lens reflection glints.
  - `_draw_reflections` / `_draw_calibration`: Applies environmental reflective overlay.
- **Constraints:** Modifying any drawing properties directly in `IrisCore` or `LivingIris` state configurations risks destabilizing the core state transition framework.
- **Integration Strategy:** We created the `IrisEvolutionVisualConsumer` layer. It acts as a middleware, intercepting the base ticking behavior output of the core and scaling the variables (glow, presence, fiber motion, fiber density) dynamically before drawing.

---

## 3. Available State Transitions
- **Current State:** Core transitions between states (`CALIBRATING`, `STIRRING`, `AWAKENING`, `WELCOMING`, `AWARE`, `ATTENDING`, `FOCUSED`, `OBSERVING`, `SETTLED`, `REFLECTIVE`) are governed strictly by the `IrisCore` class.
- **Authority Preservation:** The state transitions and timings are completely protected. Our visual consumer and progress feedback layers do not touch `IrisCore`'s state machine, keeping state authority intact.

---

## 4. Safe Integration Points
- **LivingIris Tick Hook:** Connecting our `IrisEvolutionVisualConsumer` in `LivingIris._process()` is extremely safe. It guarantees that the visual rendering is perfectly aligned with player achievements at all times.
- **Progression Hook:** Using the existing `_on_iris_evolution_changed(data: IrisEvolutionData)` signal connected inside `Application.gd` is the ideal event trigger. We can easily compare the old and new ranks to detect when the player reaches a new stage or aperture tier.
- **Personality Resolution:** The existing `IrisPersonalityResolver` and `IrisResponseIntent` architecture is a flawless avenue for notifying players of their growth. By adding specific feedback triggers (`evolution_detected` / `new_aperture_reached`), the Iris can immediately acknowledge the pattern shift on screen.
