# The Iris — Phase 3 UX Stress Test

## Scope

This is a heuristic first-time-user evaluation of the current prototype, not an observed usability study. It evaluates the interaction contract implied by the implementation as if the evaluator had received no explanation from the design team.

The test question is:

> Would an average user understand what to touch, what will happen, how to explore, and how to return within 30 seconds without verbal instruction?

## Executive verdict

**Partially, but not reliably.**

A cold user will probably understand that the central pupil is interactive, especially if the first-launch animation is present. They may tap it within 30 seconds. They are unlikely to reliably discover the four directional destinations without either watching the onboarding animation or receiving a stronger cue. The interface currently teaches the model once, but does not yet make the model self-evident after the teaching disappears.

The strongest risk is not lack of polish. It is an incomplete interaction contract:

- **Tap center** is reasonably legible.
- **Swipe** is discoverable only if the user notices the rim cues or sees the first-launch lesson.
- **Hold** is taught as Focus, but currently opens the same Witness experience as a tap, so its meaning is ambiguous.
- **Back** is technically correct and visually supported inside destinations, but its role is not continuously visible from the Iris.
- **Where am I?** is clear inside named destinations, but the return-to-anchor model is learned only after the first transition.

## Severity scale

- **Critical:** likely to cause abandonment, incorrect mental model, or inability to proceed.
- **High:** likely to block discovery for a meaningful portion of first-time users.
- **Medium:** causes hesitation or confusion but recovery is likely.
- **Low:** friction or polish issue that does not block the core thesis.

## Highest-priority findings

### 1. Directional navigation is too easy to miss — High

**What happens:** The persistent text arrows were removed and replaced with subtle rim lights. The rim lights are elegant, but a first-time user may read them as decoration, reflection, or shader detail rather than four destinations.

**Why it occurs:** Mobile users do not normally interpret an unlabelled circular glow as a navigation affordance. The visual language is intentionally quiet before the user has learned its grammar.

**Likely behavior:** The user admires the eye, taps the pupil, completes or exits Witness Mode, then stops. They may never try a swipe.

**Least intrusive solution:** Keep the rim indicators, but give them one short, unmistakable discovery moment during the first idle state: a very slight clockwise/left/right/up/down sequential illumination that looks like the eye sampling its surroundings. Do not add arrows or a menu. A single subtle outward response to the first touch could also expose the closest rim cue.

**Validation metric:** At least 4 of 5 cold users attempt a directional gesture or tap a rim cue within 60 seconds without being told.

### 2. “Hold” has no distinct user-facing meaning — High

**What happens:** The first-launch lesson says “HOLD · FOCUS,” but holding the center ultimately enters Witness Mode just like tapping. The hold adds a focus pulse, but there is no clearly different result the user can name.

**Why it occurs:** The gesture vocabulary promises three actions, while the product currently exposes two outcomes: enter and enter-with-a-slightly-different-transition.

**Likely behavior:** Users either tap only, or hold repeatedly waiting for a separate Focus state. Some may interpret the hold as a failed tap or as a requirement to keep holding through the entire Witness experience.

**Least intrusive solution:** Treat hold as a modifier, not a separate destination. Give it a visible but brief consequence before entering: the pupil contracts, the rim quiets, and the Witness view begins in a clearly deeper focus state. The first Witness copy should acknowledge that the user held focus. If that distinction is not important yet, remove “HOLD · FOCUS” from onboarding until it has a testable outcome.

**Validation metric:** After one use, users can describe the difference between tap and hold without prompting.

### 3. The home state does not answer “what else can I do?” — High

**What happens:** Once the first-launch lesson fades, the Iris has no persistent text navigation labels. The eye can be touched, but available destinations are not obvious.

**Why it occurs:** The design correctly avoids dashboard conventions, but it currently relies on users inferring an interaction language from very low-salience motion.

**Least intrusive solution:** Preserve the text-free home, but establish a stable optical grammar: four rim positions, four recurring pulse rhythms, and one short idle demonstration per session or after a long pause. The cue should remain clearly subordinate to the living eye, not become a control strip.

**Validation metric:** In a five-person cold test, no participant should ask “Is this only an animation?” before trying a second action.

### 4. Android edge gestures compete with left/right exploration — High

**What happens:** Left and right swipes are core navigation actions, while Android devices may also reserve edge swipes for system Back or other system gestures.

**Why it occurs:** The prototype treats the entire screen as a gesture surface. A user starting at the physical screen edge may trigger Android navigation instead of Archive or Discover, or may become unsure which gesture should win.

**Least intrusive solution:** Make directional exploration respond from the Iris body and a central gesture band, not only from the extreme screen edges. Leave a small system-safe margin at both edges. Also retain Android Back as the unambiguous exit from any destination.

**Validation metric:** Test on gesture-navigation Android and three-button Android. Record whether users can reach Archive and Discover without accidentally leaving the app.

### 5. The first-launch lesson is doing too much of the explanatory work — Medium/High

**What happens:** The onboarding animation teaches Tap, Swipe, and Hold. After it finishes, the system becomes intentionally silent.

