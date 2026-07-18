# Player Progression Design

## Purpose

Progression gives the Witness a local, legible record of restored moments without changing the current Witness Runtime or inventing unmeasured performance data.

## Resonance

Resonance is the local progression currency.

### Current verified award

The current runtime emits only `moment_completed(moment_id)`. Therefore the verified current award is:

```text
First completion: +20 Resonance
Replay completion: +6 Resonance
```

### Supported future result inputs

When a future Witness result provides real data, the same award function accepts:

| Result field | Award |
| --- | ---: |
| `accuracy` | 0–15 Resonance |
| `anomalies_found` | +4 each |
| `assistance_used = false` | +6 |
| `mastery = true` | +10 |

No accuracy, anomaly, assistance, or mastery value is inferred by the current runtime. The profile records only fields explicitly supplied in a future result payload.

## Aperture Rank

```text
Aperture Rank = clamp(1 + floor(Resonance / 100), 1, 100)
```

| Rank range | Title |
| --- | --- |
| 1–9 | Observer |
| 10–24 | Attuned |
| 25–49 | Perceptive |
| 50–99 | Lucid |
| 100 | Witness |

This intentionally has a finite rank ceiling. There is no prestige or infinite progression in the current foundation.

## Profile Metrics

The local profile can retain:

- Witness name
- Resonance total
- Aperture Rank and title
- Unique moments completed
- Total completion count
- Explicitly measured average accuracy
- Explicitly reported anomalies found
- Unassisted completions
- Replay mastery count
- Optional observation-style counts
- Derived Iris evolution data

## Iris Evolution Hook

Rank and completed-moment count derive an `IrisEvolutionData` snapshot containing a future `visual_cue_key`. This is a hook only. The current Living Iris does not consume or change from profile data.

## Design Rules

- Progression rewards real Witness results, not time spent in menus.
- Replays remain useful but provide lower baseline Resonance.
- Missing result data stays missing; profile data must not simulate accuracy.
- Local progression must work without accounts, social features, or network access.
