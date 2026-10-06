# Vibecheck: Safe Crowd Guide

A privacy-first, production-quality mobile attendee app for VenueFlow, a crowd-safety platform for any crowded venue (concerts, stadiums, festivals, melas, processions).

**Vibecheck** is purely the attendee client: it collects location and movement data, shows the attendee's zone status, displays advisory recommendations, and sends SOS alerts. The app is never the source of truth for crowd state—that role belongs to the backend AI aggregation layer.

## Context

- **VenueFlow** = the complete crowd-safety platform (3 layers)
  - 1. **Vibecheck Flutter app** (this repo): attendee client
  - 2. **Backend + AI**: geofencing, aggregation, density, flow, risk, prediction, recommendations
  - 3. **VenueFlow Control**: admin web dashboard (already exists; not built here)
- **No custom hardware**: all data comes from attendee smartphones
- **Privacy by design**: anonymous, event-scoped, minimal data collection

## Tech Stack

| Component | Choice | Version | Rationale |
|-----------|--------|---------|-----------|
| Language | Dart | 3.0+ | Flutter requirement |
| Framework | Flutter | 3.13+ | Cross-platform (Android/iOS), rich UI, strong community |
| State | Riverpod | 2.4.0+ | Type-safe, testable, fine-grained reactivity |
| Routing | go_router | 12.0.0+ | Modern, web-friendly, deep linking support |
| HTTP | dio | 5.3+ | Interceptors, retry, logging w/ PII redaction |
| WebSocket | web_socket_channel | 2.4+ | Simple, reconnect-friendly |
| Location | geolocator | 9.0+ | Cross-platform, permissions handling, foreground service (Android) |
| Sensors | sensors_plus | 2.1+ | Accelerometer, gyroscope (no health/biometrics) |
| Storage | drift | 2.14+ | SQLite ORM; queue persistence w/ minimal PII |
| Secure Storage | flutter_secure_storage | 9.0+ | Tokens, credentials |
| QR / Deep Links | mobile_scanner + app_links | 3.5+ / 3.4+ | Event join flows |
| Localization | intl | 0.19+ | i18n scaffolding (EN, HI, MR) |
| Linting | flutter_lints | 3.0+ | + strict custom rules in `analysis_options.yaml` |

**Deviations**: None. All tech choices are justified by the spec and reflect current best practice (as of Oct 2026).

---

## Project Structure

