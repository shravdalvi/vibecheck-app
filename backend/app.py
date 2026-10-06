import os
from flask import Flask
from extensions import db, jwt, socketio, redis_client
from redis import Redis

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-vibecheck')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///vibecheck.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'jwt-dev-secret-key')
    app.config['REDIS_URL'] = os.environ.get('REDIS_URL', 'redis://localhost:6379/0')

    db.init_app(app)
    jwt.init_app(app)
    socketio.init_app(app)
    
    global redis_client
    redis_client = Redis.from_url(app.config['REDIS_URL'], decode_responses=True)
    import extensions
    extensions.redis_client = redis_client

    with app.app_context():
        import models
        import routes
        import sockets
        
        db.create_all()
        
        # Register blueprints
        app.register_blueprint(routes.auth_bp, url_prefix='/api/auth')
        app.register_blueprint(routes.api_bp, url_prefix='/api')

    return app

if __name__ == '__main__':
    app = create_app()
    socketio.run(app, debug=True, host='0.0.0.0', port=5000, allow_unsafe_werkzeug=True)
