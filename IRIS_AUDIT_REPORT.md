# IRIS_AUDIT_REPORT.md

**Mission:** MASTER PRODUCTION PROTOCOL — LIVING IRIS 4.0
**Phase executed:** STEP 1 — Pre-Implementation Reality Audit (only)
**Scope:** Read the actual Iris system and map every protocol request against what exists. **No code changes.**
**Build audited:** `2SW-src` @ `7cd98b0` (current `main`)
**Engine:** Godot 4.6.stable

---

## 0. TL;DR — the headline finding (please read first)

**The protocol's premise does not match the codebase.** The Master Production Protocol repeatedly describes the Iris as a "flat, robotic UI," a "2D sticker," with "static lines" — and instructs me to "overhaul" it into a "Sentient Perception Instrument."

**That instrument already exists.** The current Living Iris is a sophisticated, multi-layered, procedural, biologically-behaving perception instrument — not a flat sticker. Concretely, it already has (all verified in source):

- **Biological shutters (eyelids):** `IrisCore` already runs `blink_in`, `blink_elapsed`, `blink_amount` and applies an openness transform to the whole aperture on every blink (see "blink() and squint()" below — the mechanism exists; only the *named* `blink()`/`squint()` API does not).
- **Living fibers (not "static lines"):** `LivingIris._draw_fibers` draws up to **56 procedural fibers**, each with organic bending, motion, brightness modulation, and per-fiber seeded variation — they undulate continuously.
- **Saccadic gaze:** `IrisCore._update_gaze` and `_update_simulated_attention` already implement snap-flick saccades with jittered targets and lerp-follow (the "snap-flicks" the protocol asks for).
- **Concave depth + aura + limbal ring:** the aura (6 rings), the dark recessed inner ring (`radius * 0.908`), the rim, and an evolution-driven flare layer already produce depth. A gyro-parallax depth layer is the one genuinely *missing* piece.
- **An 11-state sentient lifecycle:** DORMANT → CALIBRATING → STIRRING → AWAKENING → WELCOMING → AWARE → ATTENDING → FOCUSED → OBSERVING → SETTLED → REFLECTIVE, each with its own pupil/glow/fiber/focus/breath/saccade profile.
- **A full sensory nervous system:** audio (ambient loop + one-shots), haptics (6 patterns), accessibility (TTS/caption hooks), all driven by a derived `IrisResponseIntent` from `IrisPersonalityResolver`.
- **A voice infrastructure** — but **no actual voice synthesis.** The protocol's "Iris Voice" (multi-layered Whisper + Hum speaking full lines) is the largest *real* gap.

**Therefore the correct execution of this protocol is NOT a visual overhaul. It is a set of targeted upgrades inside the existing, well-architected system.** Executing it as a "replace the flat sticker" overhaul would destroy working, tested infrastructure (the "Functional Layer" the protocol itself says to protect) and produce a worse result.

This audit delivers exactly what STEP 1 asked for: the exact node that owns the Visual Iris, where navigation signals connect, and a non-destructive plan to achieve every protocol goal.

---

## 1. The exact node that owns the "Visual Iris"

**Visual Iris owner:** `LivingIris` (`extends Control`, `class_name LivingIris`, file `scripts/iris/LivingIris.gd`).

- Instantiated by `IrisController._ready()` as `living_iris = LivingIris.new()`, named `"LivingIris"`, added as a child of `IrisController`.
- It is the **sole renderer** (its own doc comment: "The sole Iris renderer").
- It renders via `_draw()` using procedural 2D primitives (`draw_circle`, `draw_arc`, `draw_line`, `draw_colored_polygon`, `draw_set_transform`) — **no TextureRect, no sprite, no static image.**
- It pulls a `behavior` Dictionary from `IrisCore.tick(delta)` each frame and redraws. It owns no state of its own beyond `elapsed` and `portal_dilation`.
- Its sibling is `IrisExpressionOverlay` (also under `IrisController`), which draws expression-mode arcs/text on top.

