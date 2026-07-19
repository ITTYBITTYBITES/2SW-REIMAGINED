# Mission 064 — Device Runtime Validation & Chapter 01 Experience Verification

**Date:** 2026-07-18  
**Repository baseline:** `a8f00a0` — Mission 063 Chapter 01 Experience Audit  
**Mission status:** **BLOCKED — runtime/device environment unavailable**

## Validation integrity statement

Mission 064 requires a real Godot runtime and target device/emulator evaluation. This workspace was audited before execution and does **not** expose:

- `godot` or `godot4` executable;
- Android SDK / `sdkmanager`;
- Android emulator;
- `adb` device bridge;
- a device connected to the workspace;
- a visual runtime capture path.

Therefore, no claim in this document labels device behavior as passed. Static preflight checks are recorded separately from runtime/device checks.

No game code, Witness Moment content, persistence, navigation, Archive, progression, or runtime architecture was changed during this validation mission.

---

## Static preflight result

### PASS — production contracts and authority chain

The prior Chapter 01 audit and current repository state confirm:

```text
IncidentRegistry
→ WitnessContentLoader
→ WitnessMomentDefinition
→ GenericWitnessGameplay
→ WitnessMomentResult
→ WitnessProfile.moment_records
→ WitnessArchive
→ LivingArchiveProjection
→ IrisEvolutionProfile
→ LivingIris / SpatialHub
```

All Chapter 01 authored moments have static contract coverage:

| Moment | Fracture | Truth Fragment | Existing validation |
| --- | --- | --- | --- |
| WM-001 — The Unfinished Canvas | `borrowed_light` | Borrowed Light | `wm001_showcase_validation.gd` |
| WM-002 — The Forgotten Museum | `inherited_warmth` | Inherited Warmth | `wm002_production_validation.gd` |
| WM-003 — The Last Performance | `departing_echo` | Safe Harbor | `wm003_production_validation.gd` |
| WM-004 — The Faulty Reactor | `future_pressure` | Early Warning | `wm004_production_validation.gd` |
| WM-005 — The Witness | `returned_gaze` | Shared Aperture | `wm005_production_validation.gd` |

Existing static validation also covers:

- portal state/routing contract;
- Living Archive persistence/projection;
- Chapter pipeline relationship/bloom derivation;
- profile serialization;
- WM-006–WM-012 compatibility baseline;
- audio-reference existence;
- `git diff --check` integrity.

### PASS — known static player-flow supports

- Awakening flow is authored in `IrisController.begin_awakening_ritual()`.
- Hub selection is routed through existing `Application.request_memory_portal()`.
- Portal entry and return remain in `IrisPortalTransition` / `Application`.
- Generic runtime has Fracture, Synchronization, Revelation, and Truth Fragment phases.
- Fragment recovery persists through existing `WitnessProfile.moment_records`.
- Archive/constellation/Iris relationship state is derived from the same records.

---

## Runtime/device validation matrix

| Validation area | Required evaluation | Status | Evidence required |
| --- | --- | --- | --- |
| Fresh profile | Clean install/profile through first Hub presentation | **NOT RUN** | Device video or tester notes with build/version/device |
| Awakening | Timing, dialogue/audio/haptic synchronization | **NOT RUN** | Video with audio, haptic observation notes |
| Spatial Hub | Iris centrality, memory selection clarity, readable relationship text | **NOT RUN** | Screen recording and tester observations |
| Portal entry | Pupil dilation, visual continuity, audio pacing, intent as travel | **NOT RUN** | Capture of entry into WM-001 and WM-005 |
| WM-001–WM-005 completion | Fracture readability, false leads, synchronization intent, Truth payoff | **NOT RUN** | One completed run per moment, notes on friction/clarity |
| Iris absorption | Visible response and meaningful transition after every restoration | **NOT RUN** | Pre/post capture plus tester notes |
| Archive inspection | Fragment identity, truth statement, reflection clarity | **NOT RUN** | Archive captures after at least two fragments |
| Five-fragment Chapter Bloom | `5 / 5` constellation/bloom and `AWAKENING` relationship behavior | **NOT RUN** | Persisted complete profile capture |
| Persistence | Force close/restart after 1 and 5 fragments | **NOT RUN** | Restart video or profile-state screenshots |
| Touch interaction | Target sizing, accidental input, hold timing | **NOT RUN** | Device tester notes across common screen sizes |
| Interruption/resume | Backgrounding, resume, rotation if supported | **NOT RUN** | Platform-specific test notes |
| Reduced motion | Screenshake/visual intensity behavior | **NOT RUN** | Accessibility setting capture and comparison |
| Audio/haptic dependency | Readability and completion without either sensory channel | **NOT RUN** | Muted/haptics-disabled test notes |

