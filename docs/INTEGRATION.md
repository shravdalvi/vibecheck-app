# Vibecheck Integration Plan

## Architecture Overview
Vibecheck (Attendee App) and VenueFlow Control (Dashboard Website) communicate via a unified Backend. 
- **App -> Backend**: Telemetry sent via HTTPS POST.
- **Backend -> App**: Responds to telemetry with current zone/recommendations. App receives live events (`CONFIG_UPDATE`, `ANNOUNCEMENT`, etc.) via WebSocket.
- **Backend -> Website**: Pushes aggregated data (snapshots) and position deltas via WebSocket.
- **Storage**: Redis for live state and pub/sub. PostgreSQL for persistent history.

## 1. Endpoints
### REST API
- `POST /events/{event_id}/telemetry`
  - Auth: Event-scoped Bearer token
  - Body: Batch of telemetry records
  - Returns: `{ zone, zone_level, recommendation, config_version, event_status, server_time }`
- `POST /events/{event_id}/presence`
  - Body: `{ state: "ACTIVE" | "PAUSED" | "LEFT" }`
- `GET /events/{event_id}/config`
  - Returns: Full event config (zones, pois, etc.) + `config_version`

### WebSockets
- `WS /events/{event_id}/dashboard`
  - For dashboard snapshot data, gate status, alerts.
- `WS /events/{event_id}/dashboard/positions`
  - For live phone positions. Requires `view_individual_locations` permission.
- `WS /events/{id}/stream`
  - For the app. Streams `CONFIG_UPDATE`, `ANNOUNCEMENT`, `RECOMMENDATION`, `EVENT_STARTED`, `EVENT_ENDED`.

## 2. Message Formats (WebSockets)
- **POSITIONS_FULL**: 
  `{ "type": "POSITIONS_FULL", "seq": 1, "server_time": 1700000000, "points": [["id1", 37.77, -122.41, 5.0, "Zone A", 0.8]] }`
- **POSITIONS_DELTA**: 
  `{ "type": "POSITIONS_DELTA", "seq": 2, "upsert": [["id2", 37.78, -122.42, 4.0, "Zone B", 0.5]], "remove": ["id1"] }`
- **SNAPSHOT**:
  Aggregated zone counts, risk, flow, etc.

## 3. Authentication & Security
- **App**: Event-scoped Bearer tokens.
- **Dashboard**: Role-based (Operator vs Viewer). Dashboard websockets use a short-lived token via query param (since WS can't set headers).
- **Privacy**: Anonymous short IDs only. No names, phone numbers, or device IDs stored with coordinates. History auto-deleted post-event.

## 4. Environment Variables
- `REDIS_URL`: Redis connection string.
- `DATABASE_URL`: PostgreSQL connection string.
- `JWT_SECRET_KEY`: Secret for JWT signing.
- `PORT`: Backend port (e.g., 5000).

## 5. Deployment
- **Docker Compose**: `api`, `redis`, `postgres`, `website_mock`.
- **Reverse Proxy**: Caddy/Nginx configured for WS upgrade and long timeouts.

## 6. Assumptions & Missing Pieces
- **Website Codebase**: The website codebase is not present in this repository. We assume an adapter module `realtimeClient.ts` will be built for it, but for testing, we will mock the dashboard connection.
- **Redis & PostgreSQL**: Currently, the backend only uses SQLite. Redis and PostgreSQL need to be introduced and configured.
- **App Architecture**: The app currently lacks a network layer (no ApiClient, Telemetry models, or WebSocket service). These will be built from scratch.
- **Existing Backend**: The current Flask backend has a basic SQLite schema and mock endpoints. We will modify it heavily to match the required contracts, moving to Postgres/Redis.

