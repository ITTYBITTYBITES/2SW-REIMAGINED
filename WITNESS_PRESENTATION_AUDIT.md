# Witness Experience Presentation Pass Audit

## 1. Current Gameplay Visuals Analysis
- **Current State:** The generic interactive loop (`GenericWitnessGameplay.gd`) is completely functional. It correctly displays backgrounds, overlays action/reveal textures, positions coordinates, and shows lists of clues.
- **Limitation:** Visual transitions are instantaneous. Texture swaps of the background feel sudden and mechanical, and UI panels pop onto the screen with no aesthetic padding.
- **Opportunity:** Introduce fluid cross-fading (cross-dissolve) on background texture swaps, smooth opacity fades for text and control panels, and soft pulsing highlights on interactive elements.

---

## 2. Existing Iris Transitions & Integration
- **Current State:** The Living Iris is present in the Hub and Chapter select, but becomes completely hidden during the active `GenericWitnessGameplay` interactive loop.
- **Limitation:** The player loses the emotional connection with the Iris during active investigations. The Iris feels like a "lobby ornament" rather than an active observer of the memory.
- **Opportunity:** Keep the Iris subtly present as a low-opacity watermark background layer, or pass events to the `IrisPersonalityResolver` during the investigation (e.g. when entering, observing, finding anomalies, succeeding in captures, and resolving the truth). This allows the Iris overlay to breathe and react in real-time.

---

## 3. Sensory Feedback Gaps
- **Misstep Vibration:** Clicking outside the anomaly currently only changes a text label. There is no tactile or visual feedback (like a brief screen vibration or red color flash) to emphasize the timeline desynchronization.
- **Alignment Pulse:** During the timeline capture hold window, the feedback is purely text-based. A glowing timing indicator, button scaling, or shifting progress color will emphasize success.
- **Evidence Gathering:** Completing a clue has no visual flourish. Adding a subtle checkmark scaling flash and border pulse highlights the discovery.

---

## 4. Architectural Integration Points (Sensory Contracts)
- **Audio & Haptic Hooks:** Establish structured sensory contracts directly inside `IrisResponseIntent` so future native sound/haptic engines can hook in without modifying the progression framework.
- **Visual continuity:** Orchestrate smooth state transitions from `Hub` (Settled) -> `Witness Moment` (Observing) -> `Discovery` (Attentive) -> `Completion` (Reflective) -> `Return` (Settled).
