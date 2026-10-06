# VibeCheck Frontend

Flutter/Dart mobile application for VibeCheck platform.

## 📁 Structure

```
frontend/
├── lib/                    # Dart source code
│   ├── main.dart          # Entry point
│   ├── app.dart           # App initialization
│   ├── core/              # Core utilities, theme, constants
│   ├── features/          # Feature-based module structure
│   ├── models/            # Data models (DTOs)
│   ├── services/          # API, local storage, authentication
│   └── widgets/           # Reusable UI components
├── assets/                # App resources
│   ├── fonts/            # Custom fonts
│   ├── locales/          # i18n translation files
│   └── venue_maps/       # Map data
├── test/                 # Unit & widget tests
├── android/              # Android platform code
├── ios/                  # iOS platform code
├── macos/                # macOS platform code
├── windows/              # Windows platform code
├── linux/                # Linux platform code
├── web/                  # Web platform code
├── pubspec.yaml          # Dependencies & configuration
├── analysis_options.yaml # Lint rules
└── build/                # Build output (git ignored)
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Git

### Installation

```bash
# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release
flutter build apk    # Android
flutter build ipa    # iOS
flutter build web    # Web
```

## 🏗️ Architecture

### Feature-First Structure
```
lib/features/
├── auth/              # Authentication feature
├── venues/            # Venues listing & details
├── events/            # Events management
├── profile/           # User profile
└── ...
```

### Layers
- **UI/Screens** - Widget trees and layouts
- **State Management** - BLoC, Provider, or Riverpod
- **Services** - API calls, local storage
- **Models** - Data structures

## 📦 Key Dependencies

Check `pubspec.yaml` for all dependencies:
- Flutter
- Firebase (push notifications, auth)
- GetIt (service locator)
- Dio (HTTP client)
- SQLite/Hive (local storage)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --summary coverage/lcov.info
```

## 📱 Platform-Specific Code

- **Android** - See `android/` for native code, build config, and permissions
- **iOS** - See `ios/` for Swift code, CocoaPods dependencies
- **Web** - See `web/` for JavaScript integration

## 🔐 Configuration

Environment-specific configuration:
- `.env` - Environment variables (git ignored)
- `pubspec.yaml` - Global configuration

## 📝 Code Style

- Follow Dart style guide
- Use `dart format` for formatting
- Use `dart analyze` for linting

```bash
dart format lib/
dart analyze
```

## 🔗 Related

- **Backend** - See `/backend/README.md`
- **Database** - See `/database/README.md`
- **Documentation** - See `/docs/`

## 📚 Useful Commands

```bash
# Clean build
flutter clean

# Get latest dependencies
flutter pub upgrade

# Generate code (if using build_runner)
flutter pub run build_runner build

# Launch on specific device
flutter run -d <device_id>

# Enable web
flutter config --enable-web

# Check device list
flutter devices
```

**Maintainers**: VibeCheck Team
