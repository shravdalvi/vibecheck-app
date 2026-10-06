# Integration Audit (Step 0)

## 1. Current State vs CONTRACT

Currently, the Vibecheck Flutter app relies entirely on mock providers (`mock_providers.dart`, `mock_map_provider.dart`, `profile_providers.dart`) and does not implement a concrete API layer. It defines an abstract `ApiAdapter` and data models that differ significantly from the new CONTRACT.

### Environmental & Configuration State
- **Config Loading**: `AppConfig` uses `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000')`.
- **Environment**: Not dynamically loaded based on the website.
- **WebSocket Messages**: `WebSocketMessage` enum defines `ZONE_ASSIGNMENT`, `ZONE_ALERT`, `SOS_STATUS`, `EMERGENCY_NOTICE` which are no longer in the contract.
- **Auth**: The `login_screen.dart` directly succeeds without an API call.

## 2. Audit Table: Changes Needed

| Item | Current Behavior (in `ApiAdapter` / models) | CONTRACT Requirement | Change Needed |
|------|------------------------------------------|----------------------|---------------|
| **Join Event** | `joinEvent` returns `Participant` | `POST /events/join` returns `{session_token, refresh_token, participant_id, event, config}` | Update `ApiAdapter.joinEvent` return type to include tokens, event, and config. |
| **Config Loading** | `getEvent` | `GET /events/{event_id}/config` | Replace `getEvent` with `getConfig` (returns `EventConfig` + `config_version`). |
| **Telemetry Response**| Returns `TelemetryBatchResponse(acceptedCount, rejected)` | Returns `{ zone, zone_level, recommendation, config_version, event_status, server_time }` | Update `TelemetryBatchResponse` model and adapter. Feed this data to Riverpod providers on every tick. |
| **Presence API** | Missing completely | `POST /events/{event_id}/presence` with `state` | Add `updatePresence(state)` to `ApiAdapter`. Wire to `Pause/Stop` UI. |
| **WebSocket Stream**| Expects deprecated events (e.g. `SOS_STATUS`, `ZONE_ALERT`) | `CONFIG_UPDATE`, `ANNOUNCEMENT`, `RECOMMENDATION`, `EVENT_STARTED`, `EVENT_ENDED` | Prune unused message types in `WebSocketMessage`. Add `EVENT_STARTED` and `EVENT_ENDED`. |
| **Auth Headers** | Passed explicitly in adapter methods, or mocked | Bearer token in secure storage | Build the concrete Dio API client injecting the Bearer token. |
| **Freshness (Time)**| Local device time | `server_time` | Update UI/models to calculate relative time based on `server_time`. |
| **SOS Feature** | Defined in `ApiAdapter` and `models/sos.dart` | Hard ban on SOS | Delete `sos.dart` and remove from `ApiAdapter`. |

## 3. Unverified / Assumptions
- **Concrete Implementations**: There is no Dio client, WebSocket service, or SQLite queue implementation in the codebase. I assume I will need to build the `ApiClient` (implementing the modified `ApiAdapter`), the WebSocket client, and the durable queue for telemetry.
- **Join Flow UI**: The `LoginScreen` currently accepts a dummy email. I will need to modify it or the auth layer to accept an event code (e.g. `VC-7K4M2Q`) to match `POST /events/join`, unless we keep the UI as-is and mock the event code underneath.

**Wait for approval before proceeding to Step 1.**


## Step 1 Execution
- **ApiClient (`api_client.dart`)**: Created a concrete implementation of `ApiAdapter`. Updated `TelemetryBatchResponse` to expect `{zone, zone_level, recommendation, config_version, event_status, server_time}`.
- **TelemetryUploader (`telemetry_uploader.dart`)**: Created a background uploader.
  - **Durable Queue**: Uses `path_provider` to persist the queue to a local JSON file.
  - **Logic**: Enforces `maxBatchSize = 50`, exponential backoff with jitter (max 30s), and ordered flushing.
  - **Riverpod Sync**: On every successful batch flush, updates `currentZoneProvider` and `recommendationProvider` via `ref.read().state`.