---

## Required device test protocol

### Environment record

Record before testing:

```text
Build commit:
Godot version:
Device model:
OS version:
Screen resolution / refresh rate:
Audio output:
Haptics enabled/disabled:
Reduced motion enabled/disabled:
Fresh profile or persisted profile:
```

### A. Fresh-profile validation

1. Clear app data or use a new profile.
2. Launch application.
3. Observe splash → awakening → ready state.
4. Enter the Spatial Hub.
5. Record whether the Iris is understood as an artifact/home rather than a menu.
6. Select the available first-memory path and enter via the pupil portal.

**Pass condition:** A first-time player can explain that the Iris noticed them and opened a memory.

### B. Per-moment validation

Complete WM-001 through WM-005 in sequence. For each moment, record:

- Fracture was discoverable from observation/evidence rather than trial-and-error;
- false leads redirected rather than frustrated;
- Synchronization felt like stabilization, not a generic hold bar;
- Revelation explained the human meaning;
- Truth Fragment felt distinct;
- Iris absorption was noticed;
- portal return preserved continuity.

### C. Chapter completion validation

With all five fragments recovered:

1. Return to Hub.
2. Inspect constellation/relationship state.
3. Open Archive and inspect each recovered fragment.
4. Confirm Chapter 01 reports `5 / 5` recovered memories.
5. Restart app and repeat Hub/Archive inspection.

**Pass condition:** The player understands that the Iris retains the five restored human truths and that Shared Aperture reframed their role as witness.

### D. Resilience and accessibility

- Background/resume during portal, observation, Synchronization, and Archive inspection.
- Test portrait orientation and any supported rotation behavior.
- Test muted audio and haptics disabled.
- Test reduced motion enabled.
- Test text readability under bright ambient light where possible.

---

## PASS / TUNE / BLOCKER classification

### PASS — static/foundation confidence

- Chapter 01 production contracts are consistent.
- Existing authority chain remains singular.
- Portal, Archive, persistence, and relationship derivation have static validation coverage.
- No system rebuild is indicated.

### TUNE — expected runtime refinement candidates

- Awakening, portal, synchronization, and return timing.
- Audio balance between ambient loops, Iris cues, and Witness resolution.
- Haptic cadence/intensity.
- Fracture target clarity, false-lead language, and touch ergonomics.
- Spatial Hub current-memory framing vs. Story/Chapters selection.
- Archive inspection layout and relationship/Chapter bloom readability.

### BLOCKER — release-quality experience verification

- **No Godot runtime/device is available in this workspace.**
- Actual hardware validation cannot be completed or claimed from static code inspection.
- No screenshots or video can be captured here.

### KEEP

- All current authority systems and Chapter 01 architecture.

### POLISH

- All items listed under TUNE after device evidence is collected.

### EXTEND

- A repeatable device test harness/checklist and optional automated device smoke workflow after the first manual pass.

### REBUILD

- None currently indicated.

---

## Decision gate

Mission 064 is only complete after the device test matrix is executed and evidence is attached/recorded.

**Current recommendation:** Do not begin WM-006–WM-012 production migration until a real runtime/device test confirms that Chapter 01 is playable end-to-end and that remaining work is polish rather than an experiential blocker.
