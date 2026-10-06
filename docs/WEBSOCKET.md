# WebSocket Real-Time Messages

VenueFlow uses a single WebSocket connection per event for real-time zone alerts,
recommendations, zone assignments, and configuration updates.

## Connection

**Endpoint:** `wss://api.venueflow.example.com/v1/ws`

**Authentication:** Bearer token (query param `?token=...` or Authorization header)

**Heartbeat:** Server sends `{"type": "HEARTBEAT", "timestamp": "2025-01-15T10:00:00Z"}` every 30s.
Client should respond with `{"type": "HEARTBEAT"}` or allow inactivity timeout (60s).

**Reconnection:** Exponential backoff with jitter (1s, 2s, 4s, 8s, 16s, max 60s).

## Message Types

### HEARTBEAT
Server -> Client: Keep-alive. Client responds to prevent server timeout.

```json
{
  "type": "HEARTBEAT",
  "timestamp": "2025-01-15T10:00:00Z"
}
```

### ZONE_ASSIGNMENT
Server -> Client: Participant's current zone (authoritative). Sent on join and when the participant moves to a new zone.

```json
{
  "type": "ZONE_ASSIGNMENT",
  "event_id": "evt_ABC_2025",
  "participant_id": "00e7...",
  "zone_id": "ZONE_B",
  "zone_name": "Main Area",
  "assigned_at": "2025-01-15T10:00:00Z"
}
```

### ZONE_ALERT
Server -> Client: Zone is now HIGH or CRITICAL density. Advisory alert.

```json
{
  "type": "ZONE_ALERT",
  "event_id": "evt_ABC_2025",
  "zone_id": "ZONE_B",
  "zone_name": "Main Area",
  "density": "CRITICAL",
  "occupancy": 4850,
  "capacity": 5000,
  "message": "Zone B is at critical density. Please move toward Zone C or Zone D.",
  "priority": "HIGH",
  "created_at": "2025-01-15T10:00:00Z",
  "expires_at": "2025-01-15T10:05:00Z"
}
```

### RISK_UPDATE
Server -> Client: Overall crowd-risk state (analytics-driven, optional).

```json
{
  "type": "RISK_UPDATE",
  "event_id": "evt_ABC_2025",
  "risk_level": "MODERATE",
  "message": "Crowd flow is steady. All clear.",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### RECOMMENDATION
Server -> Client: Advisory recommendation to move. Replaces older versions automatically.

```json
{
  "type": "RECOMMENDATION",
  "recommendation_id": "rec_xyz123",
  "version": 1,
  "event_id": "evt_ABC_2025",
  "participant_id": "00e7...",
  "current_zone_id": "ZONE_B",
  "target_zone_id": "ZONE_C",
  "target_zone_name": "North Lawn",
  "route": "Gate 3 → Zone C",
  "est_walk_time_seconds": 240,
  "reason": "Zone B has reached 85% capacity. Zone C has more space.",
  "priority": "NORMAL",
  "created_at": "2025-01-15T10:00:00Z",
  "expires_at": "2025-01-15T10:15:00Z"
}
```

### ROUTE_UPDATE
Server -> Client: New route or evacuation path (low-frequency, high-priority).

```json
{
  "type": "ROUTE_UPDATE",
  "event_id": "evt_ABC_2025",
  "route_id": "rt_emergency_001",
  "name": "Emergency Assembly Point",
  "points": [
    [19.076, 72.877],
    [19.077, 72.876]
  ],
  "is_evacuation": true,
  "message": "In case of emergency, proceed to Assembly Point A.",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### ANNOUNCEMENT
Server -> Client: General announcement to all participants in the event.

```json
{
  "type": "ANNOUNCEMENT",
  "announcement_id": "ann_001",
  "event_id": "evt_ABC_2025",
  "message": "The parade will start in 30 minutes. Enjoy the event safely!",
  "priority": "LOW",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### EMERGENCY_NOTICE
Server -> Client: Mass emergency or mass-movement coordination. High-priority, rare.

```json
{
  "type": "EMERGENCY_NOTICE",
  "event_id": "evt_ABC_2025",
  "severity": "HIGH",
  "message": "Weather alert: Thunderstorm approaching. Seek shelter and move toward covered areas. Follow marshals.",
  "action": "MOVE_TO_SHELTER",
  "assembly_points": [
    {
      "name": "Assembly Point A",
      "coordinates": [19.076, 72.877]
    }
  ],
  "created_at": "2025-01-15T10:00:00Z",
  "expires_at": "2025-01-15T10:30:00Z"
}
```

### CONFIG_UPDATE
Server -> Client: Policy change (sampling interval, movement thresholds, etc.).

```json
{
  "type": "CONFIG_UPDATE",
  "config_version": 2,
  "event_id": "evt_ABC_2025",
  "sampling_policy": {
    "stationary_interval_s": 12,
    "walking_interval_s": 5,
    "high_movement_interval_s": 2
  },
  "movement_thresholds": {
    "stationary_max": 20,
    "walking_max": 45
  },
  "created_at": "2025-01-15T10:00:00Z"
}
```

### SOS_STATUS
Server -> Client: Acknowledgement of a submitted SOS record.

```json
{
  "type": "SOS_STATUS",
  "sos_id": "sos_abc123",
  "event_id": "evt_ABC_2025",
  "participant_id": "00e7...",
  "status": "ACKNOWLEDGED",
  "message": "Emergency service alerted. Help is on the way.",
  "acknowledged_at": "2025-01-15T10:00:00Z"
}
```

## Client Acknowledgements

For critical messages (RECOMMENDATION, EMERGENCY_NOTICE, SOS_STATUS), the app may send an ack:

```json
{
  "type": "ACK",
  "message_id": "rec_xyz123",
  "timestamp": "2025-01-15T10:00:00Z"
}
```

## Error Handling

If the server closes the connection without a explicit close frame, the client should
reconnect with exponential backoff.

Token expiry during a WebSocket session: The server will close with code 4001 and reason "token_expired".
The client must re-authenticate and reconnect.
