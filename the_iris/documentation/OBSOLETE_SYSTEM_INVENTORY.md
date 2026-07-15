# Two Second Witness 4.0 Obsolete System Inventory

**Purpose:** identify candidates for eventual removal without deleting anything in this phase.
**Status:** inventory only

## Removal policy

An item is not removable merely because it is not visible in the current Iris flow. Before removal, verify:

- scene/resource references;
- production manifests;
- save/replay references;
- tests and regression fixtures;
- accessibility/deep-link paths;
- Android/export references;
- roadmap dependencies;
- support/recovery workflows.

## Candidate inventory

### 1. Regression-only Scene Investigation fixture family

**Location:** `src/LegacyMechanics/scene_investigation/SceneInvestigationFixtureFamily.gd` and fixture policies/tutorial.

**Status:** KEEP for tests; REMOVE FROM PLAYER ROTATION eventually.

**Why:** It protects deterministic runtime regression coverage but is not a product Challenge Type. Keep the code/test coverage while ensuring Story Mode and recommendations never select it.

**Removal condition:** replace all regression coverage with an explicit test-only registry or test manifest, then remove player-facing manifest exposure without removing test fixtures.

### 2. Legacy sample Iris Witness fallback

**Location:** legacy behavior in `scripts/WitnessMode.gd`, `WitnessCanvas.gd`, and the procedural sample reveal.

**Status:** REMOVE EVENTUALLY FROM NORMAL PLAYER FLOW.

**Why:** ProductionWitnessHost is now the authoritative production experience. The fallback remains useful for failure recovery and Iris-only smoke tests.

**Removal condition:** production Witness error/empty-session fallback exists and is accessible, tested, and visually continuous.

### 3. Prototype destination drawings

**Locations:** fallback rendering in `Archive.gd`, `Profile.gd`, `Settings.gd`, and `Discovery.gd`.

**Status:** KEEP AS FALLBACK; REMOVE EVENTUALLY FROM PRIMARY FLOW.

**Why:** ProductionDestinationHost now mounts production rooms. The Iris fallback still provides a graceful surface if a production room cannot load.

**Removal condition:** production host load failures have an equivalent Iris recovery state, accessibility path, and test coverage.

### 4. Direct production AppShell root assumptions

**Location:** `src/ui/shell/AppShell.tscn` / `AppShell.gd` and older top/tab navigation components.

**Status:** KEEP AS COMPATIBILITY INFRASTRUCTURE; REMOVE EVENTUALLY ONLY IF SAFE.

**Why:** Production screens may depend on AppShell conventions, direct routes, deep links, tests, and future release support. The Story Mode root should not mount a second AppShell.

**Removal condition:** all production screens are host-safe, direct routes have a replacement entry, and release/support workflows no longer use AppShell as a root.

### 5. Challenge-type-first Home hub assumptions

**Locations:** production HomeV2, Experiences/Library flows, route tab metadata, and old home recommendations.

**Status:** MODIFY first; REMOVE EVENTUALLY AS DEFAULT ROOT.

**Why:** These rooms remain valuable for explicit choice, mastery, and accessibility, but they conflict with Story Mode as the default doorway.

**Removal condition:** Story Mode Director has equivalent recommendation, continue, daily/featured, and recovery behavior.

### 6. Conventional bottom/tab navigation assumptions

**Locations:** `src/ui/shell/MainNavigation.gd`, `TopBar.gd`, AppShell chrome.

**Status:** MODIFY; remove only from default Story Mode root later.

**Why:** They remain useful for production rooms and explicit access. They should not be the primary product hierarchy after Story Mode is accepted.

### 7. Family-first tutorial wording and route flow

**Locations:** family tutorial screens and direct `tutorial` route behavior.

**Status:** MODIFY.

**Why:** Tutorials are currently family-mode explanations. Story Mode should turn first exposure into an integrated Witness beat while retaining replay tutorials.

**Removal condition:** Story Mode introductions cover every required family and accessibility mode.

### 8. Historical migration / phase documentation

**Locations:** `documentation/UX_STRESS_TEST.md`, older phase reports, integration audit history.

**Status:** KEEP AS HISTORY; REMOVE EVENTUALLY ONLY AFTER ARCHIVAL POLICY.

**Why:** These documents explain decisions and risks. They should not compete with `PROJECT_FOUNDATION.md`, baseline, rules, and current reports.

**Removal condition:** archive history in an agreed location and update all references.

### 9. Generated Godot artifacts

**Locations:** `.godot/`, `*.import`, build output.

**Status:** REMOVE whenever generated.

**Why:** They are environment-specific and can create stale import/parser behavior.

**Removal condition:** none; always safe to regenerate when not in use.

### 10. Temporary test scenes/scripts

**Status:** REMOVE after each validation run.

**Current inventory:** no temporary integration test scenes/scripts remain in the root source tree.

### 11. Duplicate Iris/prototype state for production progress

**Locations:** Iris `StateManager.gd` and `user://the_iris_state.cfg` fields related to observations/discoveries.

**Status:** MODIFY / REMOVE DUPLICATE FIELDS EVENTUALLY.

**Why:** Iris awakening/relationship state is valid. Production challenge counts, mastery, history, and achievements must not be duplicated there.

**Removal condition:** all Iris-facing stats read from PlayerProgressService and Iris-only state is explicitly separated.

### 12. Duplicate audio ownership

**Locations:** Iris `ProceduralSound.gd` / VoiceGuide and production `AudioService.gd`.

**Status:** KEEP WITH BOUNDARY; REFACTOR EVENTUALLY.

**Why:** Iris voice/procedural ambience and production BGM/SFX are distinct channels, but future mix/settings synchronization should be centralized.

**Removal condition:** AudioService can expose safe Iris guidance/ambience channels without breaking production audio.

### 13. Unused planned content folders

**Locations:** empty `.gitkeep` content folders such as `assets/evidence`, `assets/home`, `assets/record`, and `assets/scenes`.

**Status:** KEEP.

**Why:** They are roadmap extension points, not abandoned assets by default.

**Removal condition:** only after roadmap ownership confirms a folder is no longer part of the content plan.

## Cleanup order

1. Keep all production/content assets and challenge runtime.
2. Keep fallback screens until production hosts have parity.
3. Move Story Mode to the default doorway only after migration gates pass.
4. Mark old direct routes as secondary before removing any route.
5. Remove generated artifacts every packaging cycle.
6. Archive historical docs only after governance documents are accepted.

## Conclusion

No gameplay files, challenge mechanics, assets, or working services should be deleted as a result of this inventory. The primary obsolete material is not code that can safely disappear today; it is the old player-facing assumption that challenge families should be the first navigation choice.
