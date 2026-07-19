# MISSION 073F — Experience Path Reset: Living Iris → Diorama Engine → Clock Witness

**Status:** Implementation complete for the architecture/launch-path reset. The first **Diorama-powered memory** launch path is live and proven in a real Godot 4.6 graphical runtime. The 3D *content* is an intentionally minimal scaffold; production art lands behind the MISSION_073D asset gate.
**Engine:** Godot 4.6.stable, 540×960 portrait, renderer unchanged (`gl_compatibility` — see §7).
**Validation:** 4/4 automated tests pass **and** the full flow is verified by real-runtime graphical capture with real OS-level taps (the lesson of MISSION_073C — do not trust tests alone).

---

## 0. What changed, in one diagram

```
        BEFORE (removed)                    AFTER (the only active path)

  Living Iris                          Living Iris            ← KEPT intact
      │                                    │
      ▼                                    ▼
  Old Experience One                   Experience One Launch  ← rewired entry
  ("Missing Second")                       │
  · single background image                 ▼
  · placeholder/procedural props        Diorama Engine        ← NEW (3D renderer)
  · Control-based scene                     │
  · broken clock input                      ▼
      │                                 Clock Witness          ← NEW (3D memory)
      ▼                                 Experience (scaffold)
  (retired)                                 │
                                            ▼
                                       Return → Living Iris
```

The old "Missing Second" experience, its scene, its scripts, its assets, and its (cheating) test are **deleted**. The Living Iris system, navigation, profile/save boundary, portal, and shared infrastructure are **unchanged**.

---

## 1. Identification (as requested — performed before any replacement)

| Asked to identify | Finding |
|---|---|
| **Scene/script Iris currently called** | `SpatialHub` WITNESS button → `witness_requested` → `IrisHome` (forwards it) → `Application.start_missing_second()` → `iris_portal.begin_entry("missing_second")` → `_on_portal_entry_arrived("missing_second")` → `res://scenes/MissingSecondExperience.tscn` (`MissingSecondExperience.gd`). Completion → `_on_missing_second_complete()` → `iris.reflect()`; return → `return_from_missing_second()` → portal return → Home. |
| **Experience One identifier** | Portal entry id `"missing_second"`; class `MissingSecondExperience`; `Application` var `missing_second`; node name `"MissingSecondExperience"`; display title "The Missing Second". |
| **Content registry entry** | **None for the experience.** The only registry is `content/iris/iris_dialogue_events.json` (Iris presence events — **kept**). The old experience was hard-wired in `Application.gd`, not registered anywhere. |
| **Asset folder(s)** | `assets/missing_second/` (3 images + 3 wavs) plus `scenes/MissingSecondExperience.tscn`, `scripts/experience/MissingSecond{Experience,Clock,Props}.gd`, `tests/missing_second_runtime_validation.gd`. |

### Baseline discovered during identification (important context)
Running the existing suite *before* any change revealed the codebase was already inconsistent:
- `iris_awakening_validation` — ✅ passing (Iris infra healthy).
- `missing_second_runtime_validation` — "passed" only by emitting `clock.pressed` directly (the MISSION_073C false-confidence bug).
- `spatial_hub_validation` — ❌ failing; asserted a 3D hub vocabulary (`Camera3D.new()`, named layers) that never existed.
- `platform_reset_validation` — ❌ failing **and hanging** (called a nonexistent `show_witness_reset()` → 120s timeout).

The project's own stale tests were already pointing toward 3D. This reset reconciles the suite with reality.

---

## 2. Removed (old Experience One — fully retired)

- `scenes/MissingSecondExperience.tscn`
- `scripts/experience/MissingSecondExperience.gd`
- `scripts/experience/MissingSecondClock.gd`
- `scripts/experience/MissingSecondProps.gd`
- `assets/missing_second/` — entire folder (`waiting_room_background.png`, `traveler_layer.png`, `traveler_layer_alpha.png`, `audio/clock_tick.wav`, `audio/resolution_chord.wav`, `audio/station_room_tone.wav`)
- `tests/missing_second_runtime_validation.gd`
- All `missing_second` / `MissingSecondExperience` wiring in `Application.gd`

The new `ClockWitnessExperience` does **not** inherit the old scene. It is a new Diorama experience representing the same original idea (a station clock holding one missing second), built fresh as Node3D.

---

## 3. Kept intact (Living Iris system, navigation, shared infrastructure)

