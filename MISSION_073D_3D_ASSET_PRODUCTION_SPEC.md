# MISSION 073D — The Missing Second: 3D Asset Production Specification

**Status:** Asset approval-gate deliverable. **No implementation, scene creation, code, or asset production is authorized until this is accepted.**
**Supersedes (medium only):** the 2D / "single background image" / "layered 2D composition" language in `MISSION_072B…§4.4` and `MISSION_072C…§4`. All other 072B/072C direction (era, palette, lighting, tone, composition, timing, interaction model, audio brief, reuse boundaries, first-playable definition) is **carried forward unchanged** and governs this spec.
**Locks (per Mission 073E):** Stylized Cinematic 3D Memory Environment. One exceptional 3D memory. No reuse-pipeline optimization.
**Build target:** Godot 4.6, 540×960 portrait, Android (primary) + desktop (authoring/capture).

---

## 0. Decisions this spec locks (and two that need a one-word confirm)

Already approved in 072B — **not reopened**: era (*contemporary-but-timeless*), place (*small enclosed railway waiting room, last departure, late night*), palette (slate-blue base / sodium-amber motion / warm cream human accent / ivory clock), emotional arc (*quiet → attentive unease → private tenderness*), the missing-second mechanic, the four text lines, examination model, audio brief.

This spec **locks**:
- **Medium:** true 3D scene (Node3D + Camera3D + MeshInstance3D + AnimationPlayer), not a 2D Control composition.
- **Style:** stylized cinematic realism, slightly dreamlike memory quality.
- **Renderer:** **Forward+** (desktop authoring + cinematic capture) and **Mobile** (Android target). Both share one scene/lighting rig so the look transfers. *This requires changing `project.godot` from the current `gl_compatibility`, which cannot deliver the emotional lighting the approved brief requires.*
- **Camera:** 3D perspective, ~38–45 mm-equivalent FOV, seated eye-height, slow handheld drift.
- **Examination model:** scene-native 3D pick (camera ray → Area3D hitboxes), replacing the Control-button layer — *this also eliminates the fatal input bug documented in MISSION_073C.*

**Two items I recommend but flag for a one-word confirm** (so the production path is right before any art is commissioned):
1. **Production path:** **human 3D artist (Blender) primary for hero assets; AI/asset-store assist only for secondary dressing under art direction.** The prior mission explicitly criticized generated/placeholder look, and stylized-cinematic humans are where AI 3D fails hardest. Alternative: full-artist commission. (Confirm: *artist-primary* / *artist-only* / *other*.)
2. **Performance tier:** target **Godot Mobile (Vulkan) at mid-range Android, 60 Hz, ≤ ~150 k visible tris, ≤ 2 dynamic shadow-casting lights + baked GI**, with LOD0/LOD1 on hero meshes. (Confirm: *accept* / *raise ceiling* / *lower for low-end*.)

Everything below is valid regardless of those two answers; they only tune cost and ceiling.

---

## 1. Visual direction & final references (the look)

### 1.1 Style definition — stylized cinematic realism, slightly dreamlike memory

Believable materials and realistic proportions, but with intentional artistic direction: no photoreal-uncanny faces, no cartoon, no flat illustration, no diorama/game-board artifice. A gentle **memory haze**: soft atmospheric depth, restrained bloom, faint vignette, micro handheld camera drift, a graded color script. The player should feel they stepped *through Iris into a reconstructed place*, not into a render.

### 1.2 Named reference anchors (to brief the artist / build the moodboard)

*Tonal & emotional memory:*
- **Season: A Letter to the Future** — observational slowness, memory-as-place, tender transit journey. **Primary tonal + pacing anchor.**
- **Everybody's Gone to the Rapture** — quiet environmental memory, warm/cool emotional light.
- Studio Ghibli — *Spirited Away* water-train sequence: dreamlike transit memory, tenderness.
- Wong Kar-wai, *In the Mood for Love* — warm/cool memory palette, temporal ache (color-script reference, not content).

