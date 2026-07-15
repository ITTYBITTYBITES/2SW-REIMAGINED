# Two Second Witness 4.0 Asset Pipeline Plan

**Status:** Blueprint only — no assets changed in this phase

## Objective

Create a scalable, non-blocking pipeline for Witness Story Mode and future challenge content. Development must be able to use procedural/current placeholders while production art arrives in deliberate batches.

The pipeline must preserve:

- deterministic content IDs;
- replaceable presentation assets;
- accessibility variants;
- reduced-motion behavior;
- safe fallback rendering;
- Android size/performance budgets;
- consistent Two Second Witness / ITTYBITTYBITES identity.

## 1. Placeholder strategy

### Rule

A placeholder is acceptable when it proves:

- the gameplay contract;
- the content data shape;
- the intended composition;
- the interaction target;
- the evidence/reveal behavior;
- the accessibility fallback.

A placeholder is not acceptable as a permanent production assumption if it changes the player’s understanding of the challenge.

### Placeholder tiers

#### Tier 0 — contract placeholder

- vector fallback;
- flat color blocks;
- generated shapes;
- text labels for debug/accessibility only;
- no dependency on final art.

Use for runtime and content pipeline development.

#### Tier 1 — composition placeholder

- rough scene background;
- temporary object sprites;
- approximate audio cue;
- final target bounds and safe areas.

Use for interaction/fairness testing.

#### Tier 2 — production candidate

- reviewed composition;
- approved object hierarchy;
- final target readability;
- calibrated contrast and touch bounds;
- final or near-final audio mix.

Use for human playtest.

#### Tier 3 — release asset

- legal/brand review complete;
- optimized/imported for Android;
- accessibility variants reviewed;
- device-size/foldable/safe-area validation complete;
- content version locked.

## 2. Production asset batches

### Batch A — Scene Investigation reference slice

Purpose: establish the production visual and evidence language.

- one flagship scenario, recommended Office or Garden Bench;
- background image or authored scene layer;
- 10–18 object variants across difficulty tiers;
- object highlight/evidence states;
- target/reveal annotations;
- observation ambience and reveal SFX;
- Iris-to-scene transition treatment;
- accessible high-contrast and reduced-motion behavior.

### Batch B — Scene Investigation scenario expansion

- Kitchen;
- Workshop;
- Travel Desk;
- Garden Bench / additional environmental contexts;
- scenario-specific object libraries;
- question-specific evidence treatment.

### Batch C — Spot the Difference

- paired/sequential scene compositions;
- mutation-specific evidence overlays;
- spatial target states;
- accessible single-choice equivalents.

### Batch D — Object Recall

- reviewed object sprite pack;
- tray/background compositions;
- object selected/missed/correct states;
- multi-select response states;
- set evidence presentation.

### Batch E — Pattern Recall and Flash Words

- symbol system and geometric tokens;
- typography hierarchy and word display treatments;
- reading-comfort variants;
- sequence pulse/evidence states;
- audio rhythm and timing cues.

### Batch F — Shared Story Mode

- Iris entry portal treatment;
- Witness field framing;
- discovery/evidence transitions;
- reward/record response;
- return-to-Iris memory response;
- family introduction motifs.

## 3. Naming standards

### Files

Use lowercase `snake_case` with versioned content IDs:

```text
assets/gameplay/scene_investigation/office/office_wall_v1.png
assets/gameplay/scene_investigation/objects/desk_lamp_v1.png
assets/gameplay/spot_the_difference/themes/paper_v1.png
assets/audio/witness/scene_investigation_reveal_v1.wav
```

### Content IDs

Use stable semantic IDs, never filenames as identity:

```text
family_id: scene_investigation
scenario_id: office_v1
template_id: office_detail_v1
asset_id: office_desk_lamp_v1
content_version: scene-investigation-office-v1
```

### Variants

Suffix variants by purpose:

- `_hc` — high contrast;
- `_reduced` — reduced-motion or static variant;
- `_small` — compact-device optimization;
- `_landscape` — composition variant only when genuinely necessary;
- `_v2` — intentional content revision.

Do not create portrait and landscape duplicates by default. Prefer responsive scene data/composition.

## 4. Replacement workflow

1. Identify the content ID and current placeholder source.
2. Do not change the gameplay contract or target semantics.
3. Add the production asset at a versioned path.
4. Update the family/content manifest reference.
5. Keep the previous asset available until validation completes if save/history/replay depends on its ID.
6. Run validator, content audit, and scene preview checks.
7. Test target bounds, evidence highlight, reduced motion, high contrast, and mobile safe areas.
8. Compare old/new screenshots and result evidence.
9. Update content version and changelog.
10. Remove the old asset only after confirming no stored/replay reference requires it.

## 5. Scalable content creation

### Data first

Every production moment should be expressible as data:

- family/scenario/template ID;
- background/reference;
- object library;
- target/distractor rules;
- question type;
- evidence/highlight IDs;
- difficulty ranges;
- exposure ranges;
- accessibility requirements;
- audio profile;
- content version.

### Authoring contract

Content authors should not edit runtime code for a new scenario when an existing family contract supports it. New code is appropriate only for:

- a genuinely new perception mechanic;
- a new interaction adapter;
- a new renderer contract;
- a new fairness rule that cannot be data-driven.

### Batch validation

Each content batch should run:

- JSON/schema validation;
- generator determinism;
- fairness validator;
- duplicate/repeat signature checks;
- target-size/bounds checks;
- missing asset checks;
- accessibility metadata checks;
- preview/render smoke test;
- performance/import size report.

## 6. Image and sprite standards

- Prefer dimensions appropriate to the logical composition rather than oversized source files.
- Keep transparent sprite bounds tight enough for predictable visual placement.
- Preserve texture filtering appropriate to the family style.
- Use deterministic import settings where pixel or shape precision matters.
- Avoid baking text into art when text must scale or be read by accessibility tools.
- Keep focal/evidence details large enough to explain the result on small phones.

## 7. Audio standards

- Production gameplay audio remains under `assets/audio` and is routed by `AudioService`.
- Iris VoiceGuide remains a separate guidance channel.
- New voice lines require a short phrase, transcript, mute behavior, caption behavior, and cooldown decision.
- SFX should communicate state changes without being required for task completion.
- Normalize loudness across family cues and test sound-off equivalence.
- Prefer short, loop-safe clips and avoid unnecessary runtime decoding of large files.

## 8. Accessibility asset variants

Every new visual family should answer:

- Is the target identifiable without color alone?
- Is evidence identifiable without motion alone?
- Is the challenge usable with reduced motion?
- Are target regions at least the production minimum touch size?
- Is there an explicit adapter when spatial interaction is not usable?
- Can a caption/transcript describe the relevant state?

Accessibility is a content requirement, not a final post-process.

## 9. Android and performance budgets

Before release-candidate status:

- remove generated import/cache artifacts from source packages;
- measure texture memory after importing a full family batch;
- verify no unnecessary large textures remain referenced by an active screen;
- check audio memory and simultaneous player counts;
- test low-memory Android behavior;
- avoid loading every future family asset at startup;
- use lazy loading for challenge-specific assets where the production runtime permits.

## 10. Asset governance

- The production asset tree is intentionally retained for the existing five families and future roadmap.
- Do not delete an apparently unused asset without checking manifests, renderer scripts, tutorial scenes, result reveals, tests, and future roadmap documents.
- Generated `.import` files and `.godot` caches are not source assets.
- Each batch should have an owner, content version, review status, and rollback path.