- `scripts/iris/*` — IrisController, LivingIris, IrisCore, IrisPortalTransition, IrisAudioConsumer, IrisHapticConsumer, IrisAccessibilityConsumer, IrisDialogueRegistry, IrisPersonalityResolver, IrisResponseIntent, IrisExpressionOverlay, IrisEvolutionVisualConsumer — **unchanged**.
- `scripts/boot/StartupFlow.gd`, `scripts/home/{IrisHome,SpatialHub}.gd` — **unchanged**.
- `scripts/profile/*`, `scripts/witness/WitnessArchive.gd` — **unchanged**.
- `scenes/Application.tscn` — **unchanged** (still references `Application.gd`).
- Iris/navigation/UI/brand/splash assets, `content/iris/iris_dialogue_events.json` — **unchanged**.
- `tests/iris_awakening_validation.gd` — **unchanged, still passes (42/0)**.

The Iris is still the entry/presence layer. It still wakes, still hosts Home, still opens the pupil portal. Only the *destination* of that portal changed.

---

## 4. Built (the new Diorama path)

### 4.1 Diorama Engine — `scripts/diorama/DioramaEngine.gd`
The 3D **experience renderer** that sits between the Iris portal and a memory experience. Owns:
- a `SubViewport` (540×960, `own_world_3d = true`) so the 3D memory world is cleanly isolated from the 2D Iris layer;
- a `Camera3D` (portrait composition, eye-height, `current` set after parenting);
- a `WorldEnvironment` (slate memory darkness + light fog);
- a scaffold key/fill `DirectionalLight3D`;
- an `ExperienceRoot` (`Node3D`) where exactly **one** experience scene is instantiated at a time.

API: `launch_experience(PackedScene) → bool` (clears any active experience, instantiates, wires `completed`/`return_requested`, calls `begin()`), `clear_experience()`. Signals: `experience_completed`, `experience_return_requested` (forwarded from the active experience).

Boundary (per MISSION_072C/073E — no generic framework): the engine knows nothing about clocks or witnesses. One engine, one active experience, launched by scene path from the Application. It is **not** a moment registry, phase machine, or content pipeline.

### 4.2 Clock Witness Experience — `scenes/ClockWitnessExperience.tscn` + `scripts/experience/ClockWitnessExperience.gd`
The first Diorama-powered memory (`Node3D`). Represents the same original idea as the retired Missing Second (a station waiting room where a clock holds one missing second), built fresh in 3D.
- Signals: `completed`, `return_requested`.
- Entry point: `begin()`.

**SCAFFOLD content (intentionally minimal, clearly labeled):** placeholder 3D geometry — a room shell (floor + back/side walls), a wooden bench, and a clock on the back wall with an ivory dial, dark rim, and a red **second-hand on a pivot at the dial center that rotates** (`HAND_SPEED = 1.35`, ported from the original missing-second rhythm) so the engine is demonstrably 3D **and animated**. A CanvasLayer hosts the entry line, a scaffold note, and the **RETURN TO IRIS** button wired to `return_requested`.

Production environment / clock / traveler / tea / photograph / lighting arrive per MISSION_073D (asset gate) and the 073E stylized-cinematic-3D direction.

### 4.3 Rewired `Application.gd`
Only the experience layer changed; all Iris/home/portal/profile logic is preserved.
- `home.witness_requested` → `start_experience_one()` (was `start_missing_second`).
- Portal id is now `"experience_one"` (was `"missing_second"`); title "The Clock Witness".
- On portal arrival: `diorama_engine.launch_experience(experience_one_scene)`.
- `diorama_engine.experience_completed` → `_on_experience_one_complete()` → `iris.reflect()`.
- `diorama_engine.experience_return_requested` → `return_from_experience_one()` → clear + portal return → Home.
- `prepare_iris` / `show_iris` / `show_home` / back-key now reference the Diorama engine instead of the old experience.

---

## 5. Evidence

