# Living Iris Cognitive OS — Memory Field Audit

## Scope

This is an audit-only document for the current `fc212ca` repository state. No runtime, Iris, Home, Witness, content, or navigation code was changed during the audit.

The repository contains no separate Experience Readiness scene or service. The current boot-readiness behavior is the Iris calibration and awakening sequence owned by `IrisCore` after `StartupFlow` finishes.

## Current Home Architecture

`Application.tscn` contains only a root `PrototypeApplication` control. All visible application components are constructed at runtime in `Application.gd`.

```text
PrototypeApplication
├── IncidentRegistry
├── WitnessExperienceDirector
├── WitnessMomentOrchestrator
├── IrisController
│   ├── ColorRect background
│   ├── IrisCore
│   ├── LivingIris
│   └── Iris chrome labels
├── IrisHome
│   ├── procedural archive atmosphere (_draw)
│   ├── contextual labels
│   ├── ContinueWitnessCard
│   │   └── ArchiveAction button
│   ├── Journey placeholder card
│   ├── Discoveries placeholder card
│   └── RestWithIris button
├── WitnessChapters
└── StartupFlow
```

There is no dedicated Iris Home scene. `IrisHome.gd` creates the complete Home hierarchy in `_ready()` using absolute portrait coordinates for the `540 × 960` project viewport.

### Current Home presentation

- `IrisHome` is a transparent overlay with a low-frequency procedural archive atmosphere.
- At Home, the one real `IrisController` remains visible behind this overlay in `SETTLED` state.
- `IrisController.set_home_environment(true)` hides Iris chrome and sets its mouse filter to ignore, leaving `LivingIris` visible without making it a Home button.
- The current dominant navigation element is `ContinueWitnessCard`, a full-width card that emits `witness_requested`.
- Journey and Discoveries are non-interactive visual placeholders. They do not implement progression, profile, or discovery logic.

## Living Iris Ownership and Hierarchy

```text
IrisController
├── IrisCore        # sole state and behavior authority
└── LivingIris      # sole procedural renderer
```

Audit result:

| Check | Result |
| --- | --- |
| `IrisController` definitions | One |
| `IrisCore` definitions | One |
| `LivingIris` definitions | One |
| Construction site for each | One each |
| Iris-specific image assets | None |
| Iris shaders, portals, destination previews, adapters, managers, or services | None |

`IrisController` owns pointer/touch handling only while the direct Iris screen is active. In Home environment mode it ignores input, so Home controls are the active input surface.

## Current Navigation Routing

```text
Iris touch
→ IrisController.home_requested
→ Application.show_home()
→ Iris visible + SETTLED + Home environment mode
→ IrisHome visible

ContinueWitnessCard.ArchiveAction
→ IrisHome.witness_requested
→ Application.show_witness()
→ Home hidden + Iris hidden + OBSERVING
→ WitnessChapters

WitnessChapters return action
→ WitnessChapters.home_requested
→ Application.show_home()
→ same settled Iris Home environment

Escape from Home or RestWithIris
→ Application.show_iris()
→ direct Iris + WELCOMING
```

`Application` is the existing route owner. There is no `NavigationService`, route registry, `CanvasLayer`, or separate Home navigation framework in the repository.

## Canvas and Input Audit

### Canvas

- No `CanvasLayer` exists in scenes or scripts.
- The layer order is ordinary Control sibling order: `IrisController` is added before `IrisHome`, so the Home overlay renders above the actual Iris.
- `StartupFlow` is added last and temporarily renders above all application controls during boot.

### Input

| Surface | Current input behavior |
| --- | --- |
| `StartupFlow` | Stops pointer/touch and can skip the boot sequence. |
| Direct `IrisController` | Stops pointer/touch, enters `ATTENDING`, then `FOCUSED`, then emits the existing Home request. |
| Iris in Home environment | Ignores input; it remains presence only. |
| `IrisHome` | Stops input. The Continue card has one transparent `ArchiveAction` button overlay. |
| `WitnessChapters` | Stops input and owns the existing Witness controls. |
| Application | Handles escape/back: Witness returns Home; Home returns direct Iris. |

## What Must Remain Untouched

The following systems are protected by this Memory Field work:

