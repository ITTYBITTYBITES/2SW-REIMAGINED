# Iris Memory Field — Implementation Report

## Scope

This implementation replaces the dominant Continue Witness Home card with one lightweight, Iris-centered memory shard.

```text
IrisHome
├── settled, existing Living Iris (behind)
└── MemoryField
    └── ContinueWitnessShard
```

Only one real destination exists: Continue Witness. It uses the existing routing path without modifying the Witness Runtime.

## Files Modified

| File | Change |
| --- | --- |
| `the_iris/scripts/home/MemoryField.gd` | New lightweight procedural Memory Field with one Continue Witness shard. |
| `the_iris/scripts/home/IrisHome.gd` | Replaced the dominant Continue Witness card with MemoryField and retained contextual archive information. |
| `the_iris/scripts/Application.gd` | Connected Memory Field intent focus to the existing IrisCore attention API; existing Witness routing remains unchanged. |
| `the_iris/tests/prototype_smoke.gd` | Added coverage for the single real shard, Iris attention acquisition, and existing Witness routing. |

No IrisCore, LivingIris, IncidentRegistry, WitnessExperienceDirector, WitnessMomentOrchestrator, Witness runtime, chapter content, or Witness asset file was modified.

## Behavior Implemented

### Idle

- The Continue Witness shard drifts on a shallow, multi-frequency orbit around the existing settled Iris.
- It is drawn procedurally as a small irregular memory fragment with a low-energy aura.
- Contextual Journey and Discoveries text remains non-interactive. No fake destinations or progression data exist.

### Focus

- Pointer or touch proximity focuses the shard.
- The shard brightens, grows slightly, moves subtly toward intent, and reveals a quiet link to the Iris.
- `MemoryField.intent_focused` sends a normalized target to `Application`.
- `Application` calls the existing `IrisCore.acquire_attention()` API, so the one real Iris enters `ATTENDING` and then `FOCUSED` without a duplicate renderer or new navigation layer.
- When intent leaves the shard without selection, the field emits a release signal and the existing Iris returns to `SETTLED`.

### Selection

```text
ContinueWitnessShard touch
→ Memory Field focus
→ existing Iris ATTENDING / FOCUSED response
→ 0.42 s selection hold
→ existing IrisHome.witness_requested
→ existing Application.show_witness()
→ existing Witness runtime
```

The selection hold gives the Iris time to respond before the current Witness flow begins. No portal, preview, SubViewport, scene pre-render, or new route is involved.

## Architecture Status

- One `IrisController`, one `IrisCore`, and one `LivingIris` remain in the project.
- The real Iris remains visible as a non-interactive settled presence while Home is active.
- MemoryField is a Home presentation/input component; it never instantiates or modifies an Iris renderer.
- `Application` remains the existing route owner.
- The existing `witness_requested → show_witness()` signal contract remains the only destination route.

## Performance Notes

- MemoryField uses only Godot 2D drawing primitives and label controls.
- No images, shaders, particle systems, SubViewports, previews, or destination scenes are loaded by the field.
- The field contains one shard only.
- Its visual redraw is capped at 30 Hz; the underlying Living Iris retains its own existing life cadence.
- Home atmosphere continues to redraw at its existing low-frequency cadence.

Target-device frame, thermal, and battery validation remains required before adding more shards or visual density.

## Validation Results

| Validation | Result |
| --- | --- |
| Application boot and Iris lifecycle | Pass |
| Iris Home loads with one real Iris | Pass |
| MemoryField appears | Pass |
| Continue Witness shard acquires Iris attention | Pass |
| Continue Witness shard enters existing Witness Chapters flow | Pass |
| `WM_001`–`WM_005` load and complete | Pass |
| Returning from Witness restores Iris Home | Pass |
| Duplicate Iris instances | None |
| Protected Witness systems and content | Unchanged |

## Protected Systems Confirmed Unchanged

- `IncidentRegistry`
- `WitnessExperienceDirector`
- `WitnessMomentOrchestrator`
- `WitnessChapters`
- `WM_001`–`WM_005`
- Witness assets

## Deferred Work

This pass intentionally does not implement:

- shard attraction choreography beyond the one-shard proximity response
- multi-shard selection
- audio or haptics
- portal transitions
- pupil destination previews
- progression logic
- new content or routes

The next safe step is a dedicated Memory Shard interaction pass only after reviewing this one-shard behavior on target hardware.
