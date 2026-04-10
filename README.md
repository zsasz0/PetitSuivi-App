# PetitSuivi App

PetitSuivi is a multi-part application made of:

- `PetitSuiviBackendV1`: Laravel API backend
- `PetitSuiviAdminFrontEndV1`: React admin frontend
- `PetitSuiviMobileFrontEndV1`: Flutter mobile app
- `copilot-api`: helper service
- `docker-compose.yml`: Docker stack for backend, admin frontend, database, phpMyAdmin, and Copilot
- `switch_env.sh`: helper to switch local and production API URLs

This repository also includes the production deployment flow used on the home server.

## Repository Layout

```text
PetitSuivi-App/
├── PetitSuiviBackendV1/
├── PetitSuiviAdminFrontEndV1/
├── PetitSuiviMobileFrontEndV1/
├── copilot-api/
├── .github/workflows/deploy.yml
├── docker-compose.yml
├── scripts/deploy.sh
└── switch_env.sh
```

## What Runs In Docker

The current Docker stack runs these services:

- `mysql`
- `backend`
- `frontreact`
- `copilot`
- `phpmyadmin`

The Flutter app is not deployed in Docker in the current setup.

## Local Development

### Requirements

- Docker
- Docker Compose
- Node.js and npm for local React development if needed
- PHP and Composer for local Laravel development if needed
- Flutter SDK for the mobile app

### Start the local stack

From the repository root:

```bash
docker compose up --build
```

Local endpoints:

- React admin: `http://localhost:5000`
- Laravel API: `http://localhost:8000`
- phpMyAdmin: `http://localhost:8081`
- Copilot API: `http://localhost:4141`
- MySQL from host: `127.0.0.1:3307`

### phpMyAdmin login

- Host from browser: `http://localhost:8081`
- User: `root`
- Password: `root`

Or:

- User: `petitsuivi`
- Password: `petitsuivi`

### Run parts without Docker

#### Backend

```bash
cd PetitSuiviBackendV1
composer install
php artisan serve
```

#### React admin

```bash
cd PetitSuiviAdminFrontEndV1
npm install
npm start
```

#### Flutter mobile

```bash
cd PetitSuiviMobileFrontEndV1
flutter pub get
flutter run
```

## Environment Switching

Use the helper script from the repo root:

```bash
bash switch_env.sh local
```

or:

```bash
bash switch_env.sh prod
```

What it updates:

- `App/.env`
- `PetitSuiviAdminFrontEndV1/.env`
- `PetitSuiviBackendV1/.env`
- Flutter API constant in `PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart`

Important notes:

- React uses build-time environment values, so after switching env you must rebuild the React container:

```bash
docker compose up -d --build frontreact
```

- Flutter is not using a `.env` file here. The script updates the Flutter source config, so you must rebuild or rerun the Flutter app after switching.

## Production Server Setup

Production is running on the home server under:

```bash
/home/test/PetitSuivi-App
```

The old `~/Desktop/app` copy was removed to avoid serving stale code.

### Production containers

Current running containers on the server:

- `petitsuivi-backend`
- `petitsuivi-frontreact`
- `petitsuivi-mysql`
- `petitsuivi-phpmyadmin`
- `petitsuivi-copilot`
- `petitsuivi-cloudflared`

### Production port mapping on the server

Because some default host ports were already in use, production uses:

- React admin: `5001 -> 80`
- Backend: `8001 -> 8000`
- phpMyAdmin: `8081 -> 80`
- Copilot: `4141 -> 4141`
- MySQL host access: `3307 -> 3306`

### Public URLs

- Frontend: `https://petitsuivi.me`
- API: `https://api.petitsuivi.me`

Cloudflare Tunnel forwards those domains to the local server ports.

## Database

The production MySQL database was loaded from:

```text
PetitSuivi/petitsuiviv1(6).sql
```

That SQL dump is imported into the active MySQL database used by the Laravel backend.

Laravel support tables were also created for runtime support:

- `personal_access_tokens`
- `sessions`
- `cache`
- `cache_locks`

### Verified login test

The deployment was verified with this admin account:

- Email: `admin@testing.com`
- Password: `password`

## Backend Notes

The backend Docker image uses PHP 8.4.

The backend container entrypoint does the following:

- ensures `.env` exists
- syncs Docker database/session/cache values into `.env`
- clears Laravel cached config
- generates `APP_KEY` if missing
- runs migrations
- starts the Laravel server

The root route `/` returns a simple JSON health-style response:

```json
{"name":"Laravel","status":"ok"}
```

## CI/CD Auto Deploy

This repo is configured to auto-deploy on every push to `main`.

### GitHub Actions workflow

Workflow file:

```text
.github/workflows/deploy.yml
```

### Deployment script

Script used by the workflow:

```text
scripts/deploy.sh
```

### Self-hosted runner

The repo has its own dedicated GitHub Actions self-hosted runner on the server:

- runner name: `petitsuivi-app`
- labels:
  - `self-hosted`
  - `Linux`
  - `X64`
  - `petitsuivi-app`
  - `deployer`

The runner service on the server is:

```text
actions.runner.zsasz0-PetitSuivi-App.petitsuivi-app.service
```

### What auto-deploy does

On push to `main`, the workflow:

1. runs on the self-hosted server runner
2. checks which files changed
3. syncs `/home/test/PetitSuivi-App` to `origin/main`
4. rebuilds only the affected services when possible
5. verifies the public endpoints after deploy

### Service rebuild rules

- changes in `PetitSuiviBackendV1/**` rebuild `backend`
- changes in `PetitSuiviAdminFrontEndV1/**` rebuild `frontreact`
- changes in `copilot-api/**` rebuild `copilot`
- changes in `docker-compose.yml`, `switch_env.sh`, workflow files, or deploy scripts trigger the full app service deploy

### Verified workflow

The deploy workflow has already been tested successfully from GitHub.

Recent successful run:

- workflow: `Deploy`
- trigger: push to `main`
- run status: success

## Useful Commands

### Local Docker

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f backend
```

### Server Docker

```bash
ssh test@192.168.100.32
cd ~/PetitSuivi-App
docker compose ps
docker compose logs -f backend
```

### Manual deploy on server

```bash
cd ~/PetitSuivi-App
bash scripts/deploy.sh ~/PetitSuivi-App backend frontreact
```

### Check runner status on server

```bash
systemctl status actions.runner.zsasz0-PetitSuivi-App.petitsuivi-app.service
```

## Notes

- Local `.env` files are intentionally ignored and are not committed.
- The production deploy checkout is hard-synced to `origin/main` during CI/CD.
- The Docker MySQL host port is `3307` because `3306` was already occupied on the host.
- Flutter mobile is part of the repo but not part of the production Docker deployment.
