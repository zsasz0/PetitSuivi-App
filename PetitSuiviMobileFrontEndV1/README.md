# PetitSuivi Mobile

Flutter app for **PetitSuivi**, the daycare management platform. One codebase, two roles: **parents** and **teachers**.

## Requirements

- Flutter SDK **3.38+** (Dart 3.10+)
- Android Studio or Xcode for device builds

## Setup

```bash
flutter pub get
```

Point the app at your backend with `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000  # iOS simulator / desktop
```

The default is `https://api.petitsuivi.me` (set in `lib/utils/api_constants.dart`).

Web build:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.petitsuivi.me
```

## Structure

```text
lib/
├── main.dart
├── l10n/          French localization (.arb)
├── models/        child, payment, evaluation, planning, notification, ...
├── services/      notifications, photos, evaluations, auth session
├── utils/         API constants, unauthorized handler
└── views/
    ├── auth/      login + multi-step registration
    ├── intro/     splash + onboarding
    ├── parent/    home, child tracking, payments, photos, profile, notifications
    ├── teacher/   home, classes, activities, photos, profile, notifications
    ├── shared/    combined home shell, event details, support
    └── themes/    app theme + theme manager
```

Each feature folder follows `apis / components / controllers / themes`.