# WM_001: Learning to Notice — Vertical Slice Design Document

## Overview

**Title:** Learning to Notice
**Moment ID:** WM_001
**Chapter:** chapter_01_learning_to_notice
**Purpose:** This is the player's first introduction to what it means to be a Witness. It must teach: *"I do not solve puzzles. I notice moments."*

---

## 1. Story & Narrative

### Why Iris Chose This Moment

The Iris does not show you this moment because it is important. It shows you this moment because it is *ordinary*.

A desk. Morning light. A cup of tea going cold. The small, quiet violence of a day beginning before you are ready for it. The Iris chose this moment because Witnessing begins not with the extraordinary, but with the discipline of staying present for the mundane.

### What the Player Is Witnessing

**The Moment (2 seconds):**
A hand reaches for a tea cup on a desk. The hand hesitates. Fingers brush the ceramic. The hand withdraws without lifting the cup. The moment passes.

**The Hidden Truth:**
The tea was made by someone who left before the player arrived. The hand belongs to the player. The hesitation is grief, not distraction. The cup was never meant to be drunk—it was meant to be witnessed cooling.

### Emotional Purpose

This moment teaches the core grammar of Witnessing:
- **Attention is not extraction.** You do not take from the moment. You stay with it.
- **Meaning is not given.** The moment does not explain itself. You must notice what is there.
- **The ordinary is the threshold.** Every profound truth passes through a moment this small.

### Iris's Introduction (Voice Guide)

> *"The instrument opens a small field. Two seconds. A desk. Morning light. A hand that does not lift the cup. Stay with it. Do not name what you see. Only notice."*

---

## 2. Environment

### Location
**A writer's desk in a quiet room.** Not an office. A personal space. Morning.

### Time
**7:47 AM.** The specific time when the world is still deciding what kind of day it will be.

### Lighting
- **Primary:** Cool morning window light from camera-left, slicing across the desk at a 35° angle
- **Fill:** Warm ambient bounce from cream walls
- **Key detail:** A single dust mote illuminated in the light shaft—this is the "anchor point" for attention

### Camera Style
- **Locked-off medium shot.** No camera movement during the 2-second observation.
- **Aspect:** 4:3 (portrait-friendly, intimate)
- **Depth of field:** Shallow. The desk surface is sharp; background falls to soft bokeh.
- **Color grade:** Slightly desaturated, cool shadows, warm highlights. The tea cup catches a specular highlight that *moves* as the hand approaches.

### Animation
- **The Hand:** Single continuous motion. Reach → hover (0.6s) → withdraw (0.4s). Total: ~1.6s of the 2s window.
- **The Tea:** Steam rises. Stops when hand hovers (micro-disturbance of air current). Resumes when hand withdraws.
- **The Dust Mote:** Drifts lazily. Unaffected. The constant.
- **The Light:** Imperceptibly shifts (sun moving). Only noticeable on replay.

### Ambient Details (The "Noise" That Becomes Signal)
| Element | Purpose |
|---------|---------|
| Notebook, half-open, pen resting in spine | Context: someone was writing |
| Fountain pen, capped, ink visible in window | Detail: cared-for object |
| Glasses folded beside notebook | Detail: the writer wears glasses |
| Keys on a leather fob | Detail: someone comes and goes |
| Plant (pothos) trailing from shelf | Life continuing |
| Second cup, empty, lipstick stain | **The hidden truth** — someone else was here |

### Audio Environment
- **Base layer:** Room tone. HVAC hum. Distant traffic (muffled, 3 floors down).
- **Focus layer (emerges during observation):**
  - Steam hiss (subtle, stops during hover)
  - Fabric whisper (sleeve against desk)
  - Finger-on-ceramic *microsound* (the hesitation)
  - Breath — held, then released
- **Post-observation:** The room tone continues. A single piano note (C3, felt, long decay) marks the transition to reconstruction.

---

## 3. Observation Phase (The 2-Second Moment)

### What Happens
**0.0s – 2.0s:** The moment plays once. No player input accepted. The screen is the moment.

### What the Player Should Notice (The "Curriculum")
The game does not tell the player what to notice. But the design ensures these are *noticeable*:

| Tier | Detail | Why It Matters |
|------|--------|----------------|
| **Surface** | Hand reaches for cup | The action |
| **Surface** | Hand stops, hovers | The hesitation |
| **Surface** | Hand withdraws | The non-action |
| **Subtle** | Steam stops during hover | Air current disturbed |
| **Subtle** | Specular highlight on cup moves | Light geometry confirms 3D space |
| **Subtle** | Second cup (lipstick) in background | Another person |
| **Deep** | Notebook page has writing, not blank | Someone was thinking |
| **Deep** | Pen is *capped* | Writing stopped deliberately |
| **Deep** | Dust mote drifts *through* the light shaft | Time passes regardless |

