# Project Cleanup Plan

## Cleanup status

The current workspace has been audited and the core project is intentionally preserved. This plan identifies future cleanup work without deleting anything in the placeholder foundation phase.

## Keep

- production `src/` services, gameplay, content, UI rooms, and contracts;
- Iris Foundation scripts/scenes/shaders;
- Mobile Simulator and validation tooling;
- Android custom build files/export presets;
- production and Iris assets referenced by manifests/scenes;
- baseline, rules, audit, and architecture documentation.

## Modify later

- move remaining root Iris scripts into a clearer `src/iris/` namespace once path stability is approved;
- centralize future Story Mode placeholder/Director route mapping;
- consolidate Profile/Settings/Your Iris presentation while keeping production services;
- improve direct-route compatibility documentation;
- add a content dependency report for assets used by each family.

## Archive later

- historical phase documents that duplicate current foundation guidance;
- migration reports after their decisions are incorporated into baseline docs;
- old prototype UX reports after a formal research archive exists;
- fixture-only family documentation in a test archive while retaining regression code.

## Remove only after verification

- legacy sample Witness fallback after production Witness error fallback is complete;
- prototype destination drawings after ProductionDestinationHost has parity and accessibility coverage;
- obsolete AppShell assumptions after all direct routes/deep links/recovery paths are tested;
- generated `.godot`, `.import`, build, APK, and AAB artifacts on every source packaging pass.

## Do not remove

- content that is not currently visible but appears in production manifests;
- unused-looking object libraries needed by future family templates;
- production tutorial scenes;
- save/profile migration code;
- accessibility adapters;
- Android branding/signing/export configuration;
- regression fixtures without replacing their test coverage.

## Cleanup acceptance

A cleanup is safe only when:

1. dependency search reports no references;
2. manifests and future roadmap are checked;
3. save/replay/history compatibility is verified;
4. production and Iris editor/runtime scans pass;
5. documentation is updated;
6. the change has a rollback copy or version-control checkpoint.
