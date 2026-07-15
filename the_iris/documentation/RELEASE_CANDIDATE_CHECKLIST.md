# Two Second Witness 4.0 Release Candidate Checklist

## Engineering

- [ ] Godot 4.6.3 project opens cleanly.
- [ ] Clean editor scan passes with no parser errors or warnings.
- [ ] Headless startup passes with no script/resource errors.
- [ ] Production runtime regression suite passes.
- [ ] Iris startup and production AppBoot complete.
- [ ] Iris → Witness → Tutorial/Observation → Recall → Result path completes.
- [ ] Results update production progress and recommendations.
- [ ] Profile reads persisted production progress.
- [ ] Settings persist through `SettingsService`.
- [ ] Accessibility preferences persist and apply.
- [ ] Mobile Simulator passes phone profiles, touch, mouse, keyboard, controller, Back, and orientation checks.
- [ ] No generated `.godot`, `.import`, build, APK, or AAB artifacts are committed.
- [ ] Resource/preload audit reports zero missing references.

## Android identity and export

- [ ] Application name is `Two Second Witness`.
- [ ] Publisher identity is ITTYBITTYBITES.
- [ ] Package is `com.ittybittybites.the2secondwitness`.
- [ ] Version is `4.0.0` or the approved next version.
- [ ] Version code is greater than the previous Play Store version code.
- [ ] Android Development preset opens and exports.
- [ ] Android Play Store preset opens and exports.
- [ ] Existing private release signing key is used.
- [ ] No new package identity or signing key was introduced.
- [ ] Custom Android Gradle build is reproducible.

## Device validation

- [ ] Install signed artifact on a physical Android phone.
- [ ] Install over the existing Play Store build where authorized.
- [ ] Verify profile/progress/settings survive upgrade.
- [ ] Verify first-launch and returning-user behavior.
- [ ] Verify Android Back from Witness, Archive, Discover, Profile, and Settings.
- [ ] Verify portrait behavior.
- [ ] Verify approved landscape/sensor orientation policy.
- [ ] Verify notch and safe-area composition.
- [ ] Verify haptic feedback with haptics enabled and disabled.
- [ ] Verify production audio and VoiceGuide together.
- [ ] Verify sound-off visual guidance.
- [ ] Verify captions/transcripts.
- [ ] Verify reduced motion.
- [ ] Verify high contrast, text scale, color assistance, and explicit access path.
- [ ] Verify no crashes during repeated rotation.
- [ ] Verify memory and frame stability after repeated challenge sessions.

## User journey

### First launch

- [ ] ITTYBITTYBITES startup is visible and recognizable.
- [ ] Two Second Witness identity is clear.
- [ ] Iris awakening feels intentional rather than like a loading screen.
- [ ] User can discover center interaction without verbal help.
- [ ] Voice helps when enabled.
- [ ] Visual/haptic/caption alternatives remain sufficient when voice is unavailable.

### Navigation

- [ ] Center enters Witness.
- [ ] Left opens Archive/Challenge Library.
- [ ] Right opens Discover/future content.
- [ ] Down opens Profile/Record.
- [ ] Up opens Settings/Calibration.
- [ ] Every room returns through the Iris.
- [ ] User can explain where they are and how to return.

### Gameplay

- [ ] Observation challenge starts.
- [ ] Two Second Witness timing is understandable.
- [ ] Recall interaction accepts the intended input.
- [ ] Correct and incorrect outcomes are clear.
- [ ] Result screen exposes evidence/explanation.
- [ ] Progress, history, mastery, achievements, and recommendations update.
- [ ] Replay/continue behavior works.

## Final sign-off

- [ ] Foundation Acceptance Report updated.
- [ ] Production Hardening Report updated if architecture changed.
- [ ] Change log/version notes prepared.
- [ ] Privacy/analytics review completed.
- [ ] Store metadata and release notes prepared.
- [ ] Release owner approves signing and Play Store update path.
- [ ] Human stranger test accepted.
