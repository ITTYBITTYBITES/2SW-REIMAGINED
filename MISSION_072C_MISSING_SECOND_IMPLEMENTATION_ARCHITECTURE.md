# Mission 072C — The Missing Second Implementation Architecture Review

**Status:** Implementation map only. No code, scene, asset, or runtime implementation is authorized by this document.  
**Scope:** The Missing Second only.  
**Principle:** Scene ownership before framework extraction.

---

## 1. Scene ownership

### Final scene boundary

```text
res://scenes/MissingSecondExperience.tscn
```

The scene owns the waiting room, temporal discrepancy, examination interactions, resolution, and local UI. It is not a template for future experiences.

### Recommended final hierarchy

```text
MissingSecondExperience (Control)
├── Environment (Control)
│   ├── Background
│   ├── PlatformWindow
│   ├── PlatformLightSweep
│   ├── StationClock
│   │   ├── ClockFace
│   │   └── SecondHand
│   └── DepthElements
│       ├── Bench
│       ├── StationSignage
│       └── RoomParticles
│
├── MemoryActors (Control)
│   ├── Traveler
│   │   ├── Body
│   │   ├── ReachPose
│   │   └── DeparturePose
│   └── Props
│       ├── Suitcase
│       ├── Tea
│       │   └── Steam
│       └── Photograph
│
├── InvestigationLayer (Control)
│   ├── ClockInteraction
│   ├── TeaInteraction
│   ├── SuitcaseInteraction
│   └── PhotographInteraction
│
├── PresentationLayer (Control)
│   ├── EntryLine
│   ├── InvestigationPrompt
│   ├── ObjectResponse
│   ├── ResolutionText
│   └── ReturnAction
│
└── MissingSecondExperience.gd
```

### Ownership rules

| Layer | Owns | Does not own |
| --- | --- | --- |
| Environment | Room depth, light, clock placement, ambient movement | Player progression, Iris lifecycle, global navigation |
| MemoryActors | Traveler action, props, tea steam, photograph reveal | Generic actor logic, future stories |
| InvestigationLayer | Scene-local hit regions and object selection feedback | Reusable examination framework, scoring, global input routing |
| PresentationLayer | Minimal text and return action | Narrative database, generic dialogue pipeline |
| Root controller | The Missing Second sequence only | Future moment registry, generic phase machine |

### Readability priority

The scene should be inspectable in the Godot tree by a designer without tracing runtime code:

```text
Where is the clock?
Where does its second hand live?
Where does the traveler motion live?
Where are the four examination targets?
Where is return UI?
```

If the answer requires finding a generic controller or data parser, the scene boundary is wrong.

---

## 2. Code ownership

### `MissingSecondExperience.gd`

This one bespoke controller owns:

- entry state after Iris handoff;
- approximately two-second observation timing;
- local animation sequence ordering;
- reconstruction freeze;
- scene-local examination availability;
- wrong-object contextual response;
- correct clock discovery;
- resolution sequence;
- one completion/return request.

It may contain a small local enum if it makes this one scene readable, for example:

```text
FORMING
OBSERVING
RECONSTRUCTING
INVESTIGATING
RESOLVING
COMPLETE
```

This is not a reusable phase framework. It exists only because one scene must have legible ownership of its own sequence.

### Allowed scene-specific helper scripts

Only if they reduce scene clarity rather than create abstraction:

| Script | Allowed responsibility |
| --- | --- |
| `MissingSecondClock.gd` | Rotate/hold/realign this scene’s second hand. |
| `MissingSecondTraveler.gd` | Reach, pause, photograph placement, departure pose for this traveler. |
| `MissingSecondInteractable.gd` | Optional local object response helper only if all four scene targets share identical minimal behavior. |

### Not allowed

```text
UniversalMemoryClockSystem
UniversalWitnessActorSystem
GenericInvestigationEngine
ExperienceEngine
MomentPhaseMachine
ReusableTemporalAnomalySystem
StoryPipeline
```

### Extraction rule

If a helper would be useful for another story, document it in **Future Extraction Candidates**. Do not extract or implement it as a reusable system during this mission.

---

## 3. Existing system reuse audit

