# Two Second Witness — Living Iris 4.0
# Witness Moment Production Guide

**Status:** Production authoring standard established by Mission 059.  
**Applies to:** All future authored Witness Moments.  
**Authority chain:** Do not bypass it.

```text
IncidentRegistry
→ WitnessContentLoader
→ WitnessMomentDefinition
→ GenericWitnessGameplay
→ WitnessMomentResult
→ WitnessProfile
→ WitnessArchive
→ LivingArchiveProjection
→ LivingIris / SpatialHub
```

A Witness Moment is not a level, achievement, or isolated puzzle. It is a damaged memory the player and Iris restore together.

---

## 1. Identity

Every production moment requires:

| Field | Requirement |
| --- | --- |
| `id` / `moment_id` | Stable unique ID, e.g. `WM_003`. Never reuse an ID. |
| `incident_id` | Stable narrative incident identifier. |
| `title` | Specific human memory title, not a mechanic label. |
| `subtitle` | Chapter placement and thematic framing. |
| Chapter placement | Use the existing Chapter membership/data convention. Do not create a second chapter system. |
| Narrative theme | State the human relationship or loss at the center of the memory. |

The title should name a memory, not the player task. *The Forgotten Museum* is preferable to *Find the Handprint*.

---

## 2. Narrative Secret

Before authoring mechanics, write three concise answers:

1. **What appears wrong?** What the player initially sees as impossible.
2. **What does the player believe initially?** The plausible but incomplete interpretation.
3. **What truth is recovered?** The human meaning that makes the Fracture matter.

The Revelation must make the player reinterpret the observed impossibility. A Fracture is not merely a visual error; it is a relationship, ritual, grief, promise, or care made temporally unstable.

Required existing fields:

```json
{
  "introduction": "…",
  "description": "…",
  "observation": "…",
  "reconstruction": "…",
  "revelation": "…"
}
```

---

## 3. Fracture Design

Author a canonical `fractures` array even though legacy `anomaly_definition` and `capture_window` must remain intact for compatibility.

```json
{
  "fractures": [{
    "fracture_id": "stable_unique_name",
    "location": { "x": 0, "y": 0 },
    "size": { "x": 0, "y": 0 },
    "discovery_text": "What the player has noticed.",
    "misstep_text": "A meaningful redirect, not a generic failure.",
    "truth_fragment_reward": "fragment_stable_unique_name",
    "synchronization": {
      "hold_duration": 1.0,
      "stability_recovery": 1.0,
      "audio": "res://assets/audio/iris/iris_focus.ogg",
      "haptic": "light"
    }
  }]
}
```

### Fracture authoring checklist

- **Identity:** What has become out of sequence?
- **Visual behavior:** Where does it manifest in the supplied image/action?
- **Discovery condition:** What observation makes the player notice it?
- **False leads:** Include 2–3 authored redirects in `showcase.false_leads`.
- **Stability impact:** Tune `memory_stability` so the memory feels delicate without becoming punitive.
- **Meaning:** Explain why the Fracture is emotionally/narratively important.

Do not make the correct location arbitrary. The evidence, action image, observation copy, and Revelation should point to the same hidden relationship.

---

## 4. Synchronization Design

Use the existing Generic Witness synchronization interaction. Do not create a new minigame.

Author:

| Concern | Existing data location |
| --- | --- |
| Focus duration | `fractures[0].synchronization.hold_duration` |
| Stability pressure | `memory_stability` |
| Iris guidance | `iris_guidance.synchronization_event` |
| Completion response | `iris_guidance.synchronization_complete_event` + manifest audio |
| Success/failure feedback | Existing haptic/audio runtime plus authored copy |

Recommended first-production range:

- `hold_duration`: **0.9–1.3 seconds**
- `initial` stability: **0.72–0.84**
- `misstep_cost`: **0.12–0.18**
- `idle_drain_per_second`: **0.07–0.11**

The player should feel they are holding a memory together, not filling a generic meter.

---

## 5. Revelation Design

The Revelation answers the Narrative Secret.

Define:

- recovered truth;
- what the false memory showed;
- what actually happened;
- why the recovered truth matters to a person;
- reconstruction moment using the existing reveal image and procedural showcase treatment.

