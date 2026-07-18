# Current Iris Architecture

## Runtime path

`StartupFlow` finishes, then `Application` presents `IrisController` through calibration, stirring, awakening, welcoming, and aware behavior. A touch first acquires attention, then focuses before requesting Iris Home. Iris Home keeps that same Iris visible as a non-interactive settled presence while the archive opens Witness Chapters. The application sets the Iris to observing while a Witness Moment is active and reflective after moment completion.

## Iris

- `scripts/iris/IrisController.gd` owns the Iris screen, state labels, touch interaction, the Home navigation request, and the non-interactive Home-environment presentation mode.
- `scripts/iris/IrisCore.gd` is the behavior-only state model: dormant, calibrating, stirring, awakening, welcoming, aware, attending, focused, observing, settled, and reflective.
- `scripts/iris/LivingIris.gd` is the sole renderer. One `Control` draws the complete Iris procedurally with 2D primitives: aura, organic body contour, irregular fibers, pupil, micro-saccades, rare aperture blinks, glints, calibration ring, and reflective threads.

## Current integrations

- Navigation: `Application.gd` is the sole Iris state caller.
- Shaders: none. The Iris uses no texture layer or PNG eye asset.
- Audio, voice, and haptics: none are present in the clean baseline, so no inactive hook is retained.
- Rendering: the Iris skips animation work while it is not visible.

## Audit result

There are no portal or destination-preview nodes, image-based Iris replacements, navigation overlays, Iris managers, services, compatibility adapters, unused Iris resources, or Iris-specific image assets in the current project.
