# TWO SECOND WITNESS 4.0 — REGRESSION CHECKLIST

This checklist must be executed before cutting any release candidate. It verifies that the "Engine Feature Freeze v1.0" remains intact while content production scales.

## 1. Automated Pipeline (Headless)
Run the headless regression suite to verify data integrity:
`godot --headless -s tests/regression_test.gd`
- [ ] Core scenes exist and compile
- [ ] Incident Registry manifest parses 100% of defined JSONs without schema failures
- [ ] Witness Director successfully maps all moment definitions
- [ ] Script linting passes without cyclic dependencies

## 2. Interactive Run (Device / Simulator)

### Boot & Readiness
- [ ] App launches directly into `ProductionStartup` splash sequence.
- [ ] On a clean install, the `ExperienceReadinessScreen` displays.
- [ ] Hardware capability queries evaluate correctly (Audio / Haptics).
- [ ] Bypassing or continuing the gate drops the player directly into the `Living Iris` home view.
- [ ] On second launch, the `ExperienceReadinessScreen` is bypassed completely.

### Iris Navigation & Awakening
- [ ] The Iris properly transitions from `DORMANT` to `AWARE` upon startup.
- [ ] Dragging the pupil to peripheral limits highlights valid destinations.
- [ ] Audio/haptic confirmation correctly fires upon focusing on a destination.
- [ ] Releasing focus on the "Story Mode" aperture properly hands off control to the `WitnessMomentOrchestrator`.

### Chapter Execution
- [ ] The system accurately queries `PlayerProgressService` and loads the correct uncompleted incident.
- [ ] **Observation Phase:** Cinematic window executes for exactly the profile duration (e.g., 2.0 seconds).
- [ ] **Reconstruction Phase:** Dragging fragments to ghost outlines correctly anchors items.
- [ ] **Investigation Phase:** Hotspots register taps and incrementally reveal attunements.
- [ ] **Revelation Phase:** Archive data is compiled successfully.

### Scoring & Save/Load
- [ ] Accuracy, Reasoning, and Reconstruction scores mathematically match player performance.
- [ ] Result payload is accurately handed back to `PlayerProgressService`.
- [ ] Player is seamlessly returned to the Living Iris state (`SETTLED` phase).
- [ ] Force-closing and reopening the app verifies `completed_moment_ids` persisted safely to disk.