```
vibecheck-app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # MaterialApp setup
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart            # Environment, API URLs, feature flags
│   │   ├── constants/
│   │   │   └── app.dart                   # APP_NAME (single source of truth) + all string constants
│   │   ├── networking/
│   │   │   └── adapters/
│   │   │       ├── api_adapter.dart       # Interface (backend-agnostic)
│   │   │       └── dio_api_adapter.dart   # DIO-based HTTP + WebSocket impl (Phase 2)
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Dark, high-contrast, colorblind-safe theme
│   │   ├── errors/
│   │   │   └── app_exceptions.dart        # Custom exception types
│   │   ├── utils/                         # (TODO) logging, validation, helpers
│   │   ├── permissions/                   # (TODO) location, battery, etc
│   │   ├── storage/                       # (TODO) drift DB, secure storage
│   │   └── l10n/                          # (TODO) localization (EN, HI, MR)
│   ├── models/
│   │   ├── event.dart                     # Event, Zone, EventConfig, SamplingPolicy
│   │   ├── participant.dart               # Participant (session, tokens)
│   │   ├── telemetry.dart                 # TelemetryRecord, TelemetryBatch
│   │   ├── sos.dart                       # SOSSubmission, SOSStatus
│   │   ├── recommendation.dart            # Recommendation (advisory)
│   │   └── device_status.dart             # (TODO) GPS, battery, network state
│   ├── services/                          # (TODO) Phase 3+
│   │   ├── location_service.dart          # (TODO) Central LocationService
│   │   ├── motion_service.dart            # (TODO) Accel/gyro + movement scoring
│   │   ├── telemetry_service.dart         # (TODO) Queue, uploader, batching
│   │   ├── websocket_service.dart         # (TODO) WS connection, reconnect, heartbeat
│   │   ├── permission_service.dart        # (TODO) Permission requests + checks
│   │   ├── connectivity_service.dart      # (TODO) Network status, offline mode
│   │   ├── battery_service.dart           # (TODO) Battery monitoring, saver mode
│   │   ├── zone_resolver_service.dart     # (TODO) Point-in-polygon, hysteresis
│   │   ├── sampling_policy_service.dart   # (TODO) Adaptive interval calculation
│   │   ├── clock_sync_service.dart        # (TODO) Device clock offset estimation
│   │   └── simulation_service.dart        # (TODO) Virtual participants (dev only)
│   ├── features/                          # (TODO) Phase 2+
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── consent/
│   │   ├── event_join/
│   │   ├── home/
│   │   ├── venue_map/
│   │   ├── recommendations/
│   │   ├── emergency/
│   │   ├── settings_privacy/
│   │   ├── connection_status/
│   │   └── debug/
│   └── widgets/                           # (TODO) Phase 5+
│       ├── status_card.dart
│       ├── zone_card.dart
│       ├── crowd_indicator.dart
│       ├── recommendation_card.dart
│       └── sos_button.dart
├── test/                                  # Unit tests
├── integration_test/                      # Integration tests
├── tools/
│   ├── mock_server/
│   │   ├── main.py                        # FastAPI mock server (Phase 1)
│   │   ├── requirements.txt
│   │   └── __init__.py
│   └── load_simulator/                    # (TODO) Phase 8: CLI for load testing
├── docs/
│   ├── README.md                          # (This file)
│   ├── api_contract.openapi.yaml          # OpenAPI 3.0 spec
│   ├── WEBSOCKET.md                       # WebSocket message spec
│   ├── API_INTEGRATION.md                 # (TODO) How to integrate with real backend
│   ├── PRIVACY.md                         # (TODO) Data inventory, retention, compliance
│   ├── TEST_PLAN.md                       # (TODO) Manual + automated test checklist
│   └── SAMPLE_PAYLOADS.md                 # (TODO) Example JSON for all API calls
├── assets/
│   ├── venue_maps/                        # (TODO) Map images/SVG configs
│   └── locales/                           # (TODO) i18n ARB files
├── .env.example                           # Environment template
├── pubspec.yaml                           # Flutter dependencies
├── analysis_options.yaml                  # Strict linting rules
├── android/                               # Android native config
├── ios/                                   # iOS native config
└── web/                                   # (Not built; included for completeness)
```

---

## Execution Order & Phases

This project is built phase by phase. **Each phase compiles, passes `flutter analyze`, and passes all tests before moving to the next.**

### **Phase 1: Backend Discovery, Contract, Mock Server, Project Skeleton ✓**
- ✓ Analyzed backend (none exists) → decided to create contract + mock
- ✓ Created `docs/api_contract.openapi.yaml` (OpenAPI 3.0)
- ✓ Built `tools/mock_server/` (Python FastAPI, fully functional)
- ✓ Initialized Flutter project with flavors (dev, staging, prod, demo)
- ✓ Set up environment config (`lib/core/config/app_config.dart`, `.env.example`)
- ✓ Created core theme, constants, error handling
- ✓ Defined all models (Event, Telemetry, SOS, Recommendation, Participant)
- ✓ Created `ApiAdapter` interface (backend-agnostic)
- ✓ Created strict `analysis_options.yaml`
- **Status**: Ready; `pubspec.yaml` configured; mock server runnable; lint rules in place

### **Phase 2: Onboarding, Consent, Permissions, Event Join, Session** (TODO)
- Splash screen (config check, session resume)
- Welcome screen (APP_NAME, tagline, CTA)
- Consent screen (opt-in, data inventory, withdrawal flow)
- Location permission flow (when-in-use first; background step with explanation)
- Event join screen (code entry, QR scan, deep link handling)
- Session persistence (participant ID, tokens, expiry + refresh)
- Secure token storage
- **Testing**: Widget tests for all screens, permission prompt handling

