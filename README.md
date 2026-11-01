# PetitSuivi

**PetitSuivi** is a daycare / kindergarten management platform. It covers the full daily life of a childcare centre: children, classes, inscriptions (enrolment) and approvals, attendance, meals and dietary exceptions, activities and planning, competency evaluations, photo sharing, payments, events and notifications â€” for **administrators**, **teachers** and **parents**.

The repository is a monorepo containing four services, orchestrated with Docker Compose:

| Module | Stack | Dev port | Role |
| --- | --- | --- | --- |
| [`PetitSuiviBackendV1`](PetitSuiviBackendV1) | Laravel 13 Â· PHP 8.3+ Â· Sanctum | `8000` | REST API shared by the admin and mobile apps |
| [`PetitSuiviAdminFrontEndV1`](PetitSuiviAdminFrontEndV1) | React 18 Â· MUI 5 Â· CRA Â· axios | `5000` | Admin / staff web dashboard |
| [`PetitSuiviMobileFrontEndV1`](PetitSuiviMobileFrontEndV1) | Flutter 3 Â· Dart Â· Provider | â€” | Parent + teacher mobile app (Android, iOS, web, desktop) |
| [`copilot-api`](copilot-api) | Bun Â· TypeScript | `4141` | GitHub Copilot â†’ OpenAI-compatible proxy used for AI features |

Supporting services: **MySQL 8.4** (`3307`) and **phpMyAdmin** (`8081`).

Production runs at **https://petitsuivi.me** (dashboard) and **https://api.petitsuivi.me** (API), deployed from `main` by GitHub Actions to a self-hosted runner (see `.github/workflows/deploy.yml`).

---

## Table of contents

