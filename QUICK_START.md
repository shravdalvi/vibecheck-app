# VibeCheck - Quick Reference Guide

Fast navigation guide for the reorganized project structure.

---

## 📂 Folder Navigation

### 🎨 Frontend (Flutter/Dart)
```
frontend/
```
**Location**: `./frontend/`  
**What**: Mobile app UI, screens, widgets  
**Key Files**: `lib/main.dart`, `pubspec.yaml`  
**Start Here**: `frontend/README.md`  
**Commands**:
```bash
cd frontend
flutter pub get      # Install deps
flutter run          # Run app
flutter test         # Run tests
```

---

### 🔧 Backend (Python/Flask)
```
backend/
├── app.py           # Main server file
├── models/          # Database models
├── routes/          # API endpoints
├── services/        # Business logic
└── config/          # Configuration
```
**Location**: `./backend/`  
**What**: REST API, business logic, WebSocket  
**Key Files**: `app.py`, `requirements.txt`  
**Start Here**: `backend/README.md`  
**Commands**:
```bash
cd backend
source venv/bin/activate  # Activate environment
pip install -r requirements.txt
python app.py       # Run server
pytest              # Run tests
```

---

### 💾 Database
```
database/
├── migrations/      # Schema versions
├── schemas/         # SQL definitions
└── seeds/          # Test data
```
**Location**: `./database/`  
**What**: Database schema, migrations, seed data  
**Key Files**: `alembic.ini`, migration files  
**Start Here**: `database/README.md`  
**Commands**:
```bash
cd database
alembic upgrade head       # Apply migrations
alembic revision -m "msg"  # Create migration
python load_seeds.py       # Load test data
```

---

## 📋 Important Files at Root

| File | Purpose |
|------|---------|
| `.env.example` | Environment variables template |
| `.env` ⛔ | Your actual secrets (git ignored) |
| `.gitignore` | What not to commit |
| `PROJECT_STRUCTURE.md` | Detailed folder structure |
| `SETUP.md` | **Complete setup guide** ⭐ |
| `README.md` | Main project readme |
| `pubspec.yaml` | Root-level Dart config (if monorepo) |
| `analysis_options.yaml` | Dart linter rules |

---

## 🎯 Common Tasks

### I want to modify the API
```bash
cd backend/routes/
# Edit your endpoint file (auth.py, users.py, etc.)
```

### I want to add a UI screen
```bash
cd frontend/lib/features/
# Create new feature folder with screens/widgets
```

### I want to change the database schema
```bash
cd database
alembic revision --autogenerate -m "description"
# Edit migration file in versions/
alembic upgrade head
```

### I want to add a Python dependency
```bash
cd backend
source venv/bin/activate
pip install package-name
pip freeze > requirements.txt
```

### I want to add a Flutter package
```bash
cd frontend
flutter pub add package_name
# Updates pubspec.yaml automatically
```

---

## 🚀 Running Everything

**Terminal 1 - Backend**:
```bash
cd backend
source venv/bin/activate
python app.py
# Runs at http://localhost:5000
```

**Terminal 2 - Frontend**:
```bash
cd frontend
flutter run
# Select emulator/device
```

---

## 📚 Documentation

| Document | Content |
|----------|---------|
| [SETUP.md](SETUP.md) | Installation & setup guide |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Complete structure details |
| [frontend/README.md](frontend/README.md) | Flutter-specific info |
| [backend/README.md](backend/README.md) | Flask & API info |
| [database/README.md](database/README.md) | Database & migrations info |
| [docs/api_contract.openapi.yaml](docs/api_contract.openapi.yaml) | API specification |
| [docs/WEBSOCKET.md](docs/WEBSOCKET.md) | WebSocket documentation |

---

## 🔓 Access Control

### Frontend Models
Location: `frontend/lib/models/`  
Purpose: Data structures for frontend  
Examples: `user_model.dart`, `event_model.dart`

### Backend Models (Database)
Location: `backend/models/`  
Purpose: SQLAlchemy ORM models  
Examples: `user.py`, `event.py`, `venue.py`

### Database Schemas
Location: `database/schemas/`  
Purpose: SQL table definitions  
Examples: `users.sql`, `venues.sql`

---

## 🔐 Secrets & Environment

📍 **Location**: `.env` (root directory)  
⚠️ **Never commit**: `.env` is in `.gitignore`  
📋 **Template**: Copy from `.env.example`  

**Required for Backend**:
```env
FLASK_ENV=development
DATABASE_URL=sqlite:///vibecheck.db
JWT_SECRET_KEY=your-secret
```

**Required for Frontend**:
```env
API_BASE_URL=http://localhost:5000
```

---

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
flutter test              # Run all tests
flutter test -k "auth"   # Run specific tests
flutter test --coverage  # With coverage
```

### Backend Tests
```bash
cd backend
source venv/bin/activate
pytest                    # Run all tests
pytest::test_auth.py     # Specific file
pytest -v                # Verbose
pytest --cov             # With coverage
```

---

## 📊 Project Size

```
frontend/   ~100-200 MB  (with build artifacts)
backend/    ~50-100 MB   (with venv)
database/   ~1-10 MB     (with data)
docs/       ~5 MB
Total:      ~160-300 MB  (development)
```

---

## 🔗 Communication

- **Frontend → Backend**: API calls via `frontend/services/`
- **Backend → Database**: ORM queries via `backend/models/`
- **Real-time**: WebSocket via `backend/sockets.py`

---

## ✅ Quick Checklist

After setup, verify:

- [ ] Backend runs (`python app.py`)
- [ ] Frontend runs (`flutter run`)
- [ ] Database initialized
- [ ] Can call API endpoints
- [ ] Hot reload works
- [ ] Tests pass

---

## 🆘 Troubleshooting

**Backend won't start**: Check `.env` and database connection
**Frontend won't connect**: Ensure backend is running at `API_BASE_URL`
**Database error**: Run `alembic upgrade head`
**Package conflicts**: Delete `venv/` and reinstall

See [SETUP.md](SETUP.md) for detailed troubleshooting.

---

**Last Updated**: October 2026  
**For Full Details**: See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
