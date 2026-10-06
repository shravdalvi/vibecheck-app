# VibeCheck - Setup Guide

Complete setup instructions for the VibeCheck application with Frontend, Backend, and Database.

## 📋 Prerequisites

### System Requirements
- **OS**: macOS, Linux, or Windows
- **Disk Space**: 5GB minimum
- **RAM**: 8GB minimum

### Required Software

1. **Git**
   ```bash
   # macOS
   brew install git
   
   # Ubuntu/Debian
   sudo apt-get install git
   
   # Windows
   # Download from https://git-scm.com/
   ```

2. **Flutter & Dart**
   ```bash
   # Install Flutter (includes Dart)
   # https://flutter.dev/docs/get-started/install
   
   # Verify installation
   flutter --version
   dart --version
   ```

3. **Python 3.8+**
   ```bash
   # macOS
   brew install python@3.11
   
   # Ubuntu/Debian
   sudo apt-get install python3.11 python3.11-venv
   
   # Windows
   # Download from https://www.python.org/
   ```

4. **Database** (Choose one)
   - **SQLite** (Built-in, no setup needed - Development)
   - **PostgreSQL** (Recommended for Production)
   - **MySQL** (Alternative)

---

## 🚀 Quick Start (All Components)

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/vibecheck-app.git
cd vibecheck-app
```

### 2. Setup Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configurations
# Important variables:
# - FLASK_ENV=development
# - DATABASE_URL=sqlite:///vibecheck.db
# - JWT_SECRET_KEY=your-secret-key
# - API_BASE_URL=http://localhost:5000
```

### 3. Setup Backend

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# macOS/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Initialize database
python init_db.py
# or
alembic upgrade head

# Start backend server
python app.py
```

Server runs at: `http://localhost:5000`

### 4. Setup Frontend

In a **new terminal**:

```bash
cd frontend

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or run specific platform:
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run -d windows      # Windows
```

---

## 💻 Individual Setup Guides

### Frontend Only

```bash
cd frontend

# Install Flutter (if not already installed)
# https://flutter.dev/docs/get-started/install

# Verify setup
flutter doctor

# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Build release
flutter build apk      # Android
flutter build ipa      # iOS
flutter build web      # Web
flutter build windows  # Windows
flutter build macos    # macOS
flutter build linux    # Linux
```

**Docs**: See [frontend/README.md](frontend/README.md)

### Backend Only

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate          # macOS/Linux
# OR
venv\Scripts\activate             # Windows

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp ../.env.example .env

# Initialize database
python init_db.py

# Run development server
python app.py
# OR
flask run
# OR with auto-reload
FLASK_ENV=development FLASK_DEBUG=True python app.py
```

**API Documentation**: Available at `http://localhost:5000/docs` (if Swagger configured)

**Docs**: See [backend/README.md](backend/README.md)

### Database Only

```bash
cd database

# Install Alembic (if not in requirements)
pip install alembic

# Create new migration after model changes
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1

# Load seed data
python seeds/load_seeds.py
```

**Docs**: See [database/README.md](database/README.md)

---

## 🔧 Common Setup Issues

### Issue: Flask Can't Find Database

**Solution**:
```bash
# Ensure DATABASE_URL is set in .env
# SQLite (development):
DATABASE_URL=sqlite:///vibecheck.db

# Apply migrations
cd backend
alembic upgrade head
```

### Issue: Flutter Can't Connect to Backend

**Solution**:
```bash
# Backend must be running
cd backend
python app.py

# Check API_BASE_URL in .env
# Should match backend URL (usually http://localhost:5000)
```

### Issue: Python Virtual Environment Issues

**Solution**:
```bash
# Delete and recreate venv
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Issue: Flutter Build Errors

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📱 Development Workflow

### Starting All Services

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
# Emulator/Device must be running
```

**Terminal 3 - Optional Monitoring**:
```bash
# Watch frontend tests
cd frontend
flutter test --watch

# Or watch backend tests
cd backend
pytest --watch
```

### Making Changes

**Backend Changes**:
```bash
# Flask with debug mode auto-reloads
# Just save changes in backend/
```

**Frontend Changes**:
```bash
# Flutter hot-reload
# Just save changes in frontend/lib/
# Or press 'r' in terminal running flutter run
```

**Database Changes**:
```bash
# Create migration
cd database
alembic revision --autogenerate -m "description"

# Apply migration
alembic upgrade head

# Backend models will sync automatically
```

---

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest                          # Run all tests
pytest tests/test_auth.py      # Run specific file
pytest -v                       # Verbose output
pytest --cov                    # With coverage
```

### Frontend Tests
```bash
cd frontend
flutter test                    # Run all tests
flutter test --coverage         # With coverage
flutter test -k "pattern"       # Run matching tests
```

---

## 📦 Dependency Management

### Add Backend Package
```bash
cd backend
source venv/bin/activate
pip install package-name
pip freeze > requirements.txt
```

### Add Frontend Package
```bash
cd frontend
flutter pub add package_name
# Updates pubspec.yaml automatically
```

---

## 🔐 Security Setup

### Generate JWT Secret (Backend)
```python
import secrets
print(secrets.token_urlsafe(32))
```

Add to `.env`:
```env
JWT_SECRET_KEY=<generated-key>
```

### Database Connection (Production)
Use strong credentials and secure environment:
```env
DATABASE_URL=postgresql://user:strong_password@secure_host:5432/vibecheck
```

---

## 🚢 Deployment Preparation

### Backend
```bash
# Build requirements.txt
cd backend
pip freeze > requirements.txt

# Setup production config
export FLASK_ENV=production
export SECRET_KEY=<strong-key>
export DATABASE_URL=<production-db>

# Can use gunicorn
gunicorn wsgi:app --workers 4
```

### Frontend
```bash
# Build release
cd frontend
flutter build apk       # Android
flutter build ipa       # iOS
flutter build web       # Web

# Outputs in build/ directory
```

---

## 📚 Documentation

- [Project Structure](PROJECT_STRUCTURE.md) - Complete folder hierarchy
- [Frontend Docs](frontend/README.md) - Flutter setup & architecture
- [Backend Docs](backend/README.md) - Flask setup & API
- [Database Docs](database/README.md) - Schema & migrations
- [API Contract](docs/api_contract.openapi.yaml) - OpenAPI spec
- [WebSocket Guide](docs/WEBSOCKET.md) - Real-time communication

---

## 🆘 Getting Help

1. Check README files in each component
2. Review [docs/](docs/) directory
3. Check GitHub Issues
4. Review error messages carefully
5. Try cleaning and rebuilding

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] Backend starts without errors (`python app.py`)
- [ ] Frontend builds successfully (`flutter pub get && flutter run`)
- [ ] Database initializes (`python init_db.py`)
- [ ] API endpoints respond (test with curl/Postman)
- [ ] Frontend connects to backend
- [ ] All tests pass (`flutter test` and `pytest`)
- [ ] Environment variables are set (`.env`)

---

**Setup Complete!** 🎉

Your VibeCheck development environment is ready. Start developing!

For questions or issues, refer to the documentation or check project READMEs.