### **Phase 3: Location, Motion, Validation, Sampling** (TODO)
- `LocationService`: central service, foreground + background
- `MotionService`: accelerometer/gyro → movement state + score
- Validation: coordinate range, accuracy threshold, speed check, timestamp freshness, deduplication
- `SamplingPolicy`: adaptive intervals (remotely configurable)
- `ClockSyncService`: device clock offset estimation
- Android foreground service + persistent notification config
- iOS background location + "Always" permission upgrade flow
- **Testing**: Unit tests (validation, sampling), widget tests (GPS off, permission denied), integration (background resume)

### **Phase 4: Telemetry Queue, Uploader, Connectivity, Offline** (TODO)
- `TelemetryService`: local queue (drift, encrypted, minimal PII)
- `TelemetryUploader`: batching, exponential backoff with jitter, idempotency
- Queue drop policy (SOS > device status > telemetry)
- Connectivity service: detect offline, rate-limit awareness (429/Retry-After)
- UI: "Monitoring locally", queue depth, last upload time
- Offline telemetry file preservation (for SOS)
- **Testing**: Unit (backoff calc, dedupe), widget (offline UI), integration (offline→online flush)

### **Phase 5: WebSocket, Zone Assignment, Home Screen, Recommendations, Venue Map** (TODO)
- WebSocket service: auth, heartbeat, reconnect, resume, fallback to REST poll
- Message types: ZONE_ASSIGNMENT, ZONE_ALERT, RECOMMENDATION, CONFIG_UPDATE, SOS_STATUS, etc.
- Zone resolver: point-in-polygon, hysteresis, offline fallback
- Home screen: event name, monitoring status, current zone, crowd status, recommendation card, [View Map], [SOS]
- Recommendation detail screen
- Venue map: position marker, recommended destination, route polyline, zoom, high-contrast
- **Testing**: Widget (each ZoneAlert state), integration (zone transition B→C), WebSocket reconnect

### **Phase 6: SOS End-to-End (including offline & app kill)** (TODO)
- SOS flow: type selector, hold-to-confirm (~2-3 s), cancel window, idempotency
- Offline SOS: persist to queue, retry on reconnect
- App kill/restart: SOS status survives (drift persistence)
- States: Sending → Sent → Received → Acknowledged
- UI feedback: show status, "Alert sent to event control", local guidance
- **Testing**: Widget (hold UI, cancel), integration (offline → online retry), kill/restart scenario

### **Phase 7: Background Operation & Battery** (TODO)
- Android foreground service with location tracking
- iOS background location + background app refresh
- Battery monitoring + "Battery Saver" mode
- Debug battery-trace screen
- Target drain rate (e.g., ≤ 8%/hour in walking mode)
- Telemetry pause at event end or on withdrawal
- **Testing**: Real-device background tests, battery measurement procedure

### **Phase 8: Simulation Mode, Load Simulator, Docs, Localization, Full Test Pass** (TODO)
- Simulation UI (dev/demo only): "SIMULATION MODE: ON" banner
- Virtual participants (SIM-001...): route, speed, jitter, outage injection
- Source_type SIMULATED tag; is_simulated flag
- Production flavor must disable/hard-reject simulation
- `tools/load_simulator/`: CLI that spawns 1000s of virtual participants against backend/mock
- Localization: ARB files for EN, HI, MR; translation of all UI + "serious mode" SOS copy
- Docs: API_INTEGRATION.md, PRIVACY.md, TEST_PLAN.md, SAMPLE_PAYLOADS.md
- Full test pass: all units, widgets, integration tests
- Manual checklist: real-device background, SOS persistence, offline flush, battery drain

---

## Setup & Running

### Prerequisites

- **Dart/Flutter**: stable channel, ≥3.13.0
  ```bash
  flutter --version
  ```
- **Python**: 3.8+ (for mock server)
  ```bash
  python3 --version
  ```
- **Android SDK**: API level 31+ (for geolocator, foreground service)
- **Xcode**: 14+ (iOS builds)

### 1. Clone & Install

```bash
cd /path/to/vibecheck-app
flutter pub get
```

### 2. Run the Mock Server

The mock server implements the OpenAPI contract and is essential for local development.

