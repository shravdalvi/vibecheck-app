# VibeCheck Backend

Python REST API and WebSocket server for VibeCheck platform.

## 📁 Structure

```
backend/
├── app.py              # Flask/FastAPI application entry point
├── extensions.py       # Extension initialization (SQLAlchemy, JWT, etc)
├── sockets.py         # WebSocket event handlers
├── requirements.txt   # Python dependencies
├── config/            # Configuration management
│   ├── __init__.py
│   ├── development.py
│   ├── production.py
│   └── testing.py
├── models/            # SQLAlchemy ORM models
│   ├── __init__.py
│   ├── user.py
│   ├── venue.py
│   ├── event.py
│   └── ...
├── routes/            # API endpoint handlers
│   ├── __init__.py
│   ├── auth.py
│   ├── users.py
│   ├── venues.py
│   ├── events.py
│   └── ...
├── services/          # Business logic layer
│   ├── __init__.py
│   ├── auth_service.py
│   ├── user_service.py
│   ├── venue_service.py
│   ├── email_service.py
│   └── ...
├── database/          # Database utilities
│   ├── __init__.py
│   ├── connection.py
│   └── session.py
├── venv/              # Virtual environment (git ignored)
└── instance/          # Instance config (git ignored)
```

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- PostgreSQL/MySQL (or SQLite for dev)
- pip/venv

### Installation

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env

# Initialize database
flask db upgrade

# Start development server
python app.py
# or
flask run
```

**Server runs at**: `http://localhost:5000`

## 📋 Configuration

### Environment Variables

Create `.env` file:
```env
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=your-secret-key-here

DATABASE_URL=sqlite:///vibecheck.db
# or
DATABASE_URL=postgresql://user:password@localhost:5432/vibecheck

JWT_SECRET_KEY=your-jwt-secret
JWT_ALGORITHM=HS256

MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-password

FIREBASE_API_KEY=your-firebase-key
```

### Config Files

- `config/development.py` - Development settings
- `config/production.py` - Production settings
- `config/testing.py` - Testing settings

Current environment set via `FLASK_ENV` variable.

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `POST /api/auth/refresh` - Refresh token

### Users
- `GET /api/users/<id>` - Get user profile
- `PUT /api/users/<id>` - Update user
- `GET /api/users/<id>/venues` - Get user's venues

### Venues
- `GET /api/venues` - List all venues
- `GET /api/venues/<id>` - Get venue details
- `POST /api/venues` - Create venue
- `PUT /api/venues/<id>` - Update venue
- `DELETE /api/venues/<id>` - Delete venue

### Events
- `GET /api/events` - List events
- `GET /api/events/<id>` - Get event details
- `POST /api/events` - Create event
- `PUT /api/events/<id>` - Update event
- `DELETE /api/events/<id>` - Delete event

See `docs/api_contract.openapi.yaml` for complete API documentation.

## 🔗 WebSocket Events

Real-time communication via WebSocket:
- `user_joined` - User joins event
- `user_left` - User leaves event
- `message_sent` - New message in chat
- `vibe_updated` - Vibe state updated

See `docs/WEBSOCKET.md` for details.

## 🏗️ Project Structure

### Models (`models/`)
SQLAlchemy ORM models representing database tables:
- `User` - User accounts
- `Venue` - Venue/locations
- `Event` - Events at venues
- Relationships between tables

### Routes (`routes/`)
API endpoint handlers organized by resource:
- Request validation
- Response formatting
- HTTP status codes
- Error handling

### Services (`services/`)
Business logic layer:
- User authentication
- Venue operations
- Event management
- External integrations (email, payments)

### Database (`database/`)
Database utilities:
- Connection management
- Session handling
- Query helpers

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=backend

# Run specific test
pytest tests/test_auth.py

# Run in watch mode
ptw
```

## 📦 Dependency Management

### Adding Dependencies

```bash
# Install new package
pip install package-name

# Update requirements.txt
pip freeze > requirements.txt

# Or add manually and run
pip install -r requirements.txt
```

### Current Main Dependencies
- Flask - Web framework
- SQLAlchemy - ORM
- Flask-JWT-Extended - JWT authentication
- Flask-CORS - CORS handling
- Flask-SocketIO - WebSocket support
- Pydantic - Data validation
- Python-dotenv - Environment variables
- Requests - HTTP client

## 🔐 Security

- JWT tokens for authentication
- CORS configuration
- Rate limiting (implement)
- Input validation (Pydantic)
- SQL injection prevention (SQLAlchemy ORM)
- Environment variables for secrets

## 📚 Database Migrations

```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

Migration files in `../database/migrations/versions/`

## 🚢 Deployment

### Development
```bash
python app.py
```

### Production
```bash
gunicorn wsgi:app --workers 4 --bind 0.0.0.0:8000
```

Use environment variables for production configuration.

## 📝 Code Style

```bash
# Format code
black backend/

# Lint code
flake8 backend/

# Type checking
mypy backend/
```

## 🔗 Related

- **Frontend** - See `/frontend/README.md`
- **Database** - See `/database/README.md`
- **API Documentation** - See `/docs/api_contract.openapi.yaml`

## 📞 Support

For issues or questions, check documentation in `/docs/`

**Maintainers**: VibeCheck Backend Team