*3D look-dev (stylized cinematic realism, non-uncanny):*
- **Stray** — stylized-realistic environment lighting, atmospheric depth, "real place" legibility.
- **A Plague Tale: Requiem** — cinematic 3D lighting + character staging under low key.
- **Life is Strange: True Colors** — stylized-realistic humans that read emotionally without uncanny.

*Clock (the mechanic must read as a real station clock):*
- **Mondaine Swiss Railway clock** — the iconic analog station clock, the clean red second-hand disc (the most legible "second hand" design ever made; reference for *readability of the missing second*).
- Classic European platform station clocks (ivory face, black hand, metal housing).

*The human beat (photograph for someone arriving later):*
- *Before Your Eyes*, *After Yang* — memory retrieval framed with tenderness.

> **Reference deliverable:** a curated moodboard PDF (one page per: environment, clock, traveler, props, lighting, memory-grade) built from the above anchors + 3–5 artist-found references each, approved before modeling. (I can generate locked style-frame references on request as the next step — see §11 — but will not produce unprompted AI art, per the Mission 073D "no generic replacements" rule.)

### 1.3 Color script (carried from 072B, expressed for 3D lighting)

| Phase | Key | Fill | Accent | Post |
|---|---|---|---|---|
| Observation | warm sodium lamp (static) | cool slate sky-bounce | platform sweep (amber, moving) | faint bloom, light haze |
| Reconstruction | lamp dims ~30% | slate holds | sweep **frozen** mid-sweep | haze holds, contrast +5% |
| Discovery (clock tap) | lamp holds | slate | sweep still frozen; clock edge-light wakes | subtle desaturation |
| Resolution | lamp warms back +10% | slate → neutral | photograph warm reveal (tiny spot on); sweep completes | warm grade lift, gentle bloom |
| Memory haze | — | — | — | persistent faint vignette + micro grain |

The lighting literally encodes the brief: *cool room holds still; warm platform light moves; the clock lives between those rhythms.*

---

## 2. The 3D scene — construction approach

### 2.1 Scene root (supersedes 072C §1.2 hierarchy — *medium change only*)

```
MissingSecondExperience              (Node3D)  ← bespoke controller (072C §2 boundaries preserved)
├── CameraRig                        (Node3D)  ← slow handheld drift; portrait 540×960
│   └── Camera3D                     (Camera3D, ~40 mm-equiv, eye-height)
├── Environment                      (Node3D)
│   ├── RoomShell                    walls / floor / ceiling-suggest / wainscoting  (static, baked)
│   ├── Bench                        anchor furniture (static)
│   ├── WindowToPlatform             opening + platform + distant track (parallax/animated light)
│   ├── DepartureBoardShape          distant, non-readable (per 072B)
│   ├── Dressing                     poster frame, door, radiator/pipes (sells "real place")
│   └── StationClock                 (Node3D — see §3.1)
├── Actors                           (Node3D)
│   ├── Traveler                     rigged humanoid (see §3.2)
│   └── Props
│       ├── Suitcase
│       ├── TeaCup + Steam (GPUParticles3D)
│       └── Photograph  (normal / revealed-warm states)
├── LightingRig                      (Node3D)  ← see §2.3
├── WorldEnvironment                 fog/atmosphere + grade (see §2.4)
├── ExaminationVolumes               Area3D hitboxes on Clock/Tea/Suitcase/Photograph (see §4)
├── AnimationPlayers                 Traveler timeline + Scene timeline (freeze/resume/resolution)
└── CanvasLayer (UI)                 the four text lines + RETURN TO IRIS (2D over 3D is correct)
```

Designer-readability rule from 072C §1.1 is preserved: *the clock, its second hand, the traveler motion, the four examination targets, and return UI must each be answerable by pointing at a node — not by tracing code.*

### 2.2 Three readable depth planes (072B §2.4, now real Z-depth)

- **Foreground (closest to camera):** tea cup + steam; photograph on bench edge; optional bench armrest as a framing element.
- **Midground:** traveler + suitcase + bench body.
- **Background:** clock on back wall, window/platform glow, receding station architecture.

