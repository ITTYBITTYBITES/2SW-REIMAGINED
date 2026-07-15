# LEGACY SUPPORT MARKERS

This directory contains the legacy challenge systems that are temporarily maintained for compatibility with existing challenge modes (Daily Witness, Weekly Investigation, Discovery mode).

**DO NOT DELETE THESE SYSTEMS** - They serve active game modes outside of Story Mode.

## Marked Legacy Systems

| System | Location | Status | Replacement |
|--------|----------|--------|-------------|
| Tutorial System | `src/ui/screens/TutorialScreen.*` | LEGACY_SUPPORT | Witness Moment has no tutorial |
| Observation Challenge | `src/ui/screens/ObservationChallengeScreen.*` | LEGACY_SUPPORT | `WitnessObservationScreen` |
| Memory Question | `src/ui/screens/MemoryQuestionScreen.*` | LEGACY_SUPPORT | `WitnessReconstructionScreen` |
| Result Screen | `src/ui/screens/ResultScreen.*` | LEGACY_SUPPORT | `WitnessRevelationScreen` |
| Production Witness Host | `src/iris/integration/ProductionWitnessHost.gd` | LEGACY_SUPPORT | `WitnessMomentOrchestrator` |
| Challenge Session Service | `src/gameplay/session/ChallengeSessionService.gd` | LEGACY_SUPPORT | Not needed for Story Mode |
| Scene Investigation Family | `src/LegacyMechanics/scene_investigation/` | LEGACY_SUPPORT | Retained for Discovery mode |
| Flash Words Family | `src/LegacyMechanics/flash_words/` | LEGACY_SUPPORT | Retained for other modes |
| Object Recall Family | `src/LegacyMechanics/object_recall/` | LEGACY_SUPPORT | Retained for other modes |
| Pattern Recall Family | `src/LegacyMechanics/pattern_recall/` | LEGACY_SUPPORT | Retained for other modes |

## Migration Notes

### For WM_001 (Learning to Notice)
- **No TutorialScreen** - Iris voice guides directly
- **No ObservationChallengeScreen** - Uses `WitnessObservationScreen` (no HUD, no countdown)
- **No MemoryQuestionScreen** - Uses `WitnessReconstructionScreen` (spatial fragments, no validation)
- **No ResultScreen** - Uses `WitnessRevelationScreen` (archive entry, no score)
- **No ProductionWitnessHost routes** - Uses `WitnessMomentOrchestrator` direct phase flow

### For Other Challenge Modes (Daily, Weekly, Discovery)
- Continue using legacy systems unchanged
- These are separate game modes with different design goals

## Future Replacement Path

When Story Mode expands beyond WM_001:
1. Each new Witness Moment uses the Orchestrator + Phase Screens
2. Legacy systems remain for non-Story modes
3. Eventually, a unified "Witness Moment" family may replace challenge families
4. But NOT before the format is proven with WM_001

---

*This marker file exists to prevent accidental deletion of systems still in use by other game modes.*