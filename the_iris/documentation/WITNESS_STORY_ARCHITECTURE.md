# Witness Story Architecture

**Status:** future product architecture blueprint; no implementation in this phase

## Core model

```text
Living Iris
    ↓
Witness Story Mode
    ↓
Rank Chapter
    ↓
Witness Moment
    ↓
Challenge Sequence
```

The player sees a continuous journey. The challenge family is an internal mechanic selected by the Director.

## Story Mode

Story Mode is the default player journey across Two Second Witness. It is not a sequence of menus. It is a set of authored and Director-selected perception chapters.

Story Mode owns:

- opening/closing through the Iris;
- chapter context;
- Witness Moment beats;
- family introductions;
- result/evidence pacing;
- reward and return memory;
- continuation/rest decisions.

It does not own:

- challenge generation;
- scoring;
- save schema;
- family rules;
- interaction adapter correctness.

## Rank Chapter

A Rank Chapter is a thematic progression stage. It gives the player a reason for the next group of moments without requiring a conventional level-select menu.

Initial thematic concept:

| Rank | Name | Perception theme |
|---|---|---|
| 1 | Observer | Notice a field and hold attention |
| 2 | Investigator | Compare, question, and detect change |
| 3 | Archivist | Remember relationships, sequences, and history |

Rank Chapters should consume current XP/mastery/unlock data and add narrative framing. They must not replace production numeric progression.

## Witness Moment

A Witness Moment is one self-contained cinematic experience:

1. Iris invitation;
2. entry transition;
3. story framing;
4. observation/exposure;
5. recall/response;
6. discovery/evidence;
7. reward/progression;
8. Iris return/memory.

A moment may contain one or several challenge sequences, but the player should understand the moment’s meaning rather than the technical family name.

## Challenge Sequence

A Challenge Sequence is the internal gameplay unit. Existing families remain sequence providers:

- Scene Investigation provides rich scene observation;
- Spot the Difference provides comparison/change detection;
- Object Recall provides set memory;
- Pattern Recall provides connection/order memory;
- Flash Words provides fleeting signal recognition.

Each sequence still uses the production generator/validator/policy/adapter/result system.

## Experience Director

The future Director selects:

- Story Mode beat;
- family/template/scenario;
- difficulty and exposure via production policies;
- pacing and narrative framing;
- first-introduction vs reinforcement vs surprise vs recovery;
- next recommendation or rest.

Inputs:

- player skill/mastery;
- family history;
- recent signatures;
- streak and accuracy;
- rank/chapter;
- novelty/variety;
- accessibility and timing settings;
- current Iris relationship state.

The Director calls `ChallengeSessionService`; it does not create or score instances directly.

## Witness Archive

The Iris left/Archive destination becomes a secondary advanced space for:

- completed Witness Moments;
- challenge family history;
- evidence reveals;
- replay/tutorial access;
- family mastery;
- favorites;
- Programs and curated runs;
- explicit Challenge Library access.

Story Mode remains the default. The Archive exists for agency and mastery.

## Profile and progression

The Profile destination becomes the Witness Record:

- Witness Rank;
- Rank Chapters;
- family mastery;
- discoveries/evidence;
- achievement milestones;
- current/best streaks;
- history and personal patterns.

The production ProfileService and PlayerProgressService remain authoritative.

## Settings and accessibility

The Settings destination becomes Instrument Calibration while retaining production SettingsService and AccessibilityService:

- audio/mute;
- haptics;
- text/caption access;
- reduced motion;
- high contrast/color assistance;
- comfortable timing;
- explicit navigation;
- orientation/parallax preferences.

## Return and interruption rules

- Every Story Mode moment returns through the Iris.
- Android Back returns to the Iris after production session cleanup.
- Rotation preserves Story Mode beat, challenge session, timer, response, and progress state.
- Interruption resumes through a deterministic session snapshot or safely returns to the Iris.
- A failed Director selection falls back to a valid recommendation, never a dead screen.

## Future update compatibility

New roadmap updates should add:

- a new Rank Chapter;
- new Witness Moments;
- new content/scenarios;
- new family modules only when a truly new perception mechanic is required;
- new Archive/Discover evidence;
- additive achievement/program/recommendation data.

They should not add a new root shell or duplicate progress/navigation services.
