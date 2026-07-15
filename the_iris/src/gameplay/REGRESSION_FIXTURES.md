# Deterministic Regression Fixtures

## Status

`challenges.json` and the five `observation_challenge_0*.png` assets are deterministic regression content.

`ChallengeRegistry.gd` still loads and normalizes the fixture data. Player-facing launches now pass through the shared runtime:

```text
Fixture definition
→ ChallengeTemplate
→ deterministic generator
→ ChallengeInstance
→ validator
→ presentation
→ ChallengeResult
→ PlayerProgressService
→ recommendation
```

## Fixture IDs

- `challenge_01` — Study Desk
- `challenge_02` — Kitchen Counter
- `challenge_03` — Travel Pack
- `challenge_04` — Reading Nook
- `challenge_05` — Picnic Blanket

## Rules

- Preserve deterministic questions, options, answers, and assets.
- Use these fixtures for boot, navigation, runtime, persistence, result, and compatibility checks.
- Do not present this sequence as the long-term product architecture.
- Do not add production Challenge Types to `challenges.json`.
- Shared runtime contracts must not depend on this file format.
- Family-specific compatibility code may adapt normalized fixture data.
- Keep Challenge 01 as a permanent seed and journey regression fixture.
- Remove transitional display dependencies only after equivalent approved coverage exists.
