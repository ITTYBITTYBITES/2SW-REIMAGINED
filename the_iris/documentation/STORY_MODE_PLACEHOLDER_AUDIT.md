# Story Mode Placeholder Audit

**Scope:** review only; no implementation changes
**Reviewed against:** `WITNESS_MOMENT_DESIGN_BIBLE.md`, `WITNESS_STORY_ARCHITECTURE.md`, `STORY_MODE_FOUNDATION.md`, `WITNESS_MOMENT_GAMEPLAY_LOOP_SPEC.md`

## Executive recommendation

The existing Story Mode placeholder should **remain as a progression/chapter container**.

It should **not** become the full Witness Moment runtime, because it currently has none of the state, beat orchestration, evidence, reflection, resume, or production session responsibilities required by the Witness Moment Design Bible.

It should also **not be discarded wholesale**. Its current role is useful:

```text
Iris
→ Story Mode chapter/progression container
→ Witness Moment runtime
→ Production/internal mechanics
```

The future architecture should separate:

- **Story Mode container:** rank, chapter, moment availability, continuity, next recommendation;
- **Witness Moment runtime:** Arrival, Attunement, Observation, Memory, Investigation, Discovery, Revelation, Reflection, Reward, Archive, Return;
- **Production mechanics:** generation, validation, interaction, scoring, saves, and results.

## Current implementation map

### Scene

`scenes/StoryModePlaceholder.tscn`

Current configuration:

- root script: `scripts/FuturePlaceholder.gd`;
- destination key: `story_mode`;
- title: `STORY MODE`;
- eyebrow: `RANK CHAPTER · OBSERVER`;
- progress copy: `RANK 1 · 18 / 100 ATTENTION`;
- central focus action enabled;
- current action emits `request_witness`.

### Script

`scripts/FuturePlaceholder.gd`

Current responsibilities:

- generic placeholder drawing;
- title/eyebrow/description/progress/action labels;
- responsive label positioning;
- central optical placeholder animation;
- tap-to-return handling;
- optional focus action that emits `request_witness`.

It is shared by Story Mode, Daily Witness, Weekly Investigation, Your Iris, and Calibration placeholders. It has no Story Mode-specific data model.

### Root routing

`scenes/Main.tscn`

- instantiates `StoryModePlaceholder` under `Interface/ScreenRoot/StoryMode`;
- keeps it hidden until selected;
- also contains the production `WitnessMode`, `ProductionBridge`, `ProductionStartup`, Iris screens, destination screens, and guidance systems.

`scripts/MainController.gd`

- exposes `story_mode` as a `FuturePlaceholder`;
- maps `"story_mode"` in `_show_screen()`;
- connects `story_mode.request_home` to Iris return;
- connects `story_mode.request_witness` to `show_witness()`;
- center Iris tap currently calls `_show_screen("story_mode")`;
- Story Mode placeholder central focus then opens the existing production Witness flow.

### Production handoff

`src/iris/integration/ProductionBridge.gd`

- starts production `AppBoot.gd` and service initialization;
- does not own Story Mode state;
- provides production session cleanup/return-home.

`src/iris/integration/ProductionWitnessHost.gd`

- mounts production Tutorial, Observation, Memory Question, and Result screens;
- begins a recommended production session;
- listens to production `NavigationService` routes;
- is the current mechanic/runtime doorway after Story Mode’s focus point.

Production systems behind that host include:

- `ChallengeSessionService`;
- `ChallengeFamilyRegistry`;
- `PlayerProgressService`;
- `ProfileService`;
- `RecommendationService`;
- `ResultService`;
- `SaveService`;
- `SettingsService`;
- `AccessibilityService`;
- `AudioService`.

## Current route and state behavior

### Iris → Story Mode

- Current behavior: center tap enters `story_mode` through the Iris transition.
- Design alignment: **partially aligned**. The Iris is the gateway and Story Mode is the primary entry.
- Gap: the placeholder does not yet read a real Story Chapter, Director decision, or saved moment state.

### Story Mode → Witness

- Current behavior: central focus point emits `request_witness`, then `MainController.show_witness()` opens the production host.
- Design alignment: **useful bridge, not final runtime**.
- Gap: no Arrival/Attunement/Story Beat state separates the chapter container from the production mechanic.

### Back

- Current behavior: Back from production Witness calls production session cleanup and returns through Iris.
- Design alignment: **aligned** at the foundation level.
- Gap: Story Mode itself has no resumable beat/chapter state if a future moment is interrupted.

### Discover → Story Mode

