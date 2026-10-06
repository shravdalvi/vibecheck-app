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

