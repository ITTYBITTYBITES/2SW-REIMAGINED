# Experience Placeholder Status

## Implemented placeholder surfaces

| Surface | Scene | Access | Status |
|---|---|---|---|
| Iris Hub | `IrisHubPlaceholder.tscn` / existing Living Iris | App launch | Architecture alias; existing Living Iris is active root experience. |
| Story Mode | `StoryModePlaceholder.tscn` | Iris center, Discover Story point | Interactive focus point opens existing production Witness flow. |
| Daily Witness | `DailyWitnessPlaceholder.tscn` | Discover constellation | Visual placeholder only; no daily gameplay or server. |
| Weekly Investigation | `WeeklyInvestigationPlaceholder.tscn` | Discover constellation | Visual placeholder only; no weekly case implementation. |
| Archive | Existing `Archive.tscn` | Iris left / Discover Archive point | Existing archive doorway can mount production Challenge Library. |
| Your Iris | `YourIrisPlaceholder.tscn` / production Profile room | Discover Your Iris point, Iris down | Future unified concept; production Profile remains authoritative room. |
| Calibration | `CalibrationPlaceholder.tscn` / production Settings room | Discover Calibration point, Iris up | Future unified concept; production Settings remains authoritative room. |

## Placeholder behavior

- Uses procedural drawing and existing dark/optical style.
- Does not create final art.
- Does not create new challenge mechanics.
- Does not change production scoring or saves.
- Uses the existing Iris transitions and Back rules.
- Central Story Mode point is the only placeholder with an active Witness entry action.

## Future work intentionally not implemented

- Story Chapter data;
- Daily deterministic scheduler;
- Weekly investigation data/rotation;
- unified Your Iris screen;
- Director selection;
- final Archive discovery objects;
- reward/evidence redesign;
- final asset batches.

## Acceptance intent

A human should now be able to open the development build, enter the Iris, tap center for Story Mode, swipe right to Discover, and understand the future ecosystem without mistaking placeholders for finished gameplay.
