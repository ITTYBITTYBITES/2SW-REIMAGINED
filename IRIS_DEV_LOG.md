# IRIS_DEV_LOG.md

## Mission 054A — Living Iris Awakening Ritual

Date: 2026-07-18  
Scope: first authored Living Iris presence milestone after Mission 053C production audio foundation.

### Objective

Make the first 30–60 seconds of the prototype feel like the artifact noticed the player.

This pass does **not** add Witness Moments, menus, chapters, or navigation complexity. It extends existing Living Iris rendering, Iris state, audio, haptic, personality, and application flow into an authored awakening experience.

---

## DONE

### 1. Controlled Iris wake sequence

Startup now preserves the existing `StartupFlow` splash architecture, then enters an authored Living Iris ritual:

```text
Application launch
  ↓
StartupFlow splash
  ↓
Iris screen enters dark/quiet state
  ↓
Iris breath ambience begins
  ↓
Iris calibration lifecycle starts
  ↓
Awakening sound + blink/opening animation
  ↓
Transition cue
  ↓
Welcome dialogue
  ↓
Ready dialogue
  ↓
AWARE state / first interaction prompt
```

Implemented in `IrisController.begin_awakening_ritual()` and `_update_awakening_ritual()`.

Key authored timing details:

- initial dark veil prevents instant appearance
- ambience enters before the Iris becomes visible
- the existing `IrisCore` lifecycle still owns state transitions and animation
- labels fade in only after the artifact has visibly awakened
- low haptic pulses mark awakening and ready beats

### 2. Iris attention behavior

Extended `IrisCore` without replacing it.

Added first-pass simulated awareness behavior:

- idle gaze drift remains procedural
- small saccadic gaze movements are slightly more perceptible in `WELCOMING`, `AWARE`, `SETTLED`, and `REFLECTIVE`
- occasional focus changes pulse the Iris subtly without real tracking
- player tap still transitions through `ATTENDING` / `FOCUSED`
- player interaction now gets a soft Iris attention sound and light haptic acknowledgment

No real eye tracking was added.

### 3. Event-driven dialogue foundation

Created data-driven dialogue content:

- `the_iris/content/iris/iris_dialogue_events.json`

Created registry:

- `the_iris/scripts/iris/IrisDialogueRegistry.gd`

Added authored events:

| Event | Text |
|---|---|
| `iris_welcome` | “I remember your perspective.” |
| `iris_idle` | “I am still here.” |
| `iris_ready` | “A memory is waiting.” |
| `iris_return` | “You came back with more of the pattern.” |

The registry stores:

- display text
- accessibility text
- expression mode
- audio hook
- haptic hook
- placeholder voice key

`IrisPersonalityResolver` now checks this registry before falling back to older expression-mode defaults.

### 4. Audio integration

No new audio assets were created.

Mission 053C assets are now used for the ritual:

| Ritual/event role | Asset |
|---|---|
| wake ambience | `res://assets/audio/iris/iris_breath_loop.ogg` |
| Iris activation | `res://assets/audio/iris/iris_awaken.ogg` |
| transition cue | `res://assets/audio/iris/iris_transition.ogg` |
| welcome/focus cue | `res://assets/audio/iris/iris_focus.ogg` |
| ready cue | `res://assets/audio/iris/iris_confirm.ogg` |
| return/idle presence | `res://assets/audio/iris/iris_presence.ogg` |
| interaction attention | `res://assets/audio/iris/iris_attention.ogg` |

### 5. Haptic integration

Added low-intensity haptic hooks for:

- Iris welcome pulse
- Iris idle/breath presence
- Iris ready pulse
- Iris return acknowledgment
- player interaction acknowledgment

All new authored haptic events use `IrisHapticConsumer.Pattern.LIGHT` or direct short light pulses. No heavy rumble was added to the startup ritual.

### 6. Automated validation

Created:

- `the_iris/tests/iris_awakening_validation.gd`

Validation coverage:

- dialogue JSON exists
- required events are registered
- dialogue text exists
- dialogue audio references resolve to existing Iris audio assets
- `IrisController` exposes ritual API
- `IrisCore` exposes simulated attention behavior
- low-intensity haptic hooks exist

---

## Files changed for Mission 054A

Primary 054A files:

- `IRIS_DEV_LOG.md`
- `the_iris/content/iris/iris_dialogue_events.json`
- `the_iris/scripts/iris/IrisDialogueRegistry.gd`
- `the_iris/scripts/iris/IrisController.gd`
- `the_iris/scripts/iris/IrisCore.gd`
- `the_iris/scripts/iris/IrisPersonalityResolver.gd`
- `the_iris/scripts/iris/IrisExpressionOverlay.gd`
- `the_iris/scripts/iris/IrisAccessibilityConsumer.gd`
- `the_iris/scripts/iris/IrisAudioConsumer.gd`
- `the_iris/scripts/iris/IrisHapticConsumer.gd`
- `the_iris/scripts/Application.gd`
- `the_iris/tests/iris_awakening_validation.gd`

Mission 053C audio foundation files are also present in this working branch because 054A builds directly on them.

---

## Current limitations

1. **No real eye tracking.**  
   Awareness is simulated through procedural gaze/saccade/focus behavior.

2. **No final voice assets.**  
   Voice hooks exist as placeholder `voice_placeholder_*` keys. Dialogue currently appears as text and uses existing Iris audio cues.

3. **No video or screenshot captured.**  
   This sandbox does not provide a Godot visual runtime capture path.

4. **Godot CLI validation not run in this sandbox.**  
   `godot` / `godot4` is not installed here. Static validation was performed where practical.

5. **The ritual is first-pass authored timing.**  
   It should be tuned with actual device playback and human feel review.

6. **Not the full Signature Loop.**  
   Spatial Hub and portal transition work are intentionally deferred to later missions.

---

## Validation notes

Static checks performed:

- `git diff --check`
- audio reference existence scan
- dialogue JSON/audio reference scan
- script reference scan

Godot command to run when available:

```bash
godot --headless -s tests/iris_awakening_validation.gd
```

---

## Mission status

DONE:

- Iris no longer instantly appears after splash
- first authored wake ritual exists
- Iris starts in dark/quiet state
- breath ambience begins before visible emergence
- activation / transition / ready cues are connected
- welcome and ready text hooks are data-driven
- light haptics are connected
- simulated attention makes the Iris feel more observant

REMAINING:

- tune timings with real Godot playback
- validate on Android device
- add real voice assets later if desired
- build 054B Spatial Hub separately
- build 054C Portal Transition separately