```bash
cd tools/mock_server
pip install -r requirements.txt
python3 -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The server will start on `http://localhost:8000` and exposes:
- `POST /v1/events/join` → issue participant ID + tokens
- `POST /v1/telemetry` → accept telemetry batches
- `POST /v1/sos` → submit SOS alerts
- `WS /v1/ws` → real-time zone alerts, recommendations, etc.
- Demo endpoints: `GET /v1/_demo/events`, `POST /v1/_demo/recommendation`, `POST /v1/_demo/zone_alert`

### 3. Environment Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

**For local dev** (mock server):
```
FLAVOR=demo
ENVIRONMENT=local
API_BASE_URL=http://localhost:8000
WS_BASE_URL=ws://localhost:8000
DEFAULT_EVENT_CODE=DEMO123
SIMULATION_MODE=false
DEBUG_MODE=true
```

### 4. Build Flavor

The app supports four flavors: `dev`, `staging`, `prod`, `demo`.

```bash
# Dev (HTTP allowed on localhost, full logging, simulation enabled)
flutter run -t lib/main.dart --flavor dev --dart-define-from-file=.env

# Demo (same as dev; includes demo endpoints)
flutter run -t lib/main.dart --flavor demo --dart-define-from-file=.env

# Staging (HTTPS only, minimal logging, no simulation)
flutter run -t lib/main.dart --flavor staging --dart-define-from-file=.env

# Production (HTTPS/WSS only, no logging except errors, no simulation, strict validation)
flutter run -t lib/main.dart --flavor prod --dart-define-from-file=.env
```

### 5. Run Tests

```bash
# Unit tests
flutter test

# Analyze (strict lints)
flutter analyze

# Integration tests (Flutter emulator required)
flutter drive --target=integration_test/app_test.dart
```

### 6. Real Device Testing

**Android**:
```bash
adb devices
flutter run -t lib/main.dart --flavor dev -d <device_id>
```

**iOS**:
```bash
open -a Simulator
flutter run -t lib/main.dart --flavor dev
```

---

## API Integration

### Current: Mock Server (Phase 1)

All backend specifics are isolated behind `lib/core/networking/adapters/ApiAdapter`. The mock server implements the full OpenAPI contract.

**To test the app**:
1. Start the mock server (`tools/mock_server/main.py`)
2. Join the demo event (code: `DEMO123`)
3. Telemetry auto-uploads; zone alerts and recommendations can be triggered via `/v1/_demo/` endpoints

### Later: Real Backend (Phase 2+)

When the real VenueFlow backend is ready:
1. Inspect its API (should be compliant with `docs/api_contract.openapi.yaml`)
2. Update `lib/core/config/app_config.dart` with production URLs
3. Optionally optimize `lib/core/networking/adapters/dio_api_adapter.dart`
4. No other app code changes required (adapter abstraction)

See **docs/API_INTEGRATION.md** (TODO) for detailed remapping instructions.

---

## Assumptions & Open Questions

### ✓ Assumptions (Verified / Locked)

1. **Backend Contract**: OpenAPI 3.0 spec in `docs/api_contract.openapi.yaml`
   - All app logic assumes this contract
   - Real backend must be compatible; if not, only the adapter needs changes

2. **Auth Scheme**: Short-lived access token + refresh token
   - Issued on event join; stored in flutter_secure_storage
   - Tokens auto-refresh before expiry (in Phase 2)

3. **Participant Privacy**: Anonymous, event-scoped, rotating ID
   - Server issues participant_id on event join
   - No persistent device identifiers (IMEI, advertising ID, MAC)
   - Same person joining a second event gets a new participant_id

4. **Telemetry Model**: Versioned schema (schema_version: 1)
   - Includes GPS, movement score, device state, zone hint
   - Record is idempotent (record_id is UUID v4)
   - Server authoritative for zone assignment, recommendations

5. **Recommendations**: Advisory only, server-driven, time-limited
   - App never decides which zone is "better"; server decides
   - Recommendations expire (app ignores expired ones)
   - Each recommendation carries id, version, expires_at

6. **SOS Reliability**: Highest priority
   - Submitted immediately, bypassing telemetry batch; retried until ack
   - Persists across app kill (drift queue)
   - Visible to authorized responders only (backend responsibility)

