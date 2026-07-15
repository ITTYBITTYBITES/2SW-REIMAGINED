# Witness Moment Gameplay Loop Specification

**Status:** Product design blueprint only
**Implementation:** None in this phase
**Product:** Two Second Witness 4.0

## Core premise

The player does not choose a challenge type. The player enters a Witness Moment through the Living Iris.

The internal mechanic is invisible until it becomes necessary to the experience. The moment should feel like a short piece of perception-driven storytelling rather than a collection of mini-games.

```text
Iris
↓
Story Mode
↓
Witness Moment
↓
Arrival
↓
Attunement
↓
Two Second Witness
↓
Memory Reconstruction
↓
Investigation
↓
Discovery
↓
Evidence Reveal
↓
Reflection
↓
Archive Update
↓
Return to Iris
```

## Reusable moment contract

Every future Witness Moment should define:

- `moment_id`;
- Story Chapter / Rank context;
- perception intention;
- narrative premise;
- Arrival behavior;
- Attunement payload;
- observation window contract;
- future mechanic slots;
- memory/reconstruction intent;
- investigation affordances;
- evidence/revelation data;
- reflection prompt;
- reward/progression declaration;
- Archive record mapping;
- interruption/resume behavior;
- accessibility variants;
- audio/voice profile;
- replay/mastery variants.

The contract is intentionally broader than the existing ChallengeInstance contract. Existing runtime systems remain available beneath it, but future mechanics should be selected by story/perception need rather than exposed as family names.

# 1. Entry

## Iris transition

- The Iris recognizes the selected Story Mode moment.
- The pupil becomes the aperture.
- The optical field travels inward rather than swapping pages.
- The current emotional state and recent memory response carry into the transition.
- Back remains available and returns through the reverse optical transition.

## Camera movement

The camera should feel like a lens entering a field:

1. peripheral space dims;
2. pupil expands;
3. depth increases;
4. the witness field appears beneath the optical mask;
5. focus settles on the first meaningful subject.

The camera is not a free camera by default. Movement is authored to support attention and fairness.

## Audio transition

- Iris ambience narrows/ducks;
- a restrained aperture/focus cue marks entry;
- moment ambience begins only after the moment is valid and ready;
- VoiceGuide may provide one short phrase;
- no music or voice is required for comprehension.

## Player expectation

The player should understand:

- this is one bounded experience;
- something is present to notice;
- the answer will not be required immediately;
- the Iris will bring them back when the moment is complete.

# 2. Attunement

## What the player knows

Attunement gives only:

- the emotional/narrative premise;
- the perception intention;
- how to remain attentive;
- any accessibility or control information required to proceed.

Examples:

- “Stay with the room.”
- “Notice what remains.”
- “Hold the connection.”

## What remains hidden

Do not reveal:

- the internal mechanic name;
- the exact answer;
- the scoring formula;
- the full sequence of events;
- the target location;
- whether the player is expected to detect change, remember an object, or reconstruct a relationship until the moment makes that clear.

## Curiosity creation

Curiosity comes from an incomplete but coherent situation:

- a room with one unresolved detail;
- a memory fragment that does not quite fit;
- a signal that appears and disappears;
- a relationship between objects or events;
- a quiet anomaly in an otherwise normal field.

Attunement should not become a tutorial card or mode-selection screen.

# 3. Two Second Witness

## Meaning

“Two Second Witness” is the product’s short-attention promise: the player receives a constrained opportunity to notice something that is easy to miss.

The exact duration is authored by the moment and validated by the underlying mechanic. It is not a universal two-second hardcode.

## Observation timing

A moment may use:

- one short exposure;
- multiple short exposures;
- a staged appearance;
- a state that changes while the player is looking;
- a quiet interval before/after the key detail.

Timing must be stored as part of the moment contract and remain deterministic for the same session seed.

## Player control

During the core observation window:

- the player may look, hover, or move attention;
- the player does not need to guess a response early;
- direct input is allowed only when it is part of the authored perception goal;
- accidental taps must not invalidate a fair observation.

## Camera behavior

- Motion is authored, low-amplitude, and accessibility-aware.
- The camera must not move a target out of view unexpectedly.
- A rotation, backgrounding, or device change preserves the moment state.
- Focus and parallax communicate depth without becoming a skill test unless explicitly declared.

## Fairness rules

- every required target is visible for the declared exposure;
- target size and contrast meet accessibility requirements;
- no answer depends on color alone;
- generated or authored content is validated before presentation;
- repeated/identical recent content is avoided;
- the player can understand why an answer was correct or missed;
- any randomness is seeded and replayable;
- accommodations affect presentation time/clarity, not the underlying truth.

## Accessibility support

- extended observation timing;
- reduced motion/static presentation;
- high contrast and color assistance;
- narration/captions when enabled;
- explicit access path for users unable to rely on visual motion;
- no essential state conveyed only by audio or haptics.

# 4. Memory Reconstruction

Memory Reconstruction is a design space, not a locked mechanic.

## Future interaction possibilities

### Recall

The player identifies what was present, absent, or changed.

### Relationships

The player reconstructs which objects were near, above, before, after, or connected to one another.

### Sequences

The player restores an order, rhythm, route, or progression.

### Patterns

The player recognizes a repeated structure or missing connection.

### Emotional interpretation

The player chooses which feeling, meaning, or implication best fits the witness evidence. This must remain evidence-grounded rather than subjective trivia.

## Selection rules

The final interaction is chosen by the Witness Moment contract. Existing adapter infrastructure may provide implementation support, but the player-facing framing remains a story question.

