# MISSION 012 — CHAPTER 1 PRODUCTION VALIDATION REPORT

**Date:** 2026-07-17
**Status:** VALIDATION COMPLETE
**Target:** End-to-End Chapter 1 Production Flow (Boot → Iris → WM_001-WM_005)

## 1. Overall Readiness Assessment
**Recommendation: NOT READY (Requires Fixes)**
**Production Readiness Score: 72 / 100**

The foundational architecture for Chapter 1 (IrisCore, Witness Orchestrator, Incident Registry, and Save Systems) is remarkably solid and securely decoupled. Progression tracks correctly, and moments load their defined profiles accurately. 

However, critical flaws exist in the **Boot Routing** and **Initialization Sequence** that prevent a clean "first-run" player journey. The application currently triggers its startup sequences concurrently, hiding the Living Iris awakening behind splash screens, and entirely bypasses the newly implemented Experience Readiness Gate.

## 2. Pass/Fail Stage Breakdown

| Stage | Status | Notes |
|-------|--------|-------|
| **App Launch & Splash** | ⚠️ FAIL | Race condition between splash and main menu. |
| **Readiness Gate** | ❌ FAIL | Completely bypassed in production flow. |
| **Living Iris Awakening** | ⚠️ FAIL | Triggers immediately behind the splash screen. |
| **Navigation & Routing** | ✅ PASS | Iris gaze successfully routes to destinations. |
| **WM_001 - WM_005 Flow** | ✅ PASS | Moments load sequentially via IncidentRegistry. |
| **Observation Phase** | ✅ PASS | Cinematic execution and shader logic functional. |
| **Reconstruction Phase** | ✅ PASS | Drag-and-drop ghost matching operational. |
| **Investigation Phase** | ✅ PASS | Hotspot attunement functional. |
| **Revelation Phase** | ✅ PASS | Data collection and progression scoring valid. |
| **Archive & Return** | ✅ PASS | Returns cleanly to Iris with updated state. |

---

## 3. Issue Inventory

### ISSUE-001: Race Condition in Boot Flow
* **Severity:** HIGH
* **Reproduction Steps:** Open the application. Wait for the Publisher and Title splash screens to play.
* **Likely Cause:** `MainController.gd` calls `_start_first_launch_intro()` and `iris.start_awakening()` immediately during `_ready()`. Simultaneously, `ProductionStartup.tscn` plays a 2-second visual splash. As a result, the Iris awakens *invisibly* behind the splash screen, ruining the narrative timing of the first encounter.
* **Recommended Fix:** In `MainController.gd`, do not start the intro or awaken the Iris in `_ready()`. Instead, connect to `production_startup.finished` and wait for the splash sequence to conclude before proceeding.

### ISSUE-002: Experience Readiness Gate Bypassed
* **Severity:** HIGH
* **Reproduction Steps:** Perform a fresh install/clear save data. Launch the app. Observe that the Readiness Gate never appears.
* **Likely Cause:** The Readiness Gate logic was correctly written, but it was injected into `TitleSplashScreen.gd` (which belongs to the deprecated `AppShell` routing). The actual production root, `Main.tscn`, never mounts `AppShell`.
* **Recommended Fix:** Move the readiness check into `MainController.gd` (to execute immediately after `ProductionStartup` finishes). If readiness is incomplete, instantiate/show `ExperienceReadinessScreen`, wait for its `readiness_finished` signal, and *only then* awaken the Living Iris.

### ISSUE-003: Fragile Audio Service Coupling in Witness Screens
* **Severity:** MEDIUM
* **Reproduction Steps:** Enter the Observation Phase of any Witness Moment.
* **Likely Cause:** `WitnessObservationScreen.gd` attempts to fetch the procedural sound node via a hardcoded absolute path (`get_tree().root.get_node_or_null("Main/ProceduralSound")`). If the scene tree hierarchy changes, or if the scene is tested in isolation, audio calls fail silently or throw null reference errors.
* **Recommended Fix:** Have `WitnessMomentOrchestrator` pass the sound service reference down to the phase screens, or utilize the globally autoloaded `AudioService` singleton.

### ISSUE-004: Dead "Story Mode" Placeholder Code
* **Severity:** LOW
* **Reproduction Steps:** Inspect `Main.tscn` and `MainController.gd`.
* **Likely Cause:** A `StoryModePlaceholder` node is instantiated and wired up in `MainController`. However, the recent Phase 2D navigation update bypasses it entirely, calling `_start_director_selected_witness("story")` directly when the Iris focuses on the center.
* **Recommended Fix:** Remove `StoryModePlaceholder` from `Main.tscn` and delete its associated variables and signal connections in `MainController.gd` to keep memory clean.

---

## Conclusion
The application is mechanically capable of running Chapter 1 end-to-end, but the entry sequence is structurally flawed. Proceed to **MISSION 013 — Chapter 1 Production Hardening** to resolve these 4 specific defects.