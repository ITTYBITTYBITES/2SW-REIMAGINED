# Challenge to Witness Moment Mapping

**Status:** mapping only; no gameplay implementation in this phase

## Mapping principle

Existing Challenge Families become internal mechanics inside Witness Moments. The player should experience a perception goal and a cinematic sequence, not choose a technical family as the first action.

## Shared Witness Moment shape

```text
Iris framing
→ perception goal
→ observation/exposure
→ internal challenge mechanic
→ recall/response
→ evidence/discovery
→ production result/reward
→ Iris memory
```

The production family module, generator, validator, policy, adapter, scoring, and result contract remain unchanged beneath the moment.

## Scene Investigation → Notice what changes

### Current mechanic

- Generated 2D scene;
- 5–6 second beginner/standard exposure, shorter at higher tiers;
- 8–18 objects and varying decorations/similarity;
- one question: count, attribute, position, adjacency, or presence;
- single-choice response;
- evidence highlights and explanation.

### Witness Moment role

**Moment theme:** the field was already telling the player something.

Suggested sequence:

1. Iris opens into a grounded environment.
2. The scene settles as if viewed through an optical instrument.
3. Player receives no family name, only the perceptual invitation: “Notice what changes.”
4. Observation window completes.
5. Recall asks one focused question.
6. Evidence reveal shows the missed relationship/detail.
7. Witness Record stores a Discovery.
8. Iris returns with a memory response.

### Preserve

- procedural/seeded generation;
- fairness validator;
- exposure policy;
- content scenario data;
- question types;
- single-choice adapter;
- family scoring/mastery/progress.

### Future presentation work

- replace generic observation framing;
- improve evidence/reveal emotional payoff;
- emphasize scene depth and a single meaningful detail;
- carry a visual motif back into the Iris.

## Flash Words → Catch the signal

### Current mechanic

- brief typography sequence;
- single word, pair order, stream presence, or position recall;
- 373 reviewed words;
- timing scales from comfortable 5-second beginner display to fast expert display;
- exact single-choice response;
- word/letter/order/position comparison in result.

### Witness Moment role

**Moment theme:** a signal can exist for less time than attention expects.

Possible internal use:

- a short auditory/visual clue inside a larger scene;
- a signal that appears once and is recalled later;
- a transition beat between two larger observations.

Flash Words should be introduced after the player understands the basic Witness loop because its challenge is abstract and speed-sensitive.

### Preserve

- word content metadata;
- recent-word prevention;
- reading comfort/timing accommodations;
- deterministic generation;
- exact comparison and result explanation.

### Future presentation work

- frame it as signal capture, not typing/speed training;
- ensure typography remains readable and calm;
- use Iris pulse/voice sparingly to establish the brief signal.

## Spot the Difference → Notice the change

### Current mechanic

- paired or sequential scene states;
- exactly one semantic mutation;
- presence, attribute, sequential, or arrangement variants;
- spatial tap with accessible single-choice alternative;
- target regions, target size, bounds, and paired-state validation;
- evidence reveal of the changed object.

### Witness Moment role

**Moment theme:** something moved while the player was looking away.

Possible sequence:

1. Iris frames one state.
2. A second state emerges through a lens shift rather than a page change.
3. Player compares the two states.
4. Spatial tap or accessible target choice identifies the change.
5. Evidence overlays the semantic mutation.
6. Iris carries the changed object/light into its return memory.

### Preserve

- exactly-one-change contract;
- target-region validation;
- accessible adapter;
- mutation types and visual comparison data;
- production scoring and evidence.

### Future presentation work

- make state A/B transition legible;
- reduce visual density on small screens;
- show why the target changed rather than only where it was tapped.

## Object Recall → Remember what was present

### Current mechanic

- 3–6 illustrated objects shown in a tray;
- 48-object pool;
- seen set, missing set, top row, and bookends variants;
- multiple-choice multi-selection;
- exact set comparison with partial accuracy context;
- evidence shows remembered/missed/extra objects.

### Witness Moment role

**Moment theme:** the field leaves a trace even after the objects are gone.

Possible sequence:

1. Iris presents a quiet collection space.
2. Objects settle into a meaningful arrangement.
3. The field closes and becomes empty.
4. Player reconstructs what was present.
5. Evidence restores the set and explains omissions/extras.
6. Archive stores the recovered arrangement.

### Preserve

- reviewed object pool;
- set/missing/row/bookend rules;
- multiple-choice adapter;
- exact correctness and partial accuracy data;
- production progress/mastery.

### Future presentation work

- make multi-selection state unmistakable;
- avoid reducing the moment to a generic memory quiz;
- use arrangement/absence as narrative evidence.

## Pattern Recall → Recognize what connects

### Current mechanic

- grid path, shape sequence, or cumulative pattern;
- 3–6 tokens;
- 3×3/4×4 grids or 12 reviewed symbols;
- discrete interval/final-hold timing;
- sequence-input adapter;
- exact ordered scoring with matching-prefix explanation.

### Witness Moment role

**Moment theme:** separate signals become a structure when held together.

Possible sequence:

1. Iris reveals a sparse optical field.
2. Nodes connect in a sequence.
3. Player repeats the pattern.
4. Evidence rebuilds the connection in numbered order.
5. Rank/Chapter progression frames the newly recognized ability.

### Preserve

- connected path generator;
- no-immediate-repeat validation;
- interval/final-hold policy;
- sequence adapter;
- prefix evidence and mastery.

### Future presentation work

- connect abstract symbols to the perception story;
- reduce simultaneous counter/cue overload;
- make the result explain the structure, not just correctness.

## Family discovery sequence

Recommended order for Story Mode:

1. **Scene Investigation** — first reference moment.
2. **Spot the Difference** or **Object Recall** — introduce comparison or set memory.
3. **Pattern Recall** — introduce connection/order after initial mastery.
4. **Flash Words** — introduce fleeting signal recognition when the player understands attention timing.

This is a Director recommendation, not a replacement for production unlock metadata.

## Common result contract

Every family should continue to provide:

- outcome;
- accuracy/partial context;
- score;
- progress points;
- mastery delta;
- history entry;
- explanation;
- where-to-look;
- reveal data/highlight IDs;
- replay metadata.

The Story Mode layer translates those fields into a Witness Moment reward and Iris memory. It must not recalculate family correctness.

## Future mapping rule

A new Challenge Family should not automatically become a new primary destination. It should first answer:

1. What perception ability does it teach?
2. Which Rank Chapter does it belong to?
3. Which Witness Moment structure frames it?
4. What evidence does it reveal?
5. How does it return a memory to the Iris?
6. What production contracts does it implement?
