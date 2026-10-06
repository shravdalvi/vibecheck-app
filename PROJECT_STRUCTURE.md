# VibeCheck App - Project Structure

## Overview
This project is organized into three main components: Frontend (Flutter), Backend (Python), and Database with clear separation of concerns.

---

## 📁 Directory Structure

```
vibecheck-app/
│
├── 📂 frontend/                    # Flutter/Dart Frontend Application
│   ├── lib/                        # Dart source code
│   │   ├── main.dart              # Entry point
│   │   ├── app.dart               # App configuration
│   │   ├── core/                  # Core utilities, services, theme
│   │   ├── features/              # Feature modules (screens, logic)
│   │   ├── models/                # Data models
│   │   ├── services/              # Services (API, local storage)
│   │   └── widgets/               # Reusable widgets
│   ├── assets/                    # App assets
│   │   ├── fonts/                # Custom fonts
│   │   ├── locales/              # Translation files
│   │   └── venue_maps/           # Maps data
│   ├── test/                      # Unit & widget tests
│   ├── pubspec.yaml              # Dart dependencies
│   ├── analysis_options.yaml     # Linter rules
│   ├── android/                  # Android-specific code
│   ├── ios/                      # iOS-specific code
│   ├── macos/                    # macOS-specific code
│   ├── windows/                  # Windows-specific code
│   ├── linux/                    # Linux-specific code
│   └── web/                      # Web-specific code
│
├── 📂 backend/                    # Python Backend API
│   ├── app.py                    # Flask/FastAPI application
│   ├── requirements.txt          # Python dependencies
│   ├── 📂 config/                # Configuration files
│   │   ├── __init__.py
│   │   ├── development.py
│   │   ├── production.py
│   │   └── testing.py
│   ├── 📂 models/                # SQLAlchemy/Database models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── venue.py
│   │   ├── event.py
│   │   └── ...other models
│   ├── 📂 routes/                # API endpoint handlers
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── venues.py
│   │   └── ...other routes
│   ├── 📂 services/              # Business logic & external integrations
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── email_service.py
│   │   ├── payment_service.py
│   │   └── ...other services
│   ├── 📂 database/              # Database utilities
│   │   ├── __init__.py
│   │   ├── connection.py         # DB connection configuration
│   │   └── session.py            # SQLAlchemy session management
│   ├── 📂 extensions.py          # Flask extensions (SQLAlchemy, JWT, etc)
│   ├── 📂 sockets.py             # WebSocket handlers
│   ├── venv/ or .venv/           # Virtual environment (ignored)
│   └── instance/                 # Instance-specific config (ignored)
│
├── 📂 database/                  # Database management
│   ├── 📂 migrations/            # Alembic migrations
│   │   ├── versions/             # Migration files
│   │   ├── env.py
│   │   ├── script.py.mako
│   │   └── alembic.ini
│   ├── 📂 schemas/               # Database schema definitions
│   │   ├── users.sql
│   │   ├── venues.sql
│   │   ├── events.sql
│   │   └── ...other schemas
│   ├── 📂 seeds/                 # Initial seed data
│   │   ├── users_seed.json
│   │   ├── venues_seed.json
│   │   └── events_seed.json
│   ├── database.sqlite           # SQLite DB (if using SQLite)
│   ├── init_db.py               # Database initialization script
│   └── README.md                # Database documentation
│
├── 📂 docs/                      # Project documentation
│   ├── api_contract.openapi.yaml # API documentation
│   ├── PHASE1_SUMMARY.md        # Phase 1 summary
│   ├── WEBSOCKET.md             # WebSocket documentation
│   ├── SETUP.md                 # Setup instructions
│   ├── ARCHITECTURE.md          # Architecture overview
│   └── API.md                   # API reference
│
├── 📂 tools/                     # Development tools
│   ├── mock_server/             # Mock server for testing
│   ├── scripts/                 # Utility scripts
│   └── docker/                  # Docker configurations
│
├── 📂 build/                     # Build artifacts (git ignored)
│
├── .gitignore                    # Git ignore rules
├── .env.example                  # Environment variables template
├── .gitattributes               # Git attributes
├── analysis_options.yaml        # Dart analysis options (root)
├── pubspec.yaml                 # Root pubspec (if monorepo)
├── README.md                    # Main project README
├── README_PHASE1.md             # Phase 1 documentation
├── PROJECT_STRUCTURE.md         # This file
└── vibecheck.iml                # IntelliJ project file

```