**Why it occurs:** The design assumes a one-time lesson is enough to establish a novel navigation language. It may not be; users forget instructions quickly, especially if the lesson runs before they have a reason to encode them.

**Least intrusive solution:** Let the lesson demonstrate one real response for each gesture rather than only displaying instructional copy. For example: tap causes a small pupil response, swipe causes a rim light to travel, and hold causes a short focus contraction. Keep it under 5–6 seconds and allow immediate interaction.

**Validation metric:** Hide the tutorial for half of test participants. Compare first action, second destination discovery, and return confidence.

## First 30 seconds: likely cold-user journey

### 0–5 seconds: “Can I touch it?”

**Positive:** The centered eye is a strong object affordance. Breathing, reflections, gaze response, and pupil contrast suggest a living focal point.

**Risk:** The visual may also be interpreted as an ambient artwork, biometric scanner, or loading state. If the eye is too calm during the first seconds, some users will wait for an instruction rather than touch it.

**Least intrusive solution:** On first idle, let the reflection orient slightly toward the user’s last touch or let the pupil make one restrained response after a short idle period. Avoid a generic button pulse.

### 5–15 seconds: “What does touching do?”

**Positive:** Center tap enters Witness Mode through a distinctive transition. This strongly supports the thesis once experienced.

**Risk:** The first-launch copy appears away from the pupil and may compete with the eye’s visual center. If a user misses it, there is no obvious confirmation that the tap was intentional until the transition begins.

**Least intrusive solution:** Let the first center touch produce a 150–250 ms pupil acknowledgement before the travel transition. This makes the eye feel responsive even if the user taps slightly outside the intended center.

### 15–30 seconds: “Is there more?”

**Risk:** This is the likely failure point. The directional rim cues are subtle, and the four mappings are not conventional enough to infer immediately. Up = Settings and down = Profile are especially dependent on prior instruction.

**Least intrusive solution:** Keep the four directions but use a low-frequency ambient “sampling” motion that visits each rim location over time. A user should be able to notice that the eye has four meaningful sides without seeing a menu.

## Detailed issue inventory

| Area | Finding | Severity | Least intrusive response |
|---|---|---:|---|
| Center affordance | The pupil is the likely first target, but an ambient eye can be mistaken for non-interactive artwork. | Medium | Give the first touch or near-touch a short optical acknowledgement. |
| Tap vs hold | Both gestures enter Witness Mode; the distinction is not strong enough to form a mental model. | High | Make hold produce a clear focus modifier, or defer teaching hold. |
| Swipe discoverability | Rim lights may be perceived as visual ornament. | High | Use recurring directional sampling motion, not arrows. |
| Direction mapping | Left/Right are plausible; Up = Settings and Down = Profile are not self-evident. | Medium | Use distinct rim signatures and confirm destination names after entry. |
| Gesture threshold | A short exploratory drag under the swipe threshold can appear to do nothing. | Medium | Let the Iris visibly lean during the drag and gently settle if the gesture is cancelled. |
| Gesture conflict | Android system edge gestures can compete with left/right navigation. | High | Avoid requiring edge-originating swipes; reserve a system-safe edge margin. |
| Tap outside center | Current routing can trigger an Iris focus pulse without explaining what changed. | Low | Make the response slightly directional toward the touch, or treat the outer lens as part of the same tap target. |
| Back discoverability | Android users know Back, but the Iris home state does not show that Back exits while destinations do not always keep a persistent return cue. | Medium | Keep native Back; use a small consistent optical return-to-center cue inside experiences. |
| Back expectation | A user may expect Back to reverse the latest directional move or return to the previous destination. | Medium | Maintain the single rule: every destination Back returns to Iris, and reinforce it visually. |
| Where am I? | Destination titles help, but the transition may feel like a full-screen change before the title appears. | Low/Medium | Let one small Iris-derived motif persist into each destination. |
| Return confidence | The reverse transition is beautiful, but users may not know it is available before trying Android Back. | Medium | Add a low-salience center/orbit cue in destinations that suggests return without a conventional button. |
| Archive interaction | Floating memory objects are visually attractive but initially unlabeled. | Medium | Let the nearest object gently orient toward the user after idle, or reveal a tiny label only after focus. |
| Discovery interaction | Glowing points may look like background particles rather than selectable objects. | Medium | Give the selected point a stronger pre-touch response when the finger passes nearby. |
| Profile/Settings distinction | Up/down destinations are less semantically obvious than left/right destinations. | Medium | Use different rim textures: record-like pulse for Profile, calibration-like oscillation for Settings. |
| Tutorial timing | The first-launch sequence may be longer than a user’s patience and can be missed if they tap early. | Medium | Keep it concise, allow interaction immediately, and demonstrate effects rather than only text. |
| Tutorial persistence | `first_launch` is persisted, so repeat testers may not see the explanation. | Medium | Provide a hidden or settings-based “replay interaction guidance” affordance for testing and support. |
| Accessibility | Text-free optical cues and subtle motion exclude users with low vision, motion sensitivity, or limited touch precision. | High | Keep an alternate explicit navigation path in Calibration: larger contrast cues, reduced motion, and labeled directional actions. |
| Screen reader semantics | The core controls are custom-drawn and gesture-based, so assistive technologies may have little to announce. | High | Expose semantic descriptions for center activation, destinations, current state, and return. |
| Haptics | Haptics can confirm transitions, but some users may not feel them and the app gives no alternate confirmation. | Low/Medium | Treat haptics as reinforcement only; pair with visible pupil acknowledgement. |
| Sound | Ambient generator sound may be inaudible, disabled, or undesirable in public. | Low/Medium | Never use sound as the only cue; preserve visual confirmation. |
| Motion sensitivity | Breathing, saccades, blinking, pupil travel, and transitions create continuous motion. | Medium/High | Ensure Reduced Motion disables or shortens nonessential movement, not merely lowers speed. |
| Eye discomfort | A realistic artificial eye may evoke aversion or feel like surveillance to some users. | Low/Medium | Test emotional response separately from usability; preserve a calmer visual calibration mode. |
| Long-term memory | Users may forget the four directions after several days. | Medium | Let the Iris re-demonstrate directional cues after inactivity or when the user pauses at home. |
| System status | The Iris is alive, but users may not know whether it is idle, listening, focusing, or waiting. | Medium | Use distinct but subtle states: idle breath, focus contraction, and a stable completion glow. |
| Failure recovery | If a gesture is missed, there is little explanation of why nothing happened. | Medium | Give a cancelled drag a small return-to-center response instead of silently settling. |
| Onboarding trust | “Living instrument” language is evocative but does not tell users what practical outcome to expect. | Medium | Frame the first Witness transition as “look through the Iris” rather than abstract product language. |

