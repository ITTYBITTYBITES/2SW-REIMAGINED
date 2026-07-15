# Witness Moment Reward and Progression Model

**Status:** architecture only; no implementation in this phase

## Purpose

Rewards should make the player feel that their ability to notice is growing. Existing production XP, levels, mastery, streaks, achievements, programs, profile, and saves remain authoritative.

## Completion outputs

A completed Witness Moment may produce:

- production result;
- XP/progress points;
- family/perception mastery delta;
- current/best streak update;
- Witness Rank/Chapter progress;
- achievement evaluation;
- unlock eligibility;
- Archive Discovery record;
- Director recommendation context;
- replay/alternate interpretation availability.

## Witness Rank

Player-facing rank wraps existing production level/XP values:

1. Observer
2. Investigator
3. Archivist

Future rank names are narrative metadata. Numeric XP/level calculations remain production-owned.

## Story Chapters

Chapters group Witness Moments into a progression of perception ability. Chapter progress should be derived from or added to production unlock/progress data with an explicit schema migration if persisted.

Example abilities:

- Observer — hold attention in a field;
- Investigator — detect meaningful change;
- Archivist — preserve relationships and evidence.

## Mastery

Family mastery remains family-specific and numeric. The player-facing view can describe it as:

- Observation;
- Memory;
- Discovery/change detection;
- Connection/sequence;
- Accuracy;
- Consistency.

A combined Witness Rank may summarize these values, but must not destroy the individual family records.

## Discoveries and Archive

A Discovery is evidence/reveal metadata derived from completed production results:

- moment/family/template identity;
- scenario/content version;
- result outcome;
- evidence summary/highlights;
- date/history context;
- score/mastery context;
- replay availability.

Prefer a view over production history rather than a duplicate result database.

## Achievements and programs

Keep `AchievementService` and `ProgramService` as data/progress authorities. Story Mode can present achievements as Milestones and programs as guided Chapters without replacing identifiers or persistence.

## Streaks and consistency

Daily Witness can use current/best streaks. Weekly Investigation can track local completion continuity. Missing a day should not erase permanent Discoveries.

## Failure rewards

A failed reconstruction may still yield:

- evidence access;
- understanding;
- recovery progress where production policy allows;
- a retry or reinforcement recommendation.

Exact scoring remains family-owned. Story Mode must not invent a second score.

## Replay and mastery

Replay may reveal:

- hidden evidence;
- perfect observation markers;
- alternate interpretations;
- advanced versions;
- Archive completion;
- chapter/rank milestones.

Replay should be motivated by understanding and mastery, not only score inflation.

## Future rewarded video

The current audited product has no active monetization runtime. If added in a future update, rewarded video may offer optional hints, additional attempts, optional skip, or story continuation. It must not be required, interrupt observation, alter score silently, or remove an accessible non-ad path.

## Persistence rules

- `SaveService`, `ProfileService`, and `PlayerProgressService` remain authoritative.
- Iris awakening/relationship state remains separate from production progress.
- Story Mode fields require defaults/migration.
- Resetting Iris guidance must not reset production progress.
