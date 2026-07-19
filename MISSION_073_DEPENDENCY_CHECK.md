# Mission 073 — The Missing Second Dependency Check

**Scope:** One bespoke experience only.
**Status:** Approved implementation boundary.

## Entry

### Existing action

```text
IrisHome
→ SpatialHub WITNESS button
→ IrisHome.witness_requested
→ Application.show_witness_reset()
```

### Mission 073 replacement

```text
IrisHome
→ SpatialHub WITNESS button
→ IrisHome.witness_requested
→ Application.start_missing_second()
→ MissingSecondExperience
```

No registry, content loader, moment ID, portal payload, generic gameplay controller, old data definition, or old navigation owner is involved.

## Runtime ownership

### Allowed dependencies

| Dependency | Use | Boundary |
| --- | --- | --- |
| Godot Control/CanvasItem rendering | Bespoke waiting-room composition | Scene-local only. |
| Godot input / Button signals | Physical object examination and return action | Scene-local only. |
| Godot tween/process timing | Two-second observation and object animation | Scene-local only. |
| Existing Iris controller | Home state before/after the experience | Iris does not guide the in-memory puzzle. |
| Existing audio transport | Station tone and resolution playback | New Missing Second assets only. |
| Existing haptic transport | Optional correct-discovery/return acknowledgment | No old event keys. |
| Existing accessibility setting | Reduced-motion fallback for scene motion | No retired accessibility strings. |
| Existing profile boundary | Retained platform identity only | No new progression/experience reward persistence. |

### Explicitly excluded

```text
GenericWitnessGameplay
WitnessMomentOrchestrator
WitnessContentLoader
WitnessMomentDefinition
IncidentRegistry
old moment IDs
old content JSON
old Fracture/Synchronization/Truth Fragment systems
old Archive/Chapter progression behavior
```

## Exit

```text
MissingSecondExperience
→ completion_requested
→ Application.complete_missing_second()
→ Iris Home
```

The completion does not create a generic result object, fragment, score, chapter entry, or progression value.

## Required asset/capability check

| Requirement | Mission 073 action |
| --- | --- |
| Layered waiting room | Create bespoke visual asset and scene-local animated layers. |
| Independent clock hand | Scene-local node/control with direct animation. |
| Traveler action | Scene-local animated silhouette/layer. |
| Tea steam | Scene-local animated procedural layer. |
| Photograph | Separate scene-local prop/reveal state. |
| Platform light | Scene-local animated sweep layer. |
| Station atmosphere | New station ambience and clock/tick cues. |
| Graphical validation | Required after implementation; no headless-only acceptance. |

## Stop conditions

Implementation must stop if any solution would require:

- a generic experience framework;
- reuse of retired runtime/content;
- a static background plus card UI substitute;
- removal of visible temporal comparison anchors;
- acceptance without graphical human evidence.
