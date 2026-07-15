# Legacy System Audit

## Scope

A preparation audit for the Story Mode foundation. No final gameplay was implemented and no production challenge mechanics were redesigned.

## KEEP

- Iris navigation, transitions, Back, input intents, device/orientation handling
- startup activation and Android identity/export support
- SaveService, ProfileService, PlayerProgressService, SettingsService
- AccessibilityService, AudioService, ThemeService, AnalyticsService
- ContentService, ExperienceRegistry, manifests and asset loading
- ChallengeSessionService and result/progression infrastructure
- generation, validation, difficulty/exposure policies, interaction adapters
- Mobile Device Simulation Mode

These systems are reusable infrastructure and remain authoritative.

## MODIFY

- MainController: add Story Mode/Director ownership over time.
- ProductionWitnessHost: evolve from route host to Witness Moment host.
- ProductionDestinationHost: keep production rooms as secondary Iris destinations.
- XP/levels/ranks: present as Witness Rank/Chapters while preserving production values.
- achievements/rewards: present as Milestones/Discoveries while keeping AchievementService.
- profile: evolve toward Your Iris while keeping production profile data.
- tutorials: first-use tutorials become Story Mode beats; replay tutorials remain in Library.
- results: become Revelation/Reflection/Reward beats inside a moment.
- challenge routing: family routes remain internal; Story Director becomes the default doorway.

## ARCHIVE / LEGACY MECHANICS

The previous five Challenge Family implementations have been physically organized under:

`src/LegacyMechanics/`

They remain loaded by the production runtime through the compatibility manifest at:

`src/gameplay/families/manifest.json`

They are not deleted and are not the new product identity. Future Witness Moments may reuse their underlying mechanics only through the production contracts.

## REMOVE EVENTUALLY

- legacy challenge-first entry from the default player journey;
- standalone family-first tutorials from first-session flow;
- generic result-to-home presentation;
- prototype fallback rooms after production host parity;
- obsolete direct navigation chrome after accessibility/recovery coverage;
- generated `.godot`, `.import`, build, APK/AAB artifacts.

## Temporary / development-only

- Mobile Simulator shell and touch indicator;
- placeholder Future Experience scenes;
- test-only fixture family and regression compatibility content;
- historical documentation.

These remain until the corresponding production replacements or release process are validated.

## Audit conclusion

The current production foundation is suitable for Story Mode. The old challenge families are now explicitly internal legacy mechanics, while the reusable runtime contracts remain protected.
