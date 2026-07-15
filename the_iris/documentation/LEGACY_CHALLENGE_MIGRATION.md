# Legacy Challenge Migration

## Decision

The previous Challenge Families are prototypes of perception mechanics, not the new Two Second Witness 4.0 product identity.

Future Witness Moments may reuse their ideas internally, but they are no longer the player-facing destinations.

## Physical organization

Legacy family source now lives under:

`src/LegacyMechanics/`

The production compatibility manifest remains at:

`src/gameplay/families/manifest.json`

and points to the moved modules so the existing runtime remains intact.

## Legacy families

- Scene Investigation
- Flash Words
- Spot the Difference
- Object Recall
- Pattern Recall

## Preserve

- generators;
- validators;
- difficulty/exposure policies;
- scoring policies;
- interaction adapters;
- result/evidence metadata;
- content manifests and assets;
- tutorials for replay/explicit access;
- production saves/progression.

## Player-facing retirement

Retire from the default Story Mode identity:

- family names as main destinations;
- challenge selection as first action;
- standalone mini-game framing;
- generic challenge results as the endpoint;
- family tutorials as the first product onboarding.

Retain in secondary contexts:

- Archive/Challenge Library;
- Training/replay;
- accessibility/explicit access;
- regression tests;
- direct support/deep-link routes.

## Future transition

1. Story Mode placeholder becomes default center path.
2. Director selects an internal mechanic.
3. Production runtime starts the legacy mechanic through stable contracts.
4. Witness Moment frames the mechanic with story, evidence, and reflection.
5. New mechanics replace legacy implementations only after equivalent validation and migration.

## Do not delete yet

No legacy family is removed in this phase. Removal requires:

- a replacement mechanic contract;
- content/save migration review;
- regression test replacement;
- accessibility parity;
- Archive/history compatibility;
- physical/human validation.
