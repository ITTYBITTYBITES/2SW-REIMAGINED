# Mission 071 — First New Two Second Witness Experience Plan

**Status:** Planning gate only. No gameplay implementation begins until this plan is accepted.  
**Scope:** One complete, bespoke, player-first investigation. No generic engine, multi-story framework, content registry, reusable phase abstraction, or old Witness Moment migration.

---

## 1. Chosen concept — The Missing Second

### Working title

**The Missing Second**

### Premise

A quiet railway waiting room near closing time. A traveler gathers a small suitcase as a station clock ticks toward departure. A folded ticket, a cup of tea, and a photograph sit on a bench.

The player witnesses approximately two seconds:

```text
The traveler reaches for the suitcase.
The station clock ticks.
The platform light passes across the waiting room.
```

When the memory reconstructs, one detail is wrong:

```text
The second hand on the station clock has advanced,
but the cup’s steam and platform light have not.
```

The player identifies the changed detail: **the clock has skipped one second ahead of the room.**

### Human truth

The traveler did not miss the train because they hesitated. They stayed behind for one second to leave a photograph for someone who would arrive after them. The memory lost that second because no one knew why it mattered.

### Why this is the strongest first slice

- The changed detail is visible, specific, and understandable without lore.
- The player has a concrete observation target: compare the clock to the rest of the room.
- The scene can be atmospheric without a large content pipeline.
- The resolution turns a mechanical irregularity into a human choice.
- It demonstrates the core product question: *what changed, and why did that moment matter?*

---

## 2. Player promise

The experience should communicate:

```text
I watched a moment.
Something was wrong.
I found what changed.
I learned why that missing second mattered.
```

It must not communicate:

```text
I clicked through a card.
I filled a generic progress meter.
I completed an abstract system state.
```

---

## 3. Complete player journey

```text
Iris is open
→ player selects WITNESS
→ the waiting-room memory forms
→ one clear instruction: “Watch carefully. One second is missing.”
→ two-second observation plays without input
→ reconstruction freezes the scene
→ objective: “What moved ahead of the room?”
→ player selects the clock’s second hand
→ observation is evaluated
→ success or failure feedback
→ truth is revealed
→ player returns to the Iris
```

### First-launch interaction copy

| Beat | Player-facing language |
| --- | --- |
| Entry | `A memory has lost one second.` |
| Observation | `Watch the room. Do not touch yet.` |
| Reconstruction | `What moved ahead of the room?` |
| Correct selection | `The clock arrived before the moment did.` |
| Failure selection | `That belongs to the room. Look for what changed time first.` |
| Resolution | `The missing second was a choice to be remembered.` |
| Return | `The Iris held what the room could not.` |

---

## 4. Smallest complete gameplay loop

### Observation

- Scene appears in a living but controlled state.
- Player has no input for approximately two seconds.
- The scene contains only three readable focal objects:
  1. station clock;
  2. tea cup/steam;
  3. suitcase/photograph.
- The clock hand subtly advances one second ahead of the environment.

### Reconstruction

- Scene freezes.
- A simple prompt appears.
- Player can select exactly one of three visible focal objects.
- Only the clock is correct.

### Success

- Clock selection receives immediate visual confirmation.
- The scene briefly reconstructs the missing choice: photograph left on bench; traveler turns toward the platform.
- Short truth text appears.
- Player has a clear **RETURN TO IRIS** action.

### Failure

- Wrong object receives a quiet, non-punitive response.
- Prompt remains visible.
- Player can choose again.
- No stability system, hold interaction, generic phase meter, evidence inventory, mastery layer, or fragment system is introduced in this first slice.

### Completion

- The result is presented locally in the new experience.
- Player returns to Iris using the existing portal/return shell only if it remains appropriate after reset review.
- Persistence/progression integration is deliberately deferred until the basic interaction is proven enjoyable.

---

## 5. One scene / one implementation boundary

The first slice should use exactly one bespoke scene:

```text
scenes/MissingSecondExperience.tscn
```

Suggested composition:

```text
MissingSecondExperience (Control)
├── WaitingRoomVisual (custom Control or layered sprites)
│   ├── Clock
│   ├── TeaSteam
│   ├── Suitcase
│   ├── Photograph
│   └── PlatformLight
├── ObjectiveLayer
│   ├── Prompt
│   ├── ObservationCountdown
│   └── ResultText
├── InteractionLayer
│   ├── ClockChoice
│   ├── CupChoice
│   └── SuitcaseChoice
└── ReturnAction
```

