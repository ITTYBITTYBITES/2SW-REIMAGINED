# IRIS IMPLEMENTATION PLAN — Experience Layer Bridge

**Campaign:** Architecture Convergence  
**Phase:** Iris Experience Completion Pass  
**Status:** Approved & Implemented  
**Date:** 2026-07-17  
**Author:** Director Agent (Arena.ai)

---

## 1. Objective

Complete the player-facing Iris experience layer so that Iris acts as the seamless entry point, living guide, and reflection surface upon returning from a Witness Moment, without modifying Witness Runtime architecture or Chapter 1 content.

---

## 2. Implementation Action Items

### Action 1: Immediate Progression & Shard Synchronization
- Ensure `IrisController._sync_progression()` and `LivingIris3D` query `PlayerProgressService` upon returning to the home screen.
- Verify that newly unlocked memory shards (WM_001 through WM_005) immediately populate around the Iris portal and 3D eye model.

### Action 2: Post-Witness Awakening & Reflection Trigger
- When `MainController._return_to_iris_after_completion()` executes, trigger `IrisController.remember_recent_activity()` and `IrisController.start_awakening()`.
- This creates an organic visual pulse (stroma glow + memory shard highlight) acknowledging that a new memory has been successfully preserved in the archive.

### Action 3: Boundary Compliance Check
- Strictly adhere to implementation rules: zero changes to `WitnessIncidentRegistry`, `WitnessMomentOrchestrator`, phase screens, or Chapter 1 JSON content.

---

## 3. Verification & Completion Standard

The Iris experience layer is certified complete when:
1. Booting into Iris presents a living, breathing eye with progression-scaled stroma and shards.
2. Completing any Witness Moment automatically returns the player to Iris with a visible awakening pulse and updated memory archive count.
3. All validation check suites pass **GREEN**.