Real perspective depth + atmospheric haze gives the legibility 072B §2.4 asks for without any 2D layer collage.

### 2.3 Lighting rig (the emotional spine)

| Light | Type | Role | Animated? |
|---|---|---|---|
| Sky-bounce fill | HemisphereLight (cool slate) | Base legibility | static |
| Station lamp (key) | SpotLight/PointLight (warm sodium) | Primary illumination of bench/traveler/clock | dim on reconstruction, warm-lift on resolution |
| **Platform sweep** | SpotLight (amber), parented to a rotating/translating rig | **"Time outside the room"** — sweeps floor/bench/traveler/clock | yes — freezes on reconstruction, completes on resolution |
| Clock edge-graze | subtle SpotLight grazing the dial | wakes readability as sweep passes; one clean highlight on discovery | tied to sweep + discovery |
| Photograph reveal | tiny SpotLight (warm) on the photograph | off until resolution | powers on at resolution |
| Shadow-casting budget | ≤ 2 dynamic shadow casters (Mobile) | performance | — |

Baked GI / lightmap for the static room shell; dynamic lights only where motion/animation demands (sweep, reveal). This is what makes it *cinematic* on mobile.

### 2.4 Atmosphere & grade (the "memory" quality)

- `Environment` fog: light, cool, low density → real depth + dreamlike softening.
- Optional volumetric fog/light shaft from the window (Mobile: cheaper fog-only proxy).
- Post: gentle bloom, faint vignette, micro film grain, optional subtle chromatic aberration at frame edges, **graded via LUT** following the §1.3 color script.
- Micro handheld camera drift (±a few mm, slow sinusoid) → "I am present in a memory," not "I am a fixed camera."

---

## 3. Asset list — full inventory, classified, with retention decision

Legend — **Class:** HERO (bespoke, artist-built) / DRESS (secondary, artist-built or curated) / FX (particle/shader) / REUSE (carried from existing build) / AUDIO. **Retention:** KEEP-PORT (retain logic, rebuild as 3D) / REPLACE (discard 2D asset, build 3D) / KEEP-AS-IS.

