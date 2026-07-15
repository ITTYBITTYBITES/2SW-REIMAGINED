# Witness Moment Runtime Specification

**Status:** Design bridge only — no implementation in this phase
**Product:** Two Second Witness 4.0 Story Mode

## Purpose

Define the reusable runtime that turns a `WitnessMomentDefinition` into a coherent, resumable experience while keeping production challenge mechanics behind `ProductionWitnessHost`.

The runtime is the stage. It is not the Story Mode lobby, the Experience Director, or the production challenge engine.

```text
Living Iris
    ↓
Story Mode Chapter Shell
    ↓
Witness Experience Director
    ↓
Witness Moment Runtime
    ↓
ProductionWitnessHost
    ↓
Production challenge mechanics
```

## Responsibilities

### Witness Moment Runtime owns

- lifecycle state;
- beat sequencing;
- Arrival and Attunement;
- handoff to Observation/Memory/Investigation mechanics;
- Evidence/Revelation/Reflection framing;
- reward/archive handoff;
- pause/resume/cancel behavior;
- accessibility and channel selection;
- transition requests to/from the Iris;
- moment-level analytics context.

### Witness Moment Runtime does not own

- challenge generation;
- challenge scoring;
- production save schema;
- family difficulty calculations;
- interaction adapter correctness;
- XP/level/mastery calculations;
- Android input/device detection;
- final art/audio asset loading policy.

Those remain owned by production services, Iris Foundation systems, or content contracts.

# Lifecycle states

## State machine

```text
DORMANT
  ↓ open(moment)
ARRIVING
  ↓ arrival complete
ATTUNING
  ↓ ready
OBSERVING
  ↓ observation complete
RECONSTRUCTING
  ↓ response accepted
INVESTIGATING
  ↓ evidence understood / skipped
REVEALING
  ↓ truth presented
REFLECTING
  ↓ reflection complete / skipped
REWARDING
  ↓ progress committed
ARCHIVING
  ↓ archive update complete
RETURNING
  ↓ Iris transition complete
COMPLETED
```

## State definitions

### DORMANT

No active moment. Runtime holds no mutable interaction state.

### ARRIVING

- Iris transition is in progress.
- Moment metadata is loaded/validated.
- Production session context is prepared.
- User input is limited to Back/Cancel.

### ATTUNING

- The player receives the moment’s intention.
- Hidden information remains hidden.
- Voice/visual/caption guidance may occur.
- The runtime waits for the field to become ready.

### OBSERVING

- A declared observation window is active.
- The runtime records elapsed time and phase state.
- Production or future mechanics receive only the controls declared by the moment.
- Rotation/backgrounding must preserve state.

### RECONSTRUCTING

- The player responds to what was witnessed.
- The runtime requests the declared mechanic/adapter.
- The production session remains authoritative for response and timing.

### INVESTIGATING

- Optional or required evidence interaction is active.
- The runtime can present evidence, hints, relationships, or alternate viewpoints.
- Investigation interactions must not secretly rewrite the production result.

### REVEALING

- Truth/evidence is presented.
- The runtime coordinates camera, audio, voice, captions, and Iris response.
- Result explanation comes from production result data or approved moment evidence data.

### REFLECTING

- The player may choose an interpretation, confidence, testimony, or silence.
- Reflection is not required to invalidate the gameplay result unless the moment definition explicitly says so.

### REWARDING

- Production result/progress is finalized.
- XP/mastery/streak/achievement/recommendation services are called through existing authorities.
- No duplicate reward store is created.

### ARCHIVING

- A moment-level Archive record is created or projected from production history.
- Evidence and reflection metadata are associated with the moment.
- Archive failure must not erase the completed production result.

### RETURNING

- Production session cleanup occurs.
- Iris reverse transition begins.
- Completion context is handed to Story Mode/Director.

### COMPLETED

- Runtime clears active state after the Iris has received the completion context.
- A replay/resume snapshot is either removed or retained according to the moment contract.

# WitnessMomentDefinition data model

The following is a design schema, not a final code class.

```text
WitnessMomentDefinition
{
    id,
    version,
    chapter_id,
    rank_requirement,
    title,
    setting,
    theme,
    perception_goal,
    emotional_arc,

    arrival_sequence,
    attunement,

    observation_phase,
    memory_phase,
    investigation_phase,
    discovery_phase,
    reveal_sequence,
    reflection,

    challenge_sequence,
    production_context,

    rewards,
    archive_record,
    replay,
    mastery,

    accessibility,
    audio,
    music,
    camera,
    animation,
    voice,
    ui,

    save_resume,
    failure_recovery,
    developer_notes,
    asset_requirements,
    testing_requirements
}
```

## Core field intent

### Identity

- `id`: stable moment identity.
- `version`: content/behavior version for saves and replay.
- `chapter_id`: Story Mode chapter.
- `rank_requirement`: production-authoritative unlock context.

