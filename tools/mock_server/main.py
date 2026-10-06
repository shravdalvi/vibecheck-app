import uuid
import datetime
import asyncio
import json
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect, Header, Request
from pydantic import BaseModel
from typing import List, Optional, Any

app = FastAPI(title="Vibecheck Mock Server")

# Models
class JoinRequest(BaseModel):
    code: str

class EventInfo(BaseModel):
    id: str
    name: str
    type: str
    status: str
    starts_at: str
    ends_at: str
    venue_name: str

class RecommendationObj(BaseModel):
    message: str
    target_zone: str
    walk_minutes: int

class ConfigObj(BaseModel):
    config_version: int
    map: dict
    zones: list
    pois: list
    thresholds: dict
    sampling: dict
    copy: dict

class JoinResponse(BaseModel):
    session_token: str
    refresh_token: str
    participant_id: str
    event: EventInfo
    config: ConfigObj

class TelemetryBatch(BaseModel):
    records: list

class TelemetryResponse(BaseModel):
    zone: str
    zone_level: str
    recommendation: Optional[RecommendationObj]
    config_version: int
    event_status: str
    server_time: str

class PresenceRequest(BaseModel):
    state: str

def get_mock_config(version: int = 1) -> ConfigObj:
    return ConfigObj(
        config_version=version,
        map={"url": "https://example.com/map.svg"},
        zones=[{"id": "zone_a", "name": "Zone A"}],
        pois=[],
        thresholds={"high": 0.8},
        sampling={"base_interval": 5},
        copy={"consent": "Event staff can see your anonymous location on a live map during the event. Other attendees never can."}
    )

@app.post("/events/join", response_model=JoinResponse)
async def join_event(req: JoinRequest):
    if req.code == "VC-7K4M2Q":
        return JoinResponse(
            session_token=f"sess_{uuid.uuid4()}",
            refresh_token=f"ref_{uuid.uuid4()}",
            participant_id=f"part_{uuid.uuid4()}",
            event=EventInfo(
                id="evt_demo",
                name="Music Fest 2026",
                type="concert",
                status="active",
                starts_at="2026-01-01T18:00:00Z",
                ends_at="2026-01-01T23:00:00Z",
                venue_name="Main Stadium"
            ),
            config=get_mock_config(1)
        )
    raise HTTPException(status_code=400, detail="Invalid event code")

@app.get("/events/{event_id}/config", response_model=ConfigObj)
async def get_config(event_id: str):
    return get_mock_config(2)

@app.post("/events/{event_id}/telemetry", response_model=TelemetryResponse)
async def upload_telemetry(event_id: str, req: TelemetryBatch):
    print(f"Received {len(req.records)} telemetry records for {event_id}")
    return TelemetryResponse(
        zone="Zone B",
        zone_level="HIGH",
        recommendation=RecommendationObj(
            message="Try food court",
            target_zone="Food",
            walk_minutes=2
        ),
        config_version=2,
        event_status="active",
        server_time=datetime.datetime.utcnow().isoformat() + "Z"
    )

@app.post("/events/{event_id}/presence", status_code=200)
async def update_presence(event_id: str, req: PresenceRequest):
    print(f"Presence update for {event_id}: {req.state}")
    return {"status": "ok"}

# WebSocket
@app.websocket("/events/{event_id}/stream")
async def websocket_endpoint(websocket: WebSocket, event_id: str, token: str = None):
    await websocket.accept()
    print(f"WebSocket connected for {event_id} with token {token}")
    try:
        # Simulate pushing some data after connection
        await asyncio.sleep(2)
        await websocket.send_text(json.dumps({"type": "CONFIG_UPDATE", "version": 2}))
        
        await asyncio.sleep(5)
        await websocket.send_text(json.dumps({
            "type": "ANNOUNCEMENT", 
            "message": "Stage 1 starting", 
            "urgent": True
        }))
        
        while True:
            data = await websocket.receive_text()
            print(f"WS Received: {data}")
    except WebSocketDisconnect:
        print("Client disconnected")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