**Behavior authority:** `IrisCore` (`extends Node`, `class_name IrisCore`, file `scripts/iris/IrisCore.gd`) — the single source of truth for state, gaze, blink, pupil, glow, presence, fiber params, saccades, pulses. `LivingIris` never mutates Iris state; it only reads it.

**Scene/screen owner:** `IrisController` (`extends Control`, file `scripts/iris/IrisController.gd`) — owns the screen: background `ColorRect`, the `LivingIris`, `IrisExpressionOverlay`, brand/state/invitation/navigation labels, the ritual veil, the awakening ritual timeline, input handling, and the `home_requested` navigation signal.

**Tree (runtime, as assembled by `IrisController._ready`):**
```
IrisController (Control)                      ← screen owner, input, ritual, labels
├── background (ColorRect #030a0d)
├── IrisCore (Node)                           ← behavior authority (state machine)
├── LivingIris (Control)                      ← THE VISUAL IRIS (procedural _draw)
├── IrisExpressionOverlay (Control)           ← expression arcs + message text
├── brand_label / state_label / invitation / navigation_label (Label)
└── ritual_veil (ColorRect)
```

---

## 2. Where navigation signals are connected (the protected boundary)

Navigation is **not** owned by the Iris visual system. The connection points, all in `scripts/Application.gd`, are:

| Signal | Emitted by | Connected in | Effect |
|---|---|---|---|
| `iris.home_requested` | `IrisController` (after the 0.56 s attention hold following a tap) | `Application._ready`: `iris.home_requested.connect(start_experience_one)` | Launches Experience One through the Iris portal → Diorama Engine |
| `iris_portal.entry_arrived` | `IrisPortalTransition` | `Application._ready`: → `_on_portal_entry_arrived` | Hands off to the Diorama Engine |
| `iris_portal.return_arrived` | `IrisPortalTransition` | `Application._ready`: → `_return_to_iris_presence` | Returns to the settled Iris |
| `startup.finished` | `StartupFlow` | → `_on_startup_finished` → `show_iris(true)` | Begins the awakening ritual |
| `iris_core.state_changed` | `IrisCore` | `IrisController._ready`: → `_on_state_changed` | Updates labels only (no navigation) |

**Protected systems (per protocol §II) — confirmed intact and untouched by any visual change:**
- **Navigation Authority:** `Application.gd` state routing (boot → iris → portal → diorama → return). *No Iris script owns navigation.*
- **Incident Registry / Witness Archive:** `WitnessArchive` is an empty boundary (`is_ready()` returns false); no active content. Untouched.
- **Progression Service:** `WitnessProfile`/`WitnessProfileStore` carry identity only (name, created_at, preferences). `IrisEvolutionProfile` carries `visual_signature` + `presence_intensity` only — *visual*, not gameplay progression. Untouched.
- **Witness Runtime:** `DioramaEngine` + Experience One JSON. Completely separate subsystem from the Iris. Untouched.

**Critical safety fact:** the Iris visual system (`LivingIris`, `IrisCore`, `IrisController`, the consumers) communicates with the rest of the app through **exactly one navigation signal** (`IrisController.home_requested`) and a small set of controller entry methods called by Application (`begin_awakening_ritual`, `welcome`, `settle`, `reflect`, `set_home_environment`, `set_gameplay_environment`, `dormant`). As long as those contract surfaces are preserved, the visuals can change arbitrarily without breaking navigation. This is the contract the protocol must respect.

---

## 3. What the protocol asks for vs. what already exists

