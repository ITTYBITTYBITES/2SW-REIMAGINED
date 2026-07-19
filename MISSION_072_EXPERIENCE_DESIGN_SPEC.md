# Mission 072 — The Missing Second
# First Commercial-Quality Two Second Witness Experience Design Specification

**Status:** Required planning gate. No experience implementation has begun.  
**Scope:** One bespoke, complete player experience only.  
**Non-goal:** Build any reusable Witness, story, content, phase, investigation, or progression framework.

---

## 1. Product promise

### Title

**The Missing Second**

### One-sentence experience

The player looks through the Living Iris into a railway waiting room and discovers that the station clock has moved one second ahead of the people and objects around it.

### Emotional goal

The player should move through three feelings:

```text
quiet attention
→ uneasy realization
→ tenderness
```

The final realization is not that time broke randomly. The traveler chose to remain for one second to leave a photograph for someone arriving after them.

### Intended player statement

> “I saw the second that everyone else would have missed, and I understood why it mattered.”

### Living Iris relationship

The Iris is the threshold and the receiver of the experience:

```text
Iris opens the memory
→ player witnesses alone
→ Iris receives the recovered moment
→ player returns to Iris
```

The Iris does not narrate, hint, label targets, explain the mystery, or solve the observation during the memory.

---

## 2. Complete player journey

```text
Living Iris at Home
→ player selects WITNESS
→ pupil transition opens
→ railway waiting room emerges
→ observation begins automatically
→ player watches for approximately two seconds
→ room freezes/reconstructs
→ player examines physical scene elements
→ player notices clock second hand is ahead of the room
→ player selects the clock
→ discovery is confirmed
→ reconstruction reveals photograph left behind
→ truth is presented
→ Iris receives the recovered moment
→ return pupil transition
→ Iris Home
```

### Success criteria in player language

At the end, an unfamiliar player should naturally answer:

1. **What did I witness?** A traveler preparing to leave a railway waiting room.
2. **What changed?** The clock’s second hand had moved ahead of everything else.
3. **What was I looking for?** The one detail that no longer matched the room.
4. **Did I succeed?** Yes; the scene visibly confirms the clock was wrong.
5. **Why did it matter?** The traveler stayed behind for one second to leave a photograph for someone arriving later.
6. **How do I return to Iris?** A clear post-revelation return action leads back through the pupil.

---

## 3. Interaction flow

### 3.1 Entry / memory formation

- Existing Iris portal is used only if it can support a clean handoff without retired moment assumptions.
- The room fades in from an Iris-shaped aperture, then settles into a full waiting-room composition.
- No text card dominates the scene.
- A short unobtrusive line may appear:

```text
Watch carefully. One second is missing.
```

### 3.2 Observation — approximately two seconds

The player has no interaction during observation.

The scene shows:

- traveler reaching toward suitcase;
- station clock ticking;
- tea steam rising;
- platform light sweeping across the room;
- photograph visible on bench;
- second hand advancing one tick beyond the room’s physical rhythm.

The clock discrepancy must be perceivable but not highlighted by an icon, glowing hotspot, or tutorial arrow.

### 3.3 Reconstruction

- The scene becomes still.
- Ambient room tone remains.
- The platform light pauses in its prior position.
- Tea steam holds at its prior curl.
- The clock second hand remains ahead.
- Minimal question appears:

```text
What moved ahead of the room?
```

### 3.4 Investigation

The player can tap three physical scene elements:

| Element | Response | Purpose |
| --- | --- | --- |
| Tea cup / steam | “The tea is still cooling where the room left it.” | Establishes comparison anchor. |
| Suitcase / photograph | “The traveler has not yet decided to leave.” | Establishes human stakes. |
| Clock | Correct selection. | Solves the changed detail. |

The elements must be visually part of the scene—not buttons in a list or separate answer cards.

### 3.5 Failure response

Incorrect examination:

- subtle focus/lighting pulse on examined object;
- short contextual sentence;
- no penalty, lives, reset, failure loop, score loss, or generic red flash;
- player remains in the reconstructed scene.

### 3.6 Success response

Correct clock selection:

1. Sound drops to near silence.
2. Clock second hand eases backward into alignment.
3. The platform light completes its sweep.
4. Tea steam moves again.
5. Traveler places photograph on the bench.
6. Traveler leaves toward the platform.
7. Truth text appears over the now-coherent scene.

### 3.7 Resolution

```text
The Missing Second

The traveler did not hesitate.
They stayed one second longer to leave a photograph
for someone who would arrive after them.
```

A single action appears:

```text
RETURN TO IRIS
```

---

## 4. Visual design

### 4.1 Scene composition

**Camera:** 540 × 960 portrait composition, eye-height, seated/waiting-room intimacy.

**Foreground**

- tea cup with subtle visible steam;
- folded photograph on bench edge;
- suitcase handle / traveler hand.

**Midground**

- traveler in coat, moving toward suitcase/platform direction;
- bench and clock as high-value focal geometry.

**Background**

- station window or platform glow;
- departure-board-like geometry without readable lore text;
- distant train-light movement.

### 4.2 Lighting

- cool blue-grey station ambient;
- amber platform light sweep crossing the floor and bench;
- clock face receives a small readable edge light;
- warm photograph accent becomes visible at resolution.

