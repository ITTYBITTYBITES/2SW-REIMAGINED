# Scene Investigation Vertical Slice Plan

**Status:** Blueprint only — no implementation in this phase
**Reference family:** Scene Investigation
**Purpose:** Define the first rebuilt Witness Story Mode experience without changing current gameplay yet.

## Objective

Build one complete, production-quality perception journey that proves the Iris can open, frame, and remember the existing Two Second Witness mechanics.

The slice must preserve the production Scene Investigation generator, validator, exposure policy, scoring policy, result contract, and progress services. The redesign is primarily the experience/presentation layer.

## Slice scope

### In scope

- Iris entry transition;
- one authored Scene Investigation scenario;
- observation exposure;
- recall response;
- evidence reveal;
- reward/progress acknowledgement;
- return-to-Iris memory response;
- voice/visual/haptic/caption equivalents;
- desktop Mobile Simulator validation;
- reduced motion and explicit access behavior.

### Out of scope

- new challenge family;
- scoring changes;
- new timing policy;
- full Scene Investigation scenario portfolio;
- daily/weekly rotation;
- monetization;
- new long-term reward economy;
- final asset replacement for every scenario.

## Target journey

```text
Living Iris
  ↓ pupil / optical transition
Witness Moment framing
  ↓ field settles
Scene Investigation observation
  ↓ exposure completes
Recall question
  ↓ response submitted
Evidence reveal
  ↓ result/progress
Witness Record acknowledgement
  ↓ reverse optical transition
Living Iris remembers the moment
```

## Beat-by-beat design

### Beat 1 — Iris invitation

- Iris idles in the home state.
- Recent history and Director context decide whether this is a first introduction, reinforcement, recovery, or continuation.
- Center pupil responds to touch/hover.
- Voice, if enabled, uses a minimal phrase such as “Look closer.”

### Beat 2 — Iris entry

- Tap center commits `Enter` intent.
- Pupil opens and the optical chamber travels inward.
- `ProductionWitnessHost` becomes the experience host.
- The current production session is started through `ChallengeSessionService`.
- If tutorial gating is required, the production Scene Investigation tutorial appears before observation.

### Beat 3 — Witness framing

Before the scene appears, the player receives a short perceptual frame:

- no conventional menu;
- no long instructions;
- one line/visual signal describing the goal;
- scene identity remains secondary to the field of attention.

Suggested phrase:

> “Notice what changes.”

### Beat 4 — Observation

- Use existing generated `ChallengeInstance`.
- Use the existing resolved `exposure_duration_sec`.
- Render the authored/production candidate scene through `SceneInvestigationSceneView` or its approved replacement.
- Show an unambiguous but non-gamey attention window.
- Preserve comfortable timing, reduced motion, color assistance, and minimum target contracts.
- Do not alter the generator or validator in the vertical slice.

### Beat 5 — Recall

- Route to the existing `MemoryQuestionScreen`.
- Use the family-declared `single_choice` adapter.
- Preserve the exact response payload and reaction-time measurement.
- The new presentation may change framing and copy, but not the scoring contract.

### Beat 6 — Evidence reveal

- Use `ChallengeResult.reveal_data` and Scene Investigation highlight IDs.
- Show the original scene with the missed object/relationship made legible.
- Explain the answer in plain, perception-centered language.
- Correct and incorrect outcomes should both result in a meaningful discovery.

Suggested incorrect-result language:

> “It was already there.”

Suggested correct-result language:

> “You caught the change.”

### Beat 7 — Reward

The vertical slice should acknowledge:

- progress points;
- family mastery change;
- history entry;
- Witness Record update;
- achievement/recommendation hooks if production rules trigger them.

Do not introduce a new currency or parallel reward system.

### Beat 8 — Return

- Result closes through the Iris, not directly to a production Home screen.
- Iris brightness/alert memory responds to the result.
- Archive/history can now reflect the production result.
- Director receives the completed result context for the next selection.