## Step 2 Execution
- **ApiAdapter / ApiClient**: Replaced `getEvent` with `getConfig(eventId, accessToken)`. Defined `EventConfigResponse` strictly matching the contract.
- **ConfigProvider**: Built `ConfigNotifier` which holds the active `EventConfigResponse` and `configVersion`.
  - It exposes a `checkVersion(newVersion)` method that atomically fetches the new config if `newVersion > currentVersion`, without blocking telemetry.
  - Implements `WidgetsBindingObserver` to fetch the config automatically on app resume.
- **TelemetryUploader**: Hooked `checkVersion` into `_handleResponse` so that every telemetry response natively acts as a config version ping.

## Step 3 Execution
- **WebSocket Messages**: Pruned deprecated types (e.g. `SOS_STATUS`, `ZONE_ALERT`) from `api_adapter.dart` and replaced them with `CONFIG_UPDATE`, `ANNOUNCEMENT`, `RECOMMENDATION`, `EVENT_STARTED`, and `EVENT_ENDED` to exactly match the CONTRACT.
- **WebSocket Service**: Created `WebSocketService` that:
  - Connects to `/events/{event_id}/stream?token=` using the `web_socket_channel` package.
  - Features exponential backoff with jitter (max 30s) on disconnects or errors.
  - Automatically triggers a config fetch (`ref.read(configProvider).fetchConfig()`) upon successful reconnection.
  - Parses incoming JSON into the strict `WebSocketMessage` types.
  - Uses Riverpod to immediately push `ANNOUNCEMENT` and `RECOMMENDATION` updates to the UI, and calls `checkVersion` for `CONFIG_UPDATE`.
  - Implements a 25-second heartbeat ping.

## Step 4 Execution
- **Presence API**: Added `updatePresence(state: 'ACTIVE' | 'PAUSED' | 'LEFT')` to `ApiClient`.
- **State Management**: Updated `SharingStatusNotifier` to act as a proper asynchronous `Notifier`. It sends the `updatePresence` API request and features a local fallback queue (`presence_queue.txt`) if the network fails, attempting to flush the latest queued state on initialization or subsequent changes.
- **UI Integration**: Updated `ProfileScreen` to call `updateStatus(SharingStatus)` instead of modifying `.state` directly.
- **Location Halting**: Updated `VenueMapScreen` (the only consumer of `Geolocator`) to a `ConsumerStatefulWidget`, directly checking `sharingStatusProvider`. The map stream now discards points and stops sending WS payloads when paused. The `Geolocator` subscription is properly cancelled on dispose.

## Step 5 Execution
- **Consent Copy**: Added explicit text *"Event staff can see your anonymous location on a live map during the event. Other attendees never can."* to `ProfileScreen`.
- **Localization**: Added the `locationConsentText` key and translation to `app_en.arb`, `app_hi.arb`, and `app_mr.arb`.
- **Privacy Doc**: Created `docs/PRIVACY.md` detailing the data collected (Location, Movement, Battery, Connection status) and what is NOT collected (Name, Contacts, etc.).

## Step 6 Execution
- **SOS Purge**: Completely removed `SOSSubmission` and `SOSStatus` endpoints from `ApiAdapter` and `ApiClient`, and deleted `sos.dart`.
- **Mock Server**: Updated `tools/mock_server/main.py` with FastAPI models to exactly match the new POST `/events/join`, POST `/events/{eventId}/telemetry`, POST `/events/{eventId}/presence` and WS endpoints.
- **Unit Tests**: Wrote `test/core/networking/api_client_test.dart` containing unit tests to verify `ApiClient` parsing against a fake Dio HTTP client, asserting proper `JoinResponse` and `TelemetryBatchResponse`.
