# VibeCheck Database

Database schema, migrations, and seed data management.

## 📁 Structure

```
database/
├── migrations/          # Alembic version-controlled migrations
│   ├── versions/       # Individual migration files
│   ├── env.py         # Migration environment setup
│   ├── script.py.mako # Migration template
│   └── alembic.ini    # Alembic configuration
├── schemas/           # Database schema definitions (SQL)
│   ├── users.sql      # Users table schema
│   ├── venues.sql     # Venues table schema
│   ├── events.sql     # Events table schema
│   └── ...
├── seeds/             # Initial seed data
│   ├── users_seed.json
│   ├── venues_seed.json
│   ├── events_seed.json
│   └── load_seeds.py
├── init_db.py         # Database initialization script
└── README.md         # This file
```

## 🗄️ Database Configuration

Supported databases:
- **SQLite** - Development/Testing
- **PostgreSQL** - Production recommended
- **MySQL** - Alternative

### Connection String

```
# SQLite (file-based)
sqlite:///vibecheck.db

# PostgreSQL
postgresql://user:password@localhost:5432/vibecheck

# MySQL
mysql+pymysql://user:password@localhost:3306/vibecheck
```

Set via `DATABASE_URL` environment variable in `.env`

## 📋 Schema Overview

### Tables

#### `users`
```sql
id (PK)
email (UNIQUE)
username (UNIQUE)
password_hash
first_name
last_name
profile_picture
bio
created_at
updated_at
```

#### `venues`
```sql
id (PK)
name
description
location
latitude
longitude
capacity
owner_id (FK -> users)
created_at
updated_at
```

#### `events`
```sql
id (PK)
title
description
venue_id (FK -> venues)
event_date
start_time
end_time
capacity
current_vibes (JSON)
created_by (FK -> users)
created_at
updated_at
```

See `schemas/` directory for complete SQL definitions.

## 🔄 Migrations

Migrations track database schema changes over time.

### Create New Migration

```bash
cd /path/to/backend

# Auto-generate from model changes
alembic revision --autogenerate -m "add user bio field"

# Creates file: database/migrations/versions/xxx_add_user_bio_field.py
```

### Apply Migrations

```bash
# Apply latest migrations
alembic upgrade head

# Apply specific version
alembic upgrade +1

# Check migration status
alembic current
```

### Rollback

```bash
# Rollback to previous version
alembic downgrade -1

# Rollback to specific version
alembic downgrade abc123def456
```

### Migration Structure

```python
"""Description of changes"""

from alembic import op
import sqlalchemy as sa

revision = 'abc123def456'
down_revision = 'xyz789def123'

def upgrade():
    # Code to apply changes
    op.add_column('users', sa.Column('bio', sa.String(500)))

def downgrade():
    # Code to revert changes
    op.drop_column('users', 'bio')
```

## 🌱 Seed Data

Initial/test data loaded for development and testing.

### Load Seeds

```bash
# From database directory
python load_seeds.py

# Or from backend directory
python -c "from database.seeds import load_seeds; load_seeds()"
```

### Seed Files Format

```json
[
  {
    "email": "user@example.com",
    "username": "testuser",
    "first_name": "Test",
    "last_name": "User"
  }
]
```

Seed files located in `seeds/` directory:
- `users_seed.json` - Test users
- `venues_seed.json` - Test venues
- `events_seed.json` - Test events

## 🔧 Database Commands

### Initialize Database

```bash
# Create all tables and apply migrations
python init_db.py

# Or using Flask CLI
flask db init
flask db migrate
flask db upgrade
```

### Backup Database

```bash
# SQLite
cp vibecheck.db vibecheck.db.backup

# PostgreSQL
pg_dump -U user -h localhost vibecheck > backup.sql
```

### Restore Database

```bash
# SQLite
cp vibecheck.db.backup vibecheck.db

# PostgreSQL
psql -U user -h localhost vibecheck < backup.sql
```

### Reset Database (Development Only)

```bash
# Delete all data and rebuild
python -c "
import os
from backend.database import db
from backend.app import create_app

app = create_app()
with app.app_context():
    db.drop_all()
    db.create_all()
    # Optionally load seeds
"
```

## 📊 Database Relationships

```
users
├─── owns ──-> venues
└─── creates --> events

venues
└─--- hosts ---> events

events
├─--- created_by ---> users
└─--- hosted_at ---> venues
```

## 🔐 Security

### Access Control
- Use environment variables for connection strings
- Never commit credentials
- Use `.env` for local development (git ignored)

### Data Protection
- Hash passwords with bcrypt/argon2
- Validate all input with Pydantic
- Use parameterized queries (SQLAlchemy ORM)
- Implement row-level security in production

## 📈 Performance

### Indexes
Add indexes for frequently queried fields:
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_events_venue_id ON events(venue_id);
CREATE INDEX idx_events_created_by ON events(created_by);
```

### Query Optimization
- Use lazy loading/eager loading appropriately
- Limit query results with pagination
- Use database query profiling tools

## 🔗 Integration

### Backend Integration
ORM models in `backend/models/` connect to these tables:
- Models auto-sync with schema
- Migrations managed via Alembic
- Use SQLAlchemy for queries

### Frontend Integration
API endpoints return data from these tables:
- See `backend/routes/` for endpoint definitions
- See `docs/api_contract.openapi.yaml` for response schemas

## 🧪 Testing Database

### Test Database Configuration

```python
# config/testing.py
SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
```

### Test Setup
```python
def setup_test_db():
    db.create_all()
    # load test data
    yield
    db.session.remove()
    db.drop_all()
```

## 📚 Resources

- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [SQLAlchemy ORM](https://docs.sqlalchemy.org/orm/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🔗 Related

- **Backend** - See `/backend/README.md`
- **Frontend** - See `/frontend/README.md`
- **API** - See `/docs/api_contract.openapi.yaml`

**Maintainers**: VibeCheck Database Team
