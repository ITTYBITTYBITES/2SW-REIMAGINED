# Future Experience Map

## Product intent

The Living Iris is the application foundation. It reveals experiences as meaningful places rather than presenting a mode list.

```text
Living Iris
│
├── Center → Story Mode
├── Right → Discover constellation
│   ├── Daily Witness
│   ├── Weekly Investigation
│   ├── Future experiences
│   └── challenge signals
├── Left → Archive / Challenge Library
├── Down → Your Iris / Witness Record
└── Up → Calibration / production Settings
```

## Placeholder destinations

### Iris Hub

The existing Living Iris is the hub. `IrisHubPlaceholder.tscn` is a named architecture alias for future hub composition; the current Iris remains the actual living instrument.

### Story Mode

`StoryModePlaceholder.tscn` is now reachable from the center pupil and the Discover constellation. It communicates:

- Rank 1 — Observer;
- current attention progress;
- the first chapter forming;
- a central focus point that leads into the existing production Witness flow.

It is intentionally a place, not a card grid.

### Daily Witness

`DailyWitnessPlaceholder.tscn` is reachable from Discover. It communicates:

- today’s personal witness;
- ready/completed state;
- streak/personal-best placeholders;
- offline, individual, mastery-oriented intent.

It does not add server accounts, leaderboards, or a new challenge mechanic.

### Weekly Investigation

`WeeklyInvestigationPlaceholder.tscn` is reachable from Discover. It communicates:

- featured case;
- investigation progress;
- completion state;
- future archive reward.

### Archive

The existing Archive destination now remains the left doorway and can mount the production Challenge Library/Experiences room. Its Iris fallback still communicates memory/history when production room loading is unavailable.

### Your Iris

`YourIrisPlaceholder.tscn` is a future personal-space concept. The existing Down destination continues to mount the production Profile room. The placeholder communicates the planned unification of:

- Witness Rank;
- Mastery;
- Discoveries;
- Achievements;
- Personal Records;
- Calibration.

### Calibration

`CalibrationPlaceholder.tscn` documents the future unified personal/calibration concept while the existing Up destination continues to mount production Settings and Accessibility.

## Interaction rule

- Tap the Iris center to enter Story Mode.
- Swipe right to reveal the Discover constellation.
- Tap a constellation point to enter its future destination.
- Back or the Iris return cue always returns to the Iris.
- No destination is a traditional first-level dashboard.

## Placeholder boundary

These scenes are architecture and comprehension surfaces only. They do not replace the production challenge runtime, change scoring, or create new progression data.
