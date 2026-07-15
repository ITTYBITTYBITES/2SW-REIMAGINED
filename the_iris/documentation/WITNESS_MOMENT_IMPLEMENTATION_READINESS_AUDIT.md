# Witness Moment Implementation Readiness Audit

**Status:** readiness audit only — no implementation in this phase
**Product:** Two Second Witness 4.0 Story Mode

## Executive readiness verdict

The project is ready for a **small Runtime Skeleton phase**, not yet for a full Story Mode rewrite or a ten-moment content build.

The minimum safe first implementation is:

```text
Story Mode placeholder
→ one Chapter One entry
→ one Moment Definition
→ Runtime state machine
→ existing ProductionWitnessHost
→ existing production Observation / Recall / Result
→ Iris return
```

The first milestone should prove the translation layer, not redesign the mechanics.

## Layer ownership

```text
Story Mode
  answers: where am I in the journey?

Witness Experience Director
  answers: which moment should happen next?

Witness Moment Runtime
  answers: what beat is active and what happens next?

ProductionWitnessHost
  answers: how do existing production screens/mechanics mount and report state?

Production Challenge Runtime
  answers: how is the mechanic generated, validated, scored, saved, and progressed?
```

## Systems reusable unchanged

### Iris Foundation

Reuse without gameplay changes:

- Living Iris shader/state behavior;
- Iris center/Discover/Archive/Profile/Settings destination model;
- `InputIntentController`;
- `NavigationController`;
- `TransitionController`;
- `BackNavigationController`;
- `OrientationManager`;
- `DeviceCapabilityManager`;
- `VoiceGuide` and captions;
- explicit accessibility path;
- Mobile Device Simulator.

These systems already provide entry, return, multimodal guidance, hardware abstraction, and device continuity.

### Production boot and player systems

Reuse unchanged as authorities:

- `AppBoot.gd`;
- `AppState.gd`;
- `EventBus.gd`;
- `NavigationService.gd`;
- `SaveService.gd`;
- `ProfileService.gd`;
- `PlayerProgressService.gd`;
- `SettingsService.gd`;
- `AccessibilityService.gd`;
- `AudioService.gd`;
- `AnalyticsService.gd`;
- `ThemeService.gd`.

### Production game runtime

Reuse unchanged for the first slice:

- `ChallengeSessionService.gd`;
- `ChallengeFamilyRegistry.gd`;
- `ChallengeInstance`;
- `ChallengeResult`;
- `ChallengeValidationResult`;
- `ResultService.gd`;
- `InteractionAdapterRegistry.gd`;
- existing Scene Investigation family policies/generator/validator/scoring;
- existing Observation/Memory Question/Result screen contracts.

Do not create a new result, score, save, or challenge controller for the Runtime Skeleton.

## Systems requiring adapters

### Story Mode → Director adapter

The current Story Mode placeholder has a focus action that opens Witness. It needs an adapter that supplies:

- chapter ID;
- rank context;
- moment ID;
- selection reason;
- first/repeat/introduction state;
- production session context.

The adapter may initially return one hardcoded development moment, but it must use the future Director boundary rather than calling a family generator directly.

### Director → Moment Runtime adapter

The Director should select a `WitnessMomentDefinition` and pass it to the Runtime. The first slice can use a static definition loaded from a placeholder content resource.

### Runtime → ProductionWitnessHost adapter

The Runtime needs event handoffs for:

- session requested;
- production session ready;
- observation started;
- response phase entered;
- result ready;
- session failed;
- session returned/home.

The host remains a backstage adapter. Its name and route should not appear in player-facing copy.

### Production result → Story reward adapter

The Runtime should translate a `ChallengeResult` into:

- Evidence/Reflection beat context;
- Archive projection;
- Rank/Chapter presentation;
- Iris memory response.

It must not recalculate score or mastery.

### Save/resume adapter

The first skeleton needs a transient Runtime snapshot containing:

- moment ID/version;
- current lifecycle state;
- beat index;
- production session ID;
- resume/exit policy.

Durable progress remains production-owned.

## Minimum new scripts for Runtime Skeleton

The smallest production-shaped implementation should require no more than:

