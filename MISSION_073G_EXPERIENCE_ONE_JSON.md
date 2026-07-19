# MISSION 073G — Experience One: JSON-Driven Missing Second via Diorama Engine

**Status:** Implementation complete. The renderer-validation ClockWitness scene is replaced by a JSON-driven Experience One that recreates the original Missing Second Witness Moment. The Diorama Engine is preserved and extended into a generic, data-driven assembler. All experience-specific data lives in one JSON definition.
**Engine:** Godot 4.6.stable, 540×960 portrait.
**Validation:** 4/4 automated tests pass **and** the full experience is proven in a real graphical runtime with real OS-level taps (`EXPERIENCE_ONE_JSON_EVIDENCE.png`).

---

## 0. What changed

| Before (073F) | After (073G) |
|---|---|
| `ClockWitnessExperience.tscn` + `.gd` — a renderer-validation scene with hardcoded box geometry and a rotating hand. | **Removed.** |
| `DioramaEngine` assembled a fixed scaffold (hardcoded camera, env, light, key light). | **Preserved + extended.** The engine is now a generic assembler that builds environment, lights, camera, objects, timeline, and interactions from a JSON definition. |
| Experience content (the clock, the hand, the room) lived in GDScript. | **All experience-specific data moved to `content/experience_one/experience_one.json`.** |

The engine contains **zero** experience-specific knowledge — no clock, no "missing second", no waiting room, no traveler. Every such fact is expressed in JSON and assembled at launch.

---

## 1. Architecture

```
Living Iris (entry/presence — KEPT)
    │  WITNESS tapped
    ▼
Application.start_experience_one()  →  Iris portal  (KEPT)
    │  entry_arrived
    ▼
DioramaEngine.launch_experience(definition_path)   ← GENERIC, JSON-driven
    │  reads content/experience_one/experience_one.json
    │  assembles: environment, camera, lights, objects, interactions
    │  drives:    timeline (forming→observing→reconstructing→investigating→resolving)
    ▼
Experience One: The Missing Second  (the data, not code)
    │  correct interaction (clock) → resolution → RETURN
    ▼
Return → Living Iris
```

### The Diorama Engine (preserved role, data-driven internals)
`scripts/diorama/DioramaEngine.gd` keeps its role as the 3D renderer between Iris and a memory (SubViewport with `own_world_3d`, Camera3D, WorldEnvironment, ExperienceRoot). What changed: it no longer hardcodes any scene. Its new generic capabilities, driven entirely by the definition:

- **Mesh primitives:** `box`, `cylinder`, `sphere`, `plane`, `group`, `pivot` (with nested children).
- **Lights:** `directional`, `spot` (with range/angle/shadow).
- **Camera:** position + FOV + look_at.
- **Environment:** background, ambient, fog.
- **Timeline:** a list of phases; each phase has a `mode` (`animate`/`freeze`), a duration, and `animations`. Generic animation primitives: `lerp`, `lerp_delayed`, `rate`, `rate_with_jump` (a continuous advance plus a discrete jump at a time — this is how the missing-second is expressed, generically), `ease_back_by` (ease a frozen value back — how the hand realigns), `event`.
- **Interactions:** definition declares targets with hit radii and outcomes (`wrong`/`correct`); the engine does camera-projected screen-space hit-testing on real taps and dispatches to outcomes.
- **State machine:** driven by the phase list (`forming`/`observing`/`reconstructing`/`investigating`/`resolving`), with freeze-snapshot/resume and resolution beats (reveal photograph, show truth, complete).

