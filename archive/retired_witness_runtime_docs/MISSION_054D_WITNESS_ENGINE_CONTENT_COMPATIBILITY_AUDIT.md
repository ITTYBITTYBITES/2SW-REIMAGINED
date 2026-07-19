# Mission 054D — Witness Engine & Content Compatibility Audit

**Date:** 2026-07-18  
**Repository state audited:** `main` at `711e4dc` (local, prior to this audit document)  
**Scope:** Read-only architecture and content assessment for Mission 055 planning. No gameplay, routing, schema, profile, or content behavior was changed.

---

## Decision summary

The current project is **an evolution candidate, not a rewrite candidate**.

The repository already has a functioning data-to-runtime path:

```text
Witness JSON
→ IncidentRegistry / WitnessContentLoader
→ WitnessMomentDefinition + WitnessAssetManifest
→ GenericWitnessGameplay
→ WitnessMomentResult
→ WitnessProfile / WitnessArchive
→ Iris evolution and existing return flow
```

That path can support the new Witness direction through **additive contracts and a focused gameplay-loop refactor**. The core registry, loading, profile persistence, and completion handoff should be retained.

The principal limitation is not architectural absence; it is that the active loop is still a **single-hotspot anomaly prototype** with a fixed sequence. It already contains several concepts that should be renamed/evolved into Fractures, but it needs a phase and interaction refactor before it can represent the full new design.

### Classification at a glance

| System | Recommendation | Why |
| --- | --- | --- |
| Incident Registry | **Extend** | Sound catalogue and lookup authority; add schema/version/chapter-aware validation rather than replace it. |
| Witness Moment JSON | **Extend** | Already carries narrative, evidence, reveal, timing, assets, and reward data; needs optional new design fields. |
| `WitnessContentLoader` / `WitnessMomentDefinition` | **Extend** | Correct data boundary; map optional new fields with backward-compatible defaults. |
| `WitnessAssetManifest` / resolver | **Keep** | Existing extensible asset namespace and safe fallbacks are suitable. |
| Generic Witness runtime loader | **Keep** | `start_generic_gameplay()` and definition loading should remain the launch path. |
| `GenericWitnessGameplay` | **Refactor** | Active player loop is data-fed but hard-wired to one anomaly/hotspot and a fixed phase chain. |
| Anomaly system | **Refactor — evolve into Fracture system** | A strong conceptual seed exists, including timing and “fracture” language, but the data and runtime are singular. |
| Synchronization phase | **Extend / insert** | Can be inserted into the generic phase enum and advance flow without replacing loading, profile, or routing. |
| `WitnessMomentOrchestrator` | **Refactor later / isolate** | It has a separate legacy five-phase flow and is not the active generic runtime path for production moments. It should not become a second Mission 055 engine. |
| `WM001GameplayLoop` / `FlagshipWitnessMoment` | **Refactor later** | Useful prototypes, but duplicate the generic loop’s responsibility. Preserve temporarily; do not extend both. |
| `WitnessMomentResult` | **Extend** | Compact result contract is appropriate; add optional Fracture/Synchronization/fragment outcome fields. |
| `WitnessProfile` + `WitnessArchive` | **Extend** | One local record authority already exists and safely accepts additive per-moment records. |
| Resonance / Iris evolution | **Extend** | Existing completion hooks can award/absorb truth data without a new save system. |
| Archive UI | **Refactor later (Mission 056)** | Data foundation is usable, but language/presentation remains “anomaly,” clue, mastery, and list-detail UI. |
| Chapter organization | **Extend** | Content is grouped historically, but no normalized runtime `chapter_id` model exists; `WitnessChapters` still presents a hard-coded Chapter 01 frame. |
| Application routing and Iris portal | **Keep** | Existing route ownership and 054C portal handoff should remain intact. |

**No currently inspected system warrants a Replace recommendation.**

---

## 1. What exists today

### 1.1 Production moment catalogue

`IncidentRegistry.MOMENT_PATHS` loads 15 JSON files:

- **12 player-exposed production moments:** `WM_001` through `WM_012`
- **1 flagship/current-memory definition:** `FM_001`
- **2 development fixtures:** `WM_TEST`, `WM_ASSET_TEST`

The registry owns catalogue discovery, lookup by ID, and an in-memory completion marker. `WitnessProfile` remains the persisted completion authority.

### 1.2 Active runtime path

For the production moments, current routing is:

```text
Spatial Hub / Chapters / Archive replay
→ Application.request_memory_portal(moment_id)
→ IrisPortalTransition
→ Application.start_generic_gameplay(moment_id)
→ WitnessContentLoader.load_moment_definition()
→ GenericWitnessGameplay
→ WitnessMomentResult
→ WitnessProfile.record_completion()
→ WitnessArchive.update_archive_entry()
→ WitnessProgression + Iris evolution / return
```

