# Living Iris Awareness Expression Pass Report

## Scope

This pass adds a derived personality expression contract around the existing Living Iris. It does not add a second lifecycle, AI behavior, chatbot, dialogue, audio controller, voice asset, haptic system, portal, progression system, or destination.

`IrisCore` remains the sole Iris lifecycle/state authority.

## Architecture Implemented

```text
IrisCore state + experience event
        |
        v
IrisPersonalityResolver
        |
        v
IrisResponseIntent
        ├── visual_cue_key
        ├── text_key
        ├── audio_key
        ├── haptic_key
        └── voice_key
```

### Authority boundary

- `IrisCore` owns all Iris lifecycle transitions and biological behavior.
- `IrisPersonalityResolver` only derives a response intent from a supplied authoritative core state and an event key.
- `IrisResponseIntent` is side-effect-free data. It does not trigger audio, voice, haptics, routing, or state changes.
- `Application` supplies existing experience events and retains current routing ownership.

## Files Changed

| File | Change |
| --- | --- |
| `the_iris/scripts/iris/IrisResponseIntent.gd` | New lightweight response data contract. |
| `the_iris/scripts/iris/IrisPersonalityResolver.gd` | New derived expression resolver and response-intent signal. |
| `the_iris/scripts/Application.gd` | Wires existing boot, Memory Field, Witness, completion, and Hub-return events into the resolver. |
| `the_iris/scripts/home/IrisHome.gd` | Emits an explicit memory-selected event before the existing Witness request. |
| `the_iris/tests/prototype_smoke.gd` | Verifies all required response-intent mappings and existing runtime flow. |
| `IRIS_AWARENESS_EXPRESSION_REPORT.md` | This report. |

## Derived Expression Modes

| Mode | Derived from |
| --- | --- |
| `INTRODUCING` | `WELCOMING` core state plus `boot_complete` event. |
| `IDLE` | `hub_return` event, or non-attention fallback state. |
| `CURIOUS` | `ATTENDING` core state plus `memory_focus` event. |
| `ATTENTIVE` | `FOCUSED` core state plus `memory_focus` event. |
| `GUIDING` | `memory_selected` or `witness_entered` event. |
| `REFLECTIVE` | `REFLECTIVE` core state plus `witness_completed` event. |

The modes are expression labels only. They neither replace nor transition IrisCore states.

## Event Mapping

```text
Startup reaches WELCOMING
→ boot_complete
→ INTRODUCING

Memory Field focus
→ memory_focus + ATTENDING
→ CURIOUS

Memory Field reaches FOCUSED
→ memory_focus + FOCUSED
→ ATTENTIVE

Continue Witness selected
→ memory_selected
→ GUIDING

Witness enters
→ witness_entered
→ GUIDING

Witness completes
→ IrisCore REFLECTIVE + witness_completed
→ REFLECTIVE

Iris Hub returns
→ hub_return
→ IDLE
```

## Response Intent Contract

Every `IrisResponseIntent` provides:

```text
expression_mode
visual_cue_key
text_key
audio_key
haptic_key
voice_key
source_event
core_state
```

The cue values are placeholder keys such as `iris_guiding_audio` and `iris_reflective_voice`. They create no ownership layer and load no audio, voice, haptic, or text asset.

Future systems can observe `IrisPersonalityResolver.response_intent_emitted` and decide whether to consume the relevant cue key.

## IrisCore Preservation Confirmation

- `IrisCore.gd` was not modified.
- `LivingIris.gd` was not modified.
- Existing Iris lifecycle states remain unchanged.
- The resolver never invokes `IrisCore.transition_to()`.
- The only existing IrisCore interaction retained is `acquire_attention()` from the current Memory Field focus path.

## Validation Results

| Validation | Result |
| --- | --- |
| Godot 4.6.3 editor scan | Pass |
| Iris lifecycle boot path | Pass |
| `boot_complete → INTRODUCING` | Pass |
| Memory focus → `CURIOUS` | Pass |
| Focused memory → `ATTENTIVE` | Pass |
| Memory selection → `GUIDING` | Pass |
| Witness entry → `GUIDING` | Pass |
| Witness completion → `REFLECTIVE` | Pass |
| Hub return → `IDLE` | Pass |
| Continue Witness existing routing | Pass |
| `WM_001`–`WM_005` completion | Pass |
| Duplicate Iris behavior authority | None |

Smoke output:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Protected Systems Confirmed Unchanged

- `IrisCore`
- `LivingIris`
- IncidentRegistry
- WitnessExperienceDirector
- WitnessMomentOrchestrator
- Witness runtime
- `WM_001`–`WM_005`
- Witness content and assets

## Deferred Work

This pass intentionally leaves these future consumers unimplemented:

- actual visual cue consumer beyond current Iris behavior
- text guidance presentation
- audio and voice playback
- haptic playback
- portal threshold transitions
- progression-driven personality changes
