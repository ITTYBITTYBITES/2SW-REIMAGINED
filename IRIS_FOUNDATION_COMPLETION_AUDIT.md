# Living Iris Foundation Completion Audit

## Scope

This audit reviews the fresh `f3f1285` repository state before Foundation Completion implementation. No production code was changed during the audit.

The goal is to complete existing Iris expression consumption without creating a second state authority, sensory owner, dialogue system, or gameplay system.

## Existing Iris Systems

```text
Application
├── IrisController
│   ├── IrisCore
│   ├── LivingIris
│   └── existing Iris labels
├── IrisPersonalityResolver
├── IrisHome
│   └── MemoryField
│       └── ContinueWitnessShard
└── Witness runtime
```

### Authoritative systems

| System | Current responsibility | Status |
| --- | --- | --- |
| `IrisCore` | Iris lifecycle, biological state, gaze, pupil, blink, energy, and visual profile authority. | Complete and protected. |
| `LivingIris` | Procedural Iris rendering. | Complete and protected. |
| `IrisController` | Direct Iris input, labels, Home-environment presentation mode. | Existing integration surface. |
| `IrisPersonalityResolver` | Derives expression modes from an IrisCore state plus an experience event. | Complete as a resolver. |
| `IrisResponseIntent` | Carries expression mode and visual/text/audio/haptic/voice cue keys. | Complete as a side-effect-free contract. |
| `MemoryField` | One-shard Home intent field and existing Iris attention request. | Complete for the current destination. |

### Existing expression events

- `boot_complete`
- `memory_focus`
- `memory_selected`
- `witness_entered`
- `witness_completed`
- `hub_return`

The resolver already produces `INTRODUCING`, `IDLE`, `CURIOUS`, `ATTENTIVE`, `GUIDING`, and `REFLECTIVE` intents for these events.

## What Is Missing From the Foundation

1. **No response consumer exists.** `IrisPersonalityResolver.response_intent_emitted` is emitted and tested, but no visual or text surface consumes it yet.
2. **No message-key presentation exists.** `text_key` values are contract keys only; no small Iris expression message is currently resolved for the player.
3. **No personality visual layer exists.** Current biological visuals correctly come from IrisCore state, but expression cues such as introducing, curiosity, guiding, and reflection do not add a lightweight visual accent.
4. **Reflective return is not currently visible in Iris Hub.** Witness completion sets `REFLECTIVE` while the Witness screen is active. Existing `show_home()` immediately changes the Iris to `SETTLED` and emits `hub_return`, so the player does not receive a short reflective Home return interval.
5. **Sensory keys have no consumers by design.** Audio, haptic, voice, and accessibility cue keys are present in the contract. No assets or runtime owner should be added in this mission.

## Dependencies

### Existing data path

```text
IrisCore authoritative state
+ Application / Memory Field event
→ IrisPersonalityResolver.resolve()
→ IrisResponseIntent
```

### Required completion path

```text
IrisResponseIntent
→ IrisExpressionOverlay          # visual and short text consumer only
→ future audio / voice / haptic / accessibility consumers
```

The future sensory branches remain contracts only. The existing response-intent signal is sufficient for them; no audio, haptic, voice, or accessibility controller is required now.

## Safe Insertion Points

### Expression surface

Insert one `IrisExpressionOverlay` inside the existing `IrisController` hierarchy:

```text
IrisController
├── background
├── IrisCore
├── LivingIris
├── IrisExpressionOverlay   ← insertion point
└── existing Iris chrome
```

The overlay may draw lightweight accent rings and display one short resolved expression line. It must:

- receive `IrisResponseIntent` data only,
- not call `IrisCore.transition_to()`,
- not instantiate another Iris,
- not own input, routing, timers for lifecycle, or sensory playback,
- remain visible in Home environment mode so personality accents can be seen around the settled Iris.

### Event wiring

`Application` already owns all event origins and should connect the resolver signal to the existing `IrisController` presentation method. No new navigation framework is needed.

### Reflective return

A small pending-return flag in `Application` is the narrowest safe integration:

```text
Witness completion
→ IrisCore REFLECTIVE
→ reflective response intent
→ Home shown with existing Iris still REFLECTIVE
→ brief presentation interval
→ existing Iris SETTLED
→ hub_return / IDLE response intent
```

This does not modify IrisCore or Witness runtime. It makes the already-derived reflective expression visible on return.

## Protected Systems

The following must remain unchanged:

- `IrisCore`
- `LivingIris`
- `IncidentRegistry`
- `WitnessExperienceDirector`
- `WitnessMomentOrchestrator`
- Witness runtime UI and behavior
- `WM_001`–`WM_005`
- Witness content and assets
- Memory Field routing through existing `witness_requested → show_witness()`

## Implementation Order

1. Add the overlay as an IrisController presentation child without changing Core or renderer behavior.
2. Add a small text-key catalog in the overlay for the six existing expression modes.
3. Connect existing resolver output to the overlay through Application.
4. Add the reflective Home-return interval through Application integration only.
5. Extend the smoke test to verify visual/text consumer receipt, all response keys, reflective Home return, and idle settlement.
6. Re-run the existing boot, Hub, Memory Field, Witness, completion, and return path.

## Validation Baseline

The fresh audit clone opened with Godot `4.6.3.stable.official.7d41c59c4` and passed:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Audit Conclusion

The existing foundation is ready for a narrow completion pass. The only missing foundation pieces are a lightweight response consumer, short message-key presentation, and a visible reflective return interval. They can be added entirely around existing authoritative systems without changing IrisCore, LivingIris, Memory Field routing, or the protected Witness runtime.
