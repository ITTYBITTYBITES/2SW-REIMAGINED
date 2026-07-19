# Mission 065 — Chapter 01 Human Playtest Protocol

**Purpose:** Collect consistent real-player evidence for the completed Chapter 01 Living Iris 4.0 experience.

**Scope:** First-launch through five-fragment Chapter 01 completion. This protocol does not alter gameplay, persistence, navigation, Archive authority, or player progression.

---

## 1. Test build intake

Record this before every session:

```text
Tester ID:
Build commit/hash:
APK filename and SHA-256 (if available):
Godot version / export template version:
Android device model:
Android OS version:
Screen resolution / refresh rate:
Audio output route:
Haptics enabled:
Reduced motion enabled:
Fresh profile / existing profile:
Session date/time:
```

### Required test setup

- Use the **Android Debug** preset, not the Play Store release preset.
- Install on a physical Android phone/tablet where possible.
- Start at least one session with a cleared app-data profile.
- Record screen and device audio for the first-launch session and at least one complete moment.
- Do not use developer skips or manually edit `user://witness_profile.json` during primary human tests.

---

## 2. First-launch protocol

### Flow

```text
Fresh profile
→ launch
→ awakening
→ Iris ready
→ Spatial Hub
→ select first path
→ pupil portal
→ WM-001
```

### Observation prompts

Rate each from **1 (unclear/poor)** to **5 (clear/strong)** and write a short note.

| Prompt | Rating | Note |
| --- | ---: | --- |
| The awakening made the Iris feel alive |  |  |
| The player understood that the Iris noticed them |  |  |
| Dialogue/audio/haptic timing felt coordinated |  |  |
| The Hub felt like a memory space rather than a menu |  |  |
| The available first path was understandable |  |  |
| Pupil entry felt like travel into a memory |  |  |

### Pass threshold

A new tester should be able to say, without explanation: **“The Iris opened a memory for me.”**

---

## 3. Witness Moment test sheet

Complete WM-001 through WM-005 in sequence. Use one sheet per moment.

### Moment record

```text
Moment ID/title:
Truth Fragment:
Session start time:
Completion time:
Accidental taps/missteps noticed:
Did the session background/resume during this moment? Y/N
```

| Prompt | Rating 1–5 | Note |
| --- | ---: | --- |
| I understood what memory I entered |  |  |
| The Fracture felt discoverable from observation |  |  |
| False leads redirected me rather than punished me |  |  |
| Synchronization felt like stabilizing a memory |  |  |
| Timing/hold interaction felt fair |  |  |
| The Revelation explained why the Fracture mattered |  |  |
| The Truth Fragment felt earned and distinct |  |  |
| The Iris reaction felt meaningful |  |  |
| Return through the pupil felt continuous |  |  |

### Moment-specific comprehension prompts

| Moment | Tester should understand |
| --- | --- |
| WM-001 — The Unfinished Canvas | The light was protected until it could be witnessed. |
| WM-002 — The Forgotten Museum | Arthur’s devotion made the museum remember his touch. |
| WM-003 — The Last Performance | Elena’s journey was a reunion, not only an escape. |
| WM-004 — The Faulty Reactor | The impossible warning gave the physicist time to prevent failure. |
| WM-005 — The Witness | The player and Iris preserve damaged memories through shared attention. |

Ask the tester to explain each in their own words before showing Archive copy.

---

## 4. Return loop and Archive protocol

After every completion, verify:

| Check | Result | Notes |
| --- | --- | --- |
| Iris absorption was noticed |  |  |
| Returned to the Iris rather than a disconnected screen |  |  |
| Hub relationship language changed appropriately |  |  |
| Recovered fragment appears in Archive |  |  |
| Fragment identity/truth/reflection is understandable |  |  |
| Constellation node is visible/meaningful |  |  |

After at least two fragments, inspect the Archive and confirm the player recognizes the entries as **preserved stories**, not score items.

---

## 5. Chapter 01 completion protocol

After WM-001 through WM-005 are all recovered:

1. Return to the Hub.
2. Verify the Chapter 01 relationship/constellation state.
3. Open Archive and inspect all five fragments.
4. Confirm the Chapter Bloom reports **5 / 5** recovered memories.
5. Ask the tester: *“What is the Iris preserving, and why are you able to restore it?”*
6. Force-close the app.
7. Relaunch and verify recovered fragments, Archive inspection, Iris relationship state, constellation, and Chapter Bloom persist.

### Completion pass threshold

The tester should identify that the five fragments are connected human memories and that **Shared Aperture** explains their role as witness.

---

## 6. Interaction, resilience, and accessibility protocol

### Touch and timing

- Test Fracture target discovery with one-handed use.
- Note accidental touches near active targets.
- Note whether hold duration feels too short, too long, or unclear.
- Verify no unintended progression occurs from tapping outside the intended controls.

### Interruption/resume

For at least one moment each, background/resume during:

- portal transition;
- observation;
- synchronization;
- Archive inspection.

Record whether state, audio, and input return safely.

### Accessibility

Run at minimum:

| Mode | Verify |
| --- | --- |
| Reduced motion enabled | No disorienting shake; core information remains visible. |
| Audio muted | Text, visual state, and interaction remain understandable. |
| Haptics disabled | Synchronization and completion remain understandable. |
| Bright light/readability | Text, Fracture halo, and progress indicators remain legible. |

---

## 7. Issue triage

Use these labels for every observation:

| Label | Meaning |
| --- | --- |
| **PASS** | Clear and emotionally/interactionally effective. |
| **TUNE** | Works, but needs timing, copy, contrast, audio, haptic, or UX adjustment. |
| **BLOCKER** | Prevents completing/understanding the chapter or invalidates persistence/flow. |
| **KEEP** | Architecture/system is behaving correctly; do not replace it. |
| **EXTEND** | Future capability needed after Chapter 01 evidence is reviewed. |
| **REBUILD** | Use only if evidence shows a true architecture conflict. |

Attach screen recording, screenshot, crash/error log, device details, reproduction steps, and severity to every BLOCKER.

---

## 8. End-of-session summary

```text
Did the Iris feel like the identity of the product? Y/N — why?
Did entering a moment feel like traveling somewhere? Y/N — why?
Did restored truths feel like preserved stories, not rewards? Y/N — why?
Most meaningful moment:
Least clear moment:
Most disruptive issue:
Recommended next action:
```