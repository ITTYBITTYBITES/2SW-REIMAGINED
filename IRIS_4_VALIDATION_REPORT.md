# Living Iris 4.0 — Presence Validation Report

## Scope

This is a validation-only pass over the Presence Pass at `05f0bfb`.

No feature, architecture, Iris-system, Witness Runtime, registry, director, content, asset, or application-flow changes were made. The only repository change produced by this pass is this report.

## Test Environment

| Item | Value |
| --- | --- |
| Source | Fresh clone of `main` at `05f0bfb7046419156a8a0f008f36dd716778507d` |
| Engine | Godot `4.6.3.stable.official.7d41c59c4` |
| Project mode | GL Compatibility, `540 × 960` viewport |
| Functional validation | Godot headless editor scan and smoke runtime |
| Render probe | Xvfb X11 session, OpenGL Compatibility, Mesa llvmpipe software renderer |
| Device hardware | Not available in this validation environment |

The Xvfb/llvmpipe probe exercises the actual Godot rendering path, but it is not a mobile GPU benchmark.

## Iris Ownership Check

| Check | Result |
| --- | --- |
| `IrisController` definitions | One |
| `IrisCore` definitions | One |
| `LivingIris` definitions | One |
| Construction site for each Iris authority | One each |
| Iris portal, destination preview, legacy controller, adapter, manager, service, texture, or shader reference in Iris source | None |

`IrisCore` remains the single behavior/state authority. `LivingIris` remains the single procedural renderer.

## Iris Lifecycle Results

The complete lifecycle executed in the runtime probe:

```text
DORMANT
→ CALIBRATING
→ STIRRING
→ AWAKENING
→ WELCOMING
→ AWARE
```

Measured timing from application creation in the software-rendering probe:

| Milestone | Observed time |
| --- | ---: |
| `CALIBRATING` | 2.410 s |
| `STIRRING` | 3.039 s |
| `AWAKENING` | 4.097 s |
| First `WELCOMING` | approximately 5.817 s |
| `AWARE` | 8.093 s |

The startup sequence, calibration, stirring, awakening, welcoming, and awareness transitions completed without a runtime error.

## Player Interaction Results

The live interaction path executed as designed:

```text
ATTENDING
→ FOCUSED
→ existing Home request
```

| Measurement | Observed time |
| --- | ---: |
| Attention acquisition to `FOCUSED` | 356 ms |
| `FOCUSED` to Home visible | 221 ms |
| Total attention acquisition to Home visible | 578 ms |

This confirms that the Iris visibly owns an attention interval before the existing navigation request takes effect. The interaction did not behave as an immediate conventional button transition.

## Witness Runtime Preservation

All protected runtime paths passed unchanged:

- Iris Home loaded.
- Witness Chapters loaded.
- `WM_001`, `WM_002`, `WM_003`, `WM_004`, and `WM_005` loaded and completed.
- Completion produced the Iris `REFLECTIVE` state.
- Returning through Home restored the Iris `WELCOMING` state.

Smoke output:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Performance and Memory Results

### Structural mobile safeguards

- One procedural `Control` renderer
- No Iris images, animated image sequences, particle system, shader, or external Iris resource
- At most 56 fibers
- Two primary fiber segments per fiber; third segment only on one third of fibers
- Six aura circles, one 48-point silhouette, and two 40-point rim arcs
- Rendering and `IrisCore.tick()` stop while the Iris is hidden

### Software-rendering measurements

Full lifecycle probe, including startup and interaction:

| Measurement | Result |
| --- | ---: |
| Frame samples | 446 |
| Average frame interval | 21.233 ms |
| Minimum frame interval | 6.817 ms |
| Maximum frame interval | 182.464 ms |
| Frames over 33 ms | 24 |
| Static memory at probe start | 31,550,247 bytes |
| Peak static memory | 32,930,087 bytes |

Steady `AWARE` probe over five seconds:

| Measurement | Result |
| --- | ---: |
| Frame samples | 152 |
| Average frame interval | 32.902 ms |
| Minimum frame interval | 21.485 ms |
| Maximum frame interval | 43.415 ms |
| Frames over 33 ms | 49 |
| Static-memory growth after `AWARE` | 0 bytes |

### Interpretation

The initial maximum interval occurs during startup in a software-rendered virtual display. Static memory did not grow during the steady `AWARE` observation window. The measured frame cadence is constrained by Xvfb/llvmpipe and must not be represented as target-device frame performance.

The current implementation remains structurally mobile-safe. A physical target-device profile is still required to confirm frame stability and startup performance on the intended mobile GPU.

## Visual Review

### Successful

- The emergence sequence reads as absence, small aperture, awakening, and stable presence.
- The pupil remains the visual center and supports the future perceptual-lens direction.
- The attention hold makes the Iris appear to notice input before Home appears.
- The procedural rendering remains minimal and avoids menu, card, thumbnail, image-layer, and portal-selection behavior.
- The dark field and restrained teal energy preserve a premium, focused presentation.

### Unnatural or incomplete

- The outer rim remains more geometrically precise than biological in still imagery.
- Individual fibers can read as radial in a static frame; the intended irregularity is clearer in motion.
- Rare blink and pulse cadence requires a longer target-device observation to judge naturalness over time.
- The complete launch-to-aware duration of about 8.1 seconds may feel deliberate or slow depending on product pacing; this requires player review rather than an implementation change in this validation pass.

### Visual polish opportunities

- Evaluate whether the outer rim needs a slightly softer or less uniform future treatment.
- Review a 30-second on-device idle recording for repeated-looking fiber, blink, or micro-saccade timing.
- Review the 578 ms attention-to-Home transition with players before changing its pacing.

## Known Issues

1. No physical mobile device or mobile GPU was available in this environment. Mobile frame stability therefore remains a hardware-validation item, not a confirmed device result.
2. The software rendering environment is unsuitable for judging target FPS. It is useful for runtime correctness, timing, and memory-stability checks only.
3. The Presence Pass preview validates emergence and aware presentation; extended live review is still needed to evaluate rare events over a longer session.

## Recommended Next Step

Do not begin a new Iris feature yet.

Run a short target-device validation session first:

1. Capture 30 seconds of idle Iris behavior after `AWARE`.
2. Measure startup-to-aware duration, steady frame time, peak memory, and battery/thermal behavior on target hardware.
3. Review the attention hold with players.
4. Approve or adjust timing and visual density using that evidence.

Only after this device validation should future perceptual-transition work be considered.
