# Experience Architecture Final

## Product-facing structure

```text
Two Second Witness 4.0
    ↓
Living Iris
    ├── Center: Story Mode
    ├── Right: Discover constellation
    │      ├── Daily Witness
    │      ├── Weekly Investigation
    │      ├── Your Iris
    │      ├── Archive
    │      └── Calibration
    ├── Left: Archive / Challenge Library
    ├── Down: Your Iris / production Profile
    └── Up: Calibration / production Settings
```

The Iris is the gateway. The existing production challenge families are internal mechanics under future Witness Moments.

## Story Mode

Primary experience: a cinematic sequence of Witness Moments.

Placeholder:

- Rank Chapter;
- current rank/progress;
- current/future moment locations;
- locked/unlocked state;
- central focus point leading into the existing production Witness flow.

## Daily Witness

One personal, offline-first Witness Moment per day.

Future contract:

- deterministic daily seed;
- completion;
- personal best;
- streak;
- reflection;
- no server/account/global leaderboard requirement.

## Weekly Investigation

A longer-form local/curated investigation.

Future contract:

- featured case;
- multi-step Witness Moment sequence;
- resume state;
- completion;
- Archive reward/evidence.

## Your Iris

Unified personal space for:

- Witness Rank;
- Growth/Mastery;
- Archive;
- Discoveries;
- Achievements;
- personal statistics;
- calibration/settings.

Production Profile and Settings rooms remain authoritative during transition.

## Future Moment layers

```text
Witness Moment
    ├── Arrival / Attunement
    ├── Observation Mechanic TBD
    ├── Memory Mechanic TBD
    ├── Discovery Mechanic TBD
    ├── Evidence Mechanic TBD
    ├── Reflection Mechanic TBD
    └── Reward / Archive / Return
```

## Ownership

- Iris owns entry, relationship, navigation, and return.
- Production services own challenge mechanics, scores, progress, settings, and saves.
- Content systems own scenario/moment data and assets.
- Future Director chooses experiences but does not replace ChallengeSessionService.