| # | Asset | Class | Retention | Deliverable form |
|---|---|---|---|---|
| E1 | Room shell (walls/floor/wainscot/door) | HERO | REPLACE | 1–2 modular mesh sets, baked |
| E2 | Bench (wooden station bench) | HERO | REPLACE | hero mesh + LOD1 |
| E3 | Window-to-platform opening + platform + distant track | HERO/DRESS | REPLACE | mesh + animated light proxy |
| E4 | Departure-board shape (non-readable) | DRESS | REPLACE | simple mesh, no readable text |
| E5 | Secondary dressing (poster frame, radiator, pipes, signage) | DRESS | REPLACE | curated/low-poly |
| **C1** | **Station clock: housing + glass + dial** | **HERO** | **REPLACE** | mesh + dial texture (numerals/markings) |
| **C2** | **Clock hour / minute / second hands** (second hand = independent Node3D pivot) | **HERO** | **KEEP-PORT** | separate meshes; second-hand pivot driven by ported mechanic |
| T1 | Traveler — rigged humanoid, timeless departure attire | HERO | REPLACE | mesh + skeleton + LOD0/1 |
| T2 | Traveler animation set (breathe/reach/hesitate/place/exit) | HERO | REPLACE | AnimationLibrary + scene timeline |
| P1 | Suitcase | HERO | REPLACE | mesh |
| P2 | Tea cup + saucer | HERO | REPLACE | mesh |
| P3 | Steam (temporal-comparison anchor) | FX | KEEP-PORT | GPUParticles3D (freeze/resume behavior preserved) |
| P4 | Photograph (normal + revealed-warm states) | HERO | REPLACE | mesh + emissive reveal material |
| L1 | Lighting rig (§2.3) | FX/scene | NEW | Godot lights + baked GI |
| L2 | Platform sweep rig | FX/scene | KEEP-PORT | moving SpotLight (sweep/freeze/complete preserved) |
| W1 | WorldEnvironment: fog + grade LUT | FX/scene | NEW | Godot Environment resource |
| UI1 | Four text lines + RETURN TO IRIS (CanvasLayer) | UI | KEEP-AS-IS | 2D over 3D (correct) |
| A1 | Station room tone | AUDIO | KEEP-AS-IS (re-evaluate mix) | existing WAV, 3D-positioned |
| A2 | Clock tick | AUDIO | KEEP-AS-IS | existing WAV, 3D from clock |
| A3 | Reconstruction hold cue | AUDIO | NEW/PORT | thinning cue |
| A4 | Aligned-tick confirmation | AUDIO | NEW/PORT | tick-dropout + return |
| A5 | Warm resolution cue | AUDIO | KEEP-AS-IS | existing `resolution_chord.wav`, re-mix |
| A6 | Platform/rail movement presence | AUDIO | NEW | low moving presence |
| **M1** | **Missing-second mechanic (clock 1.35× + 1 s jump → freeze → realign lerp)** | **LOGIC** | **KEEP-PORT** | apply to C2 second-hand Node3D |
| **M2** | **Scene state machine + timing beats** | **LOGIC** | **KEEP-PORT** | FORMING/OBSERVING/RECONSTRUCTING/INVESTIGATING/RESOLVING/COMPLETE |
| X1 | Iris portal transition (entry/return) | REUSE | KEEP-AS-IS | threshold into the 3D scene |
| X2 | Entry/exit flow (Application routing) | REUSE | KEEP-AS-IS | unchanged boundary |
| **T3** | **Real-input examination test (tap → 3D pick → state change)** | **TEST** | **NEW (mandatory)** | fixes the 073C false-confidence gap |

**Net:** discard the flat background, the slide-only traveler sprite, the procedural 2D clock/props; keep the mechanic, timing, state machine, portal, audio transport, and text; rebuild everything visible as 3D.

---

## 4. Per-asset specifications

### 4.1 Station clock (C1, C2) — the core mechanic; cannot look like a debug object

