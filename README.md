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
3. Copy `wakeupsocial_apk/.env.example` to `wakeupsocial_apk/.env` and fill in your Supabase credentials and support WhatsApp number.
4. Run `flutter pub get` inside `wakeupsocial_apk`.
5. Run `flutter run --dart-define-from-file=.env` to start the application.

## Building APK

Debug build:
```bash
flutter build apk --debug --dart-define-from-file=.env
```

Release build (requires signing keystore):
```bash
cp android/key.properties.example android/key.properties
# Edit key.properties and add your upload keystore
flutter build apk --split-per-abi --dart-define-from-file=.env
```

## Security
- API keys are injected via `--dart-define-from-file=.env`. They are not hardcoded in source.
- Ensure only `anon` keys are used in the application.
- Profile role escalation is blocked server-side via RLS trigger (migration `005_security_hardening.sql`).

## Observability
- **Structured logging:** JSON logs via `AppLogger` (`lib/core/observability/app_logger.dart`).
- **Metrics:** Operation success/failure and slow-call detection via `AppMetrics`.
- **Crash reporting:** Optional Sentry when `SENTRY_DSN` is set in `.env`. Without it, errors are logged locally and captured by Flutter zone handlers.
- **Network resilience:** All repository Supabase calls use `ResilientCall` (15s timeout, 2 retries on transient failures).

## Database Migrations
- SQL migrations live in `wakeupsocial_apk/supabase/migrations/`.
- Apply in order (`001` → `005`) via Supabase CLI or dashboard.
- See `wakeupsocial_apk/supabase/README.md` for details.

## CI/CD
- GitHub Actions runs format, analyze, dependency audit, tests, and a debug APK build on push/PR to `main`.
- Configure repository secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

## Rollback Plan
1. **App:** Revert to the previous release APK/IPA build from your store or internal distribution channel.
2. **Database:** Migrations are forward-only; roll back schema changes manually via Supabase SQL editor if needed (avoid dropping production data).
3. **Edge functions:** Redeploy the prior function version: `supabase functions deploy send-fcm --version <previous>`.
4. **Env/config:** Restore prior `.env` dart-define values and GitHub secrets if credentials were rotated.