This is intentionally bespoke. It is not a template for future content yet.

---

## 6. Required assets

No existing WM assets or stories are reused.

### Minimum art

| Asset | Need | First-pass approach |
| --- | --- | --- |
| Waiting-room background | Environment and mood | One new authored or procedural background. |
| Clock | Central changed detail | Separate visible element with controllable second hand. |
| Tea cup/steam | Comparison anchor | Small layered visual with no temporal advance. |
| Suitcase + photograph | Human truth anchor | One composed foreground element. |
| Platform light | Environmental comparison anchor | Simple moving/soft light layer. |

### Minimum audio

| Cue | Purpose |
| --- | --- |
| Quiet station room tone | Establish place. |
| Clock tick | Makes the missing second legible. |
| Subtle selection feedback | Confirms player examination. |
| Short realization cue | Supports truth reveal. |

Do not pull old moment-specific audio into this slice. Existing platform audio playback capability may be reused only after its ownership is documented.

---

## 7. Required code

### New bespoke code

```text
scripts/experience/MissingSecondExperience.gd
```

Responsibilities limited to this one experience:

- own the short observation timer;
- control one changed detail;
- receive one player selection;
- evaluate success/failure;
- present one truth;
- emit a single completion/return request.

### No new abstractions

Do not create:

```text
GenericExperience
WitnessMomentDefinition
MomentRegistry
PhaseFramework
ReusableChoiceSystem
FragmentSystem
MomentPipeline
```

If a need appears more than once only after the first slice is proven playable, document it as a future extraction candidate rather than generalizing immediately.

---

## 8. Legacy discovery classification

| Existing area | Classification | Planned treatment |
| --- | --- | --- |
| Application shell | **Reuse** | Preserve as platform composition until reset review confirms exact new entry point. |
| Iris / awakening / portal shell | **Reuse candidate** | Preserve only if it supports the new single experience without importing old Witness logic. |
| Profile save boundary | **Reuse** | Keep local profile infrastructure; do not connect new experience progression until interaction is proven. |
| Audio / haptic / accessibility consumers | **Reference / selective reuse** | Reuse transport capability, not old moment keys/content. |
| Asset loader safety utilities | **Reference only** | May reuse safe texture/audio loading ideas if needed, without importing moment manifest architecture. |
| `GenericWitnessGameplay` | **Remove from active runtime** | Retired gameplay layer. Do not rename/rebuild it. |
| `WitnessMomentOrchestrator` | **Remove from active runtime** | Retired phase system. |
| `WM001GameplayLoop` | **Remove from active runtime** | Legacy prototype. |
| `FlagshipWitnessMoment` | **Remove from active runtime** | Legacy prototype. |
| WM/FМ JSON catalogues and moment assets | **Archive/remove during reset** | Retired content, not input to the new slice. |
| Fracture/Synchronization/Truth Fragment structures | **Do not reuse** | Retired old gameplay interpretation. |

---

## 9. Reset sequencing after plan approval

1. Verify/publish a pre-reset repository tag.
2. Archive/remove current Witness runtime/content branch according to Mission 070 cleanup report.
3. Preserve only approved platform foundations.
4. Add the one bespoke `MissingSecondExperience` scene and script.
5. Add only its required new assets/audio.
6. Wire one explicit Witness entry action to the bespoke scene.
7. Play it graphically with a human.
8. Fix clarity/interaction before introducing persistence, progression, Archive meaning, or a second experience.
9. Write a post-playtest decision before extracting any reusable system.

---

## 10. Acceptance criteria for the first slice

The first rebuilt experience passes only if an unfamiliar player can answer:

1. **What did I see?** — A traveler preparing to leave a waiting room.
2. **What was wrong?** — The clock skipped ahead of the rest of the room.
3. **What do I do?** — Select the detail that changed.
4. **Did I succeed?** — The experience clearly confirms or redirects the choice.
5. **Why did it matter?** — The missing second preserved a deliberate human choice.
6. **What happens now?** — I can return to the Iris.

No framework success criterion substitutes for this player understanding.