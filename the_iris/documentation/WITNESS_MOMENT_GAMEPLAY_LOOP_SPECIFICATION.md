# Two Second Witness 4.0 Witness Moment Gameplay Loop Specification

**Status:** Reusable gameplay blueprint — specification only
**Implementation changes:** none
**Reference moment:** Scene Investigation / “The Forgotten Museum” style moment
**Authority:** production Challenge Runtime for mechanics, scoring, results, saves, and progression

## Purpose

A Witness Moment is the player-facing unit of Story Mode. It wraps one or more existing production challenge mechanics in a coherent perception journey.

The player should not feel that they opened a mini-game. They should feel that the Iris opened a short-lived reality, asked them to notice something, and helped them understand what remained hidden.

```text
Iris
→ Entry
→ Attunement
→ Two Second Witness
→ Memory Reconstruction
→ Investigation
→ Revelation
→ Completion / Reward
→ Archive update
→ Return to Iris
```

## Design principles

- The Iris is the doorway and memory anchor.
- The Challenge Family is an internal mechanic, not the first player-facing label.
- The player receives only the information needed for the next beat.
- The observation window is short, fair, and family-policy controlled.
- Incorrect recall still leads to meaningful evidence.
- Results are discoveries, not terminal score pages.
- Every moment can be resumed, replayed, or exited through the Iris.
- Accessibility changes the delivery channel, not the underlying perception goal.

# 1. Entry

## Purpose

Move the player from the living instrument into a specific Witness Moment without feeling like a page load.

## Sequence

1. The Iris recognizes the selected Story Mode beat.
2. Recent memory/progression response settles.
3. The pupil opens as an optical aperture.
4. The camera/lens field travels inward through the pupil.
5. The Witness Moment field fades in beneath the optical transition.
6. The production session is resolved by `ChallengeSessionService`.
7. The moment framing appears only after the instance is valid.

## Camera behavior

The camera should feel like a physical optical instrument moving closer:

- center remains stable;
- peripheral field darkens first;
- depth/blur increases briefly;
- pupil aperture widens;
- scene field resolves from soft to clear;
- no scene reload language;
- no flash of a generic loading screen.

The transition should be approximately 600–800 ms for normal motion, with a reduced-motion path that crossfades and shortens the travel without removing orientation.

## Audio transition

- Iris ambience narrows or ducks.
- A short focus/entry cue confirms the aperture opening.
- Witness Moment audio begins after the scene instance is ready.
- Production BGM/SFX remains owned by `AudioService`.
- VoiceGuide may speak one short framing phrase, never a tutorial paragraph.

Possible framing phrases:

- “Look closer.”
- “Something is waiting in the field.”
- “Notice what changes.”

## Player expectation

The player should expect:

- a short, bounded perception experience;
- one meaningful thing to notice;
- a later question or reconstruction;
- an evidence explanation afterward;
- a return to the same Iris.

# 2. Attunement

## Purpose

Prepare attention without giving away the answer or turning the moment into a rules screen.

## Information given

Attunement may provide:

- the perceptual intention: notice, remember, compare, connect, or catch;
- a simple timing expectation such as “stay with the field”; 
- a visible focus point or light behavior;
- accessible text/caption equivalent;
- family-specific safety information only when required.

For the Scene Investigation reference moment:

> “Notice what changes.”

## Information intentionally hidden

Do not reveal:

- the exact target object;
- the question answer;
- which family module is running unless the player is in Library/Training;
- the difficulty tier;
- the scoring formula;
- the exact evidence location;
- the full future sequence.

## Attunement duration

- Normal: approximately 700–1200 ms.
- First introduction: may extend to approximately 1800 ms if the Iris is demonstrating the perception goal.
- Reduced motion: use a calm static focus state with a short fade.
- No permanent tutorial overlay in the normal path.

# 3. Two Second Witness

## Purpose

Give the player a constrained observation window in which attention matters.

## Exact player interaction

For the Scene Investigation reference moment:

1. Player watches a generated/content-backed scene.
2. No response is accepted during the exposure phase.
3. The player can visually scan the field.
4. The observation window ends automatically.
5. The production runtime advances to the response route.

The player does not tap the answer during observation. This prevents the observation phase from becoming a hidden search interaction.

## Timing

The production `ExposurePolicy` remains authoritative.

Scene Investigation current policy:

| Tier | Exposure range | Reference default |
|---|---:|---:|
| Beginner | 5.0–6.0 seconds | ~5.5 seconds |
| Standard | 3.5–5.0 seconds | ~4.25 seconds |
| Advanced | 2.0–3.5 seconds | ~2.75 seconds |
| Expert | 1.5–2.0 seconds | ~1.75 seconds |

Comfortable Timing may extend exposure. The blueprint does not change these values.

The “Two Second Witness” name describes the product’s short-attention premise, not a universal hardcoded duration for every family/tier.

## Camera behavior