| Existing system | Decision | Reason | Boundary |
| --- | --- | --- | --- |
| Application shell | **Reuse** | Owns app composition, startup, Iris Home, and platform-level return location. | It must expose one explicit route into/out of MissingSecondExperience only. |
| Living Iris / IrisCore | **Reuse** | Defines product identity and the player’s threshold. | Iris remains outside the investigation and does not narrate puzzle actions. |
| Iris Portal Transition | **Modify only if needed** | Candidate for memory entry/return continuity. | It must not require retired content IDs, old runtime types, or old result systems. If it does, isolate/replace its handoff only. |
| Iris audio/haptic/accessibility consumers | **Selective reuse** | Useful transport for entry/return sensory language. | No retired event keys, no in-memory guidance narration. |
| WitnessProfile / WitnessProfileStore | **Reuse unchanged** | Local platform identity/save boundary. | Do not add experience progression until first human experience proves it deserves persistence. |
| WitnessArchive | **Do not use yet** | Archive meaning is not part of the first playability proof. | Keep boundary empty; do not reconnect old archive assumptions. |
| SpatialHub / IrisHome | **Reuse minimally** | Existing player-facing Iris home and Witness entry location. | Replace empty reset entry with one direct Missing Second entry only after implementation begins. |
| Retired portal/moment infrastructure | **Do not reuse** | Carries old content/pipeline assumptions. | No imports, adapters, aliases, or compatibility bridges. |

---

## 4. Asset strategy

### Assets required before first human playtest

These are mandatory. The first graphical test must not substitute them with a static card or generic UI.

| Asset/capability | Required form | Why |
| --- | --- | --- |
| Waiting room | Layered environment composition | Provides depth and a living place. |
| Clock | Separate face and independently controllable second hand | Core changed detail. |
| Traveler | At least reach, pause, photograph placement, and departure motion | Establishes human stakes. |
| Tea | Cup plus animated/freezable steam | Temporal comparison anchor. |
| Suitcase | Visible scene prop | Departure anchor and wrong examination option. |
| Photograph | Normal and resolution-readable state | Human meaning of missing second. |
| Platform light | Separate sweep layer | Shared room-time anchor. |
| Sound | Station tone, clock tick, reconstruction hold, resolution cue | Establishes rhythm and emotional payoff. |

### Allowed temporary production-development assets

Allowed only while testing scene timing internally—not for human acceptance:

- flat-color lighting proxy layers;
- rough temporary room geometry;
- temporary station audio loop;
- temporary traveler silhouette rig;
- temporary photograph artwork;
- temporary resolution cue.

### Prohibited placeholders for first human validation

```text
single static room image
static clock texture without an independently animated hand
missing traveler motion
missing tea/steam timing anchor
generic object-button list
opaque lower-half card panel
unwritten/missing resolution animation
text-only explanation of the changed second
```

---

## 5. First playable definition

“The scene opens” is not first playable.

### First playable is achieved only when:

```text
1. Player selects WITNESS from Iris Home.
2. Iris opens the bespoke waiting-room scene.
3. Player watches a complete two-second living observation.
4. The room freezes into reconstruction.
5. Player can examine tea, suitcase, photograph, and clock in the scene.
6. Wrong examinations return contextual observations without reset/punishment.
7. Clock selection triggers a visible temporal realignment.
8. Traveler leaves photograph and exits.
9. Truth resolves in-scene.
10. Player chooses RETURN TO IRIS.
11. Iris Home is reached successfully.
```

### Explicitly not sufficient

```text
scene loads
clock rotates in isolation
button changes text
state enum advances
headless test passes
```

---

## 6. Human validation requirement

Before declaring the experience complete, capture graphical evidence from a human-facing runtime for:

1. **Iris entry:** player selects Witness and pupil opens.
2. **Living room:** waiting room is readable before the anomaly.
3. **Observation:** clock, traveler, steam, and light are visibly moving.
4. **Reconstruction:** room freeze and one-second mismatch are readable.
5. **Examination:** player taps at least one wrong physical object.
6. **Discovery:** clock selection visibly identifies the discrepancy.
7. **Truth:** traveler leaves photograph; player understands why.
8. **Return:** player reaches Iris Home through one clear action.

For each capture, record:

```text
Build commit
Viewport/device size
Input method
What player was expected to understand
What player actually understood
PASS / TUNE / BLOCKER
```

No headless trace, direct method call, synthetic signal, code inspection, or scene tree alone substitutes for this requirement.

---

## 7. Implementation readiness decision

### Ready to build after this review only if:

- scene ownership is accepted;
- all mandatory asset/capability requirements are accepted;
- no static-card substitute is proposed;
- the bespoke controller boundary is accepted;
- graphical human validation is available before final acceptance.

### Stop and reconsider if:

- production tries to introduce a generic experience/moment system;
- old runtime types reappear as dependencies;
- scene-local objects become a list/card UI;
- asset constraints force removal of movement/comparison anchors;
- graphical human testing cannot be arranged.
