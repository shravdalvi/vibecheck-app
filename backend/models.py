from extensions import db
from datetime import datetime

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    locations = db.relationship('Location', backref='user', lazy=True)

class Location(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    status = db.Column(db.String(20), default='upcoming')
    latitude = db.Column(db.Float, nullable=False, default=37.7749)
    longitude = db.Column(db.Float, nullable=False, default=-122.4194)

class Zone(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    crowd_level = db.Column(db.String(20), default='low')

class TelemetryHistory(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False, index=True)
    participant_id = db.Column(db.String(255), nullable=False, index=True)
    record_id = db.Column(db.String(255), unique=True, nullable=False)
    seq = db.Column(db.Integer)
    server_time = db.Column(db.DateTime, default=datetime.utcnow)
    device_time = db.Column(db.DateTime)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    accuracy_m = db.Column(db.Float)
    speed_mps = db.Column(db.Float)
    heading_deg = db.Column(db.Float)
    is_simulated = db.Column(db.Boolean, default=False)