7. **Simulation**: Dev/demo flavors only
   - Production flavor must not include simulation UI or must hard-disable it
   - Simulated telemetry tagged is_simulated=true; backend rejects in prod

8. **Locale Support**: Scaffolding in place (Phase 8)
   - EN (English), HI (Hindi), MR (Marathi)
   - Two string groups: "normal" + "serious" (SOS/CRITICAL copy)

### ? Open Questions (For Backend Team / Stakeholder)

1. **Event Lifecycle**:
   - Can a participant join before the event starts (event_status = PLANNED)?
   - What happens if they remain in the app after the event ends (ENDED)?
   - Should telemetry collection stop instantly or after a graceful period?

2. **Zone Model Flexibility**:
   - Polygons are closed lists of [lat, lon] pairs. Any irregular shapes expected?
   - Can zones overlap, or are they always disjoint?
   - How does the server handle a participant outside all zones?

3. **Recommendation Routing**:
   - The `route` field is free-text (e.g., "Gate 3 → Zone C"). Should it ever be a polyline (array of coordinates)?
   - Can the backend send multiple recommendations to one participant simultaneously?

4. **Push Notifications**:
   - Should the app register FCM token on event join? (Spec notes interface + stub; not implemented yet)
   - Can push replace WebSocket if the client is backgrounded on iOS?

5. **Offline SOS**:
   - If the app is offline and SOS is submitted, should it show a "pending" state and allow retry?
   - Or should it silently queue and show "sent" once the connection is reestablished?

6. **Battery / Telemetry Trade-offs**:
   - Target drain rate: Is ≤ 8%/hour in walking mode reasonable, or should it be more conservative?
   - Should the app respect OS-level battery saver mode or have its own thresholds?

7. **Cross-Event Tracking**:
   - If the same device joins two separate events, should the backend detect it's the same device (for analytics) or remain anonymous?
   - (Privacy spec says anonymous; asking for backend handling only)

8. **Regional Compliance**:
   - Are there data residency requirements (India's DPDP Act 2023)?
   - Max data retention on the backend? (Spec currently says server-configurable; default 90 days)

---

## Documentation Roadmap

| File | Phase | Status |
|------|-------|--------|
| `docs/api_contract.openapi.yaml` | 1 | ✓ Done |
| `docs/WEBSOCKET.md` | 1 | ✓ Done |
| `docs/API_INTEGRATION.md` | 2 | TODO |
| `docs/PRIVACY.md` | 2 | TODO |
| `docs/TEST_PLAN.md` | 8 | TODO |
| `docs/SAMPLE_PAYLOADS.md` | 8 | TODO |

---

## Privacy & Compliance

**TL;DR**: Minimal, event-scoped, anonymous, with explicit consent and easy withdrawal.

**Data Collected**: Location (GPS), movement (accel/gyro features, not raw samples), device state (battery, network, app status).
**Data Not Collected**: Contacts, photos, microphone, messages, files, health data, persistent device ID (IMEI, advertising ID, MAC).
**Retention**: Configurable by backend (default 90 days); deleted on event end or consent withdrawal.
**User Controls**: In-app consent withdrawal + "delete my data" request (triggers backend purge).
**Compliance**: DPDP Act 2023 (India); legal team review required.

See **docs/PRIVACY.md** (TODO) for full inventory and compliance checklist.

---

## Known Limitations & Non-Goals

1. **No Tile Map Backend**: Custom venue map from remote config (image + polygon overlays). Tile-based fallback designed behind interface, not implemented yet.
2. **No Native Code**: All platform specifics (foreground service, background location) via Dart plugins (geolocator, iOS background modes). Some assembly required (manifest, plist).
3. **No Video/Audio**: Microphone, camera, call recording—explicitly not collected.
4. **No Health/Biometric Framing**: Sensors collect movement, not heart rate, blood oxygen, etc. No health implications claimed.
5. **No Cross-Event Correlation**: Each event is anonymous; backend can optionally detect same-device joins (for analytics) but app never exposes it.

---

**Last Updated**: October 6, 2026
**Phase**: 1 (Backend discovery, Contract, Mock server, Project skeleton)
**Status**: ✓ Ready for Phase 2 (Onboarding & Event Join)