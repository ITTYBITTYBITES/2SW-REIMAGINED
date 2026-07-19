# Mission 072B — The Missing Second Visual Production Brief

**Status:** Final visual/interaction production brief. No implementation, scene creation, code, or assets are authorized by this document.  
**Experience:** *The Missing Second*  
**Scope:** One complete bespoke Two Second Witness experience.

---

## 1. Visual identity

### Era

Contemporary-but-timeless railway travel.

The setting must not be tied to a precise historical year. It should feel familiar enough to read immediately, but slightly removed from ordinary present day:

- analog station clock;
- worn wooden bench;
- paper railway ticket / folded photograph;
- practical suitcase;
- warm station lamp against cool platform night.

Avoid futuristic UI, overt period costume, neon cyberpunk, or nostalgia caricature.

### Location

A small enclosed railway waiting room beside a platform shortly before the last departure.

The location must communicate:

```text
Someone is leaving.
Someone else will arrive.
This room has held many goodbyes.
```

Required environmental details:

- bench beneath or near station clock;
- window/opening toward platform;
- suggestion of passing rail light beyond the room;
- traveler’s suitcase within reach;
- tea cup left warm on bench/table;
- folded photograph visible but not emphasized initially;
- one distant departure-board-like shape without readable exposition text.

### Color palette

| Role | Color direction | Purpose |
| --- | --- | --- |
| Base room | desaturated blue-grey / slate | Quiet late-night waiting-room stillness. |
| Platform motion | muted amber / sodium-vapor gold | Moving time outside the room. |
| Tea / photograph | restrained warm cream / brown | Human warmth and eventual emotional anchor. |
| Clock detail | pale ivory face with dark hand | Readability without game-marker glow. |
| Resolution | modest warm lift, not a victory bloom | The room becomes emotionally coherent. |

No saturated UI colors should compete with the scene. The clock should be noticed through composition and rhythm, not a bright outline.

### Lighting

The lighting tells the player where time is happening:

```text
Cool room holds still.
Warm platform light moves.
Clock exists between those rhythms.
```

- Base illumination is dim but legible.
- Platform light sweeps horizontally or diagonally across floor, bench, traveler, and clock face.
- Clock gets a brief readable edge highlight as platform light passes.
- Photograph receives no special light before discovery.
- At resolution, the photograph receives a small warm reveal accent while the room’s cool/warm balance settles.

### Emotional tone

```text
quiet
→ attentive unease
→ private tenderness
```

The scene is not frightening, apocalyptic, whimsical, or sentimental in a loud way. It is an ordinary room carrying an unseen act of care.

---

## 2. Scene composition

### Viewpoint

Portrait 540 × 960 composition, eye-height, from the perspective of someone seated or paused just inside the waiting room.

The player is not a floating camera and not a detective looking down at a board. They are present in the room, looking toward departure.

### Framing map

```text
TOP THIRD
  station clock                platform/window glow

MIDDLE THIRD
  traveler + suitcase          bench / photograph

LOWER THIRD
  tea cup / steam              light sweep across floor
```

### Focal-object placement

| Element | Placement | Visual requirement |
| --- | --- | --- |
| Clock | upper-mid, slightly off center | Must read at mobile size; second hand visible without zoom. |
| Traveler | midground, opposite visual weight from clock | Silhouette readable, one clear leaving gesture. |
| Suitcase | beside traveler in midground | Connects movement to departure. |
| Photograph | bench edge or near tea in foreground-midground | Present during observation; readable as meaningful only later. |
| Tea | lower third / foreground | Steam is a time comparison anchor. |
| Platform light | offscreen source / window side | Moves across all layers without obscuring focal objects. |

### Depth

The room needs three readable planes:

1. **Foreground:** tea and photograph.
2. **Midground:** traveler, bench, suitcase.
3. **Background:** clock, window/platform light, station architecture.

The player should be able to inspect objects after reconstruction without the scene becoming a flat collage.

### Movement paths