- `the_iris/scripts/witness/IncidentRegistry.gd`
- `the_iris/scripts/witness/WitnessExperienceDirector.gd`
- `the_iris/scripts/witness/WitnessMomentOrchestrator.gd`
- `the_iris/scripts/witness/WitnessChapters.gd`
- `the_iris/content/witness/wm_001.json` through `wm_005.json`
- `the_iris/assets/witness/`
- Existing `Application.show_witness()` routing contract
- Existing Iris behavior logic in `IrisCore` and procedural rendering logic in `LivingIris`

The only direct Iris integration already required by Home is presentation mode: `IrisController.set_home_environment(true/false)`. A Memory Field must reuse this single Iris instance rather than create or mount another one.

## Memory Field Insertion Point

The Memory Field belongs **inside `IrisHome`**, not inside `IrisCore`, `LivingIris`, `WitnessChapters`, or a new application-level navigation framework.

Target visual hierarchy for the first implementation:

```text
IrisController (behind, settled, input ignored)
└── LivingIris

IrisHome (above)
├── procedural archive atmosphere
├── Contextual Information
├── MemoryField
│   └── ContinueWitnessShard
└── secondary non-routed archive context
```

### Exact replacement boundary

In a later implementation pass, replace the current `ContinueWitnessCard` construction and `ArchiveAction` button with one `MemoryField` visual container and one `ContinueWitnessShard` control.

- The `MemoryField` should be constructed by `IrisHome`, where the current card construction already lives.
- It should render above the Home atmosphere and above the underlying Iris, while leaving the Iris visually unobscured at center.
- The shard should be the only active destination in the first pass.
- Journey and Discoveries may remain contextual, non-interactive labels until real content exists.
- The current card must be replaced rather than kept beside the shard; two controls for the same destination would reintroduce conventional-menu duplication.

## Safe Introduction Plan

The first Memory Field implementation should preserve current routing exactly:

```text
ContinueWitnessShard selected
→ IrisHome.witness_requested.emit()
→ Application.show_witness()
→ existing IncidentRegistry
→ existing WitnessExperienceDirector
→ existing WitnessMomentOrchestrator
→ existing WM runtime
```

No new route, destination, progression record, content definition, or portal system is needed.

Implementation sequence after this audit:

1. Replace only the visible Continue Witness card with one non-orbiting or gently drifting shard.
2. Reuse the existing `witness_requested` signal for selection.
3. Keep `IrisController` input ignored while Home is visible; the shard receives Home input.
4. Extend the smoke test to assert the one shard routes to existing Witness Chapters and that the same Iris instance remains present.
5. Keep the return path unchanged: Witness → `show_home()` → settled Iris Hub.
6. Defer shard attraction, Iris gaze response, selection choreography, audio, haptics, and portal behavior to a subsequent interaction pass.

## Risks and Guardrails

| Risk | Guardrail |
| --- | --- |
| Duplicate Iris renderer | Memory Field lives in `IrisHome`; it must never instantiate `LivingIris` or `IrisController`. |
| New navigation framework | Reuse `witness_requested` and `Application.show_witness()` exactly. |
| Card-and-shard duplication | Replace `ContinueWitnessCard`; do not present both controls for the same chapter. |
| Iris becomes a button again | Keep Iris input ignored in Home mode. The shard owns the one destination selection. |
| Witness coupling | Do not import or modify Witness runtime classes. The existing signal is sufficient. |
| Fake content | Keep only Continue Witness interactive. Other labels remain non-routed context. |
| Visual performance drift | Start with one shard, lightweight Control drawing, no shaders, particles, subviewports, or destination previews. |
| Layer/input conflict | Keep the Home overlay above Iris and give the shard an explicit hit area. |

## Validation Baseline

The fresh audit clone opened with Godot `4.6.3.stable.official.7d41c59c4` and passed the current full smoke path:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Audit Conclusion

The current architecture has a safe, narrow insertion point for the first Cognitive OS step. A one-destination Memory Field can be introduced entirely inside `IrisHome` while retaining the actual settled Iris as center, preserving `Application` routing, and leaving the Witness Runtime untouched.

No implementation was performed in this audit pass.
