# Two Second Witness 4.0 Witness Experience Architecture

**Status:** Blueprint only — no implementation in this phase
**Product:** Two Second Witness 4.0
**Publisher:** ITTYBITTYBITES
**Foundation:** Living Iris + production Challenge Runtime

## 1. Product direction

Two Second Witness is no longer organized around a challenge-selection menu as its primary experience. The default product journey is **Witness Story Mode**: a guided sequence of perception moments that opens and closes through the Living Iris.

The player should feel guided, not assigned a random game. Each moment should answer one quiet question:

> What did you notice, and what did you miss?

Challenge families remain powerful internal systems. They are not the player-facing information architecture. The player experiences a continuous instrument; the runtime selects the family, scenario, timing, and difficulty behind the Iris.

## 2. Architectural layers

```text
Iris Foundation
    ↓ opens / frames / remembers / returns
Witness Experience Director
    ↓ selects a meaningful next moment
Production Challenge Runtime
    ↓ generates / validates / presents / scores
Player Systems
    ↓ saves mastery / XP / history / unlocks
Content Systems
    ↓ supplies scenarios, families, assets, and future moments
```

### Iris Foundation owns

- launch activation;
- first-session awakening;
- navigation and input intent;
- transition into and out of Witness Story Mode;
- voice, visual, haptic, and caption guidance;
- memory/relationship response after a moment;
- orientation, device adaptation, and accessibility doorway.

### Production Runtime owns

- challenge family contracts;
- generation and fairness validation;
- difficulty and exposure policies;
- family-specific interaction adapters;
- scoring and result evidence;
- progression declarations;
- replay and continuation mechanics.

### Witness Experience Director owns

- choosing what the player should experience next;
- balancing skill, novelty, mastery, narrative pacing, and variety;
- connecting a family result to the next story beat;
- deciding when a family should be introduced or revisited;
- converting production results into a coherent Witness journey.

## 3. First Launch Experience

### Goal

Within the first session, the player should understand:

1. Two Second Witness is a product about noticing.
2. The Iris is interactive.
3. A short Witness moment has a beginning, observation, recall, reveal, and return.
4. Returning to the Iris is progress, not exiting the experience.

### First-session sequence

```text
ITTYBITTYBITES activation
→ Two Second Witness identity
→ Iris awakens
→ center invitation
→ first touch
→ Iris opens the Witness field
→ first Scene Investigation moment
→ recall
→ evidence reveal
→ first reward
→ Iris remembers the moment
→ one quiet invitation to explore further
```

### Beat design

#### Activation

- Show ITTYBITTYBITES publisher identity first.
- Follow with Two Second Witness identity.
- Use the existing startup layer; do not introduce an app dashboard.
- Keep the sequence short enough that the player reaches the Iris quickly.

#### Awakening

- The Iris breathes, gathers reflection, and speaks only if voice is enabled.
- Voice copy should be minimal: “Initializing.” then “Touch the center.”
- With sound off, center invitation must be visible through pupil/reflection behavior.
- The first touch receives a visible optical acknowledgement before transition.

#### First Witness

- Use Scene Investigation as the first family because it best communicates the product promise.
- Do not expose family terminology yet.
- Frame the moment as looking through the instrument, not launching a game mode.

#### First reward

The first reward should be a **Witness Record** update, not a currency-heavy reward:

- first observation recorded;
- first discovery stored;
- a small attention/progress increase;
- one new family or direction becoming available only if it is actually ready.

#### Return

- Reverse transition returns through the Iris.
- The Iris briefly remembers the evidence just found.
- The player receives a nonverbal indication that the instrument has more to reveal.
- Do not immediately open a library or menu.

## 4. Witness Story Mode

### Default journey

```text
Living Iris
  ↓
Witness Moment framing
  ↓
Observation / exposure
  ↓
Recall / response
  ↓
Discovery / correctness and meaning
  ↓
Evidence reveal
  ↓
Reward and progression
  ↓
Return through Iris
```

### Story Mode principles

- The player should not choose a family before the first moment.
- The Director chooses a challenge that is appropriate and legible.
- The family identity may be revealed after the experience, not before it.
- Every result should explain what was present, what changed, or what was missed.
- The Iris should remain aware of the recent result when the player returns.

### Continuing naturally

After a completed moment, the Director chooses one of three next actions:

1. **Continue the thread** — another scenario in the same family when the player is building confidence.
2. **Shift perception** — introduce a related family when the player has demonstrated readiness.
3. **Return to rest** — return to the Iris and let the player explore voluntarily.

A player should be able to stop after every moment without feeling penalized. Continuing is an invitation, not a forced endless run.

### Failure journey

Incorrect responses should not create a dead end:

```text
Incorrect recall
→ evidence explains the missed detail
→ small progress / recovery credit
→ Iris acknowledges attention, not failure
→ Director chooses reinforcement or rest
```

## 5. Challenge Family Discovery

Challenge families are perception abilities the player learns over time, not categories presented in a menu.

### Discovery model

Each family has:

- a first-introduction beat;
- a one-line Iris framing phrase;
- a guided first attempt;
- a minimum readiness/unlock condition;
- a quiet mastery loop after introduction;
- an explanation that fades once the player demonstrates understanding.

### Family introductions

#### Scene Investigation

**Perception ability:** noticing what changes in a rich scene.

Suggested Iris framing:

> “Notice what changes.”

First attempt:

- slower exposure;
- clearly grounded scene;
- one question with strong evidence;
- no family name required before play.

#### Object Recall

**Perception ability:** remembering what was present.

Suggested framing:

> “Remember what was present.”

First attempt:

- small object set;
- large, clear targets;
- immediate evidence of the remembered set.

#### Pattern Recall

