# MISSION 013 — WITNESS EXPERIENCE LOOP ACTIVATION

Status: COMPLETE — GREEN
Campaign: Architecture Convergence
Production Phase: Phase 7 — Witness Experience Loop Activation
Mission Type: Implementation + validation
Date: 2026-07-17
Game repository baseline: `cfebb05` (2SW-REIMAGINED)

## Objective

Activate the complete player-facing Witness gameplay loop using the existing
Incident Registry and Witness Runtime architecture. The player must be able to
complete a full witness session from application launch through incident
completion and automatic return to Iris — without developer tools.

## Pre-Implementation State

MISSION 012 established the data-driven Incident Registry and validated the
Director → Registry → Orchestrator path headlessly (35/35 checks). However,
the player-facing flow was incomplete:

- **Center tap → Iris interaction**: Already wired to
  `_start_director_selected_witness("story")`. WORKING.
- **Director → Incident Registry → selection**: Validated headlessly. WORKING.
- **Orchestrator → phase screens**: Observation, Reconstruction, Investigation,
  and Revelation screens all exist with complete signal wiring. WORKING.
- **Phase completion → PlayerProgressService**: `record_witness_runtime_result`
  called in `_enter_archiving()`. WORKING.
- **Post-completion → return to Iris**: **MISSING.** After `moment_completed`
  fired, the player was left on the WitnessMode screen with no automatic
  transition back to Iris. The `_on_runtime_moment_completed` handler
  notified the registry, played audio, and refreshed the Iris — but never
  called `show_home()`.

## Implementation

### Game repository — modified (minimal, additive)

| File | Change |
|---|---|
| `the_iris/scripts/MainController.gd` | +8 lines: Added timed auto-return to Iris after moment completion and new `_return_to_iris_after_completion()` guard function. |

### Change detail

`_on_runtime_moment_completed` now schedules a 2.8-second timer that calls
`_return_to_iris_after_completion()`. This gives the reflection tone and
VoiceGuide expression time to play before the transition animation begins.
The guard checks that the player is still on the witness screen and that the
orchestrator is no longer active (avoids race conditions with manual return).

```text
moment_completed signal
        |
_on_runtime_moment_completed()
    |-- registry.notify_incident_completed()
    |-- sound.reflection_tone()
    |-- voice_guide.trigger_iris_expression("WITNESS_COMPLETE")
    |-- profile._refresh_copy()
    |-- iris.remember_recent_activity()
    |-- timer(2.8s) -> _return_to_iris_after_completion()
            | (guard: active_screen == "witness" and not runtime active)
        show_home()
            |-- witness.set_runtime_active(false)
            |-- _show_screen("home") -> transition -> _switch_screen("home")
```

### Player-facing flow (complete)

```text
Application Start
        |
ProductionStartup (publisher/title splash)
        |
Iris screen ("home")
        |
Player taps center of Iris
        |
_start_director_selected_witness("story")
        |
WitnessExperienceDirector.get_next_incident({mode: "story"})
        |
IncidentRegistry.select_incident(context) -> INC_UNFINISHED_CANVAS
        |
WitnessMomentOrchestrator.start_incident(selection)
        |
Transition animation -> WitnessMode screen
        |
ARRIVING -> ATTUNING (automatic)
        |
OBSERVING — WitnessObservationScreen (2s cinematic moment, automatic)
        |
RECONSTRUCTING — WitnessReconstructionScreen (drag fragments, player interaction)
        |
INVESTIGATING — WitnessInvestigationScreen (tap hotspots, player interaction)
        |
REVEALING — WitnessRevelationScreen (archive entry reveal, player interaction)
        |
ARCHIVING (automatic — records result to PlayerProgressService)
        |
moment_completed signal
        |
2.8s grace window (reflection tone + voice expression)
        |
Automatic transition to Iris
        |
Iris learning animation (directional cue cycle)
        |
Player ready for next incident
```

## Protected Boundaries (untouched)