## Accessibility and Android review

### Accessibility concerns

The current concept is strongly visual and gestural. That is acceptable for an experimental instrument, but it cannot be the only path if the prototype is judged as a usable application.

Minimum validation requirements:

1. Can a low-vision user identify the center activation and current destination?
2. Can a user who cannot perform a sustained hold complete the primary flow?
3. Can a motion-sensitive user reduce or disable blinking, saccades, and transitions?
4. Can TalkBack or another screen reader announce the current state and available actions?
5. Can all four destinations be reached without relying on precise directional swipes?

The least disruptive answer is not to add visible buttons to the main Iris. It is to provide an alternate Calibration mode with explicit, high-contrast, semantically labelled controls and reduced motion.

### Android conventions

The prototype correctly treats Back as a navigation command rather than an abrupt scene change. That is a strength. The main Android risks are:

- left/right swipes competing with system edge gestures;
- custom gesture navigation not being discoverable to users accustomed to bottom navigation or tabs;
- haptic feedback being device-dependent;
- users expecting the system Back gesture to work even when an animation is in progress;
- the app exiting from the Iris without a visible indication that it is the root state.

The product should retain native Back behavior and avoid making the user learn a custom replacement for it.

## Recommended validation protocol

Do not explain the interface before testing.

### Participants

Five to eight people who have not seen the prototype. Include at least:

- one Android gesture-navigation user;
- one Android three-button-navigation user;
- one person who regularly uses accessibility or reduced-motion settings;
- one person who does not play games or use experimental interfaces often.

### Cold-start script

> “This is a prototype. Please use it naturally. Tell me what you think is happening, but do not ask me what to do. I will not help unless the app stops responding.”

Do not say “tap,” “swipe,” “hold,” “eye,” “archive,” or “Witness.”

### Tasks

1. Start from the Iris and do whatever feels natural.
2. Tell me what you think the center action did.
3. Find one other area without being told what areas exist.
4. Return to the Iris.
5. Complete the first meaningful observation if you can.

### Measures

- Time to first intentional action.
- First action type: tap, swipe, hold, wait, or ask.
- Percentage who tap the pupil without prompting.
- Percentage who discover a second destination within 30 and 60 seconds.
- Percentage who understand that all destinations originate from the Iris.
- Percentage who use Android Back or an equivalent return path successfully.
- Number of times a participant asks “What can I do?” or “Where am I?”
- Participant’s ability to explain tap, hold, swipe, and Back after one minute.
- Emotional response: inviting, intriguing, confusing, intimidating, or decorative.

### Decision thresholds

- **Proceed:** 4/5 tap the center within 5 seconds, 4/5 discover another destination within 60 seconds, and 4/5 return without assistance.
- **Simplify interaction language:** fewer than 3/5 discover a second destination within 60 seconds, even if they admire the Iris.
- **Rework onboarding:** fewer than 4/5 understand what the first tap did or more than 2/5 wait passively for the eye to explain itself.
- **Accessibility block:** any participant cannot complete the primary path because the only available affordance is a subtle gesture or motion cue.

## Final answer

**Would an average user understand this interface within 30 seconds without being taught?**

**No, not reliably.** The central tap is close to self-evident, but the broader navigation language is still learned rather than discovered. The prototype is ready for cold-user testing now. The next iteration should be driven by those observations—not by adding more animation—and should focus first on making directional exploration and the meaning of Hold unmistakable while preserving the living-instrument illusion.
