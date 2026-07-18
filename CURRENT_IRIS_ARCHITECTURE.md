# Current Iris Architecture

## Runtime path

`StartupFlow` finishes, then `Application` presents `IrisController` through calibration, awakening, welcoming, and aware behavior. Touching the Iris enters Iris Home. Iris Home opens Witness Chapters. The application sets the Iris to observing while a Witness Moment is active, settled on Home, and reflective after moment completion.

## Iris

- `scripts/iris/IrisController.gd` owns the Iris screen, state labels, touch interaction, and the Home navigation request.
- `scripts/iris/IrisCore.gd` is the behavior-only state model: dormant, calibrating, awakening, welcoming, aware, focused, observing, settled, and reflective.
- `scripts/iris/LivingIris.gd` is the sole renderer. One `Control` draws the complete Iris procedurally with 2D primitives: aura, organic body contour, fibers, pupil, micro-saccade position, glints, calibration ring, and reflective threads.

## Current integrations

- Navigation: `Application.gd` is the sole Iris state caller.
- Shaders: none. The Iris uses no texture layer or PNG eye asset.
- Audio, voice, and haptics: none are present in the clean baseline, so no inactive hook is retained.
- Rendering: the Iris skips animation work while it is not visible.

## Audit result

There are no portal or destination-preview nodes, image-based Iris replacements, navigation overlays, Iris managers, services, compatibility adapters, unused Iris resources, or Iris-specific image assets in the current project.