This is a good base for Mission 055. The 054C portal already turns entry into an Iris-mediated experience without taking ownership away from the loader.

### 1.3 Legacy/prototype paths that coexist

- `WitnessMomentOrchestrator` contains a compact five-phase player: `ARRIVING`, `OBSERVING`, `RECONSTRUCTING`, `INVESTIGATING`, `REVEALING`.
- `WM001GameplayLoop` is a moment-specific prototype using that orchestrator.
- `FlagshipWitnessMoment` is another specific prototype.
- `GenericWitnessGameplay` is the current active data-driven path used for the production moment list.

This is a **duplication risk**, not a reason to rebuild the whole engine. Mission 055 should make the generic path more capable and avoid adding new behavior to the two legacy loops.

---

## 2. Existing Witness Moment assessment

All twelve `WM_001`–`WM_012` files currently parse through both the registry’s minimum requirements and the generic loader’s minimum contract. All include the same core structural families:

- identity and incident fields;
- title/subtitle/introduction/description/reconstruction/revelation;
- background/action/reveal references;
- a two-second observation duration;
- one `anomaly_definition` with a location, size, failure text, and success text;
- one timed `capture_window`;
- three evidence nodes;
- reward definition;
- asset manifest.

### 2.1 Moment-by-moment content classification

| Moment | Current content status | Asset/runtime status | Recommendation |
| --- | --- | --- | --- |
| `WM_001` — *The Unfinished Canvas* | Authored narrative, causal break, reveal, evidence, timing. | Distinct studio/action/reveal assets; generic runtime-ready. | **Extend** with Fracture, Synchronization, fragment, stability, and guidance fields. Strong first migration candidate. |
| `WM_002` — *The Forgotten Museum* | Authored narrative and handprint-before-contact causal break. | Distinct museum/action/reveal assets; generic runtime-ready. | **Extend**. |
| `WM_003` — *The Last Performance* | Authored narrative and premature case/telegram causal break. | Distinct dressing-room/action/reveal assets; generic runtime-ready. | **Extend**. |
| `WM_004` — *The Faulty Reactor* | Authored narrative and diagnostic-before-key causal break. | Distinct cleanroom/action/reveal assets; generic runtime-ready. | **Extend**. |
| `WM_005` — *The Witness* | Authored meta-narrative linking player and Iris. | Distinct internal-stroma/reflection assets; generic runtime-ready. | **Extend**. Important Iris-absorption candidate, not a replacement candidate. |
| `WM_006` — *The Silent Bell* | Authored narrative, fracture wording, evidence IDs, timing, and reveal. | Reuses the WM_001 visual asset triplet; runtime data works but visual identity is placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_007` — *The Stopped Chronometer* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_008` — *The Cold Hearth* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_009` — *The Broken Sundial* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_010` — *The Unbound Ledger* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_011` — *The Still Waterfall* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |
| `WM_012` — *The Sealed Letter* | Authored narrative, evidence IDs, timing, and reveal. | Reuses WM_001 visual asset triplet; visual placeholder. | **Extend** behavior/data; **replace art later** only. |

### 2.2 Content conclusion

- **WM_001–WM_005** are the strongest authored vertical-slice set because each has distinct supplied imagery as well as differentiated narrative data.
- **WM_006–WM_012** are structurally valid, runtime-loadable authored definitions, but their shared WM_001 image references make their *visual execution* placeholder. This is an art/content-production limitation, not an engine incompatibility.
- All 12 are compatible with an additive Mission 055 migration because their narrative and interaction fields are already data-driven.
- `WM_TEST` and `WM_ASSET_TEST` should remain fixtures only and should not acquire new player-facing design fields.

---

## 3. Current gameplay loop and the Fracture opportunity

### 3.1 Current generic phase sequence

`GenericWitnessGameplay` currently runs:

```text
BRIEFING
→ OBSERVATION
→ ANOMALY
→ CAPTURE
→ REVIEW
→ CONTEXT
→ RESOLUTION
→ REWARD
```

The loop is already more aligned than its current naming implies:

| Existing behavior | New-design interpretation | Compatibility |
| --- | --- | --- |
| `OBSERVATION` | Witness the memory before intervention. | Keep. |
| `ANOMALY` hotspot | Detect a Fracture. | Evolve/rename. |
| `CAPTURE` timed hold | Stabilize/contact the active Fracture window. | Keep mechanics; rename/present as Fracture stabilization. |
| `REVIEW` timeline scrub | Inspect the fracture’s temporal relationship. | Keep; can feed Synchronization. |
| `CONTEXT` evidence collection | Reconstruct why the Fracture exists. | Keep; extend with truth-fragment readiness. |
| `RESOLUTION` revelation | Reveal/restore the truth. | Keep; make Revelation data richer. |
| `REWARD` | Iris absorbs a recovered fragment and progression updates. | Extend. |

### 3.2 Why the anomaly implementation is not yet a full Fracture system

The active loop currently supports exactly **one** `anomaly_definition` and one `anomaly_button` per moment. It tracks misclicks as `anomaly_missteps`, reads one location/size pair, and emits a result with `anomalies_found = 1` and `anomalies_total = 1`.

This is sufficient for a first Fracture but not for a generalized system supporting multiple Fractures, alternate manifestations, stability conditions, or branching synchronization targets.

**Recommendation: Refactor, do not replace.**

Retain the timed capture/review/evidence mechanics and migrate the singular contract from:

```text
anomaly_definition
```

to an additive canonical form such as:

```json
"fractures": [
  {
    "id": "causal_light",
    "kind": "causal",
    "location": { "x": 350, "y": 366 },
    "size": { "x": 94, "y": 94 },
    "notice_text": "…",
    "misstep_text": "…",
    "stability_window": { "start_time": 0.92, "end_time": 1.26, "hold_duration": 0.26 },
    "synchronization_target": { "time": 1.09, "tolerance": 0.12 }
  }
]
```

For a safe transition, `WitnessMomentDefinition` can synthesize one fracture from existing `anomaly_definition` + `capture_window` when `fractures` is absent. This keeps all twelve existing moments runnable during incremental migration.

---

## 4. Data contract compatibility

### 4.1 Existing strengths

The JSON definitions already support:

- authored narrative identity and context;
- an existing `revelation` string, mapped to `resolution_text`;
- evidence nodes with identifiers, relevance, truth connections, visual effects, color, and asset references;
- time-window behavior through `capture_window`;
- explicit asset/audio/lighting manifests;
- reward parameters;
- backward-compatible definition and asset fallbacks.

`WitnessContentLoader` intentionally has a small required-field validator. `WitnessMomentDefinition.from_dictionary()` already ignores unknown keys, so additive fields will not break existing definitions.

### 4.2 Required additive fields for Mission 055

| New concept | Current equivalent | Recommendation |
| --- | --- | --- |
| `truth_fragment` | None as authored data; completion data can carry it. | Add optional moment-level object. |
| `revelation` | Existing top-level string already exists. | Keep compatibility; optionally support richer object/metadata while retaining the string fallback. |
| `memory_stability` | Partial equivalent: capture timing and accuracy. | Add optional configuration plus per-run result output. |
| `iris_guidance` | Existing generic strings plus Iris personality events. | Add optional structured text/event/audio/haptic guidance hooks. |
| `fractures` | Singular `anomaly_definition` + `capture_window`. | Add canonical array and build one legacy fracture when absent. |
| `synchronization` | Review slider and timing window are a partial behavioral equivalent. | Add optional definition object and result data. |
| `chapter_id` / ordering | Subtitle and historical documentation only. | Add optional content metadata when chapter grouping becomes part of runtime selection. |

### 4.3 Recommended additive shape

This is a **planning shape**, not a change made by this audit:

```json
{
  "schema_version": 2,
  "chapter_id": "chapter_01",
  "iris_guidance": {
    "entry_event": "memory_focus",
    "fracture_found_event": "fracture_found",
    "synchronization_event": "synchronization_aligned"
  },
  "memory_stability": {
    "initial": 1.0,
    "misstep_cost": 0.15,
    "capture_miss_cost": 0.10,
    "minimum_to_restore": 0.40
  },
  "truth_fragment": {
    "id": "fragment_borrowed_light",
    "title": "Borrowed Light",
    "summary": "Cause arrived after its effect.",
    "iris_absorption_event": "truth_fragment_absorbed"
  },
  "fractures": [],
  "synchronization": {
    "target_time": 1.09,
    "tolerance": 0.12,
    "success_text": "…"
  }
}
```

This leaves all current fields in place during the migration. In particular, existing `revelation`, `anomaly_definition`, and `capture_window` should not be deleted in Mission 055.

### 4.4 Validator issue to resolve while extending

There are two independent minimum validators:

- `IncidentRegistry._is_valid()` requires `id`, `incident_id`, `title`, `introduction`, `background`, `action`, and `reveal`.
- `WitnessContentLoader.validate_moment_data()` requires ID, incident ID, title, subtitle, and description/introduction.

Both are sensible but do not express one canonical versioned contract. **Extend/consolidate validation**, retaining strict asset checks where needed and compatibility defaults for new optional fields.

---

## 5. Can Synchronization be inserted safely?

**Yes.** It can be inserted in `GenericWitnessGameplay` without rewriting routing, loading, archive persistence, or the Iris portal.

The existing `REVIEW` phase already has a timeline slider, a target-center calculation, and a tolerance check. A Mission 055 Synchronization phase can initially be an explicit evolution of that behavior:

```text
… → FRACTURE_STABILIZATION → SYNCHRONIZATION → CONTEXT → REVELATION → …
```

Recommended implementation boundary:

1. Add a `SYNCHRONIZATION` phase to `GenericWitnessGameplay`.
2. Move/rename review-target success behavior into it.
3. Read optional `synchronization` data, falling back to current capture-window center and tolerance.
4. Add synchronization outcome fields to `WitnessMomentResult`.
5. Keep `WitnessContentLoader`, `Application.start_generic_gameplay()`, profile persistence, and portal routing unchanged.

Do **not** add Synchronization to both `GenericWitnessGameplay` and `WitnessMomentOrchestrator`. The generic path should be the Mission 055 execution target; the orchestrator remains a legacy prototype until consolidated deliberately.

---

## 6. Archive, progression, Truth Fragments, and Iris absorption

### 6.1 Existing compatible foundations

`WitnessProfile.moment_records` is a dictionary keyed by moment ID and is persisted through the existing profile store. `WitnessArchive.update_archive_entry()` already adds archive-specific metadata in place. This is exactly the right location for additive truth-fragment state because it avoids a duplicate save system.

The present record system already tracks, among other data:

- completion count;
- first completion time;
- best accuracy;
- resonance award;
- replay count;
- discovered evidence;
- mastery level.

`Application` already responds to completion by:

- recording the result;
- saving the profile;
- updating Iris evolution;
- emitting personality events;
- returning through the Iris portal/home path.

### 6.2 Recommended extension

Attach fragment state to the existing moment record and optionally derive an aggregate index from it:

```text
moment_records[moment_id]
├── truth_fragment_id
├── truth_fragment_recovered
├── truth_fragment_first_absorbed_at
├── best_memory_stability
└── best_synchronization_score
```

The profile may later expose an aggregate `truth_fragments` view for the constellation/archive, but it should be derived or maintained from the same `moment_records` authority.

For Iris absorption, Mission 055 can add a single explicit completion event after `record_completion()` succeeds. This builds on existing Iris personality, audio, haptic, evolution, and 054C return hooks rather than creating a second Iris progression system.

### 6.3 Archive recommendation

- **Data authority:** Extend now, only as required by the Mission 055 result contract.
- **Archive UI:** Refactor later in Mission 056. Its current terms (“timeline anomalies,” “clues,” “mastery”) and list/detail framing do not yet express a constellation of absorbed Truth Fragments.

---

## 7. Chapter organization finding

The repository contains historical Chapter 2 content documentation and exposes `WM_001`–`WM_012` in the chapter selection. However, runtime chapter organization is not currently normalized:

- moment JSON does not contain `chapter_id` or an explicit order field;
- `WitnessChapters` presents a hard-coded “Chapter 01” frame;
- the list is effectively a catalogue of all visible production IDs.

Therefore, the **content grouping intent should be kept**, but the runtime data model should be **extended** when Mission 055/056 needs actual chapter-aware selection or constellation grouping. This does not block Fractures, Synchronization, or Truth Fragments.

---

## 8. Focused Mission 055 plan

Mission 055 should be scoped as an **additive Witness Engine evolution**:

1. Establish one versioned, backward-compatible moment-definition contract.
2. Add optional `fractures`, `synchronization`, `memory_stability`, `truth_fragment`, and `iris_guidance` fields to the loader/definition layer.
3. Add legacy adapters so current `anomaly_definition` and `capture_window` remain playable.
4. Refactor the active `GenericWitnessGameplay` loop from singular Anomaly semantics to singular-or-many Fracture semantics.
5. Insert Synchronization by evolving the existing review/timing behavior.
6. Extend `WitnessMomentResult`, `WitnessProfile`, and `WitnessArchive` with optional fragment/stability/synchronization outcomes.
7. Trigger Iris absorption through the existing completion/evolution/personality path.
8. Migrate one strong authored moment first—recommended `WM_001`—then validate the fallback path across `WM_002`–`WM_012` before authoring distinct new fields for all content.

### Explicit non-goals for Mission 055

- no replacement registry;
- no new save system;
- no rewrite of Application routing or the 054C pupil portal;
- no new Witness Moments;
- no final archive/constellation UI redesign;
- no requirement to replace the WM_006–WM_012 placeholder art as part of engine evolution.

---

## Final recommendation

Proceed to Mission 055 as a **targeted evolution**, with these decisions locked:

- Preserve the registry, loader, asset manifest/resolver, runtime launch route, profile persistence, Iris hooks, and portal.
- Evolve Anomalies into Fractures through backward-compatible adapters.
- Insert Synchronization in `GenericWitnessGameplay`, not in every legacy prototype path.
- Store Truth Fragment and absorption outcomes in the existing `moment_records` authority.
- Defer Archive UI and visual-asset replacement to later missions.

This path uses the substantial existing engine investment while making the new design legible in the actual player loop.