Use current systems:

```json
{
  "revelation": "…",
  "truth_fragment": {
    "revelation_text": "…",
    "revelation_audio_hook": "res://assets/audio/witness/resolution.ogg"
  },
  "asset_manifest": {
    "audio_assets": {
      "reconstruction": "res://assets/audio/iris/iris_transition.ogg"
    }
  },
  "showcase": {
    "reconstruction_seconds": 1.5
  }
}
```

Do not add a cinematic engine. The existing reveal image, reconstruction lines, Iris event, and audio path are the production presentation surface.

---

## 6. Truth Fragment

A fragment is a preserved truth, not a score item. Every production moment must author:

```json
{
  "truth_fragment": {
    "truth_fragment_id": "fragment_unique_name",
    "title": "Human-facing name",
    "summary": "What returned to the Iris.",
    "revelation_text": "The moment's recovered truth.",
    "revelation_audio_hook": "res://assets/audio/witness/resolution.ogg",
    "archive_entry": "Short Archive identity line.",
    "recovered_memory_summary": "Whose memory this was and why it mattered.",
    "truth_statement": "The concise truth that changed the player's reading.",
    "iris_reflection": "What the Iris feels/remembers.",
    "iris_reflection_event": "data_driven_iris_event"
  }
}
```

The existing `WitnessMomentResult → WitnessProfile → WitnessArchive` path persists and projects these fields. Do not store them elsewhere.

---

## 7. Atmosphere

Use supplied assets and the existing asset manifest. Author the place before authoring the interaction.

| Concern | Existing authoring surface |
| --- | --- |
| Environment mood | `description`, `observation`, `showcase` prompts |
| Lighting direction | `asset_manifest.lighting_profile`, `showcase.atmosphere_light_color`, `showcase.atmosphere_light_origin_x` |
| Ambient audio | `asset_manifest.audio_assets.ambient` |
| Environmental motion | Existing procedural showcase atmosphere; no final animation required |
| Iris visibility | `showcase.iris_presence_alpha` |

Required manifest keys for authored production moments:

```json
{
  "audio_assets": {
    "ambient": "…",
    "fracture_discovery": "res://assets/audio/iris/iris_attention.ogg",
    "synchronization_complete": "res://assets/audio/iris/iris_confirm.ogg",
    "reconstruction": "res://assets/audio/iris/iris_transition.ogg",
    "resolution": "…"
  }
}
```

---

## 8. Iris Relationship

Every moment should give the Iris a reason to participate. Author data-driven events for:

| Beat | `iris_guidance` field |
| --- | --- |
| Observation | `observation_event` |
| Fracture prompt | `fracture_prompt_event` |
| Discovery | `fracture_discovered_event` |
| Synchronization | `synchronization_event` |
| Stabilization | `synchronization_complete_event` |
| Revelation | `revelation_event` |
| Archive reflection | `truth_fragment.iris_reflection_event` |

Register events in `content/iris/iris_dialogue_events.json` with text, accessibility text, expression mode, existing audio path, haptic hook, and placeholder voice key.

Use the existing Application personality route. Do not make a moment script own Iris state.

---

## Required production validation

Before merging a production migration:

1. Validate JSON parse and all manifest assets.
2. Confirm `WitnessContentLoader.load_moment_definition()` succeeds.
3. Confirm canonical Fracture and synchronization values resolve.
4. Confirm all Iris dialogue event names/audio resolve.
5. Complete in a test profile and confirm fragment projection through `WitnessArchive`.
6. Confirm Chapter membership and relationship state update.
7. Serialize/restore the profile and confirm fragment persistence.
8. Confirm earlier authored moments and all compatible legacy moments still load.
9. Run `git diff --check`.
10. Run Godot headless validation when available.

---

## Production boundaries

Do:

- Author one moment completely through this contract.
- Add only optional data consumed by existing systems.
- Preserve legacy `anomaly_definition` and `capture_window` fields.
- Use the one existing profile/archive authority chain.

Do not:

- add a parallel gameplay loop;
- add a new save file or fragment inventory;
- bypass `WitnessContentLoader`;
- alter Application routing for a content migration;
- author another moment while the current migration is under validation.