---

## 🚀 Component Responsibilities

### Frontend (`/frontend/`)
- **Languages**: Dart/Flutter
- **Responsibilities**:
  - User interfaces and screens
  - Client-side state management
  - Local data storage (SharedPreferences, Hive)
  - API communication
  - Real-time WebSocket connections
- **Run Command**: `flutter run` (from frontend/)
- **Config**: `pubspec.yaml`, `analysis_options.yaml`

### Backend (`/backend/`)
- **Language**: Python
- **Framework**: Flask/FastAPI
- **Responsibilities**:
  - REST API endpoints
  - Business logic
  - Authentication & Authorization
  - External service integrations
  - WebSocket management
  - Database operations
- **Run Command**: `python app.py` or `flask run` (from backend/)
- **Dependencies**: `requirements.txt`
- **Key Modules**:
  - `config/` - Environment-specific configurations
  - `models/` - Database model definitions
  - `routes/` - API endpoint handlers
  - `services/` - Business logic layer
  - `database/` - DB connection & session management

### Database (`/database/`)
- **Type**: SQL-based (PostgreSQL, MySQL, SQLite)
- **Migration Tool**: Alembic
- **Responsibilities**:
  - Schema definitions
  - Migration versioning
  - Seed data management
  - Database initialization
- **Key Directories**:
  - `migrations/` - Version-controlled schema changes
  - `schemas/` - Database schema SQL files
  - `seeds/` - Initial/test data

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK
- Python 3.8+
- Database (PostgreSQL/MySQL/SQLite)
- Git

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### Database Setup
```bash
cd database
# Run migrations
alembic upgrade head

# Seed initial data (optional)
python load_seeds.py
```

---

## 📝 Environment Variables

Create `.env` file in root directory:

```env
# Backend
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=your-secret-key

# Database
DATABASE_URL=sqlite:///vibecheck.db
# or
DATABASE_URL=postgresql://user:password@localhost:5432/vibecheck

# Frontend (if needed)
API_BASE_URL=http://localhost:5000
```

---

## 📦 Key Files & Their Locations

| File/Folder | Location | Purpose |
|---|---|---|
| Entry Point (Flutter) | `frontend/lib/main.dart` | App initialization |
| Entry Point (Backend) | `backend/app.py` | API server initialization |
| Dependencies (Dart) | `frontend/pubspec.yaml` | Flutter packages |
| Dependencies (Python) | `backend/requirements.txt` | Python packages |
| Database Models | `backend/models/` | ORM model definitions |
| API Routes | `backend/routes/` | Endpoint handlers |
| Business Logic | `backend/services/` | Service layer |
| Migrations | `database/migrations/versions/` | Version-controlled schema changes |
| Test Files | `frontend/test/` | Flutter unit & widget tests |
| Documentation | `docs/` | API docs, architecture, guides |

---

## 🎯 Development Workflow

1. **Frontend Development**
   - Work in `frontend/lib/`
   - Write tests in `frontend/test/`
   - Add assets to `frontend/assets/`

2. **Backend Development**
   - Add endpoints in `backend/routes/`
   - Add business logic in `backend/services/`
   - Define models in `backend/models/`

3. **Database Changes**
   - Create migration: `alembic revision --autogenerate -m "description"`
   - Update schema files in `database/schemas/`
   - Run: `alembic upgrade head`

4. **API Integration**
   - Refer to `docs/api_contract.openapi.yaml` for specs
   - Implement frontend calls in `frontend/services/`
   - Test with backend running

---

## 📚 Best Practices

- ✅ Keep frontend & backend completely separate
- ✅ Use consistent naming conventions
- ✅ Document API changes in `docs/API.md`
- ✅ Keep database migrations version-controlled
- ✅ Use environment variables for configurations
- ✅ Write tests alongside features
- ✅ Update this structure document when adding major components

---

## 🔗 Related Documentation

- See `docs/api_contract.openapi.yaml` for API specification
- See `docs/WEBSOCKET.md` for WebSocket implementation
- See `docs/ARCHITECTURE.md` for system design
- See `README.md` for quick start guide

---

**Last Updated**: October 2026