The clock must draw the eye through composition and motion—not through a giant game marker.

### 4.3 Environmental behavior

| Element | Observation behavior | Reconstruction behavior | Resolution behavior |
| --- | --- | --- | --- |
| Clock hand | Advances one extra second | Frozen ahead | Re-aligns with room. |
| Tea steam | Rises continuously | Frozen | Resumes. |
| Platform light | Sweeps slowly | Frozen | Completes sweep. |
| Traveler | Reaches for suitcase | Frozen mid-choice | Leaves photograph, exits. |
| Photograph | Present but easy to overlook | Still present | Warmly revealed. |
| Room ambience | Living/station quiet | Near-still | Warms slightly at realization. |

### 4.4 No static-card compromise

The waiting room must be composed from independent visual layers and actual animation controls. A single static background image with UI over it does not meet this experience specification.

---

## 5. Audio design

### Atmosphere

- low railway room tone;
- distant train/rail vibration;
- one gentle electrical hum;
- room-scale reverb without speech narration;
- clock tick audible enough to support the changed second.

### Interaction

| Event | Audio direction |
| --- | --- |
| Observation begins | Low room tone and clock tick enter. |
| Reconstruction | Ambient thins; one soft temporal discontinuity. |
| Examine wrong object | Quiet tactile/room-specific acknowledgment, no alarm. |
| Examine clock | Tick drops out, then returns in alignment. |
| Truth reveal | Small warm harmonic resolution, not a victory fanfare. |
| Return to Iris | Existing Iris transition/presence language may be reused selectively. |

### Haptics

Only if existing platform haptic transport can be used without importing retired event keys:

- one subtle acknowledgment when clock is correctly identified;
- one soft confirmation at resolution;
- no haptic punishment for incorrect examinations.

---

## 6. Required technical implementation

### Bespoke scene

```text
res://scenes/MissingSecondExperience.tscn
```

### Bespoke controller

```text
res://scripts/experience/MissingSecondExperience.gd
```

### Required visual components

These may be scene nodes or scene-local custom controls. They are not a reusable framework:

```text
MissingSecondExperience
├── WaitingRoomEnvironment
│   ├── PlatformLightLayer
│   ├── ClockFace
│   │   └── SecondHand
│   ├── Traveler
│   ├── Suitcase
│   ├── TeaCup
│   │   └── Steam
│   └── Photograph
├── ObservationOverlay
├── InvestigationPrompt
├── ResolutionOverlay
└── ReturnButton
```

### Required code responsibilities

The single controller may:

- sequence entry, observation, reconstruction, examination, resolution, and return;
- animate the scene-local objects;
- evaluate the three local examination targets;
- expose only this experience’s success/failure language;
- request return to the retained Iris shell.

The controller may **not**:

- define generic moment classes;
- read a moment catalogue;
- parse generic moment JSON;
- implement a reusable state engine;
- create future-story abstractions;
- create a progression system.

---

## 7. New assets required

The old WM assets are retired and must not be reused.

### Required first-pass production assets

1. Waiting-room environment layer set.
2. Traveler layer or simple character animation set.
3. Clock face and independently controllable second hand.
4. Tea cup and steam layer.
5. Suitcase layer.
6. Photograph layer.
7. Platform-light gradient/light sweep layer.
8. Railway ambience and clock tick.
9. Resolution cue.

### Asset quality rule

If an asset cannot express the required behavior, it is not sufficient. For example:

```text
A static clock texture cannot represent the missing second.
A static room cannot express temporal alignment.
A generic button list cannot express scene investigation.
```

---

## 8. Risk assessment

| Risk | Why it matters | Required decision/action |
| --- | --- | --- |
| Layered art unavailable | The experience cannot meet the movement/comparison requirement with one flattened image. | Create/procure scene layers before implementing interaction. |
| Graphical runtime unavailable | Human feel cannot be evaluated headlessly. | Establish graphical desktop test path before acceptance. |
| Portal integration imports old assumptions | The old portal may contain retired memory naming/data assumptions. | Audit and isolate portal shell before wiring. |
| Existing platform profile retains old data | Reset must not accidentally restore retired player state. | Test fresh profile and profile migration behavior. |
| Portrait composition crowded | Clock, traveler, tea, photograph must all read on mobile. | Validate composition at 540 × 960 before interaction polish. |
| Over-explaining | Iris narration or UI copy can destroy discovery. | Keep in-memory text sparse and object-specific. |

---

## 9. Future extraction candidates — document only

Do not implement these during Mission 072:

- scene observation controller;
- layered memory scene renderer;
- object examination component;
- reusable temporal discrepancy effect;
- future experience content format;
- progression/archive result system.

If the first slice proves enjoyable, these may become candidates for later extraction. Their presence here is not authorization to build them now.

---

## 10. Pre-implementation approval checklist

Implementation may begin only when these are accepted:

- [ ] The Missing Second story concept.
- [ ] Waiting-room visual direction.
- [ ] One-second clock discrepancy as the only core detection mechanic.
- [ ] Photograph resolution truth.
- [ ] Bespoke scene/controller boundary.
- [ ] Requirement for real layered/moving visuals.
- [ ] No generic engine/framework/pipeline work.
- [ ] Graphical human playtest availability before final acceptance.