### Creative identity

- `title`: player-facing name when appropriate.
- `setting`: location/world context.
- `theme`: thematic subject.
- `perception_goal`: what the player is learning to notice.
- `emotional_arc`: intended feeling curve.

### Beat definitions

Each beat should declare:

- purpose;
- entry condition;
- exit condition;
- allowed input intents;
- text/voice/caption payload;
- visual/audio behavior;
- accessibility equivalent;
- fallback behavior;
- timeout/skip policy.

### Challenge sequence

A moment may reference one or more internal mechanics without exposing their family identity:

```text
ChallengeSequenceEntry
{
    production_family_id_or_future_mechanic,
    template_id_or_content_id,
    context,
    difficulty_context,
    exposure_context,
    response_context,
    required,
    sequence_order
}
```

The runtime passes the context to `ProductionWitnessHost` / `ChallengeSessionService`. It does not generate an instance itself.

# Interfaces and handoffs

## Story Mode → Director

Story Mode provides:

- current chapter/rank;
- requested intent: continue, daily, weekly, replay, new moment;
- player context;
- accessibility context.

The Director returns a `WitnessMomentSelection`:

```text
moment_id
chapter_id
selection_reason
production_context
resume_snapshot_if_any
```

## Director → Witness Moment Runtime

```text
open_moment(moment_definition, selection_context)
```

The runtime validates that the moment is available and requests the Iris entry transition.

## Witness Moment Runtime → ProductionWitnessHost

```text
start_sequence(sequence_entry, moment_context)
advance_sequence()
submit_response(response, reaction_ms)
request_result()
return_home()
get_session_snapshot()
```

The host adapts current production Tutorial/Observation/Recall/Result screens and future mechanics to the Runtime’s beat interface.

## ProductionWitnessHost → Runtime

Events should include:

- session ready;
- observation started;
- observation complete;
- response available;
- response submitted;
- result ready;
- session failed;
- session completed;
- user returned/aborted.

## Runtime → Iris Foundation

Requests:

- enter optical transition;
- set Iris state: attuning, observing, revealing, remembering;
- play sparse guidance;
- show captions if enabled;
- pulse haptic if enabled;
- return with completion/memory context.

## Runtime → Player/Content services

The runtime may request through existing services:

- progress/result commit;
- achievement evaluation;
- recommendation update;
- Archive projection/update;
- analytics event;
- audio profile.

It must not write directly to production files.

# Save and resume requirements

## What must be resumable

- moment ID/version;
- chapter/rank context;
- current lifecycle state;
- current beat index;
- production session ID/snapshot;
- observation elapsed time where fair;
- response state if already submitted;
- investigation evidence state;
- reflection draft/selection if applicable;
- accessibility settings in effect;
- content/seed/version references.

## Resume rules

- Resume must verify moment/content version compatibility.
- If a moment version is no longer compatible, migrate to a safe checkpoint or return to Iris without false completion.
- A committed production result must never be duplicated by resuming.
- If the player leaves during observation, the moment can restart that beat or resume only when fairness permits.
- If the player leaves after result commit, Archive/reward should remain intact.

## Persistence ownership

- Production session/progress: production services.
- Story Moment transient state: future Story Mode/Moment runtime state.
- Iris awakening/relationship state: Iris state layer.
- No third overlapping save authority.

# Authoring from a template

Every future moment should start from `WITNESS_MOMENT_TEMPLATE.md`.

Authoring sequence:

1. Define the perception goal and emotional arc.
2. Define Arrival and Attunement.
3. Define what the player can know and what remains hidden.
4. Define the observation truth/fairness contract.
5. Choose a temporary future mechanic container.
6. Define Memory/Reconstruction.
7. Define Investigation/Discovery.
8. Define evidence/reveal.
9. Define reflection/reward/Archive.
10. Define failure/retry/resume/accessibility.
11. Define production handoffs and content/assets.
12. Review against the Design Bible before implementation.

## Authoring anti-patterns

Reject a moment when:

- the mechanic exists before the story/perception goal;
- the answer is not fair to observe;
- the result cannot explain the truth;
- the player needs a family-name tutorial to understand the action;
- failure is only a score loss;
- the moment cannot return meaningfully to the Iris;
- accessibility changes the truth rather than the delivery.

# Runtime quality gates

Before implementation approval:

- creative review;
- interaction design review;
- fairness/accessibility review;
- production contract review;
- save/resume review;
- asset/audio budget review;
- human comprehension test;
- replay/mastery review.

# Final architectural decision

The Story Mode placeholder remains a progression/chapter shell. The Witness Moment Runtime is a separate future layer. ProductionWitnessHost remains the machinery adapter beneath it.

This separation lets future moments support different forms of witnessing without forcing them into a universal two-second challenge or a legacy family category.
