from flask import request
from flask_socketio import emit
from extensions import socketio, db
from models import Location, User
from datetime import datetime

@socketio.on('connect')
def handle_connect():
    print(f"Client connected: {request.sid}")

@socketio.on('disconnect')
def handle_disconnect():
    print(f"Client disconnected: {request.sid}")

@socketio.on('location_update')
def handle_location_update(data):
    # Expected data: {'user_id': 1, 'lat': 37.7749, 'lng': -122.4194}
    try:
        if 'user_id' in data and 'lat' in data and 'lng' in data:
            # Broadcast the update to all connected clients for the real-time map
            emit('map_update', {
                'user_id': data['user_id'],
                'lat': data['lat'],
                'lng': data['lng']
            }, broadcast=True)
            
            # Note: in a real app, we might batch these or write to DB
            # For performance, we might not want to write every tick to SQLite
            # but here is an example:
            # loc = Location(user_id=data['user_id'], latitude=data['lat'], longitude=data['lng'])
            # db.session.add(loc)
            # db.session.commit()
    except Exception as e:
        print(f"Error handling location: {e}")

@socketio.on('sos_alert')
def handle_sos(data):
    print(f"SOS ALERT received: {data}")
    # Broadcast to control center or alert others
    emit('sos_broadcast', data, broadcast=True)

