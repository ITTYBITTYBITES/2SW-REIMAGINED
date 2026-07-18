# Witness Moment Content Architecture Audit

## 1. Executive Summary
The target of this architectural pass is to transition the Witness Moments system from a hardcoded, code-driven implementation to a scalable, data-driven framework. Currently, creating a new interactive Witness Moment requires writing custom GDScript files (such as `WM001GameplayLoop.gd` or `FlagshipWitnessMoment.gd`) containing hardcoded paths, hotspots, names, and logic. 

By defining a structured **Witness Moment Data Contract** (with rich schema definitions) and implementing a **Generic Content Loader** alongside a **Generic Experience Flow**, new moments can be authored entirely in JSON, making the system highly scalable for future content expansions.

---

## 2. Analysis of Current Components

### 2.1. `IncidentRegistry`
- **Current State:** Loads 5 simple narrative moments (`WM_001` to `WM_005`) from hardcoded JSON files in the `MOMENT_PATHS` constant. It performs a basic validation to check for keys like `"id"`, `"incident_id"`, `"title"`, etc., but has no concept of rich interactive gameplay definitions (such as anomalies, capture windows, or specific evidence nodes).
- **Abstractions Present:** Basic catalogue loading and dictionary-based lookups.
- **Limitations:** Only supports narrative flow via `WitnessChapters.gd`, leaving interactive gameplay completely hardcoded.

### 2.2. Existing WM JSON Structure
- **Current State:** Every JSON file from `wm_001.json` to `wm_005.json` is split into:
  - Narrative keys: `title`, `subtitle`, `introduction`, `observation`, `reconstruction`, `attunements`, `revelation`
  - Resource keys: `background`, `action`, `reveal`
- **Limitations:** Completely lacks interaction metadata, such as:
  - Anomaly hotspot locations (coordinates, shapes)
  - Timing thresholds (observation duration, capture windows)
  - Detail description mappings for evidence/attunements
  - Specific reward scaling factors

### 2.3. `WM001GameplayLoop.gd` (Interactive Reference)
- **Current State:** Designed strictly for `WM_001`. It implements an interactive flow using custom UI nodes.
- **Hardcoded Logic:**
  - Anomaly hotspot is a hardcoded circle button at `Vector2(350, 366)` with hardcoded size `Vector2(94, 94)`.
  - Misstep messaging is hardcoded: `"Not there. Watch the light, not the painter."`
  - Evidence list is manually constructed in code with hardcoded keys and names (`"paused_brush"`, `"crystal_prism"`, `"color_notes"`).
  - Accuracy math is hardcoded to reduce accuracy by `20%` per discovery misstep.
  - Hardcoded result generation with a fixed observation style `"deliberate"`.

### 2.4. `FlagshipWitnessMoment.gd` (`FM_001` Reference)
- **Current State:** Standalone mock gameplay loop for `FM_001_BORROWED_LIGHT`.
- **Hardcoded Logic:**
  - Hardcoded capture window (`CAPTURE_WINDOW_START = 0.92`, `CAPTURE_WINDOW_END = 1.26`, `CAPTURE_HOLD_REQUIRED = 0.26`).
  - Anomaly hotspot positioned at `Vector2(350, 366)` with size `Vector2(94, 94)`.
  - Hardcoded evidence keys (`"paused_brush"`, `"crystal_prism"`, `"color_note"`) and guidance labels matching them.
  - Dedicated slider logic for scrubbing through time and custom triggers for timeline-review unlock (e.g. `absf(value - 1.08) <= 0.12`).

---

## 3. Missing Abstractions

To achieve a fully data-driven pipeline, the following abstractions must be established:

1. **Witness Moment Data Contract (Schema):**
   A unified representation of an interactive moment including:
   - Metadata (`id`, `incident_id`, `title`, `subtitle`, etc.)
   - Observation timing (`observation_duration`)
   - Anomaly hotspot definition (location, shape, radius, misstep message)
   - Capture window criteria (active start, active end, hold duration)
   - Evidence/Attunement collection nodes (interactive identifiers, visual labels, unique guidance/lore connection text)
   - Reward definition (base Resonance, accuracy modifiers, unassisted modifiers)

2. **WitnessContentLoader (Parser & Validator):**
   A standalone utility that:
   - Reads JSON moment definitions.
   - Validates that all required narrative and gameplay keys exist and are typed correctly.
   - Transforms raw JSON data into structured dictionary or RefCounted configurations safely.

3. **Generic Experience Flow (Gameplay Controller):**
   A single, reusable scene/script capable of loading ANY Witness Moment using the new data contract. Instead of hardcoding buttons and coordinates, it dynamically instantiates the anomaly button, configures the capture timing progress bar, binds timeline scrubbers, builds the interactive list of evidence nodes, and emits a standard `WitnessMomentResult`.

---

## 4. Proposed Migration Strategy (Target Architecture)

```text
  [ JSON Moment Definition ]
              │
              ▼
    [ WitnessContentLoader ]  ──(Validates Schema & Fields)
              │
              ▼
   [ Generic Gameplay Loop ]  ──(Reads Config and Instantiates Hotspots/Timers)
              │
              ▼
    [ WitnessMomentResult ]   ──(Generates Standardized Accuracy & Mastery)
              │
              ▼
   [ WitnessProfile System ]  ──(Awards Resonance & Updates Aperture Rank)
```

By introducing this structure, the codebase remains modular, the existing stable runtime continues unchanged, and the foundation is fully prepared for future data-only content expansion.