- Camera remains observational rather than game-like.
- No manual camera movement is required for the first slice.
- A subtle breathing/focus drift is allowed if it does not move targets unfairly.
- Any scene motion must be deterministic, readable, and disabled/reduced by accessibility settings.
- On rotation, the optical field adapts without resetting elapsed exposure or generated content.

## Input expectations

- Touch: watch; no touch required during exposure.
- Mouse/desktop: cursor may create attention/parallax response but does not alter the scene.
- Keyboard/controller: no response input until the response phase.
- Back/Escape: exits the moment safely and returns through the Iris after production session cleanup.

# 4. Memory Reconstruction

## Purpose

Ask the player to reconstruct the relevant perception from memory rather than merely react to what is still visible.

## First reference format

Scene Investigation uses:

- one focused question;
- single-choice response;
- 4 accessible answer options;
- one correct answer;
- production `single_choice` adapter;
- reaction time captured for result metadata.

Example question forms:

- “How many colored pencils were visible?”
- “What color was the lamp?”
- “Which side of the room was the plant on?”
- “Which object was closest to the clock?”

## Family formats

The same Memory Reconstruction beat can host:

- Flash Words — single word, order, presence, or position choice;
- Spot the Difference — spatial tap or accessible target choice;
- Object Recall — multiple selection/set reconstruction;
- Pattern Recall — sequence input;
- Scene Investigation — focused single choice.

## Difficulty scaling

Difficulty remains family-policy controlled. The Witness layer should not invent a second scaling model.

It may choose a narrative framing such as:

- first attempt;
- reinforcement;
- challenge;
- recovery;
- mastery.

The family policy resolves actual:

- details/object count;
- similarity/distractors;
- sequence length;
- target size;
- timing;
- exposure;
- response complexity.

## Response feedback

- Selection should be immediately legible but not prematurely reveal correctness if the production adapter expects submission.
- On submission, the Witness Moment moves to Discovery/Revelation.
- No generic “game over” language.

# 5. Investigation Phase

## Purpose

Give the player a small opportunity to interrogate meaning after the core recall, before the truth is fully revealed.

This phase is a future Story Mode layer. It must not bypass or replace production scoring.

## What the player can interact with

Depending on the moment:

- inspect a permitted evidence region;
- tap a highlighted or suspected object;
- compare two evidence states;
- rotate or focus a witness artifact;
- open a short “where to look” hint;
- choose whether to inspect the evidence before continuing.

For the first Scene Investigation slice, the safest implementation is a **guided evidence inspection**, not free exploration:

1. response is submitted;
2. one evidence focus region becomes available;
3. player may tap/focus it;
4. the reveal explains the detail.

## Discovery behavior

Discovery should feel like the player is understanding a truth that was already present:

- evidence draws attention toward the relevant object;
- the rest of the scene quiets;
- the target becomes readable through motion/light/contrast, not a red game marker;
- the explanation names what changed or was missed.

## Hints

Hints should be optional and non-punitive.

Recommended hint levels:

1. **Atmospheric:** Iris/evidence light leans toward the relevant region.
2. **Spatial:** “Look toward the left side of the scene.”
3. **Explicit:** a target highlight or accessible label.

Hints should:

- be announced as assistance in accessibility/explicit mode;
- not change the saved score unless the production scoring contract later adds a declared hint modifier;
- not be required for the core first slice;
- use comfortable timing and reduced motion.

## Failure in investigation

If the player misses or selects the wrong evidence region:

- do not trap the player;
- show the correct evidence after a short retry/acknowledgement;
- preserve the production result already calculated;
- record hint/evidence interaction separately from answer correctness.

# 6. Revelation

## Purpose

Make the hidden truth emotionally and visually legible.

## Revelation sequence

1. Response state settles.
2. Scene returns or reconstructs the relevant field.
3. Non-relevant objects quiet or recede.
4. Evidence target becomes visible through a controlled highlight.
5. The result explanation says what was present/changed/connected.
6. The player can inspect the evidence long enough to understand it.
7. Reward/progression is acknowledged.

## Truth representation

Use the production result contract:

- `ChallengeResult.outcome`;
- explanation;
- `where_to_look`;
- `reveal_data`;
- generated scene/state;
- `highlight_ids`;
- replay metadata.

The Witness layer may reframe the evidence presentation but must not recalculate correctness.

## Iris reaction

The Iris should react to:

- correct observation: focused brightness / precise recognition;
- incorrect observation: calm memory response / not shame;
- meaningful discovery: rim destination or archive response;
- new mastery: rank/chapter response;
- repeated attempt: familiarity and lower guidance frequency.

## Reward feeling

The player should feel:

- “I understand what I missed.”
- “The detail was fair.”
- “I want to look again.”
- “The Iris remembers this.”

# 7. Completion

## Completion state

A Witness Moment is complete after:

