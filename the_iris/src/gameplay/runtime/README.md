# Shared Challenge Runtime

The runtime executes registered family contracts without checking concrete family IDs.

## Pipeline

```text
Challenge session
→ family
→ template
→ difficulty policy
→ exposure policy
→ generator
→ validator
→ challenge instance
→ presentation profile
→ player response
→ result contract
→ player progress
→ recommendation
→ Home or continue
```

## Services

- `ChallengeSessionService` — orchestrates one active session and bounded generation attempts.
- `ChallengeFamilyRegistry` — discovers manifest modules and validates public dynamic registration.
- `ResultService` — creates `ChallengeResult` data.
- `PlayerProgressService` — adapts results to the validated `ProfileService`.
- `RecommendationService` — selects start and next templates.

## Family-supplied strategies

- `ChallengeFamilyModule`
- `ChallengeGenerator`
- `ChallengeValidator`
- `DifficultyPolicy`
- `ExposurePolicy`

## Non-negotiable rules

- No concrete family or template identifiers in this directory.
- No family-specific UI branches.
- No replacement save, profile, navigation, analytics, audio, or accessibility systems.
- All challenge truth is resolved before presentation.
- Every candidate is validated before navigation to presentation.
- A response is persisted exactly once.
- Controlled candidate/fallback failure has no navigation or progress side effects.
- The frozen API is documented in `docs/product/CHALLENGE_RUNTIME_API.md`.