| Protocol request (§) | Already exists? | Evidence | What's actually needed |
|---|---|---|---|
| Biological shutters / eyelids; `blink()`, `squint()` (III.1) | **Partly.** Blink is fully implemented as a whole-aperture openness transform driven by `IrisCore.blink_amount` (0–1 sine pulse). Squint is not implemented. | `IrisCore._update_blink`, `LivingIris._draw` `openness = 1.0 - blink * 0.70`, state-aware blink cadence | Add a named `blink()`/`squint()` API on IrisCore (thin wrapper over existing mechanism) + optional separate eyelid crescent nodes for a more literal shutter look. **Enhancement, not replacement.** |
| Stroma shader; fibers undulate toward pupil (III.2) | **Yes — as procedural draws, not a shader.** Up to 56 fibers, each with organic multi-harmonic bending, motion, brightness; they already undulate continuously. | `LivingIris._draw_fibers` | Optional upgrade: port the procedural fibers to a real `ShaderMaterial` (Simplex-noise fragment shader) for higher fidelity and GPU efficiency. The *behavior* already meets the spec. |
| Concave depth; parallax; gyro (III.3) | **Partly.** Concave depth is faked convincingly via aura rings + recessed inner ring + evolution flare. **No parallax/gyro.** | `LivingIris._draw_aura`, `_draw_iris_body`, `depth_offset`/`geometry_scale` hooks | The one genuinely missing visual: a parallax depth system reacting to device tilt (`Input.get_gravity()` / accelerometer). Can layer-ify the existing draw passes. |
| Limbal ring (soft dark outer blend) (III.4) | **Yes.** Rim arcs + aura falloff already blend the eye into the void. | `LivingIris._draw_iris_body` rim loop, `_draw_aura` | Already satisfied; can be deepened cosmetically. |
| Saccadic gaze / snap-flicks to targets (IV.1) | **Yes.** Saccades with jittered targets + lerp-follow, plus state-driven "simulated attention" saccades. | `IrisCore._update_gaze`, `_update_simulated_attention` | *Targeted* saccades (flick to specific UI cards/touch points) not yet wired — currently saccades are ambient. Add an API to aim saccades at named targets. |
| Iris Voice — Whisper + Hum, speaks lines (IV.2) | **No — the largest real gap.** There is a `voice_key` field threaded through `IrisResponseIntent`/`IrisPersonalityResolver`/`IrisDialogueRegistry`, but **nothing synthesizes or plays voice audio.** | `IrisResponseIntent.voice_key`, `IrisDialogueRegistry.voice_for_event` (returns placeholder strings like `voice_placeholder_iris_welcome`) | Build a real `VoiceManager`: layered (whisper + hum) voice playback, ideally TTS or pre-rendered layered stems, triggered from the existing `voice_key` contract. |
| Contextual awareness — idle/selection/success lines (IV.3) | **Partly.** State → expression_mode → text resolution pipeline exists (`IrisPersonalityResolver` → `IrisExpressionOverlay` message + `IrisAccessibilityConsumer` TTS). The *examples* quoted ("A wise choice…", "You see what others overlook…") are not authored. | `IrisPersonalityResolver._resolve_mode`, `IrisExpressionOverlay._message_for`, `content/iris/iris_dialogue_events.json` | Author the contextual lines in `iris_dialogue_events.json` and add events for selection/success. The pipeline already delivers them. |
| Ambient breath drone, pitch-shift on focus (V.1) | **Partly.** `iris_breath_loop.ogg` plays as the ambient loop. **No pitch-shift on focus.** | `IrisAudioConsumer.play_ambient_loop` | Add a continuous-pitch parameter to the ambient player tied to `IrisCore.focus_amount`. |
| Saccadic clicks (crystalline pings on flick) (V.2) | **No.** Saccades are silent. | `IrisCore._update_gaze` emits nothing | Wire a one-shot crystalline cue into the saccade trigger. |
| Tactile synesthesia — haptic on every voice/saccade (V.3) | **Partly.** Haptics fire on presence events and interactions. **Not on saccades or voice (no voice yet).** | `IrisHapticConsumer` (6 patterns) | Trigger a LIGHT haptic on saccadic snap and on voice pulse once voice exists. |