### Experience One definition
`content/experience_one/experience_one.json` — the complete Missing Second:
- Camera (eye-height, portrait), environment (slate darkness + fog), lights (warm key + amber platform sweep spot).
- Objects: room shell (floor/walls/window glow), bench, **station clock** (rim + ivory dial + hour/minute/**second** hand on a pivot + hub), **traveler** (composite figure: legs/body/head/arm), suitcase, tea cup + saucer + **steam** wisps, **photograph** (with reveal state).
- Interactions: tea/suitcase/photograph (wrong, contextual lines) + clock (correct → resolution).
- Text: the four canonical Missing Second lines + resolution truth + return label (carried verbatim from MISSION_072).
- Timeline: forming(1.25s fade) → observing(2.0s living — traveler slides, **second hand advances at 1.35× with the missing-second jump at t≥0.95**, platform light sweeps, steam rises) → reconstructing(0.55s freeze) → investigating(enable interactions) → resolving(3.0s — clock eases back into alignment, photograph reveals, traveler exits, truth text, RETURN).

The missing-second math is preserved exactly from the original `MissingSecondExperience`: rate `1.35 × TAU/60 = 0.14137 rad/s`, jump `TAU/60 = 0.10472 rad` at 0.95s — now expressed as generic JSON animation parameters, not experience-named code.

---

## 2. Evidence

### Automated tests — 4/4 green
```
iris_awakening_validation          RESULTS: 42 passed, 0 failed
experience_one_launch_validation   EXPERIENCE_ONE_LAUNCH_PASS
platform_reset_validation          PLATFORM_RESET_VALIDATION_PASS
spatial_hub_validation             Spatial Hub platform validation passed
```
The launch test asserts the JSON-driven contract: engine assembles ≥12 objects, wires 4 interactions, runs the timeline through investigating, the clock dispatch enters resolving, resolution completes, and RETURN appears — then the public return route restores Iris.

### Real-runtime graphical capture (`EXPERIENCE_ONE_JSON_EVIDENCE.png`)
17 frames, real game, real taps. Key measurements (frame-to-frame Δ):
- Forming veil lifts (3.58 → 52.93 brightness) — scene assembles and fades in.
- Observation is alive (Δ 4.0 / 32.8 / 16.3 across the 2s window).
- Freeze holds (Δ 0.80).
- **Clock tap → discovery**: the `Discovery` (SUCCESS) haptic fired (not merely Examination), the clock region changed (Δ 1.79), and resolving began. This is the mechanic that was **fatal-broken in 073C** — now working through the engine's interaction system.
- Resolution animates (Δ 5.1 / 3.1 / 6.0): clock easing back, photograph warming, truth text landing (light-pixel count jumps from ~2800 to ~9200 when the truth text appears).
- RETURN visible, real tap → portal → Iris Home (Δ 50.08 then home restored).

No runtime errors.

---

## 3. Files

**Added:**
- `content/experience_one/experience_one.json` — the Experience One definition (all experience data).
- `EXPERIENCE_ONE_JSON_EVIDENCE.png` — runtime evidence.
- `MISSION_073G_EXPERIENCE_ONE_JSON.md` — this report.

**Rewritten:** `scripts/diorama/DioramaEngine.gd` (preserved role; made generic + JSON-driven).

**Modified:** `scripts/Application.gd` (launches from JSON path instead of a scene), `tests/experience_one_launch_validation.gd`, `tests/platform_reset_validation.gd`.

**Removed:** `scenes/ClockWitnessExperience.tscn`, `scripts/experience/ClockWitnessExperience.gd` (renderer-validation only).

---

## 4. Notes & explicit non-goals

- **Scaffold visuals remain.** The geometry is primitive (boxes/cylinders/spheres), not production art. Per MISSION_073D/073E, the stylized-cinematic 3D environment, readable station clock, animated traveler, and real props land behind the 073D asset gate. What this mission delivers is the **data-driven architecture and the complete, correct, winnable Missing Second loop** — assembled from JSON, not hardcoded.
- **The engine is generic on purpose** (per this mission's instruction). It is not a "Missing Second engine"; it is an assembler that happens to render the Missing Second from its definition. This is a deliberate change from the earlier "no generic framework" guardrail (072C/073E), superseded by this mission's explicit instruction to make the engine assemble everything from a definition.
- **Renderer unchanged** (`gl_compatibility`); the 073D Forward+/Mobile upgrade is still gated on production art.
- **Interaction robustness:** the engine uses camera-projected screen-space hit-testing (depth-aware radius), which is reliable in the SubViewport and validated by real taps. Production can upgrade to Area3D ray-picks per 073D without changing the definition format.
- **No commits/pushes yet** — worked in the local clone only. Ready to push on request.
