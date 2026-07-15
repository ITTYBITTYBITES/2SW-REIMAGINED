# Challenge Difficulty, Rotation, and Progression Audit

**Scope:** discovery only
**Gameplay/code changes:** none
**Engine:** Godot 4.6.3

## Executive summary

The current Two Second Witness challenge framework is already built for replayable, scalable content. It has:

- four named adaptive tiers: Beginner, Standard, Advanced, Expert;
- family-owned difficulty axes;
- family-owned exposure policies;
- seeded generation;
- validation retries and deterministic fallback;
- recent-history signature prevention;
- player-aware recommendations and continue flows;
- per-family mastery, accuracy, streak, XP, achievements, programs, and Witness Level hooks.

The system is not a flat random challenge list. It is a contract-driven runtime that can support hundreds of future witness moments if the content/manifests and family modules remain disciplined.

The main gaps are not the existence of scaling infrastructure. They are:

- rotation is mostly session/content rotation rather than a formal daily/weekly schedule;
- the five families do not expose identical difficulty axes;
- reward and mastery rules are similar but still family-owned and not always equally expressive;
- partial performance is calculated in some families but commonly produces zero score unless the answer is exact;
- challenge variety is strong within families but recommendation/rotation needs more explicit long-term anti-repetition policy;
- public docs have small content-count mismatches, especially Flash Words template documentation.

## Exact challenge families

| Player-facing family | Templates / variants | Content scale |
|---|---|---|
| Scene Investigation | Office, Kitchen, Workshop, Travel Desk, Garden Bench; question types count, attribute, position, adjacency, presence | 5 scenario JSON files, 24 objects each, procedural placement/questions |
| Flash Words | Single Word, Word Pair, Word Stream, Position Catch | 373 reviewed English words plus balancing metadata |
| Spot the Difference | Presence, Attribute, Sequential Switch, Arrangement Shift | 48 object archetypes, 4 themes, seeded paired/sequential mutation |
| Object Recall | Seen Set, Missing Set, Top Row, Bookends | 48 reviewed objects, 3–6 shown objects, 6–9 response options by tier |
| Pattern Recall | Grid Path, Shape Sequence, Pattern Build | 12 symbol kinds, 3×3/4×4 paths, 3–6 token sequences |

`scene_investigation_fixtures` is a regression compatibility family and is excluded from player-facing rotation.

# Difficulty systems

## Shared difficulty model

Every production family supplies a `DifficultyPolicy` that receives a player-state snapshot and returns:

- tier label;
- difficulty axes;
- policy version.

The shared runtime does not interpret those axes. It passes them to the family generator, validator, exposure policy, and scoring policy.

Common inputs are:

- family plays;
- family accuracy;
- family mastery;
- incorrect streak;
- player preferences such as comfortable timing, reading comfort, and color assistance.

Most families use the same broad progression thresholds:

- **Beginner:** fewer than 3 plays;
- **Standard:** early play, lower accuracy, or recovery after misses;
- **Advanced:** roughly 10+ plays, moderate mastery and accuracy;
- **Expert:** roughly 20+ plays, high mastery, high accuracy, and no current miss streak.

Scene Investigation and Flash Words use slightly different thresholds, but the intent is consistent: increase complexity only after repeated evidence of skill and fall back after misses.

## Scene Investigation difficulty

| Tier | Details / complexity | Timing | Distraction / question complexity |
|---|---|---|---|
| Beginner | 8–10 objects, 1 decoration, target scale 1.10, low similarity, low scene/question complexity | 5.0–6.0 sec, default ~5.5 sec | Low distractor similarity; simple question types |
| Standard | 10–13 objects, 3 decorations, target scale 1.0 | 3.5–5.0 sec, default ~4.25 sec | Moderate similarity and question complexity |
| Advanced | 13–16 objects, 4 decorations, target scale 0.90 | 2.0–3.5 sec, default ~2.75 sec | Higher similarity, distractor similarity, and question complexity |
| Expert | 15–18 objects, 5 decorations, target scale 0.82 | 1.5–2.0 sec, default ~1.75 sec | High similarity, high scene complexity, complex question selection |

