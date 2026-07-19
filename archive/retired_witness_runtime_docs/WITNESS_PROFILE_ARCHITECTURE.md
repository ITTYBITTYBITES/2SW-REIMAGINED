# Witness Profile Architecture

## Local Profile Boundary

```text
Witness completion observer
→ WitnessProfile
→ WitnessProgression
→ IrisEvolutionData hook
→ WitnessProfileStore
→ user://witness_profile.json
```

The profile is local-only. It has no account, authentication, cloud sync, social graph, leaderboard, or multiplayer dependency.

## Components

| Component | Responsibility |
| --- | --- |
| `WitnessProfile` | Serializable identity, moment records, metrics, progression totals, and evolution signal. |
| `WitnessProgression` | Deterministic resonance and rank rules. |
| `IrisEvolutionData` | Derived profile snapshot for a future Iris visual consumer. |
| `WitnessProfileStore` | Read/write JSON at `user://witness_profile.json`. |

## Ownership

`Application` owns one profile instance and observes the existing protected `WitnessMomentOrchestrator.moment_completed(moment_id)` signal. It records a completion after the runtime has emitted its existing result event.

The profile never writes to:

- IncidentRegistry
- WitnessExperienceDirector
- WitnessMomentOrchestrator
- Witness content
- IrisCore
- LivingIris

## Persistence Format

The JSON record includes a schema version, identity, resonance, completed moment IDs, per-moment records, metrics, observation-style counts, and the Iris evolution snapshot.

The format is intentionally versioned so future optional result fields can be added without changing existing profile data.

## Future Result Contract

A future runtime may provide a dictionary containing `accuracy`, `anomalies_found`, `assistance_used`, `mastery`, and `observation_style`. `WitnessProfile.record_completion()` already accepts this data, but current runtime behavior remains unchanged because it currently emits only a moment ID.

## Privacy

Profile data remains on-device under `user://`. It contains no personal account data by default; the Witness name begins as the local display value `Witness`.