## Difficulty scaling

Memory difficulty can scale through:

- number of remembered elements;
- relationship count;
- sequence length;
- similarity/distractor density;
- exposure duration;
- number of valid interpretations;
- amount of evidence available;
- assistance level.

The future Director chooses a difficulty context; a future mechanic resolves exact parameters.

# 5. Investigation

## Purpose

Investigation lets the player explore the memory after the initial reconstruction and discover overlooked meaning.

## Player actions

Depending on the moment, the player may:

- focus a permitted evidence region;
- compare two states;
- connect two clues;
- inspect a memory fragment;
- revisit a scene layer;
- choose where to look next;
- request a hint;
- interpret a discovered relationship.

## Discovery rules

- investigation cannot contradict the production result;
- optional inspection can deepen understanding without being required for completion;
- evidence is revealed progressively;
- the player can stop without losing the completed result;
- investigation interactions are separately instrumented from answer correctness.

## Hints

Hint ladder:

1. Iris/scene attention shift;
2. soft spatial emphasis;
3. contextual phrase;
4. explicit evidence highlight;
5. accessible text description.

Hints should assist rather than shame. If future monetization uses hints, it must not be the only accessible path.

# 6. Revelation

## Truth reveal

The reveal should answer:

- What was there?
- What changed?
- What connection mattered?
- Why was it easy to miss?

It should use production result/evidence data where an existing mechanic provides it and a future moment-specific evidence contract otherwise.

## Iris response

The Iris can respond through:

- reflection alignment;
- a brief alert/memory glow;
- a new rim destination becoming legible;
- a rank/chapter acknowledgement;
- one sparse voice phrase;
- a haptic confirmation when enabled.

## Emotional payoff

The intended feeling is not “I won a quiz.” It is:

- “That detail was already there.”
- “I understand what I overlooked.”
- “I want to look again.”
- “The instrument remembers.”

# 7. Completion

## Rewards

Use existing production authorities:

- XP;
- Witness Rank/level progress;
- family or perception mastery;
- streak update;
- achievements;
- unlock eligibility;
- Archive discovery record;
- Story Chapter progress.

No parallel currency or result store is introduced.

## Archive update

Record/view:

- moment/chapter ID;
- evidence discovered;
- result summary;
- mastery/progression context;
- completion date;
- replay availability;
- content version and seed metadata where needed.

## Rank progress

Numeric XP/level/mastery remains production-authoritative. Story Mode translates that progress into Observer, Investigator, Archivist, and future chapter language.

## Return to Iris

1. production result/progress is committed;
2. evidence/reflection completes;
3. production session closes or remains resumable according to the moment contract;
4. reverse optical transition returns to Iris;
5. Iris acknowledges the moment;
6. Director chooses next story beat, optional daily/weekly path, or rest.

# Failure and recovery

Failure must mean “the truth was not yet understood,” not “the experience was lost.”

## Retry

- retry the current reconstruction when allowed;
- replay the moment with a new or controlled seed;
- revisit evidence without rewriting the original result;
- return to Iris and resume later.

## Continue story

An incorrect or incomplete result can still grant:

- evidence access;
- small recovery progress;
- a chapter continuation;
- a Director-selected reinforcement moment.

## Return to Iris

Back, interruption, or explicit exit always returns through the Iris. In-progress state must either be resumable or safely abandoned without false completion.

## Optional assistance

Assistance may include timing extension, extra evidence, hints, or a simplified response. Assistance must be declared in moment metadata and remain compatible with accessibility.

# Rewarded video integration

The current audited product has no active monetization runtime. This is a future option only.

If rewarded video is introduced later:

- it must be optional;
- never appear during first launch or the core observation window;
- never be required to finish a moment;
- never remove the offline/no-ad path;
- may offer an extra hint, additional attempt, optional skip, or story continuation;
- must preserve agency and accessibility;
- must be owned by a future monetization service, not Iris or a mechanic;
- must not silently alter score or progression.

# Accessibility

Every Witness Moment must support:

- extended observation time;
- narration/VoiceGuide;
- optional captions/transcripts;
- visual assistance;
- audio assistance;
- reduced motion;
- simplified interaction;
- high contrast and color assistance;
- explicit navigation;
- mouse, keyboard, controller, and touch input where relevant.

The normal experience remains nonverbal and alive. Accessibility exposes language and explicit controls when needed.

# Replay and mastery

Replay can reveal:

- hidden discoveries;
- perfect observation states;
- alternate evidence interpretations;
- advanced versions;
- different story context;
- Archive completion;
- mastery thresholds;
- scene/signature variants.

Replay should be motivated by understanding and mastery, not only score inflation.

# Future mechanic containers

These are intentionally undefined placeholders:

- **Observation Mechanic TBD**
- **Memory Reconstruction Mechanic TBD**
- **Discovery Mechanic TBD**
- **Evidence Connection Mechanic TBD**
- **Reflection Mechanic TBD**

A mechanic may advance only if it:

1. makes the player feel more like a Witness;
2. strengthens the story;
3. rewards attention;
4. creates curiosity;
5. remains fair and accessible;
6. produces an interpretable reveal;
7. returns meaningfully to the Iris.

## Final reusable loop

The reusable blueprint is:

```text
Enter through Iris
→ understand only the next intention
→ witness a fair short field
→ reconstruct memory without a visible mode label
→ investigate what remains uncertain
→ discover evidence
→ receive a meaningful reveal
→ reflect and progress
→ update Archive
→ return to Iris
```
