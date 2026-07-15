# Legacy Challenge Transition Plan

## Purpose

Move from challenge-family-first product language to Witness Moment experiences without deleting or breaking production challenge infrastructure.

## KEEP

Preserve permanently:

- scoring infrastructure;
- family difficulty/exposure framework;
- seeded generation and fairness validation;
- production save/profile/progression systems;
- accessibility and alternate interaction adapters;
- analytics framework;
- audio framework;
- content loading and manifests;
- result/evidence contracts;
- ChallengeSessionService lifecycle;
- challenge history/replay metadata;
- existing five families as internal mechanic providers.

## MODIFY

### Challenge Family Registry

Keep family registration and content loading. Remove its role as a player-facing home taxonomy over time.

### Challenge selection / Library

Keep as secondary Archive/Training/Library. Add story/context framing and explicit accessibility access.

### Difficulty and progression

Keep calculations. Present results as Witness Rank, Mastery, Chapters, Discoveries, and personal records.

### Tutorials

Keep replayable family tutorials. Convert first exposure into Story Mode attunement/guided beats.

### Observation / Recall / Result screens

Keep production route/contracts and adapters. Modify their framing so they read as Arrival, Reconstruction, Revelation, and Reflection beats.

### Recommendations

Keep RecommendationService. Add a future Witness Experience Director façade that uses it without duplicating selection logic.

## RETIRE from default player flow

- challenge-family-first entry;
- standalone “choose a mini-game” language;
- direct Home dashboard as the first destination;
- family names as first-session instructions;
- tutorial pages as the first Story Mode explanation;
- generic Result → Home endings.

These can remain reachable through Archive/Library, explicit accessibility navigation, support/deep links, and tests until Story Mode parity is proven.

## REPLACE LATER

- generic challenge Library as primary discovery;
- old top/tab navigation as the default root mental model;
- family-specific tutorial-first onboarding;
- generic result copy;
- old standalone progression/profile surfaces;
- challenge-family names used as the only player-facing identity;
- prototype/fallback presentation layers after production Witness hosts have parity.

## Transition stages

1. Keep current production runtime and challenge families unchanged.
2. Add future mechanic containers and Witness Moment contract.
3. Build one Story Mode moment using a production family internally.
4. Move tutorial/result/evidence framing into the moment.
5. Make Iris Story Mode the default entry.
6. Move family selection to secondary Library/Training.
7. Rename presentation only after data/save/analytics migrations are verified.
8. Remove/archival old routes only after dependency and accessibility tests pass.

## Do not delete

- existing challenge families;
- old scores/history;
- production content/assets;
- tutorials before Story Mode replacement is complete;
- result screens before new evidence/reward surfaces are proven;
- save/profile schema or migration code;
- routes needed for recovery, testing, or accessibility.

## Acceptance gates

A legacy layer can leave the default flow only when:

- equivalent Story Mode behavior exists;
- production scoring/progress is identical or migrated;
- saved profiles continue to load;
- accessibility paths exist;
- direct/Library access remains where appropriate;
- analytics events remain comparable;
- physical/human testing confirms the new model is understandable.