Additional scaling:

- Comfortable Timing multiplies duration by 1.20.
- Color Assist changes color-dependent generation behavior.
- Exposure duration is further adjusted by scene, similarity, and question complexity.
- Correct score is 800 plus up to 150 difficulty bonus, capped at 1000.

### Audit assessment

This is the most complete multi-axis difficulty model and the strongest reference for future content. It scales density, visual similarity, target size, question complexity, scene complexity, and exposure rather than using timing alone.

## Flash Words difficulty

| Tier | Word length | Similarity | Sequence length | Single-word display timing |
|---|---:|---:|---:|---:|
| Beginner | 3–6 | 0.15 | 1 for single; 3 for stream/default | 5.0 sec |
| Standard | 4–7 | 0.45 | 1/2/3 by mode | 3.5 sec |
| Advanced | 5–8 | 0.70 | up to 4 | 2.4 sec |
| Expert | 6–9 | 0.90 | up to 5 | 1.6 sec |

Additional scaling:

- Distractor categories become more orthographically or semantically similar.
- Recent words are excluded from selection.
- Reading Comfort Mode increases display and interval timing.
- Comfortable Timing multiplies display/interval values by 1.30.
- Pair and stream modes use inter-word intervals.
- Score scales with word length, similarity, and sequence length, capped around 1000.

### Audit assessment

Flash Words has a good adaptive timing model and strong content metadata. The main risk is that timing and reading speed become the perceived difficulty rather than observation skill. Reading Comfort and accessibility need to remain first-class during any redesign.

## Spot the Difference difficulty

| Tier | Object count | Target size | Similarity | State duration |
|---|---:|---:|---:|---:|
| Beginner | 5–7 | 0.18 | 0.15 | 4.8 sec |
| Standard | 7–10 | 0.16 | 0.35 | 3.8 sec |
| Advanced | 9–12 | 0.14 | 0.55 | 3.0 sec |
| Expert | 11–14 | 0.12 | 0.72 | 2.4 sec |

Additional scaling:

- Mutation mode controls whether the difference is presence, attribute, mark, rotation, or arrangement.
- Sequential mode uses two state durations plus a transition allowance.
- Comfortable Timing multiplies total exposure by 1.25.
- Color Assist can remove color-dependent mutations.
- The validator checks target size, normalized bounds, exact mutation count, paired state consistency, and sequential exposure.
- Correct scores scale roughly 800–950 from scene complexity.

### Audit assessment

This is a strong visual-search model with explicit fairness constraints. Target size and spatial response are the most important scaling variables. The accessible Single Choice fallback is a significant preservation point.

## Object Recall difficulty

| Tier | Shown objects | Response options | Exposure |
|---|---:|---:|---:|
| Beginner | 3 | 6 | 5.8 sec |
| Standard | 4 | 7 | 4.9 sec |
| Advanced | 5 | 8 | 4.1 sec |
| Expert | 6 | 9 | 3.4 sec |

Additional scaling:

- Template mode changes the recall rule: seen set, missing set, top row, or bookends.
- The generator keeps distinct objects and guarantees options are available.
- Comfortable Timing multiplies exposure by 1.30.
- Exact set matching is required for score.
- Partial accuracy is calculated for explanation, but partial response generally scores zero.

### Audit assessment

This is a clean and easy-to-tune model. It scales memory load primarily by set size and response set size. The binary score outcome is the main long-term replay risk if near-misses do not feel meaningful.

## Pattern Recall difficulty

| Tier | Grid | Sequence length | Interval | Final hold |
|---|---:|---:|---:|---:|
| Beginner | 3×3 | 3 | 1.05 sec | 0.40 sec |
| Standard | 3×3 | 4 | 0.86 sec | 0.38 sec |
| Advanced | 4×4 | 5 | 0.72 sec | 0.34 sec |
| Expert | 4×4 | 6 | 0.60 sec | 0.30 sec |

Additional scaling:

- Grid Path uses connected cells.
- Shape Sequence uses reviewed symbols with no immediate repeats.
- Pattern Build uses cumulative reveal style.
- Comfortable Timing increases interval and final hold.
- Exact sequence is required for score; matching prefix is preserved for explanation.

