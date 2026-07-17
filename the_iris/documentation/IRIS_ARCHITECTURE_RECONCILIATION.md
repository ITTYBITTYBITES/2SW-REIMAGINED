# IRIS ARCHITECTURE RECONCILIATION AUDIT

**Campaign:** Architecture Convergence  
**Phase:** Phase 12 — Architectural Truth-Finding Pass  
**Status:** Completed — GREEN / YELLOW (No Active Conflicts)  
**Date:** 2026-07-17  
**Author:** Director Agent (Arena.ai)

---

## 1. Executive Summary

This architectural reconciliation audit inspects the entire Iris presentation and navigation stack to verify active runtime paths, identify legacy artifacts, establish a clear authority map, and confirm that the player experiences the intended Living 3D Iris / hybrid shader presentation without competing system conflicts.

---

## 2. Iris Systems Inventory & Active Runtime Path

### Existing Iris Systems in Repository
1. **`IrisController.gd` (`scenes/Iris.tscn`):** Hybrid controller combining GPU shader biological eye layers (sclera, cornea, pupil aperture, portal destination preview) with progression synchronization.
2. **`LivingIris3D.gd` (`scenes/LivingIris.tscn`):** SubViewport-based 3D presentation foundation rendering a real-time 3D eye model with quality tiers (Low, Medium, High) and orbiting memory shards. Embedded as a child node within `IrisController`.
3. **Legacy Placeholders:** `IrisHubPlaceholder.tscn` and `YourIrisPlaceholder.tscn` (historical mockup scenes).
4. **Home Screen Variants:** `HomeScreen.tscn` (active data-driven product hub) and `HomeV2Screen.tscn` (legacy layout variant).

### Current Runtime Boot & Navigation Path
1. **Boot:** Application starts at publisher splash screen (`PublisherSplashScreen`), transitioning to `TitleSplashScreen`.
2. **Scene Loading:** `Main.tscn` loads with `MainController.gd` and `NavigationService`.
3. **Iris Initialization:** `MainController` initializes `IrisController` (which instantiates `LivingIris3D` internally) and routes initial view to `HomeScreen`.
4. **Player Interaction:** Player interacts with home hub or gazes/taps Iris interface to initiate recommended rounds or story moments.
5. **Witness Launch:** `MainController` invokes `_start_director_selected_witness("story")`, querying `IncidentRegistry` via `WitnessExperienceDirector`.
6. **Witness Completion:** `WitnessMomentOrchestrator` runs the 7-phase cycle (Arriving → Archiving), recording results into `PlayerProgressService`.
7. **Return Path:** `MainController` handles completion via a 2.8-second grace window (`_return_to_iris_after_completion`), smoothly transitioning home through the standard Iris return sequence.

---

## 3. Duplicate System Detection

| System / Component | Classification | Conflict Status | Notes |
|---|---|---|---|
| `IrisController.gd` + `LivingIris3D.gd` | **Active** | GREEN | Active hybrid 2D/3D presentation layer. |
| `HomeScreen.tscn` | **Active** | GREEN | Active data-driven home product hub. |
| `IrisHubPlaceholder.tscn` | **Legacy** | YELLOW | Unreferenced scene; isolated placeholder. |
| `YourIrisPlaceholder.tscn` | **Legacy** | YELLOW | Unreferenced scene; isolated placeholder. |
| `HomeV2Screen.tscn` | **Legacy** | YELLOW | Alternate home layout variant; unreferenced in active router. |

**Conclusion:** Legacy placeholder scenes and alternate screens exist in the filesystem but are completely unreferenced by the active `Main.tscn` router and `MainController`. There are **no active runtime conflicts**.

---

## 4. Authority Map

| Domain | Responsible Authority | Notes |
|---|---|---|
| **Iris State & Presentation** | `IrisController` + `LivingIris3D` | Consumes progression state to scale stroma glow and orbital shards; presentation-only. |
| **Player Progression** | `PlayerProgressService` | Singular gameplay progression authority for Insight, rank, mastery, and archive storage. |
| **Navigation & Routing** | `NavigationService` + `MainController` | Manages screen transitions and active screen state. |
| **Archive Storage & Retrieval** | `PlayerProgressService` + `ArchiveService` | Stores and retrieves permanent archive entries. |
| **Witness Launching** | `IncidentRegistry` + `WitnessExperienceDirector` | Data-driven content authority and deterministic selection engine. |

---

## 5. Risk Assessment

- **GREEN (No Conflict):** Core active path (`MainController`, `IrisController`, `LivingIris3D`, `HomeScreen`, `IncidentRegistry`, `PlayerProgressService`) operates with clean separation of concerns and zero overlapping writers.
- **YELLOW (Isolated / Inactive):** Unreferenced legacy placeholder scenes (`IrisHubPlaceholder.tscn`, `YourIrisPlaceholder.tscn`) and `HomeV2Screen.tscn`. They present zero runtime risk because they are never instantiated by the active router.
- **RED (Active Conflict):** **NONE.**