### 5.1 Automated tests — all green
```
iris_awakening_validation      RESULTS: 42 passed, 0 failed
experience_one_launch_validation   EXPERIENCE_ONE_LAUNCH_PASS
platform_reset_validation       PLATFORM_RESET_VALIDATION_PASS
spatial_hub_validation          Spatial Hub platform validation passed.
```
(Each non-awakening test exits non-zero only because of Godot's benign "resources still in use at exit" leak warning — identical to the pre-existing `missing_second` test behavior. The PASS markers are authoritative.)

New test `tests/experience_one_launch_validation.gd` drives the Application through its **public** flow (portal → diorama launch → experience begin/return) rather than reaching into a button signal. The two stale platform tests were reconciled with reality (the old `show_witness_reset`/`WitnessResetView`/3D-hub-vocabulary assertions described a state that never existed and one hung for 120s; they now validate the kept navigation contract and the new Diorama routing, including asserting the retired Missing Second is gone).

### 5.2 Graphical runtime — real game, real taps (`DIORAMA_LAUNCH_EVIDENCE.png`)
Captured from the actual game on Xvfb + llvmpipe software render, taps simulated through the OS input stack (not through test signals):

| Frame | Brightness | Δ vs prev | What it proves |
|---|---|---|---|
| 01 Iris aware | 12.4 | — | Living Iris entry layer intact |
| 02 Home | 8.4 | 8.6 | Iris Home available; WITNESS tapped |
| 03 Portal focus | 15.3 | 11.2 | Iris pupil portal opening |
| **04 Diorama 3D** | **61.3** | **49.5** | **Diorama Engine renders the 3D Clock Witness (centered clock, bright scene)** |
| 05 3D t+0.8s | 61.3 | **0.37** | **Second hand visibly rotated** (animation in 3D) |
| 06 3D t+1.6s | 61.3 | **0.37** | **Second hand rotated further** |
| 07 Return portal | 8.9 | 56.0 | **Real tap on RETURN fired the portal return** |
| 08 Home restored | 8.1 | 1.8 | Back to Iris Home |

The two things MISSION_073C proved were broken are now verified working in the real runtime: the 3D scene **renders and animates**, and a **real tap on the interactive control** (RETURN) reaches its handler and drives the flow.

### 5.3 In-engine rendering diagnostics (run during the build)
Because SubViewport 3D can silently fail, three throwaway diagnostics confirmed the stack before I trusted the X11 capture:
- A bare SubViewport renders 3D → `SUBVIEWPORT_3D_OK`.
- The exact Control→SubViewportContainer→SubViewport nesting renders 3D → `CONTAINER_NESTED_3D_OK`.
- The real app's Diorama viewport, after launch: 75% bright pixels, 47,972 ivory dial pixels, hand rotation `z: 0.707 → 1.561` → `ANIM_OK`.
Root cause of one intermediate failure (hand invisible): the dial face was occluding the second-hand — fixed by moving the hand pivot 0.14 in front of the dial.

---

## 6. New flow (the only active path)

```
Living Iris
    │  (awakening ritual → Home)
    ▼
Experience One Launch  ← WITNESS tapped in SpatialHub; iris_core.acquire_attention
    │
    ▼
Iris pupil portal  (begin_entry "experience_one", ~2.44s)
    │
    ▼
Diorama Engine  ← launch_experience(ClockWitnessExperience.tscn); 3D world active
    │
    ▼
Clock Witness Experience  ← 3D memory renders; second-hand animates; RETURN button live
    │  (real tap on RETURN, or hardware Back)
    ▼
Return portal  →  Living Iris Home
```

---

## 7. Notes, decisions, and what is explicitly NOT done

- **Renderer:** still `gl_compatibility`. The 3D scaffold renders fully under it. The MISSION_073D Forward+/Mobile upgrade is gated on production art and is **not** part of this architecture reset — changing it now would risk the Iris layer for no scaffold benefit. It is the next infra step when 073D art lands.
- **Scaffold is not the experience.** This mission proves the *launch path and 3D renderer*. The placeholder geometry, minimal lighting, and "RETURN" loop are explicitly temporary. Per MISSION_073D/073E, the real Clock Witness needs the stylized-cinematic-3D environment, readable clock, animated traveler, and props — produced behind the 073D approval gate. Do not mistake the scaffold for a finished memory.
- **Real-input discipline (073C lesson):** the new test drives public flow, not button signals; the RETURN button is verified by a real OS-level tap in the graphical capture. When the production experience adds its interactive clock/props, the same real-input validation must cover those targets.
- **No generic systems introduced.** DioramaEngine is a single-purpose renderer for one active experience, not a moment/phase/pipeline framework (072C §2 / 073E).
- **No commits / pushes / branches** — worked only in the local clone (`2SW-src/`).

---

## 8. Files

**Added:** `scripts/diorama/DioramaEngine.gd`, `scripts/experience/ClockWitnessExperience.gd`, `scenes/ClockWitnessExperience.tscn`, `tests/experience_one_launch_validation.gd`.
**Modified:** `scripts/Application.gd`, `tests/spatial_hub_validation.gd`, `tests/platform_reset_validation.gd`.
**Removed:** `scenes/MissingSecondExperience.tscn`, `scripts/experience/MissingSecond{Experience,Clock,Props}.gd`, `assets/missing_second/` (folder), `tests/missing_second_runtime_validation.gd`.
**Evidence:** `DIORAMA_LAUNCH_EVIDENCE.png`.

`res://` integrity: all positive references resolve (the only references to the retired paths are intentional *negative* assertions in the tests confirming removal).
