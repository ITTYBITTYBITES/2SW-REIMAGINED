# Living Iris 4.0 — Current State Audit

**Audit scope:** current `main`

**Scope:** current repository only. The Witness Runtime, `IncidentRegistry`, `WitnessExperienceDirector`, chapter content, and existing experience flow were inspected but not modified.

## Current Architecture

```text
project.godot
└── Application.tscn
    └── PrototypeApplication (Application.gd)
        ├── IncidentRegistry
        ├── WitnessExperienceDirector
        ├── WitnessMomentOrchestrator
        ├── IrisController
        │   ├── IrisCore
        │   └── LivingIris
        ├── IrisHome
        ├── WitnessChapters
        └── StartupFlow
```

The application composes these nodes at runtime. `Application.tscn` contains only the root `PrototypeApplication` control; there are no separate Iris scenes, autoloads, resource files, or plugin dependencies.

## Existing Iris Files and Responsibilities

| File | Current responsibility |
| --- | --- |
| `the_iris/scripts/Application.gd` | Composes the application, owns the current screen-switch methods, and selects Iris states for boot, Home, Witness, and moment completion. |
| `the_iris/scripts/iris/IrisController.gd` | Owns the Iris screen, labels, pointer/touch input, and the `home_requested` navigation signal. Creates `IrisCore` and `LivingIris`. |
| `the_iris/scripts/iris/IrisCore.gd` | Owns behavior states, timed lifecycle transitions, micro-saccade targets, pupil response, and state visual profiles. |
| `the_iris/scripts/iris/LivingIris.gd` | Sole Iris renderer. Draws the visual procedurally using Godot 2D primitives. It stops processing when not visible. |
| `the_iris/scripts/boot/StartupFlow.gd` | Runs the publisher/title sequence and emits `finished`; it contains no Iris behavior. |
| `the_iris/tests/prototype_smoke.gd` | Verifies boot, Iris lifecycle states, Home, Witness, return, and `WM_001`–`WM_005`. |

### Resources and assets

- No Iris-specific asset file exists.
- No Iris image, texture layer, shader, portal, destination preview, or Iris scene exists.
- No Iris script calls `load()` or `preload()`.
- The retained PNG files are the application icon, startup marks, and Witness Moment art. Witness art is loaded only by `WitnessChapters`.
- `project.godot` has no autoload configuration and no Iris resource dependency.

## Application Lifecycle

```text
Project launch
→ StartupFlow publisher/title sequence
→ Application.show_iris(true)
→ IrisCore: CALIBRATING (0.62 s)
→ IrisCore: STIRRING (1.05 s)
→ IrisCore: AWAKENING (1.72 s)
→ IrisCore: WELCOMING (2.25 s)
→ IrisCore: AWARE

Iris touch
→ IrisCore: ATTENDING (0.34 s)
→ IrisCore: FOCUSED
→ IrisController.home_requested after a 0.56 s attention hold
→ Application.show_home()
→ IrisCore: SETTLED

Iris Home → Witness Chapters
→ Application.show_witness()
→ IrisCore: OBSERVING

WitnessMomentOrchestrator.moment_completed
→ Application._on_witness_moment_completed()
→ IrisCore: REFLECTIVE

Home → Return to Iris
→ Application.show_iris(false)
→ IrisCore: WELCOMING
```

`LivingIris._process()` is the only normal caller of `IrisCore.tick(delta)`. State time advances only while the Iris is visible.

## What Works Today

| Concern | Current behavior |
| --- | --- |
| Visual presence | Works. The Iris is a full-screen procedural `Control` with an aura, organic silhouette, radial fibers, pupil, glints, calibration ring, and reflective threads. |
| Animation | Works. Layered breathing, fiber motion, pupil response, micro-saccades, rare aperture blinks, energy drift, emergence scale, focus intensity, calibration, and reflection are state-driven. |
| State handling | Works. `IrisCore` defines dormant, calibrating, stirring, awakening, welcoming, aware, attending, focused, observing, settled, and reflective states. |
| Navigation interaction | Works for the current flow. `IrisController` emits a Home request; `Application` directly selects and shows Iris, Home, or Witness. |
| Audio interaction | Not present. There is no Iris audio or voice runtime in the current repository. |
| Haptic interaction | Not present. There is no haptic or vibration runtime in the current repository. |
| Progression interaction | Limited and transient. `IncidentRegistry` tracks completed moments in memory; `Application` maps the moment-completed signal to the Iris reflective state. No player profile, persistence, or Iris evolution model exists. |

## Target-Architecture Gap