| Element | Observation path | Reconstruction state | Resolution path |
| --- | --- | --- | --- |
| Traveler | Hand reaches suitcase; weight turns toward platform. | Frozen at pre-departure decision. | Sets photograph down, exits toward platform. |
| Platform light | Slow single sweep across room. | Frozen mid-sweep. | Completes sweep. |
| Tea steam | One gentle rising curl. | Frozen at an identifiable shape. | Resumes and fades naturally. |
| Clock second hand | Advances one tick beyond room rhythm. | Frozen one second ahead. | Eases backward/realigns, then resumes. |
| Photograph | Still, peripheral. | Still, selectable/examinable. | Warm reveal; traveler deliberately leaves it. |

---

## 3. Animation requirements

### Observation timing — exact intended rhythm

**Total observation:** approximately 2.0 seconds.

| Time | Visible action |
| ---: | --- |
| 0.0 s | Waiting room is already alive; traveler prepares to leave. |
| 0.2 s | Platform light starts crossing the room. |
| 0.5 s | Traveler’s hand moves toward suitcase. Tea steam rises. |
| 0.9 s | Clock second hand advances. |
| 1.0 s | Clock advances one extra second while platform light/steam/traveler remain on prior rhythm. |
| 1.3 s | Traveler has not yet completed the movement implied by clock. |
| 2.0 s | Observation ends; room freezes into reconstruction. |

### Missing-second visibility

The anomaly is not a jump cut, flash, shimmer, red alert, or icon.

The player should perceive it as a mismatch between simultaneous rhythms:

```text
The clock says later.
The room says not yet.
```

The extra advance should be clear enough to notice if watching the clock but quiet enough that a first-time player may only feel unease until reconstruction.

### Reconstruction transition

- Platform light stops where it is.
- Steam stops in a visible curl.
- Traveler freezes before completing departure.
- Ambient sound thins rather than cuts abruptly.
- Clock remains ahead.
- The room becomes still without becoming dead or dark.

### Resolution animation

After correct clock selection:

1. Clock second hand returns one beat into alignment.
2. Platform light completes its existing sweep.
3. Tea steam resumes.
4. Traveler shifts from suitcase to photograph.
5. Photograph is placed on bench.
6. Traveler exits in silhouette or moves beyond framing.
7. Waiting room remains after departure for a quiet beat before truth text arrives.

No confetti, screen flash, score pop-up, particle explosion, or generic completion animation.

---

## 4. Interaction design

### Player discovery model

The player should first inspect the scene with their eyes. Only after observation ends do physical examination affordances become available.

### Examination affordances

Objects should feel inspectable through subtle scene-native treatment:

- small change in cursor/touch feedback on hover/tap where supported;
- minimal focus ring or localized light response;
- no floating target labels before interaction;
- no answer list;
- no explicit “find the clock” copy.

### Object examination

| Object | Player action | Response |
| --- | --- | --- |
| Tea | Tap steam/cup | “The tea is still cooling where the room left it.” |
| Suitcase | Tap suitcase/handle | “The traveler has not yet decided to leave.” |
| Photograph | Tap photograph | “Someone will arrive after the platform is empty.” |
| Clock | Tap face/second hand | Correct discovery sequence begins. |

The photograph can be examined before clock discovery, but it must not reveal the full truth alone.

### Selection feel

A correct selection should feel like recognition:

```text
Clock tap
→ room sound thins
→ hand/tick response
→ second hand visibly holds attention
→ player knows: this is it
```

It should not feel like a generic button activation.

### Failure response

Incorrect examination must preserve agency:

- no wrong-answer overlay;
- no “incorrect” text;
- no meter loss;
- no lockout;
- no reset;
- no narrator correction.

The object’s response should simply sharpen the contrast between it and the clock.

---

## 5. UI direction

### Required text

Only four essential lines are allowed:

```text
Watch carefully. One second is missing.
What moved ahead of the room?
The clock arrived before the moment did.
The missing second was a choice to be remembered.
```