### What Is Intentionally Missed (First View)
- The lipstick stain on the second cup (background, out of focus)
- The writing on the notebook page (too small, upside-down)
- The wedding ring on the hand (visible only in 2 frames during hover)
- The tea level — nearly full (cup was never drunk from)

### Camera Movement
**None during observation.** This is deliberate. The player's *attention* is the camera.

### Timing
- **Total observation window:** 2.0 seconds exactly
- **No countdown visible.** The timer is internal (runtime).
- **Transition:** Hard cut to black (0.15s) → Reconstruction phase fades in

---

## 4. Memory Reconstruction (Replacing Old Recall Questions)

### Design Principle
**No questions. No multiple choice. No "correct answer."**
The player *rebuilds* the moment from memory using spatial, temporal, and sensory anchors.

### Interaction: "Place What You Remember"

**Screen:** The same desk, now empty. Ghost outlines of major objects (notebook, cups, pen, glasses, keys, plant).

**Mechanic:**
1. Player sees the empty desk with **faint ghost silhouettes** of 6 object positions.
2. A **palette of remembered fragments** appears at bottom — not objects, but *impressions*:
   - ☕ "Warm ceramic"
   - 💨 "Steam that stopped"
   - 💍 "Gold band on finger"
   - 🖊️ "Capped pen"
   - 📖 "Half-written page"
   - 🌿 "Trailing leaves"
   - 🔑 "Leather fob"
   - 👓 "Folded frames"
   - ☕☕ "Two cups"
3. Player **drags fragments to ghost positions**. Multiple fragments can go to one position. Some positions stay empty.
4. **No validation.** No "correct" placement. The act of placing *is* the reconstruction.

**Why This Works:**
- Forces spatial memory (where was it?)
- Forces sensory memory (what did it feel like?)
- Reveals gaps naturally (player realizes they missed the second cup)
- No failure state — only *incomplete* reconstruction

### Visual Language
- Ghost outlines: White, 0.15 alpha, pulsating slowly (breathing)
- Fragments: Cards with icon + text, semi-transparent, float slightly
- Placed fragments: Settle into position, gain opacity, connect to ghost with thin line
- **Iris voice:** *"Place what stayed with you. Leave what didn't. There is no wrong answer — only what you carry."*

---

## 5. Investigation Phase (Replacing Old Scene Investigation)

### What Can Be Examined
After reconstruction, the player enters the **held moment** — a frozen, explorable version of the 2-second window.

**Interaction:** Tap/click any object in the frozen moment to **attune** to it.

### Attunement Mechanics
When the player attunes to an object, the moment **replays from that object's perspective**:

| Object | Attunement Reveals |
|--------|-------------------|
| **Tea Cup (primary)** | Thermal vision: heat map shows cup at 68°C. Steam particles visualized. Hand's heat radiates into ceramic during hover. |
| **Hand** | Skeletal overlay: micro-tremor in fingers during hover. Pulse visible at wrist (72 bpm → 88 → 64). |
| **Notebook** | Text becomes legible: *"I don't know how to stay"* (half-erased). Pen pressure marks show hesitation. |
| **Second Cup** | Lipstick stain resolves to a specific shade (Rosewood 42). Rim imprint matches the hand's fingers. |
| **Dust Mote** | Particle trajectory: entered light shaft 3.2s before moment, exits 1.8s after. Unaffected by hand. |
| **Light Shaft** | Spectral breakdown: 5600K. Sun azimuth 47°. Calculates time: 7:47 AM ± 2 minutes. |

### Discovery / "Aha" Moment
The **wedding ring** on the hand (visible only in Hand attunement) + **lipstick stain** on second cup + **notebook text** ("*I don't know how to stay*") = **This is the player's own hand. The other cup was their partner's. They left. The player remains.**

This is not told. It is *assembled* by the player across 3+ attunements.

### Investigation Flow
1. Player attunes to 1st object (usually tea cup) → gets thermal data
2. Player attunes to 2nd object (hand or notebook) → gets physiological/text data
3. Player attunes to 3rd object (second cup or dust mote) → gets the connection
4. **Iris intervenes:** *"You have seen enough. Or you haven't. The moment does not require your completion. Only your presence."*

---

## 6. Revelation Phase

### Iris Response (Voice Guide)
> *"You noticed the hand did not lift the cup. You noticed the steam stopped. You noticed the second cup. You noticed the ring. You noticed the words on the page. The moment did not change. You did. This is what it means to Witness. The archive receives what you carried."*