- **Form:** wall-mounted analog station clock. Housing (metal/wood frame) + glass + ivory dial + hour/minute/**second** hands as **separate meshes**, the second hand on its own pivot Node3D at dial center.
- **Dial:** ivory face; **numerals (1–12) or refined tick markings** (Mondaine-clean); minute track; black hour/minute hands; second hand in a restrained accent (e.g., the Mondaine red disc or a thin dark-red hand) — chosen for **mobile legibility**, never a game-marker glow.
- **Readability gate:** at 540×960 portrait, on a ~5" phone, the second hand must be visible and its motion unambiguous **without zoom**. This is the single most important visual gate in the experience.
- **Mechanic (KEEP-PORT from M1):** during observation the second hand advances at 1.35× real-time with a +1.0 s jump at t≥0.95 (the "missing second"); on reconstruction it freezes at the ahead position; on discovery→resolution it eases back into alignment (lerp from `frozen_angle` to room-aligned angle) and resumes. Port the math verbatim from `MissingSecondExperience._update_living_room` / `_freeze_room` / `_update_resolution`, applied to the second-hand Node3D's `rotation`.
- **Emotional contribution:** the clock *is* the anomaly and the answer. Its readability is the difference between "I noticed something" and "I witnessed a missing second."
- **Tech:** ≤ ~3 k tris total; 1 K dial texture (numerals baked); hands on independent pivots; one edge-graze light.

### 4.2 Traveler (T1, T2) — recognizable human, not a silhouette/outline

- **Form:** rigged humanoid, believable proportions, timeless departure attire (coat, practical clothing — *not* period costume, *not* futuristic). Face **stylized-realism**, partly turned from camera during observation to reduce uncanny and suit "memory."
- **Required animation beats (072B §3.1, ported to 3D):**
  - `idle_breathe` — subtle weight shift + breathing (living presence).
  - `reach_to_suitcase` — hand extends toward case (0.5 s in observation).
  - `hesitate` — weight turns toward platform but does **not** complete (1.3 s) → this is the human half of the mismatch.
  - `place_photograph` — turns to bench, sets photograph down (resolution beat 4–5).
  - `turn_to_platform` + `exit_walk` — leaves toward platform, passes out of frame (resolution beat 6).
- **Sequencing:** authored as a scene `AnimationPlayer` timeline the controller scrubs/freezes/resumes — the freeze must hold the `hesitate` pose; the resolution must play `place → turn → exit`.
- **Emotional contribution:** the traveler is the *why*. Their hesitation makes the missing second a choice; their leaving the photograph is the tenderness payoff. A sliding sprite cannot carry this — this is why the prior build failed the brief.
- **Tech:** LOD0 ≤ ~12 k tris, LOD1 ≤ ~5 k; humanoid rig; cloth via vertex animation or simple bones (no heavy cloth sim on mobile); baked AO.

### 4.3 Suitcase (P1)

- Practical, slightly worn case, visible handle, beside traveler. Connects movement to departure. ~1 k tris, PBR (leather/fabric + metal clasps). Wrong-examination target → "The traveler has not yet decided to leave."

### 4.4 Tea cup + steam (P2, P3) — temporal-comparison anchor

- **Cup:** ceramic cup + saucer on bench/table, foreground. ~0.8 k tris, PBR ceramic with subtle warm tint.
- **Steam (P3, KEEP-PORT):** `GPUParticles3D`, one gentle rising curl. Behavior preserved from 072B §3 / existing `MissingSecondProps`: rises continuously in observation, **freezes** to an identifiable curl on reconstruction (`emitting = false` + freeze particle local motion), **resumes + fades** on resolution.
- **Emotional contribution:** steam is the player's intuitive clock — "the tea is still cooling where the room left it." It makes the clock's ahead-ness *felt*, not just seen.

### 4.5 Photograph (P4) — the meaning of the missing second

- Small folded photograph on bench edge. **Two material states:** normal (peripheral, no special light) → revealed-warm (subtle emissive + the reveal spot-light, 072B §1 lighting).
- **Emotional contribution:** this is the answer to "why it mattered." It must be present-but-overlookable during observation and *warmly revealed* at resolution. The whole experience resolves onto this object.

### 4.6 Platform sweep light (L2) — shared room-time anchor (KEEP-PORT)

- A warm (sodium-amber) SpotLight parented to a slow-moving rig, sweeping diagonally across floor → bench → traveler → clock face. Behavior preserved: slow single sweep in observation, **frozen mid-sweep** on reconstruction, **completes** on resolution. As it passes the clock it triggers the clock edge-graze readability beat.

### 4.7 Environment (E1–E5)

- Real railway waiting-room architecture: back wall with the window-to-platform opening, side walls, worn floor, wooden bench, wainscoting/tile, a door, a poster frame, a radiator/pipes — enough secondary detail to read as *a place that has held many goodbyes*, not a set. Static shell → **baked GI/lightmaps**. Departure board is a distant shape with **no readable exposition text** (072B).

### 4.8 Audio (A1–A6) — carry 072B §6, add 3D positioning

- Existing assets reused where present (station tone, tick, resolution chord — verified real-signal in 073C §6). Add reconstruction hold cue, aligned-tick confirmation, platform/rail movement.
- Position room tone + tick in 3D (clock tick from the clock node) for spatial believability.
- Discovery = tick dropout then aligned return; resolution = small warm harmonic shift, **no victory fanfare**. **No Iris voice/instruction inside the memory** (072B §6 rule preserved).

---

## 5. Animation behavior — the full beat-sheet (ported to 3D)

**Observation — ~2.0 s total (timing preserved from 072B §3.1):**

| t | Action (3D) |
|---:|---|
| 0.0 | Room already alive; traveler `idle_breathe`; station tone + tick audible |
| 0.2 | Platform sweep begins crossing the room |
| 0.5 | Traveler `reach_to_suitcase`; tea steam rising |
| 0.9 | Clock second hand advances |
| 1.0 | **Clock advances one extra second** while sweep/steam/traveler stay on prior rhythm → the missing second |
| 1.3 | Traveler `hesitate` — has not completed the motion the clock implies |
| 2.0 | Observation ends → reconstruction |

**Reconstruction (~0.55 s + held):** sweep **frozen mid-sweep**; steam **frozen** at an identifiable curl; traveler **frozen in `hesitate`**; ambient **thins** (not cuts); clock **remains ahead**; room still, not dead. Prompt: *"What moved ahead of the room?"*

**Investigation (open-ended):** tea/suitcase/photograph/clock become examinable via 3D pick (§6). Wrong objects → subtle localized light pulse + contextual line, no penalty. Photograph examinable but does **not** reveal truth alone.

**Discovery → Resolution (~3.0 s, 7 beats per 072B §3.2):**
1. Room sound thins to near-silence; clock holds attention.
2. Second hand eases back into alignment (lerp).
3. Platform sweep completes its existing arc.
4. Tea steam resumes.
5. Traveler `place_photograph` → sets photograph on bench (P4 → revealed-warm).
6. Traveler `turn_to_platform` + `exit_walk` → leaves frame.
7. Room holds a quiet beat → truth text lands → RETURN TO IRIS appears.

No confetti, flash, score pop, particle burst, or generic completion animation.

---

## 6. Interaction in 3D — and how it fixes the 073C fatal bug

The 073C audit proved the clock was unclickable because a full-rect 2D `InvestigationLayer` intercepted the touch before it reached the clock node, and the automated test hid this by emitting `pressed` directly.

**In 3D this is rebuilt correctly and inherently avoids that class of bug:**
- Tap (screen) → `Camera3D` projects a ray → picks the nearest `Area3D` examination volume among Clock/Tea/Suitcase/Photograph. Each volume is attached to its **own** 3D object, so there is no sibling-layer interception.
- Affordance is **scene-native**: a subtle rim-light / emissive pulse on the picked mesh + optional focus ring. No floating labels, no answer list, no "find the clock" copy (072B §4).
- **Mandatory test (T3):** a real-input integration test that sends an actual pointer event through the camera-ray pick and asserts the clock tap changes scene state. **No `pressed.emit()` shortcuts.** This single requirement closes the false-confidence gap that shipped the broken clock.

---

## 7. Retention audit (per Mission 073D "audit what can be retained")

**Retain (keep as-is):**
- Iris portal transition (X1), Application entry/exit flow (X2), the four text lines + RETURN TO IRIS (UI1), the audio consumer/haptic/accessibility transport (072C §3), `WitnessProfile`/`Store` (unchanged), splash images (boot, not the memory).

**Retain-and-port (keep the logic, rebuild as 3D):**
- Missing-second mechanic math (M1) → apply to the 3D second-hand pivot.
- Scene state machine + timing beats (M2) → same enum, same durations, 3D-driven.
- Steam freeze/resume behavior (P3) → `GPUParticles3D` with same freeze/resume semantics.
- Platform sweep freeze/complete behavior (L2) → moving light rig with same freeze/complete semantics.

**Do not retain (discard the 2D asset/build, replace with 3D):**
- `waiting_room_background.png` (single flat image — the core 073D/073E complaint).
- `traveler_layer*.png` (slide-only sprite — cannot carry human action).
- `MissingSecondClock._draw` procedural 2D dial (unreadable as a clock).
- `MissingSecondProps._draw` procedural tea/suitcase/photograph rectangles (placeholders).
- The Control-based 2D scene structure and the `InvestigationLayer` input model (rebuild as Node3D + Area3D pick).

**Do not reintroduce (072C §3 boundaries):** `WitnessArchive`, retired portal/moment infrastructure, generic moment/phase/story/pipeline systems.

---

## 8. Production path recommendation (flagged in §0 for confirm)

**Recommended: artist-primary.** A human 3D artist (Blender → glTF/FBX) authors all HERO assets (room shell, bench, clock, traveler, props) and the lighting/grade; AI text-to-3D and asset-store assets are permitted **only** for secondary dressing (E4/E5) and **only** under the art director's pass, never as final hero art. Reasoning: the prior mission's core critique was a *generated/placeholder look*, and stylized-cinematic humans (the traveler) are the precise failure mode of AI 3D. The spec is **tool-agnostic at the deliverable-format level** (glTF 2.0, PBR — BaseColor/Normal/ORM/Roughness/Emissive, baked lightmaps for static shell, LOD0/LOD1) so it holds under any chosen path.

**Quality gates (per asset):** silhouette read → unlit gray-shader read → lit/PBR read → in-scene-at-portrait-size read → emotional-read review against 072B §1 tone. An asset that cannot pass the portrait-mobile-readability gate is not final.

**Explicitly prohibited (per Mission 073D):** generating generic replacements; shipping primitives/placeholders as final; treating AI output as finished without art-direction pass; optimizing any of this for reuse.

---

## 9. Technical foundation requirements (must be true before art lands)

1. **Renderer switch:** `project.godot` → `forward_plus` (desktop) / `mobile` (Android). Current `gl_compatibility` cannot deliver §2.3 lighting. (Scoped project-config change, not gameplay code.)
2. **Scene rebuild:** `MissingSecondExperience.tscn` rebuilt as Node3D per §2.1; the bespoke controller (072C §2 boundaries) preserved.
3. **Performance budget (Mobile):** ≤ ~150 k visible tris; ≤ 2 dynamic shadow casters; baked GI on static shell; LOD0/LOD1 on hero meshes; stable 60 Hz on mid-range Android.
4. **Real-input test (T3):** mandatory before any "playable" claim; closes the 073C gap.
5. **Portrait validation:** every gate reviewed at 540×960 portrait on a real mobile-sized viewport (072B §7 / 072C §6), not headless.

---

## 10. Approval gate

Implementation/art production may begin only when these are accepted:

- [ ] Stylized-cinematic-3D medium lock (073E) and this spec's translation of 072B/072C are accepted.
- [ ] Renderer change to Forward+/Mobile is accepted.
- [ ] Asset list (§3) and per-asset specs (§4) accepted.
- [ ] Animation beat-sheet (§5) accepted.
- [ ] 3D examination model + mandatory real-input test (§6, T3) accepted.
- [ ] Retention audit (§7) accepted.
- [ ] Production path + quality gates (§8) accepted (and the two §0 confirms answered).
- [ ] Reference moodboard (§1.2) commissioned and approved before modeling.

**Acceptance statement (carried from 072B §9, re-grounded in 3D):**
> *"The Missing Second will be built as one true 3D stylized-cinematic memory — a living waiting room the player enters through Iris, where they discover a temporal mismatch by observation and scene-native examination, and understand the human choice that made the missing second matter."*

**First implementation review must use graphical runtime capture (not headless) at:** memory formation · mid-observation · reconstruction · wrong-object examination · clock discovery (with a **real tap**) · resolution · return to Iris. (072B §9 / 072C §6, reinforced.)

---

## 11. What this mission does **not** do

- No code, scene, asset, or renderer change is made by this document. It is the approval-gate spec only.
- No AI art is generated unprompted (per Mission 073D). On request and approval, the immediate next step I can take is producing a small set of **locked style-frame references** (environment / clock / traveler / props / lighting / memory-grade) to make §1 concrete before commissioning — these would be *direction references*, clearly labeled, not final assets.
- No reusable pipeline, framework, or content system is specified (072C §2 / Mission 073E: build one exceptional memory; do not optimize for reuse).

---

*Prepared as the Mission 073D asset approval-gate deliverable, locked to the Mission 073E Stylized Cinematic 3D direction, carrying forward all approved 072B/072C creative direction. Awaiting approval before any implementation or production.*