**Net assessment:** of ~10 distinct requests, **~4 are already fully met**, **~4 are partly met and need targeted additions**, and **2 are genuinely missing** (gyro parallax, and — the big one — a real Iris Voice). This is an **evolution**, exactly as the protocol's subtitle ("Non-Destructive Evolution") says — not the "overhaul from flat sticker" the body text assumes.

---

## 4. Plan: how to achieve every protocol goal without breaking the Functional Layer

Guiding principle (from protocol §II and the existing architecture): **the Iris is already split into Authority (`IrisCore`) and View (`LivingIris` + `IrisExpressionOverlay`) and Services (the Consumers).** Every upgrade below is fitted to that split. None touches `Application.gd` routing, `DioramaEngine`, Experience One, `WitnessProfile`/`Store`, or `WitnessArchive`.

**Layer contract that MUST be preserved (the "no-break" surface):**
- `IrisController` keeps its public methods: `begin_awakening_ritual()`, `welcome()`, `settle()`, `reflect()`, `observe()`, `dormant()`, `calibrate()`, `set_home_environment(bool)`, `set_gameplay_environment(bool)`, `present_response_intent(intent)`, and the `home_requested` signal.
- `IrisCore` keeps `transition_to(state)`, `acquire_attention(vec2)`, `tick(delta) → Dictionary`, the `State` enum, and `state_changed`.
- `LivingIris.set_core(core)` and its read-only consumption of the behavior dict.
- `IrisResponseIntent` field set (`expression_mode`, `*_key`, `source_event`, `core_state`).

### STEP 2 (Behavioral Core) — additive API on IrisCore, zero visual breakage
1. Add `func blink(force := false)` and `func squint(amount := 0.5)` to `IrisCore` as thin wrappers that drive the existing `blink_amount`/`openness` path (and a new `squint_amount` field). State machine may call them; they do not change `State`.
2. Add `func saccade_to(target: Vector2, snap := true)` to aim saccades at named screen targets (UI cards, touch points). Reuses `_update_gaze` machinery; emits a new `saccade_occurred` signal for audio/haptic sync.
3. **Do not** change the `tick()` return contract — `LivingIris` and the consumers keep reading the same dict.

### STEP 3 (Visual & Shader) — View-only, inside LivingIris
4. **Stroma shader (optional fidelity upgrade):** create a `ShaderMaterial` for the iris body that replicates the existing fiber/aura look using Simplex noise in fragment space, driven by the same `behavior` uniforms. Keep the procedural `_draw` as the fallback (important: GL Compatibility renderer + mobile must be validated — shaders must compile on the Android target, not just desktop). *Risk note: a full shader rewrite is the highest-risk item for breaking the look across devices; do it last, behind a fallback.*
5. **Gyro-parallax depth:** add an `IrisParallax` helper that samples `Input.get_gravity()` (or `InputEventMouseMotion` on desktop) and feeds a small `parallax_offset` into `LivingIris._draw` so the layers (cornea/stroma/pupil) shift against each other. This is the single clearest "4-layer concave" win and is purely additive.
6. **Eyelid crescents (optional):** if a more literal shutter look is wanted, add two `IrisShutter` nodes (teal crescents) above/below, driven by `blink_amount`/`squint_amount`. Cosmetic; the existing whole-aperture blink already works.
7. Deepen the limbal ring and aura falloff cosmetically (constants only).

