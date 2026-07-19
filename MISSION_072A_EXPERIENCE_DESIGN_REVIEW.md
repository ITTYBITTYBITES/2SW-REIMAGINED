# Mission 072A — The Missing Second Experience Design Review

**Status:** Design review gate. No implementation authorized by this document.  
**Decision target:** Confirm that *The Missing Second* expresses the intended identity of Two Second Witness before any scene, asset, or code work begins.

---

## 1. Player experience

### Required remembered sentence

> **“I was looking at a traveler leaving a railway waiting room, I noticed the clock had moved ahead of everything else, and I discovered the missing second was a choice to leave a photograph for someone still to come.”**

### What should remain after play

The player should remember one precise image:

```text
A clock hand already arriving at a second
that the room has not yet lived.
```

They should also remember one human realization:

```text
The traveler did not fail to leave on time.
They chose to remain for someone else.
```

The goal is a compact emotional afterimage, not an achievement, score, collectible, or lore explanation.

---

## 2. The role of observation

### Why two seconds matters

The observation is meaningful because it places the player in the position of a witness before they become an investigator.

The player is not told:

```text
Find the clock.
```

They see a small event unfold in real time:

```text
a traveler reaches for a suitcase
→ a light crosses the floor
→ tea continues to steam
→ a clock ticks ahead
```

The two seconds should feel just long enough that a player may register the room’s rhythm without immediately naming the discrepancy. Reconstruction transforms that lingering visual impression into a question.

### What the player is witnessing

The player witnesses a transition rather than an object inventory:

- someone about to depart;
- a room about to be left behind;
- one extra second that holds a private decision.

The player should retain a felt memory of the scene, then compare that memory against the reconstructed room.

### Anti-pattern to avoid

Do not present a static scene with a request to memorize every object. The observation is not a memory test; it is the emotional and temporal context that makes the later difference matter.

---

## 3. Anomaly design

### Why the clock is the changed detail

The clock is the correct changed detail because it is the only object in the room that can explicitly contradict the shared temporal rhythm of:

- moving steam;
- traveling light;
- traveler motion;
- a physical departure.

It is a meaningful visual discrepancy, not an arbitrary hidden object.

### How the player discovers it

During observation:

- the second hand advances one additional tick;
- the platform light and tea steam remain on their prior temporal beat;
- the traveler has not yet completed the movement implied by the clock.

During reconstruction:

- the room freezes;
- the clock remains one second ahead;
- the cup, suitcase, photograph, and light offer readable comparison anchors;
- the player can examine physical objects in the scene.

### Noticeable, but not obvious

The discrepancy should be perceptible through rhythm, not a flashing UI cue.

Target balance:

```text
First observation: “Something in that room did not feel synchronized.”
Reconstruction: “The clock is the only thing that arrived too early.”
```

### Attention reward

A player who noticed the clock should experience recognition, not surprise at a hidden answer. A player who did not notice should be able to reason their way to it using the room’s unchanged temporal anchors.

---

## 4. Emotional resolution

### What changes after discovery

Before discovery, the missing second feels like an unexplained technical error.

After discovery, it becomes an act of care:

```text
One second was held open
so a photograph could remain for someone else.
```

The scene moves from temporal unease to quiet tenderness.

### Why the photograph matters

The photograph is not a clue token. It is the evidence of intention.

It explains:

- why the traveler did not immediately board;
- why the missing second persisted;
- why the room’s memory deserves restoration.

The photograph should become visually warmer or more legible only during the resolution, allowing the player to recognize it as the purpose of the extra second.

### Why this is Two Second Witness, not hidden-object play

| Hidden-object puzzle | The Missing Second |
| --- | --- |
| Player searches a static image for a target. | Player witnesses a short event, then compares its temporal rhythm. |
| The object itself is the reward. | The changed detail reveals a human reason. |
| Correct answer ends the task. | Discovery recontextualizes the witnessed moment. |
| Challenge is visual scanning. | Challenge is attention, memory, and interpretation. |

The player is not finding a photograph. They are realizing why a second had to be missing.

---

## 5. Visual direction

### Art style

**Stylized cinematic realism.**

