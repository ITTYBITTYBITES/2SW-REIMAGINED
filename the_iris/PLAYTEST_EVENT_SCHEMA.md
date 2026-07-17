# PLAYTEST EVENT SCHEMA

**Version:** 1.0
**Storage Method:** Local JSONL Buffer (`user://analytics_buffer.jsonl`)
**Remote Dependency:** None

This schema outlines the telemetry events recorded entirely locally during a playtest. It is designed to capture the structural flow of the player's journey without recording PII or requiring a backend service.

## Core Events

### 1. `session_start`
Fired natively when `AnalyticsService` initializes.
* **Params:** `app_version`, `platform`, `session_id`

### 2. `readiness_completed`
Fired when the player presses "Continue" on the Experience Readiness Gate.
* **Params:** 
  * `audio`: `true`/`false`
  * `haptics`: `true`/`false`

### 3. `iris_first_contact`
Fired the very first time the player taps the center of the screen to interact with the Iris.
* **Params:** None

### 4. `chapter_started`
Fired by the `WitnessMomentOrchestrator` when an incident is explicitly selected and mounted.
* **Params:** 
  * `incident_id`: The ID of the incident running.
  * `chapter_id`: The thematic chapter identifier.
  * `moment_id`: The ID of the underlying moment.

### 5. `witness_moment_started`
Fired when the orchestration sequence explicitly locks in and requests entry to the moment.
* **Params:** 
  * `moment_id`: The specific moment loaded.
  * `chapter_id`: The arc context.
  * `incident_id`: The meta incident tracking it.

### 6. `observation_completed`
Fired upon exiting the 2-second cinematic window phase.
* **Params:** 
  * `moment_id`: Moment identifier.
  * `duration`: Exact elapsed time of the cinematic phase.

### 7. `recall_answer_submitted`
Fired when the player finishes the reconstruction phase and clicks continue.
* **Params:**
  * `moment_id`: Moment identifier.
  * `phase`: "reconstruction"
  * `placed_fragments_count`: Integer count of items anchored.

### 8. `incident_identified`
Fired when the player reaches the discovery threshold in the investigation phase.
* **Params:**
  * `moment_id`: Moment identifier.
  * `completed_attunements`: Number of hotspots resolved.

### 9. `chapter_completed`
Fired by `PlayerProgressService` after saving the runtime score and archiving the payload.
* **Params:**
  * `moment_id`: The moment completed.
  * `incident_id`: The incident completed.
  * `insight_score`: The point value awarded.

### 10. `session_end`
Fired via `NOTIFICATION_WM_CLOSE_REQUEST` or `NOTIFICATION_WM_WINDOW_FOCUS_OUT` when the OS suspends or closes the app.
* **Params:** None