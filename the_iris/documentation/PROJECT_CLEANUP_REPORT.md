# Project Cleanup Report

## Scope

Preparation/cleanup pass for the Story Mode foundation. No production gameplay was deleted or redesigned.

## Completed

- Organized previous challenge family source under `src/LegacyMechanics/`.
- Kept a compatibility manifest at `src/gameplay/families/manifest.json` pointing to moved modules.
- Added `src/iris/story/WitnessMoment.gd` placeholder contract.
- Added `src/iris/story/FutureWitnessMechanics.gd` placeholder names.
- Added `src/iris/story/WitnessProfileProjection.gd` future personal-space projection hook.
- Preserved production services, assets, contracts, and Android configuration.
- Kept placeholder future experience scenes and Mobile Simulator.
- Confirmed no generated `.godot` or `.import` artifacts in the package.

## Not deleted

The following remain intentionally:

- all five legacy mechanics;
- regression fixture family;
- production AppShell/screens;
- fallback Iris destination drawings;
- historical documentation;
- production content assets;
- tutorials and accessibility adapters.

They require future dependency/save/release review before removal.

## Current temporary/placeholder assets

- Future Experience placeholder scenes;
- generic FuturePlaceholder visual language;
- LegacyMechanics fallback/rendering assets;
- Iris sample Witness fallback;
- development simulator frame/touch indicator.

These are documented, not silently mistaken for final production systems.

## Generated artifact policy

Never retain in the foundation package:

- `.godot/`;
- `*.import`;
- build output;
- APK/AAB artifacts;
- temporary integration test scenes/scripts.

## Remaining cleanup candidates

1. Replace fallback destination presentation after production-host parity.
2. Consolidate old historical docs into an archive policy.
3. Review AppShell direct route compatibility before removing old chrome assumptions.
4. Remove legacy fallback Witness presentation after Story Mode has a production error state.
5. Audit large asset batches only after content ownership confirms roadmap use.

## Result

The workspace is now organized for Story Mode preparation without destructive deletion of production infrastructure.