1. `WitnessMomentDefinition.gd` — data contract/resource.
2. `WitnessMomentState.gd` — lifecycle state and transient snapshot.
3. `WitnessMomentRuntime.gd` — state machine and beat transitions.
4. `WitnessMomentEvents.gd` or an equivalent typed event contract — start/phase/result/complete signals.
5. `WitnessExperienceDirector.gd` — initial static selection façade.
6. `StoryModeChapterShell.gd` — replaces the placeholder’s future action with a chapter/moment handoff.
7. `ProductionWitnessAdapter.gd` — translates Runtime requests/events to existing ProductionWitnessHost.
8. `WitnessMomentDebugOverlay.gd` — development-only phase/state logging, removable or excluded from release.

Some of these can be combined during the skeleton experiment, but the ownership boundaries should remain explicit even if the files are fewer.

## Existing files that become legacy or secondary

### Legacy mechanics

- `src/LegacyMechanics/` remains internal infrastructure.
- Family scripts do not become Story Mode controllers.
- Family names should remain in Library/Training/debug contexts.

### Existing Story Mode placeholder

- `StoryModePlaceholder.tscn` / `FuturePlaceholder.gd` remain as the chapter-shell prototype.
- Their focus action should eventually call Director → Runtime instead of calling production Witness directly.

### ProductionWitnessHost

- Keep as compatibility adapter for the first slice.
- Do not expand it into a Story Mode Director.
- Do not expose its name in player-facing UI.

### Existing production screens

- Observation, Memory Question, and Result remain room/beat implementations for the first slice.
- Their framing can be adapted later, after the Runtime handoff is proven.

### Legacy AppShell chrome

- Keep for production room compatibility and direct routes.
- Do not use it as the new Story Mode root.

## First vertical slice milestone

### Moment 001 — Scene Investigation reference

The first milestone should be one moment only:

```text
Iris
→ Story Mode
→ Rank 1 / Observer
→ Moment 001
→ Arrival
→ Attunement
→ Production Observation
→ Production Recall
→ Production Result/Evidence
→ Reward/Archive projection
→ Iris return
```

### Acceptance criteria

- Story Mode focus opens a moment definition, not a raw family route.
- Runtime emits each lifecycle phase in order.
- ProductionWitnessHost receives a production context and starts the current valid session.
- Existing observation/recall/result mechanics still determine correctness and score.
- Runtime receives result data without interpreting family rules.
- Archive/progression uses existing production services.
- Back, interruption, and return close cleanly through the Iris.
- The phase can be inspected through a debug overlay without exposing technical names to players.
- Sound-off, captions, reduced motion, and explicit access remain usable.

### Explicit non-goals

- no new Scene Investigation mechanics;
- no final cinematic art;
- no new scoring;
- no new rank calculation;
- no ten-moment chapter build;
- no Daily/Weekly gameplay;
- no ad integration;
- no replacement of ProductionWitnessHost yet.

## Implementation order after approval

1. Create the Runtime data/state/events contracts.
2. Create a static Director selection for Moment 001.
3. Replace the Story Mode placeholder action with Director handoff.
4. Add Runtime → ProductionWitnessHost adapter.
5. Run the existing production Observation/Recall/Result sequence.
6. Translate result into Evidence/Reward/Archive context.
7. Return through Iris.
8. Validate interruption/resume and accessibility.
9. Only after this passes, design the first actual Witness Moment presentation layer.

## Readiness risks

1. The current production challenge flow may assume AppShell-specific parent context; validate the host boundary first.
2. `NavigationService` and Iris `MainController` both have navigation responsibilities; Runtime must not create a third route owner.
3. Story Mode state must not duplicate `ChallengeSessionService` state.
4. Archive projection must not introduce a second result database.
5. The first slice must demonstrate a meaningful Evidence/Reward beat rather than simply relabeling ResultScreen.

## Final decision

The project is ready to implement a **Runtime Skeleton** as the next controlled phase. The correct first goal is not a new mechanic or a new visual system. It is proving that one authored Witness Moment can travel safely through the new layer boundaries while the production game remains authoritative behind the curtain.