The room should have believable materials, scale, and atmospheric light, but avoid photorealistic asset requirements. It should feel illustrated with intentional painterly control:

- soft material edges;
- controlled atmospheric grain;
- restrained detail outside focal areas;
- readable silhouettes;
- emotionally directed color.

### Camera perspective

- portrait-oriented, eye-height three-quarter view;
- camera positioned as if seated across the waiting room from the traveler;
- station clock in upper-mid composition;
- traveler and suitcase in middle-right or middle-left balance;
- tea and photograph in foreground/bench plane;
- platform light supplies depth from window or platform side.

The clock must be visible without becoming a giant game icon.

### Lighting approach

```text
Base: cool blue-grey late-night station ambience
Contrast: warm amber platform light sweep
Resolution: photograph receives a small warm reveal accent
```

Lighting should lead attention from room → clock → photograph, but never replace player discovery with a spotlight.

### Animation level

Required animated layers:

- independently animated second hand;
- tea steam loop/freeze/resume;
- platform light sweep/freeze/complete;
- traveler reach/freeze/photograph action;
- subtle room particles or distant rail vibration.

No animation should be decorative only. Every animated element establishes the room’s shared time so the clock discrepancy can be understood.

### Realism/stylization balance

- **Real enough** for the traveler’s decision to carry emotional weight.
- **Stylized enough** that the temporal discrepancy reads cleanly on portrait/mobile screens.
- Avoid noisy realism, dark detail loss, or a busy station environment that obscures focal objects.

---

## 6. Interaction philosophy

### Required sequence

```text
observe
→ understand the room’s rhythm
→ investigate the reconstructed scene
→ discover the changed detail
```

### Interaction rules

- Examination is scene-native: tap physical visible objects.
- Wrong examinations return contextual observations, not generic failure messages.
- Correct selection is a recognition event, not a quiz answer submission.
- No answer list, multiple-choice card, score, timer pressure, lives, meter, or objective checklist.
- The player never needs Iris narration to know what to do; the scene, prompt, and object responses carry the experience.

### Exact interaction language

| Stage | Language |
| --- | --- |
| Observation | `Watch carefully. One second is missing.` |
| Reconstruction | `What moved ahead of the room?` |
| Wrong object | Object-specific observation. |
| Correct clock | `The clock arrived before the moment did.` |
| Resolution | `The missing second was a choice to be remembered.` |

---

## 7. Commercial-quality checkpoint

| Risk | Why it would feel unfinished | Required solution before acceptance |
| --- | --- | --- |
| Static environment | Converts memory into an image viewer. | Build independent room layers and required motion. |
| Clock not readable | Makes discovery arbitrary or impossible. | Compose clock at readable portrait size; test at target viewport. |
| Weak traveler motion | Removes the human stakes of departure. | Animate a clear, restrained reach/turn/photograph action. |
| Steam/light not temporal anchors | Player cannot compare the clock against the room. | Give each a distinct visible rhythm before freezing. |
| Generic UI panel | Makes the experience feel like a technical card. | Use minimal integrated overlays and scene-native object examination. |
| Excessive text | Replaces observation with instructions. | Restrict copy to short entry, question, object response, and resolution. |
| Incorrect choice feels punitive | Breaks curiosity. | Use contextual responses and retain the reconstructed scene. |
| Resolution lacks visible change | Makes discovery feel abstract. | Reanimate room, reveal photograph, and complete departure action. |
| Generic audio | Fails to establish place or time. | Build station tone, clock tick, light/room cue, and warm resolution cue. |
| No human graphical test | Cannot verify comprehension or emotional impact. | Require observed playtest before calling the slice complete. |

---

## 8. Decision

### Design review conclusion

**Approved as the intended first Two Second Witness experience, subject to implementation meeting every visual, interaction, and human-test requirement in this review.**

This is not approved for a simplified implementation.

The first slice must prove:

```text
A player can witness a living moment,
notice a temporal difference,
understand its human meaning,
and remember why it mattered.
```

### Implementation authorization boundary

Implementation may proceed only as one bespoke scene and one bespoke controller. Any emerging reusable capability must be documented as a future extraction candidate and deferred.