## Technical integration plan

### Existing systems to reuse

- `MainController.gd` for Iris entry/return orchestration;
- `TransitionController.gd` for optical travel;
- `BackNavigationController.gd` and Input Intent layer;
- `ProductionBridge.gd` for AppBoot readiness;
- `ProductionWitnessHost.gd` for route mounting;
- `ChallengeSessionService.gd` for session lifecycle;
- `SceneInvestigationFamily.gd` and its generator/validator/policies;
- `ObservationChallengeScreen.gd` / `MemoryQuestionScreen.gd` / `ResultScreen.gd` contracts;
- `PlayerProgressService.gd` and `ProfileService.gd`;
- `AudioService.gd` and `AccessibilityService.gd`;
- `VoiceGuide.gd` for milestone guidance.

### Future files likely required

These are planning targets, not files to create in this phase:

- `src/iris/story/WitnessExperienceDirector.gd`
- `src/iris/story/WitnessBeat.gd`
- `src/iris/story/WitnessStoryState.gd`
- `src/ui/witness/SceneInvestigationWitnessFrame.tscn`
- `src/ui/witness/SceneInvestigationEvidenceReveal.tscn`
- `src/ui/witness/WitnessRewardMoment.tscn`
- content/version metadata for the selected scenario.

### Director handoff

The Director should request a family/template/session through the production API. It should not instantiate generators directly.

```text
Director selection
→ ChallengeSessionService.start_family_session(
     family_id,
     template_id,
     source="witness_story",
     session_context={story_beat, introduction_state, director_reason}
  )
```

The session context can be stored in the production active session/result metadata without creating a second save system.

## Content slice recommendation

Use one existing Scene Investigation content entry as the reference scenario. The recommended first slice is an authored environment with:

- clear depth layers;
- 10–13 standard-tier objects;
- one visually meaningful change/question;
- a distinctive evidence target;
- enough negative space for small phone screens;
- a background that can support portrait and landscape composition;
- a fallback vector/texture path while final art is being produced.

Do not add new art until the production content contract and target/evidence behavior are approved.

## Acceptance criteria

### Iris integration

- Tap center opens the slice through the pupil transition.
- Back closes the slice through the reverse Iris transition.
- There is no visible detour through a traditional Home screen.
- Iris remembers the result on return.

### Gameplay

- Existing Scene Investigation instance is generated and validated.
- Observation duration comes from the production exposure policy.
- Recall uses the production adapter.
- Scoring/result comes from the family scoring policy.
- Evidence reveal uses production result metadata.
- Progress/history/mastery persist through production services.

### Accessibility

- Voice-enabled and voice-disabled paths communicate the same objective.
- Captions are optional and not shown by default.
- Reduced motion does not remove comprehension.
- Comfortable timing is respected.
- Explicit access can launch/complete the same journey.

### Performance

- No full production asset tree is loaded just to open one scenario.
- One scene instance and its required resources are active at a time.
- Frame rate remains stable in portrait and landscape simulator profiles.
- Transition and reveal animations do not create duplicate audio/player pools.

## Risks to resolve before implementation

1. Production screens currently assume AppShell-style presentation context; the host must provide only the context they actually require.
2. Result → Iris return needs a clean handoff so production session cleanup does not race the optical transition.
3. The existing `MemoryQuestionScreen` may be mechanically correct but visually too conventional for Story Mode; it should be framed rather than rewritten first.
4. Evidence reveal quality depends on family-generated `highlight_ids` and `where_to_look` data being complete.
5. The Director must not bypass the existing recent-signature and recommendation safeguards.

## Implementation order after blueprint approval

1. Add a Director selection façade without changing family mechanics.
2. Add a single Witness Story state/beat contract.
3. Frame existing Scene Investigation observation without replacing its generator.
4. Frame existing recall and result screens.
5. Add Iris reward/return response.
6. Validate saves/progression/accessibility/performance.
7. Only then begin asset replacement batches.
