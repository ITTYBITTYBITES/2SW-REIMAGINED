# Witness Archive and Mastery Foundation Pass Audit

## 1. WitnessProfile Storage Analysis
- **Current State:** `WitnessProfile` stores player credentials, aggregate stats, and moment completions in `moment_records: Dictionary = {}` and saves locally to `user://witness_profile.json` using `WitnessProfileStore`.
- **Strengths:** Excellent, clean local JSON schema format.
- **Constraints/Risk of Duplication:** Adding an entirely separate save system for the archive would introduce race conditions, state misalignment, and file-access overhead.
- **Solution:** Integrated the rich archive metadata inside the existing `moment_records` structure within `WitnessProfile`. This completely complies with the "No duplicate save systems" guardrail while guaranteeing perfect synchronization.

---

## 2. Result Contract Analysis
- **Current State:** A completed gameplay session emits a `WitnessMomentResult` which contains fields like `accuracy`, `anomalies_found`, `mastery`, and `observation_style`.
- **Gaps:** The current contract has no built-in array of specific clue identifiers gathered by the user during the attunement/context phase.
- **Solution:** Dynamically injected a list of discovered clues (`"discovered_clues"`) as an array of strings into the result dictionary in `Application.gd` during the completion call:
  ```gdscript
  result_dict["discovered_clues"] = generic_gameplay.evidence_found.keys()
  ```

---

## 3. Completed Moment Tracking
- **Current State:** Standard moments (`WM_001` - `WM_005`) are tracked primarily as completed string IDs.
- **Archive Requirements:** The model must support tracking:
  - `moment_id` (String)
  - `completion_count` (int)
  - `first_completed_date` (String)
  - `best_accuracy` (float)
  - `best_mastery` (int)
  - `highest_resonance` (int)
  - `times_replayed` (int)
  - `discovered_clues` (Array of clue strings)

---

## 4. Existing Navigation Analysis
- **Current State:** Direct method/signal wiring across screens (Hub -> Iris -> Chapters -> Gameplay).
- **Gaps:** There is no dedicated portal or path to view or manage restored moments.
- **Solution:** Added a secondary portal `"OPEN ARCHIVE"` directly into the Iris Hub (`IrisHome.gd`), accompanied by a dedicated, player-facing `WitnessArchiveUI` screen that handles list views (Collection) and detailed stats telemetry (Moment Details).

---

## 5. Missing Archive Systems
- **Mastery Tracker:** No automatic mapping of mastery titles (Discovery, Understanding, Insight, Mastery) based on user statistics.
- **Replay Router:** No generic replay mechanism. Our solution updates `start_generic_gameplay(moment_id)` to dynamically format paths (e.g. `res://content/witness/[id].json`), load the respective schemas, and launch the generic interactive loop for any selected moment, returning the player cleanly to the Archive with updated stats upon completion.