- production result exists;
- evidence has been presented or made accessible;
- progress has been written;
- reward/achievement evaluation has run;
- Archive/Discovery update is available;
- Story Mode context is ready for the next decision.

## Rewards

Use existing production systems:

- XP;
- family mastery;
- Witness progress points;
- streak update;
- achievements;
- chapter/rank eligibility;
- Archive discovery record;
- recommendation context.

Do not create a second currency or parallel reward save.

## Archive update

Add a view over production history/result data containing:

- moment/family/template identity;
- scenario/content version;
- outcome;
- evidence/reveal summary;
- score/mastery context;
- completion timestamp;
- replay availability.

## Rank progress

The Story Mode layer may translate production values into:

- Observer progress;
- Investigator progress;
- Archivist progress;
- chapter readiness;
- next perception ability.

Numeric XP/level/mastery remains production-authoritative.

## Return to Iris

- Result/reward closes through the reverse optical transition.
- Production active session is closed through `ChallengeSessionService.return_home()`.
- Iris remains slightly alert and carries a memory response.
- The Director receives the completed result and chooses continue/rest/next story beat.

# Failure states

## Generation failure

Production runtime retries generation and uses a validated fallback. If no valid instance exists:

- do not enter a blank moment;
- return through Iris with a calm unavailable/retry state;
- do not write progress;
- log a production failure event.

## Observation interruption

- Rotation: preserve instance and timer/state.
- App backgrounding: save/resume snapshot where production runtime permits.
- Back: close safely through Iris; no false completion.
- Audio failure: visual guidance continues.

## Recall failure

- Incorrect answer remains a valid completed attempt.
- Evidence explains the missed truth.
- Progress/recovery behavior follows family scoring policy.
- Retry is optional and must be explicit.

## Evidence failure

If reveal metadata is incomplete:

- show a safe textual/accessibility explanation;
- preserve result/progress;
- log missing evidence metadata;
- do not block return to Iris.

# Retry behavior

- **Replay:** creates a new valid seeded instance or uses production replay rules.
- **Retry after incorrect:** allowed according to production result/session rules; should not silently overwrite the original result.
- **Continue:** uses RecommendationService and Director context.
- **Leave:** always returns through Iris and preserves the result already recorded.
- **Tutorial replay:** remains available from Library/Training, not forced after mastery.

# Ad-supported skip behavior

The current audited product does not contain an active monetization runtime. Therefore the baseline Witness Moment has **no ad-supported skip**.

If monetization is added in a future roadmap update, the contract should be:

- optional and never required for completion;
- never shown during the first Witness Moment;
- never interrupt an observation window;
- never reveal the answer without a declared result/progression rule;
- never remove the no-ad offline path;
- support a non-ad accessible alternative;
- be owned by a future MonetizationService, not Iris or challenge families.

# Accessibility options

## Existing production options to preserve

- reduced motion;
- comfortable timing;
- high contrast;
- color assistance;
- text size/font scaling;
- haptics on/off;
- audio/voice on/off;
- captions/transcripts;
- explicit navigation path;
- accessible adapter for spatial/tap mechanics.

## Moment behavior

- timing accommodations are resolved by family policies;
- visual-only guidance replaces voice when audio is unavailable;
- hints/evidence can be explicitly labeled;
- target regions remain large enough for touch;
- no essential truth depends on color, sound, or motion alone;
- controller/keyboard/mouse intents remain supported.

# Audio and voice opportunities

## Iris layer

- entry aperture cue;
- attunement phrase;
- focus/hold cue;
- return/memory phrase;
- discovery/rank acknowledgement.

## Challenge layer

- exposure start;
- interval/state change;
- response confirmation;
- evidence reveal;
- result/reward cue.

Production `AudioService` owns gameplay BGM/SFX. `VoiceGuide` owns sparse Iris guidance. A future Witness Moment mix policy should coordinate ducking/priority without merging ownership.

# Replay and mastery behavior

## Replay

- replay current moment through production session APIs;
- replay tutorial from Library/Training;
- retry without erasing historical results;
- inspect evidence after completion;
- return to Iris at any point.

## Mastery

Mastery should reflect repeated perception skill, not only win count:

- correct/incorrect history;
- difficulty tier reached;
- consistency/streak;
- family-specific ability;
- hint usage where declared;
- completion of chapter/story beats.

The future Director should use mastery and history to choose reinforcement, novelty, challenge, or rest.

# Reusable Witness Moment contract

A future moment should declare:

```text
moment_id
chapter_id
perception_goal
framing_phrase / caption
challenge_sequence
production family/template references
difficulty context
pacing context
evidence/reveal contract
reward/progression context
archive record mapping
resume/interruption behavior
accessibility requirements
audio/voice profile
```

## Final principle

The player should enter a Witness Moment expecting to notice something, not to select a game mode. The production runtime remains the reliable machine beneath the experience; the Iris and Story Mode provide continuity, meaning, and return.
