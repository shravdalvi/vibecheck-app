import uuid
import datetime
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from typing import List, Optional, Any

app = FastAPI(title="VenueFlow Mock Server")

# Models
class JoinRequest(BaseModel):
    event_code: str

class JoinResponse(BaseModel):
    participant_id: str
    access_token: str
    event_id: str
    event_name: str

class TelemetryRecord(BaseModel):
    schema_version: int
    record_id: str
    seq: int
    event_id: str
    participant_id: str
    source_type: str
    is_simulated: bool
    device_time: str
    clock_offset_ms: int
    latitude: float
    longitude: float
    accuracy_m: float
    speed_mps: float
    heading_deg: float
    mock_location_flag: bool
    movement_score: int
    movement_state: str
    accel_variance: float
    motion_intensity_raw: float
    zone_hint: str
    sampling_mode: str
    battery_level: int
    gps_enabled: bool
    location_permission: str
    network_status: str
    app_status: str
    last_successful_upload: Optional[str]

class SOSRecord(BaseModel):
    idempotency_key: str
    participant_id: str
    event_id: str
    device_time: str
    type: str
    latitude: float
    longitude: float
    accuracy_m: float

# Routes
@app.post("/api/v1/auth/join", response_model=JoinResponse)
async def join_event(req: JoinRequest):
    if req.event_code == "DEMO123":
        return JoinResponse(
            participant_id=f"part_{uuid.uuid4()}",
            access_token=f"tok_{uuid.uuid4()}",
            event_id="evt_demo",
            event_name="Demo Concert 2025"
        )
    raise HTTPException(status_code=400, detail="Invalid event code")

@app.get("/api/v1/event/{event_id}/config")
async def get_config(event_id: str):
    return {
        "zones": [
            {"id": "zone_a", "name": "Zone A", "polygon": [[0,0], [0,1], [1,1], [1,0]]},
            {"id": "zone_b", "name": "Zone B", "polygon": [[1,0], [1,1], [2,1], [2,0]]}
        ],
        "map_url": "https://example.com/map.svg",
        "telemetry_intervals": {
            "stationary_s": 12,
            "walking_s": 5,
            "high_movement_s": 2,
            "background_s": 10
        }
    }

@app.post("/api/v1/telemetry", status_code=202)
async def upload_telemetry(records: List[TelemetryRecord]):
    print(f"Received {len(records)} telemetry records")
    return {"status": "accepted"}

@app.post("/api/v1/sos", status_code=201)
async def trigger_sos(record: SOSRecord):
    print(f"SOS Triggered: {record.type} by {record.participant_id}")
    return {"status": "acknowledged"}

# WebSocket
@app.websocket("/ws/v1/event/{event_id}")
async def websocket_endpoint(websocket: WebSocket, event_id: str):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            # Handle heartbeat/acks here
    except WebSocketDisconnect:
        print("Client disconnected")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
