# Witness Moment Difficulty Model

## Purpose

Difficulty must scale perception demand while preserving the emotional meaning of the moment. Do not expose difficulty as a challenge-family menu. The player should feel a more demanding witness, not a harder mini-game label.

## Difficulty dimensions

A future Witness Moment may scale:

- observation time;
- number of meaningful elements;
- similarity between relevant/distractor elements;
- number of relationships to hold;
- sequence length;
- evidence ambiguity;
- target size/precision;
- number of valid investigation paths;
- amount of assistance;
- emotional/narrative complexity;
- number of Challenge Sequence beats.

## Narrative tiers

### Attunement

A gentle first exposure with clear intention and generous time.

### Recognition

The player understands the perceptual goal and receives moderate complexity.

### Investigation

Multiple relationships or plausible distractions require deliberate attention.

### Mastery

The player faces subtlety, layered evidence, shorter windows, or alternate interpretations without unfairness.

## Existing production policy relationship

The future Director chooses a narrative tier/context. Existing family DifficultyPolicy and ExposurePolicy resolve the exact mechanics when an existing family is used.

```text
Director context
→ production family policy
→ difficulty axes
→ exposure policy
→ generated/validated instance
```

No Story Mode difficulty system may bypass or duplicate production family policies.

## Player-state inputs

- Witness Rank / chapter;
- family and perception mastery;
- recent accuracy;
- current/best streak;
- incorrect streak;
- recent signatures;
- prior exposure to the moment;
- daily/weekly context;
- comfortable timing;
- reduced motion and accessibility settings;
- prior hint/assistance use where declared.

## Recovery logic

After repeated misses:

- increase exposure or reduce complexity;
- use a clearer evidence path;
- introduce a related reinforcement moment;
- avoid repeating the same exact scenario;
- preserve a sense of agency.

After repeated success:

- increase complexity gradually;
- vary the family/mechanic internally;
- introduce a new relationship or evidence layer;
- avoid only making timing shorter.

## Fairness requirements

- Every required truth is observable within the declared window.
- Generated content validates target size, bounds, relationships, and answer uniqueness.
- Accessibility accommodations are known before generation.
- No difficulty tier depends on hidden information or arbitrary pixel precision.
- A wrong answer can be explained by evidence.
- Repeat prevention is deterministic and inspectable.

## Scoring relationship

Scoring remains family-owned. Story Mode may change reward framing or chapter meaning, but must not reinterpret correctness.

Possible future presentation:

- accurate response → mastery plus;
- partial understanding → evidence/recovery plus smaller progress;
- assistance used → declared reward modifier only if the production contract supports it;
- perfect observation → Archive/milestone signal.

## Validation matrix

Every moment should be tested at:

- first exposure;
- standard/repeat exposure;
- mastery exposure;
- recovery after misses;
- reduced motion;
- comfortable timing;
- high contrast/color assistance;
- explicit interaction.

## Non-goals

- No universal “Easy/Medium/Hard” buttons.
- No hidden difficulty changes without production/persistence trace.
- No difficulty changes made only to increase ad views or session length.
- No separate Story Mode save state that conflicts with player progress.
