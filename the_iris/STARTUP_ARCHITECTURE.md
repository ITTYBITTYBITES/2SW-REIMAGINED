# STARTUP ARCHITECTURE CONSOLIDATION

**Document Status:** ACTIVE (Living Document)
**Target Phase:** Living Iris 4.0

This document serves as the permanent reference for the Two Second Witness 4.0 initialization flow. To prevent architectural fragmentation and race conditions, the application mandates **exactly one authoritative production startup flow**.

## 1. Startup Ownership
* **Root Application Node:** `Main.tscn` (and `MainController.gd`)
* **Role:** `MainController.gd` acts as the exclusive startup orchestrator. It manages the presentation of the splash screens, hardware readiness gating, and the initial awakening of the Living Iris. 

## 2. Final Initialization Order
The sequence executes deterministically. The next phase does not begin until the previous phase explicitly signals completion.

1. **App Launch** (Godot Engine boots into `Main.tscn`)
2. **ProductionStartup** (`ProductionStartup.tscn`)
   * Displays the Publisher Splash (`ittybittybites_splash.png`).
   * Displays the Title Splash (`two_second_witness_splash.png`).
   * Emits `finished` signal to `MainController.gd`.
3. **Experience Readiness Gate** (`ExperienceReadinessScreen.tscn`)
   * Shown *only* on the first launch (determined by `ExperienceReadinessService.is_readiness_completed()`).
   * Allows the player to verify Audio and Haptic availability.
   * Player presses `CONTINUE`. Emits `readiness_finished` signal.
4. **Living Iris Initialization** (`IrisController.gd`)
   * `MainController.gd` calls `iris.start_awakening()` and `voice_guide.begin_session()`.
   * The Living Iris organically fades in and assumes control.
5. **Home**
   * The player rests in the Iris focus state, able to navigate visually.
6. **Witness Runtime**
   * Entered when the player releases focus on the "Story Mode" (center pupil) portal.

## 3. Routing Responsibilities
* **`MainController.gd`** owns the immediate screen switching logic (`_show_screen()`) within the context of the Living Iris paradigm (e.g. toggling the active phase overlay screens).
* **`NavigationService.gd`** remains the global orchestrator for decoupled routing calls (e.g., deep linking, legacy screen loads, or explicit external URL commands), but it delegates visual transition responsibilities to the Iris framework when in standard gameplay.

## 4. Retired Legacy Components
The following legacy startup paths were historically used for the early AppShell model but are now strictly bypassed and deprecated to preserve a single deterministic boot sequence:
* **`TitleSplashScreen.tscn` / `TitleSplashScreen.gd`:** Retired. (The splash logic is now explicitly handled by `ProductionStartup.tscn`).
* **`AppShell.tscn` / `AppShell.gd`:** Deprecated as a root mount. While its logic survives for secondary/support routes, it is absolutely forbidden to mount `AppShell` as a primary root node over `Main.tscn`.
* **`StoryModePlaceholder`:** Removed completely. Story Mode execution is handled natively by the `WitnessMomentOrchestrator` directly through `MainController.gd`'s gaze interactions.