- [Architecture](#architecture)
- [Quick start with Docker](#quick-start-with-docker)
- [Manual development setup](#manual-development-setup)
  - [Backend](#backend-petitsuvibackendv1)
  - [Admin frontend](#admin-frontend-petitsuiviadminfrontendv1)
  - [Mobile app](#mobile-app-petitsuivimobilefrontendv1)
- [Database](#database)
- [Environment switching](#environment-switching)
- [Deployment](#deployment)
- [API overview](#api-overview)
- [Repository layout](#repository-layout)
- [Design documentation](#design-documentation)

---

## Architecture

```text
                    +---------------------------+
   Admin browser -->|  PetitSuiviAdminFrontEnd  |  React (nginx :80 -> :5000)
                    +-------------+-------------+
                                  | HTTPS /api
   Mobile app (Flutter) --------->|
                                  v
                    +---------------------------+
                    |     PetitSuiviBackend     |  Laravel (artisan serve :8000)
                    +-----+---------------+-----+
                          |               |
                +---------v--+      +-----v---------+
                |  MySQL 8.4 |      |  copilot-api  |  Bun/TS :4141
                +------------+      +-------+-------+
                                            |
                                   GitHub Copilot (GH_TOKEN)
```

The backend splits its routes by audience:

- `routes/api.php` â€” public auth, shared endpoints, and the parent + teacher mobile API (Sanctum-protected).
- `routes/admin.php` â€” admin dashboard API under `/api/admin`.
- `routes/teacher.php` â€” teacher API under `/api/teacher`.

AI-assisted features (activity suggestions, behavioural summaries, report analysis) call the `copilot-api` service through `COPILOT_API_URL`.

---

## Quick start with Docker

**Requirements:** Docker Engine and Docker Compose v2.

```bash
git clone https://github.com/zsasz0/PetitSuivi-App.git
cd PetitSuivi-App
docker compose up -d --build
```

| Service | URL |
| --- | --- |
| Admin dashboard | http://localhost:5000 |
| Backend API | http://localhost:8000 |
| phpMyAdmin | http://localhost:8081 |
| MySQL | `localhost:3307` |
| copilot-api | http://localhost:4141 |

The backend container's entrypoint (`PetitSuiviBackendV1/docker/entrypoint.sh`) creates `.env` from the example, injects DB credentials from the container environment, generates `APP_KEY`, clears caches, runs `php artisan migrate --force`, then starts `php artisan serve`.

Compose can be tuned with a root `.env`:

```dotenv
MYSQL_DATABASE=petitsuivi
MYSQL_USER=petitsuivi
MYSQL_PASSWORD=petitsuivi
MYSQL_ROOT_PASSWORD=root
MYSQL_PORT=3307
BACKEND_PORT=8000
FRONTEND_PORT=5000
PHPMYADMIN_PORT=8081
COPILOT_PORT=4141
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:5000
REACT_APP_API_URL=http://localhost:8000/api
COPILOT_API_URL=http://copilot:4141
GH_TOKEN=            # required by copilot-api for AI features
```

> The mobile app is **not** part of `docker-compose.yml`. Its `Dockerfile` builds a Flutter **web** bundle served by nginx and accepts `API_BASE_URL` as a build arg â€” add it as an extra Compose service if you want the web build in the stack.

Stop the stack with `docker compose down` (add `-v` to drop the MySQL and copilot volumes).

---

## Manual development setup

### Backend (`PetitSuiviBackendV1`)

**Requirements:** PHP 8.3+ (the Docker image uses 8.4), Composer 2.8+, MySQL 8 (or SQLite for a quick start).

```bash
cd PetitSuiviBackendV1
composer install
cp .env.example .env
php artisan key:generate

# Point DB_* at your MySQL instance, or keep the SQLite default
php artisan migrate --force

php artisan serve --host=0.0.0.0 --port=8000
```

Notes:

- `.env.example` defaults to **SQLite**; the Docker stack overrides it to MySQL.
- Only two migration files are committed â€” the authoritative schema is the SQL dump (see [Database](#database)).
- API docs are generated with **Scribe** and committed to [`docs/BACKEND_API.md`](PetitSuiviBackendV1/docs/BACKEND_API.md). Regenerate with `php artisan scribe:generate`.
- Code style: `vendor/bin/pint`. Tests: `php artisan test`.

### Admin frontend (`PetitSuiviAdminFrontEndV1`)

**Requirements:** Node 18+ and npm.

```bash
cd PetitSuiviAdminFrontEndV1
npm install --legacy-peer-deps
```

Create `PetitSuiviAdminFrontEndV1/.env`:

```dotenv
REACT_APP_API_URL=http://localhost:8000/api
```

```bash
npm start      # dev server on http://localhost:5000
npm run build  # production build into build/
```

In production the build is served by nginx using `nginx.conf` (SPA fallback to `index.html`) â€” see `Dockerfile.prod`. The API URL is baked in at build time via the `REACT_APP_API_URL` build arg.

### Mobile app (`PetitSuiviMobileFrontEndV1`)

**Requirements:** Flutter SDK 3.38+ (Dart 3.10+); Android Studio / Xcode for device builds.

```bash
cd PetitSuiviMobileFrontEndV1
flutter pub get

# Defaults to https://api.petitsuivi.me; override per target:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000  # iOS simulator / desktop
```

The base URL is read in `lib/utils/api_constants.dart` via `String.fromEnvironment('API_BASE_URL')`. Web build:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.petitsuivi.me
```

The UI is French (localization files in `lib/l10n/`). Code is organized per role and feature:

```text
lib/
  main.dart
  models/       # data models (child, payment, evaluation, planning, ...)
  services/     # notifications, photos, evaluations, auth session
  utils/        # API constants, unauthorized handler
  l10n/         # French localization (.arb)
  views/
    auth/       # login, multi-step registration
    intro/      # splash + onboarding animation
    parent/     # home, child tracking, payments, photos, profile, notifications
    teacher/    # home, classes, activities, photos, profile, notifications
    shared/     # combined home shell, event details, support
    themes/     # app theme + theme manager
```

Each feature folder follows the same `apis / components / controllers / themes` split.

---

## Database

The authoritative schema is the dump [`bkpetitsuivi8.sql`](bkpetitsuivi8.sql) (~320 KB) at the repo root. Migrations are minimal, so seed a database from the dump:

```bash
mysql -u petitsuivi -p petitsuivi < bkpetitsuivi8.sql
```

```bash
docker compose exec -T mysql mysql -uroot -proot petitsuivi < bkpetitsuivi8.sql
```

phpMyAdmin is available at http://localhost:8081 for browsing and editing data.

---

## Environment switching

`switch_env.sh` rewrites the API URLs for **local** or **production** across all three apps:

```bash
./switch_env.sh local   # 127.0.0.1:8000 / localhost:5000
./switch_env.sh prod    # https://api.petitsuivi.me / https://petitsuivi.me
```

It updates:

- `PetitSuiviAdminFrontEndV1/.env` â†’ `REACT_APP_API_URL`
- root `.env` â†’ `APP_URL`, `FRONTEND_URL`, `REACT_APP_API_URL`
- `PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart` â†’ `baseUrl`
- `PetitSuiviBackendV1/.env` â†’ `APP_URL`

Bash (Git Bash / WSL / Linux) is required on Windows.

---

## Deployment

`.github/workflows/deploy.yml` runs on every push to `main` on a **self-hosted Linux runner**:

1. Diffs the pushed commit range and selects only the affected Compose services.
2. Runs `scripts/deploy.sh $TARGET $SERVICES` on the runner, which fetches `origin/main`, hard-resets to it, and runs `docker compose up -d --build` for the selected services.
3. Verifies the public endpoints (`https://petitsuivi.me`, `https://api.petitsuivi.me`, and the CORS preflight for `/api/login`) with retries.

The runner needs Docker, a checkout at the target path (default `$HOME/PetitSuivi-App`), and the repo secrets/vars used by the stack. A systemd unit for keeping the stack up is in `deploy/systemd/petitsuivi-app.service`.

`scripts/cloudflared-control.sh` manages the Cloudflare Tunnel used to expose the local stack publicly.

---

## API overview

Base URL: `http://localhost:8000/api` (or `https://api.petitsuivi.me/api`).

Authentication uses **Laravel Sanctum** bearer tokens. Public endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/login` | Admin login |
| `POST` | `/login/parent` | Parent mobile login |
| `POST` | `/login/teacher` | Teacher mobile login |
| `POST` | `/register` | Parent registration |
| `POST` | `/register/check-email` | Email availability |
| `POST` | `/register/check-cin` | CIN availability |
| `POST` | `/password/forgot` | Password reset request |
| `GET` | `/parameters` | Public app parameters |
| `GET` | `/payment-methods` | Public payment methods |
| `GET` | `/plannings/active-check` | Whether an active planning exists |

Authenticated (Sanctum) groups cover:

- **Shared** â€” `/logout`, `/me`, classes & activities, attendance (`/classes/{id}/presences`), evaluations, signalements, child AI summaries.
- **Parent** â€” `/parents/{cin}/children`, re-registration, profile, payments, child presences, photos, pickup notifications, notification inbox + unread counts, password change.
- **Admin** â€” see `routes/admin.php`.
- **Teacher** â€” see `routes/teacher.php`.

Full request/response documentation: [`PetitSuiviBackendV1/docs/BACKEND_API.md`](PetitSuiviBackendV1/docs/BACKEND_API.md).

---

## Repository layout

```text
PetitSuivi-App/
â”œâ”€â”€ PetitSuiviBackendV1/          Laravel API
â”‚   â”œâ”€â”€ app/Http/Controllers/Api/  Admin Â· Mobile/{Parent,Teacher} Â· Auth controllers
â”‚   â”œâ”€â”€ app/Models/                ~55 Eloquent models
â”‚   â”œâ”€â”€ routes/                    api.php Â· admin.php Â· teacher.php
â”‚   â”œâ”€â”€ database/                  minimal migrations + seeders
â”‚   â”œâ”€â”€ docs/BACKEND_API.md        Scribe-generated API reference
â”‚   â””â”€â”€ Dockerfile, docker/entrypoint.sh
â”œâ”€â”€ PetitSuiviAdminFrontEndV1/    React admin dashboard
â”‚   â”œâ”€â”€ src/interfaces/            feature slices: dashboard Â· classes Â· inscriptions Â·
â”‚   â”‚                              events Â· activities Â· food Â· payments Â· reports Â· ...
â”‚   â”œâ”€â”€ src/components/            shared Header, StatBox, ProgressCircle
â”‚   â”œâ”€â”€ src/context/               AuthContext
â”‚   â”œâ”€â”€ nginx.conf                 SPA fallback config
â”‚   â””â”€â”€ Dockerfile.prod
â”œâ”€â”€ PetitSuiviMobileFrontEndV1/  Flutter parent + teacher app
â”‚   â”œâ”€â”€ lib/models/                data models
â”‚   â”œâ”€â”€ lib/services/              notifications, photos, evaluations
â”‚   â”œâ”€â”€ lib/views/{auth,intro,parent,teacher,shared,themes}
â”‚   â””â”€â”€ Dockerfile                 builds Flutter web bundle
â”œâ”€â”€ copilot-api/                  GitHub Copilot -> OpenAI-compatible proxy (Bun)
â”œâ”€â”€ scripts/                      deploy.sh Â· cloudflared-control.sh
â”œâ”€â”€ deploy/systemd/               petitsuivi-app.service
â”œâ”€â”€ .github/workflows/deploy.yml  CI/CD
â”œâ”€â”€ docker-compose.yml            full local/production stack
â”œâ”€â”€ switch_env.sh                 switch local/prod API URLs across apps
â”œâ”€â”€ bkpetitsuivi8.sql             database dump (authoritative schema)
â”œâ”€â”€ main.pdf                      project report
â”œâ”€â”€ domainev3.jpg                 domain diagram
â””â”€â”€ cas d'utilisationv3.jpg       use-case diagram
```

---

## Design documentation

### Class diagram

![Class diagram](images/class%20diagram.png)

### Use-case diagram

![Use-case diagram](images/use%20case%20diag.png)

### Architecture layers

![Architecture layers](images/arch.png)

### Further reading

- [`main.pdf`](main.pdf) - full project report
- [`PetitSuiviBackendV1/docs/BACKEND_API.md`](PetitSuiviBackendV1/docs/BACKEND_API.md) - API reference

---

## License

No license file is currently included in this repository.