| Living Iris 4.0 component | Current foundation | Gap to address when required |
| --- | --- | --- |
| `MainShell` | `PrototypeApplication` is the runtime composition root. | There is no explicit shell boundary separate from screen-routing methods. |
| `NavigationService` | `Application` has `show_iris`, `show_home`, and `show_witness`. | Navigation is direct method/signal wiring; no route authority or navigation event contract exists. |
| `IrisCore` | Present and functional. | Profiles are dictionaries shared directly with the renderer; the state-to-presentation contract is implicit rather than typed and documented. |
| `IrisPresentation` | `LivingIris` is the current presentation implementation. | Presentation is named as a renderer rather than a dedicated state-to-visual boundary. |
| `IrisNavigationBridge` | `IrisController.home_requested` and `Application` state calls provide the current connection. | There is no dedicated bridge that translates Iris intent and navigation context while leaving routing ownership outside Iris. |
| `IrisProgressionAdapter` | A moment-completed callback sets `REFLECTIVE`. | There is no adapter, evolution input, persistence contract, or separation between content completion and Iris response. |
| `IrisAudioController` | No current audio/voice implementation. | Do not create a controller until the current product has concrete Iris audio requirements and assets. |
| `IrisAccessibility` | No current haptic, accessibility, reduced-motion, or assistive-output implementation. | Do not create an empty layer. Add it only with a defined accessibility contract and platform behavior. |

## Risks

1. **Split ownership:** Adding a navigation bridge or service without removing the equivalent `Application` wiring would create two Iris state writers.
2. **Witness coupling:** The current reflective response is intentionally small. An adapter must observe `WitnessMomentOrchestrator.moment_completed` without changing the protected runtime, registry, content, or completion semantics.
3. **Invisible-state timing:** Iris state time pauses when the renderer is hidden. Any future lifecycle logic that must continue off-screen needs an explicit policy rather than assuming continuous time.
4. **Transient focused and reflective visuals:** Focus immediately leads into Home, and reflection occurs while Witness remains visible. Those states are valid behavior inputs, but the current screen flow gives them little visible dwell time.
5. **Implicit profile contract:** `IrisCore` returns an untyped dictionary consumed by `LivingIris`; changes to profile keys can fail only at runtime.
6. **Mobile validation:** Rendering is bounded and paused while hidden, but device frame-time and battery behavior have not been measured on target hardware.
7. **Accessibility and sensory output:** Audio, voice, haptics, and assistive behavior are absent. Adding them requires product requirements, not placeholder controllers.

## Recommended Implementation Sequence

1. **Preserve the verified baseline.** Keep `prototype_smoke.gd` as a required gate for boot, state flow, Home, Witness, return, and all five moments.
2. **Define the Iris state contract.** Keep `IrisCore` as the sole owner of Iris behavior states. Replace the implicit profile dictionary with a small, explicit presentation-data contract only when making a presentation split.
3. **Create the presentation boundary without changing output.** Extract the current `LivingIris` state-to-draw responsibility into `IrisPresentation` or rename it only as an atomic, behavior-preserving change. Continue to use procedural rendering and retain the hidden-processing guard.
4. **Establish a narrow navigation contract.** Introduce `IrisNavigationBridge` only alongside a single navigation authority. The bridge should translate Iris intent/context into navigation requests; it must not own routes or duplicate `Application` routing.
5. **Add progression input as an observer.** Add `IrisProgressionAdapter` only after defining the current product's evolution data. It should observe existing completion signals and send Iris inputs, never write to `IncidentRegistry` or alter Witness completion.
6. **Add sensory layers from requirements.** Add audio, voice, haptics, and accessibility one at a time when concrete behaviors, assets, settings, and platform policies exist. Do not add no-op controllers.
7. **Measure before visual expansion.** Profile the procedural renderer on target mobile devices before increasing fiber density, adding shaders, or adding additional draw passes.

## Protected Systems

The following are outside the Living Iris 4.0 implementation boundary and must remain behaviorally unchanged:

- `the_iris/scripts/witness/IncidentRegistry.gd`
- `the_iris/scripts/witness/WitnessExperienceDirector.gd`
- `the_iris/scripts/witness/WitnessMomentOrchestrator.gd`
- `the_iris/scripts/witness/WitnessChapters.gd`
- `the_iris/content/witness/wm_001.json` through `wm_005.json`
- `the_iris/assets/witness/`
- Existing startup → Iris → Home → Witness flow

## Audit Verification

The audit clone opened with Godot `4.6.3.stable.official.7d41c59c4`. The current smoke test passed:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```