### Presentation rules

- Text sits in a quiet lower-third or edge-safe location.
- Text never covers clock, traveler, tea, or photograph.
- Text has sufficient contrast in both cool and warm light conditions.
- No opaque large panel over the lower half of the scene.
- Return action appears only after truth text has had time to land.

### Return action

```text
RETURN TO IRIS
```

The button is visually deliberate but secondary to the resolution. It should read as leaving a completed memory, not advancing a form.

---

## 6. Audio production brief

### Required sound layers

| Layer | Direction |
| --- | --- |
| Station tone | Quiet air, distant rail vibration, room reverb. |
| Clock tick | Clear enough to establish rhythmic reference, never loud. |
| Platform light | Low moving electrical/rail presence. |
| Tea/room detail | Nearly subliminal material presence. |
| Reconstruction | One subtle temporal thinning/held-breath cue. |
| Correct clock | Tick dropout then aligned return. |
| Resolution | Small warm harmonic shift, no victory fanfare. |
| Iris return | Existing Iris presence language only after the memory ends. |

### Audio rule

No Iris voice, instruction, or puzzle explanation occurs inside the investigation. Sound must let the room tell its own story.

---

## 7. Technical readiness

### Required Godot capabilities

| Capability | Required for | Status before implementation |
| --- | --- | --- |
| Layered 2D scene composition | Room depth and physical object placement | Must be built for this scene. |
| Scene-local animation/tween/timeline control | Clock, steam, light, traveler, freeze/resume | Must be built for this scene. |
| Scene-local touch examination | Physical object investigation | Must be built for this scene. |
| Portrait-safe layout | Commercial mobile readability | Must be validated in graphical runtime. |
| Iris portal handoff | Entry/return continuity | Existing platform candidate; audit before reuse. |
| Audio playback | Atmosphere and resolution | Existing transport candidate; use only if no retired assumptions leak. |
| Accessibility/reduced motion | Motion/readability acceptance | Existing platform candidate; test with the bespoke scene. |

### Explicitly missing capabilities

The active reset project does not yet contain the bespoke waiting-room scene, layered environment assets, independent clock hand, scene-local animation control, or object examination interaction.

These are required for the experience. They must be built correctly as scene-local capabilities before the player loop is implemented.

### Technical stop conditions

Stop implementation and resolve the underlying capability before continuing if:

- clock hand cannot animate independently from room;
- scene cannot freeze/resume individual layers;
- object examination cannot be scene-native;
- portrait composition cannot keep all focal objects readable;
- graphical runtime cannot be used for human validation;
- portal reuse requires importing retired runtime assumptions.

---

## 8. Asset production checklist

No asset production begins until this brief is accepted.

### Visual assets

- [ ] layered waiting-room background architecture;
- [ ] station clock face and independently animated second hand;
- [ ] traveler silhouette/body with reach, pause, photograph placement, exit;
- [ ] suitcase layer;
- [ ] tea cup and steam loop/freeze state;
- [ ] photograph normal/revealed state;
- [ ] platform light sweep layer;
- [ ] subtle station depth elements.

### Audio assets

- [ ] station room tone;
- [ ] clock tick;
- [ ] platform/rail light movement;
- [ ] reconstruction hold cue;
- [ ] aligned-tick confirmation;
- [ ] warm resolution cue.

### Interaction assets

- [ ] unobtrusive examination focus response for clock;
- [ ] object-specific feedback treatment for tea, suitcase, photograph;
- [ ] resolution text/return composition.

---

## 9. Production acceptance gate

Implementation can begin only when this statement is accepted:

> “The Missing Second will be built as a living, layered waiting-room memory. The player will discover a temporal mismatch through observation and scene-native examination, then understand the human choice that made the missing second matter.”

The first implementation review must use graphical runtime screenshots/video at:

1. memory formation;
2. mid-observation;
3. reconstruction;
4. wrong-object examination;
5. clock discovery;
6. resolution; and
7. return to Iris.
