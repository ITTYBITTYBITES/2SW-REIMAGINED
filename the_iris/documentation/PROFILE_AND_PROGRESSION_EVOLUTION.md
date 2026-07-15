# Profile and Progression Evolution

**Status:** architecture/discovery only; no implementation in this phase

## Current production systems

The current production player model contains:

- profile ID and display name;
- XP and level;
- total sessions and play time;
- unlocked experiences;
- per-family progress;
- observations/correct observations;
- reaction timing;
- current and best streaks;
- family mastery;
- achievements and achievement progress;
- favorite challenge types;
- programs and active program progress;
- settings/preferences;
- recent history and recent seeds/signatures.

`SaveService` persists versioned profile/settings JSON with atomic writes, backup recovery, and migrations. `ProfileService` and `PlayerProgressService` are the durable authorities.

## Preserve without change

- profile schema and migration guarantees;
- XP/level calculations until an approved product migration exists;
- family mastery and accuracy records;
- current/best streaks;
- achievements and program progress;
- history and replay metadata;
- unlock checks;
- settings/accessibility persistence;
- production save paths and package continuity.

## Proposed player-facing evolution

### Witness Rank

Current numeric level/XP becomes visible as a Witness Rank presentation:

- Rank 1 — Observer;
- Rank 2 — Investigator;
- Rank 3 — Archivist;
- future ranks based on approved chapters/content.

The numeric level remains the production calculation. Rank name, description, and unlock framing are presentation metadata.

### Story Chapters

Chapters are thematic groupings of Witness Moments. They consume current XP, mastery, and unlock signals.

Examples:

- Chapter 1: Learning to Notice;
- Chapter 2: What Changed;
- Chapter 3: Holding the Pattern;
- Chapter 4: Reading the Record.

A chapter should not become a second save schema. It can store a current chapter ID and completed beat IDs only if the production profile migration explicitly owns those fields.

### Witness Archive

The Archive is the atmospheric view of existing production history:

- completed moments;
- evidence/reveal records;
- family/template names;
- score/mastery outcomes;
- dates and streak context;
- replay/tutorial entry.

It should read `PlayerProgressService.get_recent_history()` and production result metadata rather than storing duplicate discoveries.

### Mastery

Family mastery remains family-specific and numeric. The player-facing language can describe what the mastery means:

- Scene Investigation — Field Notice;
- Spot the Difference — Change Detection;
- Object Recall — Set Memory;
- Pattern Recall — Connection Memory;
- Flash Words — Signal Catch.

Do not flatten all family mastery into one score. A combined Witness Rank can use the production values while the Archive preserves individual strengths.

### Discoveries

A Discovery is an evidence/reveal record derived from a completed result. It should include:

- challenge family/template;
- scenario/content version;
- result outcome;
- evidence/reveal metadata;
- time and progression context;
- replay-safe identifiers.

Discoveries should be additive to production history and safe to regenerate/display if older assets are migrated.

## Progression loop

```text
Complete Witness Moment
→ production result
→ family progress / mastery / streak
→ XP / Witness Rank evaluation
→ achievement/program evaluation
→ Archive Discovery entry
→ Director receives updated player state
→ next Story Moment or rest
```

## Replay motivation

The evolution should add meaning without removing current motivations:

- improve score;
- increase mastery;
- recover a streak;
- complete a chapter;
- unlock a new perception ability;
- fill the Archive;
- earn achievements;
- continue a Program;
- revisit a meaningful Discovery.

## Migration rules

1. Add presentation labels before changing calculations.
2. Keep production profile keys stable where possible.
3. Add new fields with defaults and migrations.
4. Never infer completed content from an Iris-only setting.
5. Recompute presentation summaries from authoritative production progress when possible.
6. Keep an explicit fallback for old profiles with no chapter/discovery fields.
7. Test a profile with zero progress, mid-level progress, max progress, and corrupt/legacy data.

## Open questions

- Whether chapter completion should be persisted separately or derived from existing achievements/unlocks.
- Whether a Discovery should be a new durable record or a view over result history.
- Whether partial performance should produce meaningful progress without weakening exact answer scoring.
- Whether Witness Rank should be a single combined value or a narrative wrapper over family mastery.
