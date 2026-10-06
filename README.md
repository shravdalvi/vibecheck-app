# Vibecheck: Safe Crowd Guide

A privacy-first crowd-safety attendee app.

## Project Setup

1. Copy `.env.example` to `.env`
2. Configure environment variables (e.g., `FLAVOR`, `API_BASE_URL`).
3. Run flutter packages get: `flutter pub get`
4. Run code generation: `dart run build_runner build -d`
5. Run the app: `flutter run --dart-define-from-file=.env`

## Running the Demo / Mock Server
To run the mock server locally:
```bash
cd tools/mock_server
pip install -r requirements.txt
python main.py
```
Make sure `API_BASE_URL` in `.env` points to `http://localhost:8000`.

## Assumptions, Risks & Backend Requirements

### Open Questions & Assumptions
- **Adoption Rate Calibration**: Since the app only tracks opted-in users, the backend must cross-reference active connections with real ticketing/gate data to estimate true crowd density. The app assumes the backend is correctly weighting its telemetry.
- **Hysteresis**: Zone boundaries can be fuzzy. We implement local point-in-polygon hysteresis, but authoritative assignment strictly relies on the backend to avoid flapping.
- **Spoof Detection**: The app will report `mock_location_flag`, but the backend is responsible for rejecting impossible speeds, spoofed hardware, or abusive patterns.
- **Minimum-Group Display Thresholds**: To preserve privacy, the backend should never display individual attendees on the dashboard, enforcing a minimum threshold (e.g., cell/zone density must be >N).
- **Mass Redirection Overload**: If a zone becomes CRITICAL, the backend must stagger recommendations (e.g., redirecting small batches at a time) to avoid causing a new crush in the destination zone. The app blindly renders whatever recommendation it is given.
- **Data Deletion**: We assume event data is automatically purged post-event or when requested via the API, complying with DPDP/GDPR.
