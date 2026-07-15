# Challenge Redesign Recommendations

**Scope:** discovery and prioritization only
**Gameplay changes made:** none

## Recommended first reference experience

# Redesign Scene Investigation first

Scene Investigation is the strongest candidate to become the production-quality reference experience for Two Second Witness 4.0.

## Why it is the best candidate

1. **It is the clearest expression of the product promise.** The player studies a real-feeling scene, later realizes a detail was missed, and receives an evidence reveal.
2. **It naturally connects to the Iris.** The Iris is a perception instrument; Scene Investigation is already about looking through a visual field rather than manipulating an abstract ruleset.
3. **It has enough range to become a durable reference.** Office, Kitchen, Workshop, Travel Desk, and Garden Bench give the team multiple authored worlds without needing a new challenge family.
4. **It exercises the complete platform.** It uses generated scenes, timed exposure, single-choice recall, validation, scoring, mastery, progress history, audio, accessibility, and evidence reveal.
5. **It exposes the most important product quality questions.** Fairness, visual hierarchy, evidence clarity, exposure pacing, and the emotional “I missed it” response can all be tested here.
6. **It can become the visual contract for the other families.** The shared attention-window framing, Iris entry, reveal language, and return-to-Iris memory can later inform Flash Words, Spot the Difference, Object Recall, and Pattern Recall without flattening their mechanics.

## What should be preserved

- The Scene Investigation family identity.
- The five current production scene templates:
  - Office
  - Kitchen
  - Workshop
  - Travel Desk
  - Garden Bench
- The procedural/seeded generator architecture.
- The 24-object content structure per scene.
- Question categories: count, attribute, position, adjacency, presence.
- The fairness validator and generation retries/fallback.
- Player-aware difficulty and exposure policies.
- The single-choice interaction adapter.
- Family-owned scoring and mastery policy.
- Evidence metadata: `highlight_ids`, `where_to_look`, generated scene, and explanation.
- Production profile/history/progression persistence.
- Reduced motion, comfortable timing, color-independent reveal, and accessibility hooks.
- Observation → recall → result as the core loop.

## What should be completely replaced later

These are presentation-layer replacements, not a request to rewrite the mechanics:

1. **Generic observation screen framing**
   - Replace the standard app-shell feel with an Iris-derived optical entry and attention window.
2. **Current scene visual treatment where it reads as placeholder/vector fallback**
   - Preserve the scene data contract, but replace/upgrade presentation assets and renderer styling through the approved content pipeline.
3. **Generic countdown language**
   - Replace a conventional timer-first presentation with a calm, legible attention state that still communicates the exposure boundary.
4. **Weak or inconsistent evidence reveal**
   - Make the changed/missed detail unmistakable, spatially grounded, and emotionally satisfying.
5. **Disconnected result-to-home transition**
   - Make the result close through the Iris and leave a visible memory/progress response.
6. **One-size-fits-all family question copy**
   - Keep the question contract but author language that feels like a witness prompt rather than a test item.

## Why not redesign the others first?

### Flash Words

Strong mechanics and content quality, but it risks becoming a reading-speed test. It should be redesigned after the team has established how Iris-guided attention, anticipation, and evidence reveal work in a spatial scene.

### Spot the Difference

A strong second candidate. It has a clear “what changed?” payoff and strong direct touch interaction. It should follow Scene Investigation once the team has solved fair target presentation and evidence clarity.

### Object Recall

Reliable and controlled, but more likely to feel like a conventional memory quiz. It benefits from a stronger shared evidence/reveal language before a visual redesign.

### Pattern Recall

Good tension and mastery potential, but its abstraction is farther from the product’s “notice what others miss” emotional promise. It should be redesigned after the reference language is proven.

## Recommended redesign order

1. **Scene Investigation** — reference experience for observation, recall, evidence, and Iris return.
2. **Spot the Difference** — reference for visual comparison and spatial response.
3. **Object Recall** — reference for set memory and accessible multi-selection.
4. **Pattern Recall** — reference for abstract sequence mastery.
5. **Flash Words** — reference for high-tempo typography and reading-comfort adaptation.

The order is not a ranking of product value. It is a dependency order for establishing the shared experience language.

## Design questions to answer during the first redesign

- Does the player understand when the Iris has opened the observation field?
- Does the exposure feel short, fair, and intentional rather than like a timer trap?
- Can a player explain what they missed after the evidence reveal?
- Does the reveal create curiosity to try another scene?
- Does returning to the Iris feel like returning to the same instrument rather than leaving a game screen?
- Can reduced-motion, captions, explicit access, and comfortable timing preserve the same perception goal?
- Does the Iris remain a doorway while the scene itself still owns the challenge?

## Explicit non-goals for this phase

- No new challenge families.
- No scoring changes.
- No timing changes.
- No asset replacement.
- No new art.
- No gameplay implementation.
- No removal of current family mechanics.

The next phase should redesign only after this audit is accepted and Scene Investigation is approved as the reference experience.