### Emotional Payoff
- No "Correct!" badge. No score. No stars.
- The **archive entry** appears — a living document of what the player noticed.
- The moment's title in archive: **"First Attention Field"**
- Category: **Chapter 1 — Learning to Notice**

### Archive Entry Structure
```
┌─────────────────────────────────────┐
│  FIRST ATTENTION FIELD              │
│  WM_001 · Chapter 1                 │
│  7:47 AM · 2.0 seconds              │
├─────────────────────────────────────┤
│  WHAT YOU CARRIED:                  │
│  ☑ Warm ceramic                     │
│  ☑ Steam that stopped               │
│  ☑ Gold band on finger              │
│  ☐ Capped pen                       │
│  ☐ Half-written page                │
│  ☐ Trailing leaves                  │
│  ☐ Leather fob                      │
│  ☐ Folded frames                    │
│  ☑ Two cups                         │
├─────────────────────────────────────┤
│  ATTUNEMENTS: 3 of 6                │
│  • Tea Cup (thermal)                │
│  • Hand (pulse, ring)               │
│  • Second Cup (lipstick)            │
├─────────────────────────────────────┤
│  IRIS NOTE:                         │
│  "The cup was never meant to be     │
│   drunk. It was meant to be         │
│   witnessed cooling."               │
└─────────────────────────────────────┘
```

---

## 7. Completion & Rewards

### Rank Progress
- **Rank:** Observer (starting rank)
- **Progress:** +12 Witness Progress points
- **Mastery:** "Attention" family +0.08 mastery

### Profile Update
- `completed_moments: 1`
- `discoveries: 1` (the hidden truth)
- `achievements: 1` — **"First Witness"** (unlocked on completion)
- Archive entry added: `first_attention_field`

### No Traditional Rewards
- No coins, gems, currency
- No streak counter
- No daily bonus
- **Only:** The archive grows. The Iris remembers.

---

## 8. Phase Flow Summary

```
ARRIVING
  → Iris introduction (voice)
  → "The instrument opens a small field..."
  → Player taps center to begin

ATTUNING (1.5s)
  → Screen darkens to desk
  → Ambient audio fades in
  → Dust mote appears
  → "Stay with it."

OBSERVING (2.0s) ★ THE MOMENT
  → Hand reaches, hovers, withdraws
  → NO INPUT ACCEPTED
  → Hard cut to black (0.15s)

RECONSTRUCTING (untimed)
  → Empty desk + ghost outlines
  → Fragment palette
  → "Place what stayed with you."
  → Player drags fragments
  → "Continue" when ready

INVESTIGATING (untimed)
  → Frozen moment explorable
  → Tap objects to attune
  → 3+ attunements → Iris intervenes
  → "You have seen enough."

REVEALING
  → Iris voice: synthesis of what player noticed
  → Archive entry builds in real-time
  → "First Attention Field" added

ARCHIVING
  → Profile updates
  → Rank progress animates
  → Achievement toast: "First Witness"

RETURNING
  → Transition back to Iris
  → Iris remembers recent activity (learning animation)
  → Home screen
```

---

## 9. Asset Plan (Placeholder → Production)

| Asset | Placeholder | Production Replacement Path |
|-------|-------------|----------------------------|
| **Environment** | Graybox desk + primitives | Cinematic desk scan (photogrammetry) |
| **Hand Animation** | Simple IK rig | Performance capture (actor) |
| **Tea Cup** | Basic cylinder + shader | Hero prop — ceramic, subsurface scattering |
| **Steam Particles** | CPUParticles2D | Niagara/Simulated fluid cache |
| **Dust Mote** | Single sprite | Volumetric light shaft simulation |
| **Notebook Text** | Dynamic texture | Hero prop — real handwritten pages |
| **Second Cup** | Duplicate cup | Hero prop — lipstick stain geo |
| **Audio: Room Tone** | Procedural hum | Field recording (3D ambisonic) |
| **Audio: Steam** | Procedural hiss | Foley recording |
| **Audio: Microsounds** | Synthesized | ASMR-recorded (finger/ceramic, fabric, breath) |
| **Iris Voice** | TTS (VoiceGuide) | Professional VO (recorded) |
| **Reconstruction UI** | Graybox cards | Custom UI — "memory fragments" aesthetic |
| **Attunement Overlays** | Shader effects | Custom shaders (thermal, spectral, skeletal) |
| **Archive Entry** | Text layout | Living document — animated, interactive |

**Every placeholder has a named replacement path. No asset blocks development.**

---

## 10. Legacy Support Marking

The following existing systems are **LEGACY_SUPPORT** — temporary compatibility layers for WM_001:

| System | Current Role | Future Replacement |
|--------|--------------|-------------------|
| `TutorialScreen` | Hosts family tutorials | **Removed** — WM_001 has no tutorial |
| `ObservationChallengeScreen` | 2s observation + countdown | **Replaced** — `WitnessObservationPhase` (no countdown, no HUD) |
| `MemoryQuestionScreen` | Multiple choice recall | **Replaced** — `WitnessReconstructionPhase` (spatial fragment placement) |
| `ResultScreen` | Score, correct/incorrect, progress | **Replaced** — `WitnessRevelationPhase` (archive entry, no score) |
| `ProductionWitnessHost` routes | tutorial→observation→memory_question→result | **Replaced** — `WitnessMomentRuntime` direct phase signals |
| `ChallengeSessionService` | Session management | **Retained** — for legacy challenges only |
| `SceneInvestigation` family | Puzzle gameplay | **Retained** — for Discovery mode, not Story Mode |

**Do not delete legacy systems. Mark them. They serve existing challenge modes.**

---

## 11. Human Review Checklist

A person playing WM_001 should answer:

1. **Did I understand why I was here?**
   - [ ] Iris's introduction made the purpose clear
   - [ ] I knew this was not a puzzle

2. **Did the Iris feel like a guide?**
   - [ ] Voice tone was warm, not instructional
   - [ ] Felt like a companion, not a UI narrator

3. **Did the two-second moment feel meaningful?**
   - [ ] I wanted to replay it
   - [ ] The silence during observation felt intentional

4. **Did I feel curiosity after missing something?**
   - [ ] During reconstruction, I realized I missed the second cup
   - [ ] I *chose* to investigate further

5. **Did the reveal feel worth discovering?**
   - [ ] The archive entry reflected *my* noticing
   - [ ] The Iris note resonated emotionally

6. **Did it feel different from a normal mobile puzzle game?**
   - [ ] No score, no stars, no "correct"
   - [ ] Felt like a short film I participated in

---

## 12. Implementation Sequence

### Phase 1: Core Runtime Integration (Week 1)
- [ ] Update `moment_001.json` with full design data
- [ ] Create `WitnessMomentPhase` base class
- [ ] Implement `WitnessAttunementPhase`, `WitnessReconstructionPhase`, `WitnessInvestigationPhase`, `WitnessRevelationPhase`
- [ ] Wire into `WitnessMomentRuntime` phase signals

### Phase 2: Observation Phase (Week 1-2)
- [ ] Create `WitnessObservationScreen` — replaces `ObservationChallengeScreen`
- [ ] No timer HUD, no countdown, hard cut transition
- [ ] Hand animation + steam + dust mote (placeholder assets)

### Phase 3: Reconstruction Phase (Week 2)
- [ ] Create `WitnessReconstructionScreen` — fragment placement UI
- [ ] Ghost outline system
- [ ] Drag-drop fragment palette
- [ ] No validation logic

### Phase 4: Investigation Phase (Week 2-3)
- [ ] Create `WitnessInvestigationScreen` — frozen moment + attunement
- [ ] Attunement shader system (thermal, spectral, skeletal)
- [ ] 6 attunement perspectives
- [ ] Iris intervention trigger

### Phase 5: Revelation & Archive (Week 3)
- [ ] Create `WitnessRevelationScreen` — dynamic archive entry
- [ ] Profile integration (WitnessProgress, achievements)
- [ ] Archive entry animation

### Phase 6: Polish & Review Build (Week 3-4)
- [ ] VoiceGuide integration for all Iris lines
- [ ] Audio implementation (procedural → placeholder)
- [ ] Transition animations
- [ ] Human review session with checklist

---

## 13. Constraints & Guardrails

**DO NOT:**
- Add more challenge families
- Rebuild old challenges
- Create final art (placeholder only)
- Create monetization
- Create daily/weekly modes
- Modify unrelated systems (Archive, Discovery, Profile, Settings)

**DO:**
- Prove the Witness Moment format works
- Make the first moment feel *real*
- Establish the "camera lens" for all future moments
- Keep legacy systems intact but marked

---

## 14. Success Criteria

**WM_001 is complete when:**
1. A player can run WM_001 from Story Mode → Iris → Witness → Archive without touching legacy screens
2. The review checklist scores 5/6 or higher from 3 independent testers
3. No legacy tutorial/observation/recall/result screens appear during WM_001
4. The archive entry reflects the player's actual choices
5. The experience takes 3-5 minutes and feels complete

---

*This document is the "camera lens." Every future Witness Moment will be judged against WM_001. If WM_001 works, we build the cathedral. If not, we change the foundation.*