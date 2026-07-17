# CONTENT AUTHORING GUIDE

This guide explains how to use the **Witness Content Pipeline Tooling v1.0** to create, validate, and register new content for Two Second Witness 4.0 without touching any engine code.

## 1. Overview

Two Second Witness content is entirely data-driven. The engine expects JSON files defining **Witness Moments** and **Incident Definitions**.

* **Witness Moment:** Defines the physical space, lighting, duration, fragments, hotspots, and cinematic setup of the 2-second memory.
* **Incident Definition:** Defines the meta-wrapper around the moment, including mode eligibility (e.g. story vs archive), ranking requirements, UI titles, and associations with memory cases.

## 2. Using Templates

We provide clean JSON templates to start authoring new content. You can find these in `tools/templates/`.

* **`WitnessMomentTemplate.json`**: Copy this to `src/iris/story/content/moment_[ID].json`. Fill in your environment assets, object fragments, and attunements.
* **`IncidentDefinitionTemplate.json`**: Copy this to `src/iris/story/incidents/incident_[NAME].json`. Ensure `witness_moment_ids` matches the ID in your newly created moment.

## 3. Authoring Workflow

Follow these steps to safely add a new chapter or moment to the game:

1. **Create Assets:**
   Place your images in `assets/gameplay/`.
   *Example: `assets/gameplay/wm_011_background.png`*

2. **Create JSON Files:**
   Copy the templates to the respective `src/iris/story/content/` and `src/iris/story/incidents/` folders. Update the IDs, asset references (`res://assets/...`), and narrative strings.

3. **Run the Content Pipeline:**
   Instead of manually editing the registry, use the pipeline tool to validate your files and automatically register them.

   From the `the_iris` directory, run:
   ```bash
   python3 tools/content_pipeline.py
   ```

4. **Review the Report:**
   The tool will output a `CONTENT_PIPELINE_REPORT.md` file. It will warn you if you:
   * Have missing/broken asset paths.
   * Defined an incident that points to a missing Witness Moment.
   * Missed a required `moment_id` or `incident_id`.
   * Used duplicate IDs.

   If the Validation Status is `PASS`, the tool has successfully updated `registry_manifest.json`.

5. **Launch the Game:**
   Start the application. The `IncidentRegistry` will automatically load your new content from the generated manifest, and the `WitnessExperienceDirector` will route it based on the defined chronological ordering.

## 4. Troubleshooting

* **"Incident references unknown Witness Moment"**: You misspelled the ID in `witness_moment_ids` inside your incident definition, or the corresponding moment JSON has a typo in its `moment_id`.
* **"Missing asset referenced"**: The tool checks the local disk for `res://` paths. Double-check your spelling and ensure the `.png` or `.svg` is actually inside the `assets/` folder.
