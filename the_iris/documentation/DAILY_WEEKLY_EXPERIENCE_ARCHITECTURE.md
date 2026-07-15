# Daily and Weekly Experience Architecture

## Daily Witness

### Product role

A short, repeatable, offline-first practice moment that rewards consistency and mastery without global comparison.

### Data contract concept

- local calendar date;
- deterministic content seed;
- selected family/template/scenario;
- completion state;
- personal score/best;
- streak state;
- local evidence reference;
- accessibility/timing context.

### Rules

- No server dependency.
- No account requirement.
- No global leaderboard.
- One personal daily state derived from local save/profile systems.
- The Director can select a daily moment using existing family policies.
- The daily result uses existing production scoring/progression.
- Repeat prevention must account for recent daily and Story Mode signatures.

### Placeholder state

The Daily Witness placeholder currently communicates today’s witness, readiness/completion, personal best, and streak intent. It does not launch a new gameplay implementation yet.

## Weekly Investigation

### Product role

A larger featured thread that gives the player a reason to return over multiple moments.

### Data contract concept

- weekly investigation ID;
- featured case/scenario;
- chapter/rank context;
- ordered moment IDs or Director selection rules;
- investigation progress;
- completion state;
- Archive reward/evidence package;
- local start/completion dates;
- content version.

### Rules

- Can work fully offline with a local schedule/content bundle.
- No global leaderboard is required.
- Weekly content must be deterministic for a local week.
- Existing challenge families can supply internal sequences.
- The player can pause and resume without losing the investigation state.
- Completed evidence enters the production-backed Archive.

### Placeholder state

The Weekly Investigation placeholder communicates featured case, progress, completion state, and future Archive reward. It does not implement a real weekly case yet.

## Rotation and progression relationship

Daily/weekly selection should use:

- player mastery;
- recent history;
- family variety;
- chapter/rank;
- content version;
- accessibility preferences;
- recent daily/weekly signatures.

The scheduling layer should be additive to `RecommendationService` and `ProgramService`. It should not hardcode family-specific challenge behavior.
