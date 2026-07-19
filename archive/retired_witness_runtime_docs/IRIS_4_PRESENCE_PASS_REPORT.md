# Living Iris 4.0 — Presence Pass Report

## Scope

The Presence Pass enhances the existing Iris foundation only:

```text
IrisController
├── IrisCore       # behavior and state authority
└── LivingIris     # procedural renderer
```

Iris Home remains the archive interface. Witness Runtime remains the experience provider. No portal selection, experience browser, navigation replacement, audio controller, haptic controller, or new Iris subsystem was added.

## Implementation Safety Check

Before implementation, the current repository was checked for Iris ownership conflicts.

| Check | Result |
| --- | --- |
| `IrisController` class definitions | One |
| `IrisCore` class definitions | One |
| `LivingIris` class definitions | One |
| `IrisController.new()` construction sites | One |
| `IrisCore.new()` construction sites | One |
| `LivingIris.new()` construction sites | One |
| Deprecated/duplicate Iris references in source | None found |

`IrisCore` remains the single behavior authority and `LivingIris` remains the single renderer.

## Files Changed

| File | Change |
| --- | --- |
| `the_iris/scripts/iris/IrisCore.gd` | Refined the existing behavioral sequence, layered timing, rare blink scheduling, energy drift, state visual profiles, and mobile-safe fiber bounds. |
| `the_iris/scripts/iris/LivingIris.gd` | Refined procedural emergence, layered breathing, irregular fibers, asymmetry, aperture blink expression, pupil response, energy variation, and bounded rendering cost. |
| `IRIS_4_PRESENCE_PASS_REPORT.md` | This implementation report. |

The existing `IrisController` attention hold and `prototype_smoke.gd` attention assertions were retained and verified. No Witness Runtime, registry, director, chapter-content, Witness asset, application-flow, or Iris Home file was changed.

## New Behaviors

### Presence lifecycle

```text
DORMANT
→ CALIBRATING
→ STIRRING
→ AWAKENING
→ WELCOMING
→ AWARE
```

The Iris starts from absence. It first appears as a small, low-energy aperture, then accumulates presence before reaching its stable aware state.

### Attention lifecycle

```text
Player touch
→ ATTENDING
→ FOCUSED
→ existing Home request
```

The pupil receives a normalized focus target. The Iris visibly acquires attention before the existing Home route takes over, rather than switching screens at the same instant as input.

### Procedural biological variation

- Two layered breathing frequencies instead of one synchronized loop
- Per-session asymmetric seed
- Slow energy drift
- Irregular multi-segment fiber paths
- Randomized micro-saccade timing and targets
- Rare aperture blinks
- Infrequent energy pulses
- State-specific presence, pupil, fiber, glow, calibration, and reflection expression

`IrisCore.state_changed` remains the clean state signal available to future audio, haptic, text-guidance, and voice listeners. No placeholder listener was added.

## Performance Notes

The renderer remains a single procedural `Control` with no Iris textures, image sequences, shaders, particles, or externally loaded Iris resources.

Current bounds per visible frame:

- At most 56 procedural fibers
- Two primary fiber segments per fiber; a third segment on one third of fibers
- Six aura circles
- One 48-point organic silhouette
- Two 40-point rim arcs
- Rendering and `IrisCore.tick()` stop when the Iris is hidden

A five-second desktop software-rendering probe completed without runtime errors. Its Xvfb/llvmpipe frame figure is not a mobile-device benchmark and must not be used as one. The implementation keeps the mobile-safe structural safeguards above; final mobile-frame-time verification requires a target device.

## Validation Results

| Validation | Result |
| --- | --- |
| Fresh clone used as implementation baseline | Pass |
| Godot 4.6.3 editor scan | Pass |
| Iris ownership safety check | Pass |
| Iris source contamination scan | Pass |
| Iris-specific asset scan | Pass |
| Boot through aware behavior | Pass |
| Iris interaction through attention/focus to Home | Pass |
| Iris Home to Witness Chapters | Pass |
| `WM_001`–`WM_005` load and complete | Pass |
| Witness completion to reflective Iris state | Pass |
| Return Home and return to welcoming Iris | Pass |
| Witness Runtime/protected source changes | None |

Smoke output:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Recommended Next Step

Review the captured Iris runtime preview on a target device and judge the emergence, attention hold, pupil response, and idle variation as an experience.

If the visual direction is approved, run a short device performance pass before increasing visual density. Keep the next feature focused on perception: use the existing focused pupil and blink behavior as the basis for a future experience-reveal transition only after the archive-card flow supplies an explicit Witness Moment context.