### Audit assessment

The model scales sequence length, spatial grid, and temporal interval cleanly. It has good mastery potential but is the most abstract family and may need stronger future relationship to the Witness identity.

# Challenge rotation audit

## Seeded generation

All production generators receive a seed. The seed is stored in `ChallengeInstance` and carried through result/replay metadata. This provides reproducibility, debugging, deterministic fixtures, and meaningful replay.

## Random selection

Randomness occurs inside family generators using `RandomNumberGenerator` seeded by the runtime. The runtime chooses:

- recommended family/template;
- continue recommendation;
- program recommendation;
- explicit template/family start.

Family generators then choose content, layout, mutation, sequence, or question details.

## Repeat prevention

`PlayerProgressService` stores recent history and recent seeds/signatures. `ChallengeSessionService` rejects a candidate when its `scene_signature` has appeared in recent history and retries generation, then uses validated fallback behavior.

This exists at the instance/signature level rather than as a universal content cooldown policy.

## Daily / weekly rotation

No dedicated daily or weekly challenge scheduler was found in the current runtime audit. The current product has:

- a featured recommendation;
- Play Now recommendation;
- Continue recommendation;
- program selection;
- family/template pools;
- recent-signature prevention.

There is no confirmed calendar-based daily seed, weekly rotation table, or rotating category schedule in the current challenge framework.

## Pool and category rotation

- Scene Investigation rotates through five scenario content files and question types.
- Flash Words rotates through 373 words with recent-word avoidance and distractor categories.
- Spot the Difference rotates object archetypes, themes, cells, mutation modes, and target objects.
- Object Recall rotates through a 48-object pool, set composition, row positions, and template modes.
- Pattern Recall rotates shape tokens, connected grid paths, template modes, and seeded sequences.

## What the player sees

Recommendation services choose what starts next. ProgramService can choose a family/template inside a curated program. `ChallengeSessionService.start_recommended_session()` and `continue_recommended()` are the primary runtime entry points.

The system currently does not expose a separate daily/weekly content contract. Future scheduled content should be added as an additive recommendation/rotation service, not embedded in family generators.

# Content scaling audit

## Additional scenes

**Supported.** Scene Investigation adds a JSON content file containing background, objects, groups, question types, and metadata. A new authored scene can be added through the family content path and template/module registration.

## New scenarios

**Supported.** Production families are modules with content manifests, templates, generators, validators, and presentation profiles. New scenarios within a family do not require changing the shared runtime.

## New difficulty variants

**Supported.** Difficulty policies return axes; a new tier or axis can be added inside a family policy while preserving the contract. New tiers must also be validated for accessibility and exposure fairness.

## New object libraries

**Supported.** Object Recall loads `objects_v2.json`; Spot the Difference has a generator archetype pool; Scene Investigation content files carry object libraries. New libraries can be added through content data.

## Seasonal content

**Partially supported.** Content manifests and programs are extensible, and the production `ContentService` / `ProgramService` can represent additional catalog data. A formal date-window, seasonal rotation, entitlement, or archival scheduler is not currently present in the audited challenge runtime.

## Future content scale risks

- Large libraries need content versioning and anti-repetition policy beyond the current recent-signature list.
- New content needs automated validator coverage, not only visual review.
- Family modules currently differ in how much of their content is JSON-driven versus hardcoded in generators.
- Flash Words documentation and JSON template counts are already slightly out of sync.
- Seasonal content should not modify scoring or save contracts implicitly.

# Player progression audit

## XP and levels

`ProfileService` stores player XP, level, and XP-to-next. `PlayerProgressService` records result-derived progress and Witness progress. The production profile is the durable source of truth.

## Witness Level and mastery

Each family returns a mastery change and progress declaration. Family mastery is maintained in `witness_progress.families`. Scene Investigation, Flash Words, Spot the Difference, Object Recall, and Pattern Recall each use family-specific progress keys.

Most families use a common mastery shape:

- correct: approximately +1.5 mastery;
- incorrect: approximately −0.25 mastery;
- bounded 0–100;
- confidence increases with plays.

