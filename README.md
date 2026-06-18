<div align="center">
  
  ![Flutter Version](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter)
  ![Dart Version](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
  ![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?logo=supabase)

  <h1>☕ Wake Up Social APK</h1>
  <p>
    <strong>A modern, real-time Flutter application for ordering food and drinks at Wake Up Social Coffee Shop.</strong>
  </p>
  
  <h3>
    <a href="wakeupsocial_apk/build/app/outputs/flutter-apk/app-release.apk">📥 Download Latest APK</a>
  </h3>
</div>

<br />

## 📋 Table of Contents
- [Download & Install](#-download--install)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Building the APK](#-building-the-apk)
- [Security & Architecture](#-security--architecture)
- [Observability](#-observability)
- [Rollback Plan](#-rollback-plan)

---

## 📥 Download & Install

If you just want to test the application without compiling it from source:
1. Download the latest APK file directly from this repository: [app-release.apk](wakeupsocial_apk/build/app/outputs/flutter-apk/app-release.apk).
2. Transfer the APK file to your Android device.
3. Open the file on your device and follow the prompts to install it (make sure "Install from Unknown Sources" is enabled in your Android settings).

---

## ✨ Features

- **📱 QR Code Scanning** — Quickly scan table QR codes to initiate a dine-in session.
- **🛒 Menu & Cart Management** — Browse categories, view items, and manage your cart seamlessly.
- **⚡ Real-time Order Tracking** — Place orders and track their status live via Supabase Realtime streams.
- **👤 Profile & Loyalty System** — Manage user profiles, track lifetime orders, and collect loyalty points.
- **💳 Payment Tracking** — Keep track of cash/transfer payment statuses.
- **🛡️ Secure Data Access** — Hardened Row Level Security (RLS) on the database ensuring users only see their own orders.

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart), Provider (State Management)
- **Backend (BaaS):** Supabase (PostgreSQL, Authentication, Realtime, Edge Functions)
- **Monitoring:** Sentry (Crash Reporting), Custom AppLogger (JSON Structured Logging)
- **Hardware Integrations:** `mobile_scanner` for QR code reading

---

## 📦 Prerequisites

Before you begin, ensure you have met the following requirements:
- **Flutter SDK:** Version `3.11` or higher.
- **Dart SDK:** Version `3.0` or higher.
- **Supabase Account:** A Supabase project set up with the required database schema (see `supabase/migrations`).

---

## 🚀 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/WakeUpSocial-APK.git
   cd WakeUpSocial-APK/wakeupsocial_apk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration**
   Copy the `.env.example` file to create your own `.env` file:
   ```bash
   cp .env.example .env
   ```
   Open the `.env` file and fill in your Supabase credentials:
   ```env
   SUPABASE_URL="YOUR_SUPABASE_URL"
   SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
   SUPPORT_WHATSAPP_NUMBER="6281234567890"
   SENTRY_DSN="" # Optional for crash reporting
   ```

4. **Run the App**
   Start the application and inject the environment variables:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

---

## 🏗 Building the APK

### Debug Build
```bash
flutter build apk --debug --dart-define-from-file=.env
```

### Release Build
To build a release APK, you must first set up your signing keystore:
1. Copy the example key properties file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Edit `android/key.properties` and add your upload keystore credentials.
3. Build the app:
   ```bash
   flutter build apk --release --dart-define-from-file=.env
   ```

---

## 🔒 Security & Architecture

- **Environment Injection:** API keys are injected via `--dart-define-from-file=.env`. They are **never** hardcoded in the source code.
- **Auth Tokens Only:** Ensure only the `anon` key is used in the `.env` file. Never use the `service_role` key on the client.
- **RLS Enforcement:** Profile role escalation and order snooping are blocked server-side via RLS triggers and policies (see migration `005_security_hardening.sql`).

---

## 📊 Observability

- **Structured Logging:** All app logs are outputted in JSON format via `AppLogger` (`lib/core/observability/app_logger.dart`).
- **Metrics:** Operation success/failure and slow-call detection are handled via `AppMetrics`.
- **Crash Reporting:** If `SENTRY_DSN` is provided in the `.env` file, crashes are automatically reported to Sentry. If empty, local zone handlers safely catch and log errors locally.
- **Network Resilience:** All Supabase repository calls are wrapped in `ResilientCall` (15s timeout, 2 retries on transient network failures).

---

## 🔄 Rollback Plan

1. **App:** Revert to the previous release APK build from your store or internal distribution channel.
2. **Database:** Migrations are forward-only. Roll back schema changes manually via Supabase SQL editor if needed (avoid dropping production data).
3. **Edge functions:** Redeploy the prior function version: `supabase functions deploy send-fcm --version <previous>`.
4. **Env/Config:** Restore prior `.env` dart-define values if credentials were unexpectedly rotated.
