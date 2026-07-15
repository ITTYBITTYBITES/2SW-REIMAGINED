# Scene Investigation — Gate 1 Compatibility Module

This module is the first internal `ChallengeFamily` and player-facing **Challenge Type** reference.

Gate 1 intentionally uses deterministic fixture data to prove the runtime before production procedural generation is introduced.

## Supplied strategies

- `SceneInvestigationFamily.gd`
- `FixtureSceneInvestigationGenerator.gd`
- `FixtureSceneInvestigationValidator.gd`
- `FixtureSceneInvestigationDifficultyPolicy.gd`
- `FixtureSceneInvestigationExposurePolicy.gd`

## Presentation

The family selects the `scene_investigation.standard` presentation profile:

- Presentation route: `observation`
- Response route: `memory_question`
- Result route: `result`

The shared runtime reads these routes from the profile and contains no Scene Investigation branch.

## Deferred

- Production procedural scene composition
- Adaptive difficulty
- Variable production exposure policies
- Interactive family-specific tutorial
- Production scoring and mastery