Difficulty tiers consult plays, accuracy, mastery, and incorrect streak.

## Streaks

Family progress declarations include `streak_action`:

- correct → increase;
- incorrect → reset.

The shared progress layer turns those declarations into current/best streak data.

## Unlocks

- Family metadata can declare `witness_level_required`.
- RecommendationService checks whether a family is unlocked.
- Current visible families include required level metadata; Pattern Recall requires a higher Witness Level than the initial families.
- Experience-level unlocks remain supported through ProfileService/ExperienceRegistry.

## Achievements

Achievement definitions are data-driven in `src/gameplay/progression/achievements.json`. AchievementService evaluates results/profile progress and persists unlock/progress state.

## Recommendations

RecommendationService supports:

- recommended start / Play Now;
- Continue recent or unfinished progress;
- Featured content;
- next challenge after a result;
- family availability and unlock checks;
- Home snapshot data.

## Programs

ProgramService stores curated program definitions and run progress. A program recommends a family/template and records results without owning generation, scoring, or presentation.

## Difficulty/progression connection

Difficulty reads the production player-state snapshot, especially family plays, accuracy, mastery, and incorrect streak. Results write progress and mastery, which changes future difficulty. This is a closed adaptive loop:

```text
Play
→ result / accuracy / streak / mastery
→ saved family progress
→ next difficulty policy
→ new exposure / density / complexity
```

The loop is family-owned at the policy layer and production-owned at the persistence layer.

# Replay motivation audit

Current replay motivators include:

- score improvement;
- accuracy and streak recovery;
- family mastery;
- Witness Level progression;
- achievements;
- challenge history;
- recent recommendations;
- Continue behavior;
- next challenge recommendations;
- curated Programs;
- favorites and family progress;
- evidence/reveal explanations;
- deterministic replay metadata.

Current gaps:

- no formal daily/weekly leaderboard or rotation;
- no explicit collection/season reward system in the audited runtime;
- partial accuracy is often explanatory rather than rewarding;
- replay motivation varies by family because result reveals and emotional payoffs differ;
- no single long-term “discovery catalog” contract connects all family discoveries to the Iris Archive yet.

# Preserved systems

The future redesign must preserve:

1. all five player-facing Challenge Types;
2. seeded reproducibility;
3. family-specific difficulty axes;
4. exposure accommodation and reduced-motion/accessibility policy;
5. challenge pools and scenario content;
6. recent-repeat prevention;
7. family-owned scoring/result explanations;
8. XP, levels, mastery, streaks, unlocks, achievements, programs, and recommendations;
9. production profile/save schemas;
10. generic interaction adapters and accessible alternatives;
11. the observation → response → evidence loop.

# Missing or underdeveloped systems

1. Formal daily/weekly rotation scheduler.
2. Explicit calendar/content-window contract for seasonal content.
3. A unified cross-family challenge history/discovery catalog for the Iris Archive.
4. More expressive partial-performance/recovery rewards.
5. A common pacing contract for “attention window” presentation while preserving family-specific timing.
6. A unified anti-repetition policy that works across families and programs.
7. Stronger documentation synchronization between family README, manifests, and JSON content counts.
8. A clear content validation dashboard for future hundreds of witness moments.

# Recommendations before challenge redesign

- Preserve the current generic runtime and family policy boundaries.
- Treat Scene Investigation’s multi-axis difficulty model as the reference for future authored content.
- Add rotation/scheduling as a new production recommendation service, not as a family-generator branch.
- Add a content validation/reporting tool before the content library grows significantly.
- Define a shared discovery/history schema so the Iris Archive can represent family results without duplicating progress.
- Decide whether partial accuracy should remain explanation-only or become a deliberate progression/recovery reward.
- Update family docs to match the actual manifests and template counts.
- Do not redesign a single challenge until its difficulty, repeat-prevention, progression, and evidence contracts are preserved in the new presentation.

## Final conclusion

The current framework can support hundreds of future witness moments. Its strongest scalability assets are the family module contract, seeded/fair generation, policy separation, interaction adapters, and production progress services. The redesign challenge is to make those systems feel like one coherent discovery instrument without collapsing family identity or difficulty ownership.