**Perception ability:** recognizing what connects.

Suggested framing:

> “Recognize what connects.”

First attempt:

- short sequence;
- visible step rhythm;
- reveal shows the order as a connected structure.

#### Spot the Difference

**Perception ability:** detecting the one meaningful change.

Suggested framing:

> “Something moved.”

First attempt:

- larger target region;
- clear paired or sequential states;
- evidence highlights the semantic change, not only a tap rectangle.

#### Flash Words

**Perception ability:** catching a signal before it disappears.

Suggested framing:

> “Catch the signal.”

First attempt:

- comfortable reading timing;
- calm typography;
- no implication that speed alone is the skill.

### Unlock conditions

The existing production metadata and Witness Level progression remain the authority. The Director may add a presentation condition, but must not create a second unlock/save system.

Recommended policy:

- Scene Investigation available first;
- Spot the Difference or Object Recall introduced after the first successful Witness or a small progress threshold;
- Pattern Recall available after initial attention mastery / Witness Level 2;
- Flash Words introduced when the player demonstrates comfort with short recall moments or selects it through the secondary Library.

### When explanations disappear

- First introduction: one short phrase and one demonstrated response.
- Second exposure: phrase can be reduced to a visual motif.
- After demonstrated competence: no family explanation unless the player requests the tutorial.
- Accessibility/captions mode may retain explicit descriptions.

## 6. Witness Experience Director

### Inputs

The Director reads existing production systems rather than replacing them:

- current family mastery;
- plays and accuracy;
- incorrect streak;
- recent history and scene signatures;
- last family/template;
- time since last play;
- available/unlocked families;
- challenge variety;
- program context;
- first-session state;
- accessibility/timing preferences;
- current Iris emotional/relationship state;
- desired narrative beat: introduce, reinforce, surprise, recover, or rest.

### Outputs

```text
family_id
→ template_id / scenario
→ difficulty tier and axes
→ exposure/timing policy
→ presentation framing
→ response adapter
→ evidence/reward framing
→ recommended next beat
```

The Director should call `ChallengeSessionService` and production policies, not generate challenge instances itself.

### Selection policy

Recommended priority order:

1. Hard gates: unlocked, valid, accessible, content available.
2. Safety: avoid recent exact signatures and recently repeated family sequences.
3. Narrative: satisfy first introduction, reinforce, recover, surprise, or rest.
4. Skill: choose a tier from production difficulty policy.
5. Variety: avoid repeating the same family/template too often.
6. Progression: choose an experience that can teach or reward the next ability.
7. Recommendation: use family weight, program context, and featured content.

### Determinism

- The Director may choose a selection seed/context.
- The family generator owns the instance seed.
- The selected decision should be inspectable in analytics/debug traces.
- The same saved session should remain resumable after interruption.

### Anti-randomness rule

The user should feel guided. Randomness is allowed inside a coherent arc, not as an unexplained family roulette.

## 7. Challenge Library

The Library is an optional advanced room, not the default home.

Possible names:

- Archive
- Training
- Challenge Library
- Explore Witness Types

It can expose:

- all unlocked families;
- individual templates/scenarios;
- replay/tutorial controls;
- mastery and history;
- favorites;
- Programs and curated runs;
- accessibility-friendly explicit entry.

The Iris remains the main path. The Library is for players who want agency, repetition, or mastery depth.

## 8. Progression and perception growth

### Existing production progression

Preserve:

- XP;
- levels;
- family mastery;
- accuracy;
- current/best streaks;
- achievements;
- unlocks;
- programs;
- favorites;
- history;
- recommendations.

### Perception abilities

Future abilities should be represented as meaning, not only numeric level:

| Ability | Likely family evidence |
|---|---|
| Notice a rich field | Scene Investigation |
| Catch a fleeting signal | Flash Words |
| Detect a meaningful change | Spot the Difference |
| Hold a set in mind | Object Recall |
| Recognize a connection/order | Pattern Recall |

The ability language belongs in Iris guidance and progression framing; the production services remain responsible for actual unlock/persistence state.

### Reward philosophy

Prefer:

- new perception ability acknowledgement;
- Witness Record growth;
- new family/scenario access;
- evidence archive entries;
- mastery/rank progression;
- meaningful achievement language.

Do not make the Iris feel like a currency shop or conventional battle pass.

## 9. Scene Investigation vertical slice position

Scene Investigation is the first vertical slice because it can validate the entire story arc:

```text
Iris entry
→ scene opens
→ 5–6 second observation window
→ one recall question
→ evidence reveal
→ progress/reward
→ Iris remembers
→ return / continue invitation
```

The separate `SCENE_INVESTIGATION_VERTICAL_SLICE_PLAN.md` defines the implementation sequence.

## 10. Accessibility and alternate modes

Every Story Mode beat must remain usable with:

- audio disabled;
- captions enabled;
- reduced motion;
- comfortable timing;
- high contrast;
- screen-reader/explicit access path;
- non-touch input.

The experience can become more explicit through accessibility settings without making the default Iris a dashboard.

## 11. Analytics and success measures

Instrument the Director and Story Mode for:

- first center interaction;
- first Witness entry;
- family introduction accepted/skipped;
- observation completion;
- recall submission;
- evidence reveal seen;
- return-to-Iris completion;
- next-beat acceptance/decline;
- family repetition and abandonment;
- difficulty recovery after misses;
- time to first second destination.

Success is not only completion rate. It is whether the player understands that the Iris is guiding a coherent perception journey.

## 12. Non-goals for the blueprint phase

- No new challenge types.
- No challenge scoring changes.
- No asset redesign.
- No implementation.
- No replacement of production contracts.
- No new save/progression model.
- No chatbot or conversational assistant.