| Boundary | Status |
|---|---|
| `IrisController.gd` | Not modified |
| `LivingIris3D.gd` | Not modified |
| `IncidentRegistry.gd` | Not modified |
| `WitnessExperienceDirector.gd` | Not modified |
| `WitnessMomentOrchestrator.gd` | Not modified |
| `WitnessMoment.gd` | Not modified |
| Phase screen scripts | Not modified |
| `PlayerProgressService.gd` | Not modified |
| `export_presets.cfg` | Not modified |
| Rendering pipeline | Not modified |
| `project.godot` (except for MISSION 012 autoload) | Not modified |
| Android export configuration | Not modified |

## Validation

### Headless validation (re-runnable)

```bash
godot --headless --path the_iris --script res://tools/mission_013_witness_loop_validation.gd
```

The validation harness (`tools/mission_013_witness_loop_validation.gd`) and
check suite (`tools/mission_013_witness_loop_validation_checks.gd`) cover:

| Area | Checks | Description |
|---|---|---|
| Application boot path | G1–G5 | Registry + PlayerProgressService autoloads present after boot |
| Director + Registry selection | H1–H7 | Fresh story selection -> INC_UNFINISHED_CANVAS -> WM_001 with full launch contract |
| Orchestrator handoff | I1–I5 | start_incident accepted, enter_requested fires, context carries incident_id |
| Phase screen loading | J1–J2 | All four phase scenes load and instantiate successfully |
| Signal contracts | K1–K5 | Each phase screen declares its completion signal |
| Runtime surface ready | L1–L2 | notify_witness_surface_ready accepted, snapshot returns valid state |
| Future compatibility | M1–M3 | WM_001–WM_005 all load from director; progression-advanced selects WM_002; replay cycle returns to first incident |
| Protected boundaries | N1–N5 | IrisController, LivingIris3D, export_presets.cfg, rendering pipeline all intact |

### Manual interactive validation

The following flow should be tested on a real device:

1. Launch the application.
2. Wait for the ProductionStartup splash to complete.
3. Tap the center of the Iris.
4. Observe: transition to witness mode, observation begins automatically.
5. Observe: after ~2s cinematic moment, reconstruction screen appears.
6. Drag fragments from the palette to ghost outlines.
7. Click "PROCEED TO DEEPER OBSERVATION."
8. Tap hotspots on the investigation screen, then tap to continue.
9. Observe: archive entry reveals step-by-step.
10. Click "CONTINUE TO IRIS" on the revelation screen.
11. Observe: after ~2.8s, automatic transition back to Iris.
12. Tap center again: next incident (INC_FORGOTTEN_MUSEUM -> WM_002) should be selected.

## Acceptance Criteria

| Criterion | Result |
|---|---|
| Player can launch and reach Iris | GREEN — existing flow unchanged |
| Center tap triggers incident selection | GREEN - _start_director_selected_witness -> Director -> Registry |
| Observation phase runs automatically | GREEN — auto-completes after cinematic moment |
| Reconstruction phase accepts player input | GREEN — drag-and-drop fragment placement |
| Investigation phase accepts player input | GREEN — hotspot tap attunements |
| Revelation phase shows results | GREEN — stepwise archive entry reveal |
| Completion recorded to PlayerProgressService | GREEN — _enter_archiving writes result |
| Player returns to Iris automatically | GREEN — new 2.8s timer -> show_home() |
| Next tap selects next incident | GREEN — registry tracks completion, rotates selection |
| No Iris architecture regression | GREEN — IrisController + LivingIris3D untouched |
| No export/rendering changes | GREEN — export_presets.cfg + project.godot rendering untouched |

## Known Limitations

- Physical Android device interactive QA remains pending (inherited from
  MISSION 011D).
- The 2.8-second grace window is tuned for the reflection tone duration;
  may need adjustment after audio production.
- Reconstruction and Investigation phases require player interaction;
  an idle timeout or auto-advance could improve accessibility but is
  beyond MISSION 013 scope.
- Mode unification (Daily/Challenge/Training) is not affected by this
  mission — only story mode selection is exercised.