- Current behavior: Discover constellation can route to `story_mode`.
- Design alignment: **aligned** as an alternate entry.
- Gap: Discover does not yet show real chapter/moment availability or Director context.

## Mapping against the Witness Moment Design Bible

| Design Bible beat | Current Story Mode placeholder | Assessment |
|---|---|---|
| Arrival | Iris transition into `StoryModePlaceholder` | Foundation exists; Story-specific Arrival does not. |
| Attunement | Static eyebrow/description/action copy | Placeholder only; no moment-specific intention or hidden-information contract. |
| Observation | Not inside Story Mode; starts after `request_witness` | Correctly delegated away from container, but no Story Mode beat wrapper exists. |
| Memory Reconstruction | Production `MemoryQuestionScreen` | Existing mechanic route works, but it is not yet framed as Story Mode Reconstruction. |
| Investigation | Not implemented in Story Mode | Missing future beat. |
| Discovery | Placeholder constellation/Story point | Future destination concept exists, not moment evidence. |
| Evidence Reveal | Production `ResultScreen` reveal data | Technical evidence exists; Story Mode reflection framing is missing. |
| Reflection | Not implemented in Story Mode | Missing future beat. |
| Rewards | Production progress/result services | Authority exists; no Story Mode reward beat. |
| Archive Update | Production history/archive data exists | Technical foundation exists; no moment-level Archive narrative record. |
| Return to Iris | Optical return/production session cleanup | Foundation is strong and should remain. |
| Replay/Mastery | Production replay/mastery/progression | Exists below the Story layer; not surfaced as Story continuity. |
| Accessibility | Iris multimodal/accessibility and production services | Foundation exists; placeholder has no moment-specific semantic contract. |

## What the placeholder is good at

- Establishing Story Mode as the Iris center destination;
- showing Rank/Chapter/progress language without a dashboard;
- giving the player a visual place to begin a future journey;
- providing a reversible handoff to existing production Witness mechanics;
- keeping future chapter concepts separate from legacy challenge names;
- allowing human review before final Story Mode implementation.

## What it is not capable of yet

- selecting a meaningful next moment;
- storing/resuming a Story Mode beat;
- showing real locked/unlocked moments;
- explaining why the current moment was chosen;
- managing Arrival or Attunement;
- orchestrating Observation → Memory → Investigation → Revelation;
- owning a moment-level Archive record;
- handling reflection or interpretation;
- applying Story-specific reward framing;
- supporting alternate story paths;
- differentiating daily/weekly/chapter context;
- producing a Director trace.

## Recommended future ownership

### Story Mode container: keep and evolve

Future name/concept: `StoryModeChapterShell` or equivalent.

Owns:

- current Witness Rank;
- current Rank Chapter;
- chapter progress;
- available/locked Witness Moment summaries;
- current recommendation;
- chapter continuity;
- entry into a selected Witness Moment;
- return summary after completion.

It should remain a calm progression/continuity space, not a challenge screen.

### Witness Moment runtime: create separately

Future concept: `WitnessMomentRuntime` / `WitnessMomentHost`.

Owns:

- Arrival;
- Attunement;
- Observation;
- Memory Reconstruction;
- Investigation;
- Discovery;
- Evidence Reveal;
- Reflection;
- Reward;
- Archive Update;
- Return handoff.

It should consume a future `WitnessMoment` data contract and call production mechanics as internal steps.

### Production mechanics: preserve

`ProductionWitnessHost` should remain a compatibility/mechanics host during the transition. It should not become the Story Mode Director or Story Moment runtime itself.

## Decision

| Option | Decision | Reason |
|---|---|---|
| Turn current placeholder directly into Witness Moment runtime | REJECT | It is a generic visual placeholder with no beat/state/evidence/resume model. |
| Keep it as progression container | ACCEPT | It already expresses Rank 1/Observer/progress and provides a clean Iris doorway. |
| Replace it entirely | REJECT | It would discard a useful hierarchy and require the Iris to jump directly into mechanics again. |
| Create a separate Witness Moment runtime beside it | ACCEPT | This preserves separation between chapter continuity and moment gameplay. |

## Recommended next architecture

```text
MainController
    ↓
StoryModeChapterShell
    ↓
Witness Experience Director
    ↓
WitnessMomentRuntime
    ↓
ProductionWitnessHost / production ChallengeSessionService
```

The current Story Mode placeholder is therefore a **progression container prototype**, not the future Witness Moment runtime. It should be retained as the visible chapter shell while a separate runtime is designed and implemented later.
