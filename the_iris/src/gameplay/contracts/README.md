# Gameplay Contracts

These classes define the Product Development data boundary:

- `ChallengeFamily.gd` — internal module identity and policy references. Player-facing copy calls a family a **Challenge Type**.
- `ChallengeTemplate.gd` — one balanced, versioned pattern inside a family.
- `ChallengeInstance.gd` — one fully resolved and reproducible challenge prepared for presentation.
- `PresentationProfile.gd` — presentation, response, and result routes/modes selected by a family.
- `ChallengeValidationResult.gd` — accepted or rejected validation result with reason metadata.
- `ChallengeResult.gd` — canonical outcome, explanation, progress, recommendation, and replay data.

## Runtime status

Phase 2 Gate 1 connects these contracts to the shared runtime. Contracts remain data objects; they do not navigate, save, render, or access player state.

The deterministic fixtures are adapted into templates and instances by `families/scene_investigation/`. Shared runtime files do not import or identify that family.

## Dependency rule

Shared runtime code depends on contracts and behavior interfaces. A family supplies generator, validator, difficulty, exposure, and presentation strategies, but it may not reimplement navigation, persistence, analytics transport, accessibility, or the standard session lifecycle.
