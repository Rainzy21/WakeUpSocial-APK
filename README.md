# Wake Up Social APK

Flutter application for ordering food/drinks at Wake Up Social Coffee Shop.

## Features
- QR Code Scanning for Tables
- Menu Browsing & Cart Management
- Order Placement & Live Tracking (Realtime Supabase)
- Profile Management & Loyalty Points
- Payment Tracking

## Setup Instructions

1. Install Flutter (version >= 3.11).
2. Clone this repository.
3. Copy `wakeupsocial_apk/.env.example` to `wakeupsocial_apk/.env` and fill in your Supabase credentials.
4. Run `flutter pub get` inside `wakeupsocial_apk`.
5. Run `flutter run --dart-define-from-file=.env` to start the application.

## Building APK
```bash
flutter build apk --split-per-abi --dart-define-from-file=.env
```

## Security
- API Keys are managed using `--dart-define-from-file=.env`. Do not hardcode them.
- Ensure only `anon` keys are used in the application.

## CI/CD
- GitHub Actions are set up for automated building and testing on Push/Pull Request to `main`.
