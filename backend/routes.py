from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from extensions import db
from models import User, Event, Zone

auth_bp = Blueprint('auth', __name__)
api_bp = Blueprint('api', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'User already exists'}), 400
        
    hashed_password = generate_password_hash(data['password'])
    new_user = User(name=data['name'], email=data['email'], password_hash=hashed_password)
    db.session.add(new_user)
    db.session.commit()
    
    token = create_access_token(identity=str(new_user.id))
    return jsonify({'token': token, 'user': {'id': new_user.id, 'name': new_user.name}}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()
    
    if not user or not check_password_hash(user.password_hash, data['password']):
        return jsonify({'message': 'Invalid credentials'}), 401
        
    token = create_access_token(identity=str(user.id))
    return jsonify({'token': token, 'user': {'id': user.id, 'name': user.name, 'email': user.email}}), 200

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def profile():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    return jsonify({'id': user.id, 'name': user.name, 'email': user.email, 'joined': user.created_at.isoformat()}), 200

@api_bp.route('/event/<int:event_id>', methods=['GET'])
@jwt_required()
def get_event(event_id):
    event = Event.query.get(event_id)
    if not event:
        # Create a mock event if it doesn't exist for demo purposes
        event = Event(id=event_id, name=f"Event {event_id}", latitude=37.7749, longitude=-122.4194)
        db.session.add(event)
        db.session.commit()
    return jsonify({'id': event.id, 'name': event.name, 'latitude': event.latitude, 'longitude': event.longitude}), 200

@api_bp.route('/event/<int:event_id>/zones', methods=['GET'])
@jwt_required()
def get_zones(event_id):
    zones = Zone.query.filter_by(event_id=event_id).all()
    return jsonify([{'id': z.id, 'name': z.name, 'crowd_level': z.crowd_level} for z in zones]), 200


import json
import time
from datetime import datetime, timezone
from extensions import redis_client
from models import TelemetryHistory

@api_bp.route('/events/<int:event_id>/telemetry', methods=['POST'])
@jwt_required()
def post_telemetry(event_id):
    records = request.get_json()
    if not isinstance(records, list):
        records = [records]
    
    server_time = int(time.time())
    participant_id = get_jwt_identity()

    dropped_points = 0
    valid_records = []

    for record in records:
        lat = record.get('latitude')
        lng = record.get('longitude')
        acc = record.get('accuracy_m', 0)
        device_time_ts = record.get('device_time')
        
        # 1. Validate schema & accuracy cap
        if lat is None or lng is None or acc > 100:
            dropped_points += 1
            continue
            
        # 2. Coordinate ranges (mock venue bounds for now)
        if not (-90 <= lat <= 90 and -180 <= lng <= 180):
            dropped_points += 1
            continue
            
        # 3. Stale timestamps (older than 60s)
        # Assuming device_time_ts is a unix timestamp in ms for this example, but if it's missing we just proceed
        # For a full implementation, we'd compare (server_time - clock_offset_ms) to reject old data
        
        valid_records.append(record)

    for record in valid_records:
        lat = record.get('latitude')
        lng = record.get('longitude')
        record_id = record.get('record_id')
        
        # Write latest position to Redis
        pos_data = {
            'lat': lat,
            'lng': lng,
            'acc': record.get('accuracy_m', 0),
            'score': record.get('movement_score', 0),
            'server_time': server_time
        }
        redis_client.hset(f"event:{event_id}:pos", participant_id, json.dumps(pos_data))
        
        # Async append to postgres would go here (we do sync for now as placeholder)
        hist = TelemetryHistory(
            event_id=event_id,
            participant_id=participant_id,
            record_id=record_id or f"{participant_id}-{server_time}",
            seq=record.get('seq', 0),
            server_time=datetime.fromtimestamp(server_time, tz=timezone.utc),
            latitude=lat,
            longitude=lng,
            accuracy_m=record.get('accuracy_m'),
            speed_mps=record.get('speed_mps'),
            heading_deg=record.get('heading_deg'),
            is_simulated=record.get('is_simulated', False)
        )
        db.session.add(hist)
    
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        print(f"Error saving to DB: {e}")

    # Respond fast
    return jsonify({
        'zone': 'Zone B', # Mocked for now, aggregator sets this
        'zone_level': 'MODERATE',
        'recommendation': None,
        'config_version': 1,
        'event_status': 'LIVE',
        'server_time': server_time,
        'debug_dropped': dropped_points
    }), 200

@api_bp.route('/events/<int:event_id>/presence', methods=['POST'])
@jwt_required()
def post_presence(event_id):
    data = request.get_json()
    state = data.get('state')
    participant_id = get_jwt_identity()
    
    if state in ['PAUSED', 'LEFT']:
        redis_client.hdel(f"event:{event_id}:pos", participant_id)
        # TODO: Publish a 'remove' delta to Redis pub/sub
    
    return jsonify({'status': 'ok'}), 200