### STEP 4 (Voice & Audio) — new service, fills the largest gap
8. **`IrisVoiceManager` (new):** a layered voice player (whisper stem + hum stem) that consumes `intent.voice_key`. Two viable paths: (a) pre-rendered layered `.ogg` stems per line (highest quality, most control), or (b) on-device TTS with a pitched hum bed (no asset burden). Recommend (a) for production. Triggered from `IrisController.present_response_intent` alongside the existing consumers — **no change to the intent contract.**
9. **Saccadic clicks:** wire `IrisCore.saccade_occurred` → `IrisAudioConsumer.play_manifest_sound("saccade_click")` (new short asset). Throttle to avoid spam.
10. **Ambient pitch-shift:** give the ambient-loop player a `pitch_scale` driven each frame by `IrisCore.focus_amount` (subtle, e.g. 0.96–1.04).
11. **Tactile synesthesia:** on `saccade_occurred` and on each voice pulse, fire `IrisHapticConsumer.Pattern.LIGHT`. The haptic system already exists.
12. **Contextual lines:** author idle/selection/success events in `content/iris/iris_dialogue_events.json` and emit the matching events from `Application`/`DioramaEngine` at those moments. The delivery pipeline (PersonalityResolver → ExpressionOverlay + AccessibilityConsumer) already works.

### Verification (protocol §VII, the Mirror Test) — how we prove non-destruction
- **Functionality preserved:** the existing 4 automated tests (`iris_awakening_validation` 42/0, `experience_one_launch_validation`, `platform_reset_validation`, `spatial_hub_validation`) must remain green unchanged, and the real-runtime Iris → Experience One → return flow must still work. These are the regression net.
- **Sentience achieved:** capture Iris frames across states (calibrating → awakening → aware → attending → reflective) before and after; demonstrate saccade-to-target, blink/squint, voice on events, parallax on tilt.
- **Artifact proof:** logs of `IrisCore.state_changed` transitions and `saccade_occurred`/voice events, captured from a real runtime.

---

## 5. Risks & open questions for the protocol author

1. **Premise mismatch (most important).** The protocol is written as if it is rescuing a flat sticker. Acting on that premise literally (rip out the Iris, replace with a 4-layer system) would delete a working, tested, multi-layered instrument and violate the protocol's own "do not break the Functional Layer" rule. This audit reframes each request as a targeted upgrade. **I recommend the author re-scope §III from "overhaul" to "upgrade in place."**
2. **Shader/device risk.** A Simplex-noise fragment shader for the stroma must be validated on the actual Android GL Compatibility target, not just desktop llvmpipe. Recommend keeping the proven procedural `_draw` as a fallback. (The recent clock-visibility bug — meshes dropped by the GL-compat renderer at distance — is a cautionary precedent.)
3. **Voice is the biggest new subsystem and the biggest new asset ask.** Pre-rendered layered stems per line = real audio production work. TTS = no assets but lower quality and platform-dependent. **Decision needed:** stems vs TTS vs hybrid.
4. **`IrisEvolutionProfile` is currently near-empty** (`visual_signature = "baseline"`, `presence_intensity = 1.0`). The protocol's "4-layer concave entity" could naturally live as evolution tiers — but that flirts with the "progression" boundary the protocol says to protect. Recommend treating evolution as a future, out-of-scope-for-now item.
5. **The Iris is currently 2D-procedural, not 3D.** Given the just-completed 073G work moved *experiences* to true 3D (Diorama Engine), a reasonable question is whether the Iris itself should become a 3D entity. That would be a far larger change than this protocol describes and would touch the Iris at a foundational level. **Recommend keeping the Iris 2D-procedural for this protocol** (it already reads as deep/sentient) unless a 3D Iris is explicitly approved.

---

## 6. Audit artifacts

- This report: `IRIS_AUDIT_REPORT.md`
- Dev log initialized: `IRIS_DEV_LOG.md`
- Runtime captures of the *current* Iris (baseline for before/after): `iris_audit_shots/iris_awakening.png` (Iris still emerging), `iris_audit_shots/iris_aware.png` (fully present — 13,852 teal iris pixels).

---

## 7. Status

**STEP 1 complete. No code changes made.** Awaiting approval of (a) the reframing in §0/§5.1 (targeted upgrade, not overhaul) and (b) the voice decision in §5.3 before proceeding to STEP 2.
