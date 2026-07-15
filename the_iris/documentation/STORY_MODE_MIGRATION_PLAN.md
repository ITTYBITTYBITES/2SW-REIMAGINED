# Two Second Witness 4.0 Story Mode Migration Plan

**Scope:** safe transition strategy only
**Implementation changes:** none

## Migration principle

Migrate the doorway before migrating the rooms.

The production game already has working challenge generation, scoring, content, saves, profile, settings, accessibility, audio, and progression. Story Mode should add a new experience director and framing layer around those systems, not replace them.

## Current state → target state

```text
Current
Iris → production screen host → challenge route

Target
Iris → Story Mode Director → Witness Moment → Challenge Sequence
       ↓                                      ↓
  story/chapter context                 production runtime
```

## Safe migration stages

### Stage 0 — freeze and protect

Before implementation:

- lock the current foundation baseline;
- preserve the five families and production save schema;
- record current routes and result contracts;
- create test fixtures for an existing Scene Investigation result;
- establish a feature flag or development-only Story Mode entry so direct production routes remain available during migration.

No user data or production route should be made unreachable during this stage.

### Stage 1 — introduce Story Mode state, not new gameplay

Add a future Story Mode state model with:

- current chapter/rank;
- current Witness Moment ID;
- current beat;
- Director reason;
- family introduction state;
- interruption/resume snapshot.

This state should be transient/session state unless a production progression decision explicitly requires persistence. Do not duplicate `ProfileService` or `ChallengeSessionService` state.

### Stage 2 — add Experience Director façade

The Director should call existing production APIs:

```text
Director
→ RecommendationService / PlayerProgressService
→ ChallengeSessionService.start_family_session(...)
→ existing production routes and adapters
```

The Director chooses family/template/context. The production runtime still generates, validates, scores, saves, and recommends.

### Stage 3 — make Scene Investigation the reference moment

Frame one existing Scene Investigation scenario with:

- Iris entry;
- Witness framing;
- existing observation duration;
- existing recall adapter;
- evidence reveal;
- existing result/progress contract;
- return-to-Iris memory.

Do not change family scoring or timing during this stage.

### Stage 4 — move tutorial logic into Story Mode beats

- First family introduction becomes a beat in the first Witness Moment.
- Tutorial screen remains replayable through Library/Training.
- Tutorial completion continues to write production tutorial state.
- Accessibility and reduced-motion paths remain equivalent.

### Stage 5 — add Rank Chapter structure

Introduce thematic framing around existing families:

- Rank 1 — Observer;
- Rank 2 — Investigator;
- Rank 3 — Archivist;
- future ranks as approved content.

Ranks should consume existing XP/mastery/unlock signals. They should not replace numeric progress or create a parallel save.

### Stage 6 — unify Archive/Library

The current Library and Iris Archive should become two views of the same production catalog/history source:

- Iris Archive: atmospheric, memory-first, minimal choices;
- Library/Training: explicit, filterable, replay/mastery-oriented.

Both should resolve the same family/template IDs and history records.

### Stage 7 — migrate other families into internal sequences

After the Scene Investigation reference is accepted:

1. Spot the Difference — comparison beat;
2. Object Recall — set-memory beat;
3. Pattern Recall — connection/order beat;
4. Flash Words — fleeting-signal beat.

Each migration preserves its family mechanics and adapter.

### Stage 8 — make Story Mode the default root flow

Only after Stage 3–7 are tested:

- Iris center starts Director-selected Story Mode;
- direct family selection moves to Library/Training;
- production AppShell is retained only as compatibility infrastructure or secondary rooms;
- direct route/deep-link behavior remains available for accessibility, tests, and recovery.

## Transition safety rules

- Every Story Mode beat must be resumable after Back, rotation, or app interruption.
- Production `ChallengeSessionService` must remain the only active challenge session owner.
- `NavigationService` must remain the only production route history owner.
- `MainController` must not directly mutate production profile/progress.
- Story Mode state must not overwrite production result state.
- If a Director decision fails, fall back to a valid production recommendation.
- If a production session fails, return through the Iris with an error/recovery moment.

## Old flow mapping

| Old experience | Transition strategy |
|---|---|
| Home product hub | Keep as secondary catalog/explicit-access room; Iris becomes default root. |
| Play Now | Director-selected Witness Moment. |
| Continue | Director reads active/recent production session and resumes a Story Moment. |
| Daily featured | Future Director input; do not expose as a mandatory first decision. |
| Challenge Library | Iris Archive/secondary Library dual-view. |
| Profile | Witness Record room. |
| Settings | Instrument Calibration room using production SettingsService. |
| Tutorial | Story beat on first introduction; replayable in Library. |
| Observation/Recall/Result | Internal Challenge Sequence beats inside a Witness Moment. |

## Rollout and fallback

### Development rollout

- Story Mode behind a development flag initially.
- Existing direct route tests remain usable.
- Simulator overlay reports Story Mode beat/direct route context.
- Every Director selection emits a traceable reason.

### Internal test rollout

- Enable Story Mode for first-launch sessions.
- Preserve explicit Library start for testers.
- Compare Story Mode completion, abandonment, and comprehension to the old route.

### Production rollout

- Only after save migration, accessibility, result integrity, and physical-device validation.
- Keep direct route fallback for deep links, accessibility, support, and corrupted Story Mode state.

## Validation gates

1. No code path starts a challenge without `ChallengeSessionService`.
2. No result bypasses `ResultService` / `PlayerProgressService`.
3. Back always returns through Iris at the product layer.
4. Profile/settings/save schemas remain compatible.
5. Family-specific tests remain green.
6. Story Mode interruption/resume is tested.
7. New players can understand the first Witness Moment.
8. Returning players see continuity rather than a reset.

## Non-goals

- Do not delete current screens yet.
- Do not rewrite family generators or policies.
- Do not add new challenge types.
- Do not redesign assets in this migration plan.
- Do not replace the production AppBoot/service graph.
