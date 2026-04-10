# PetitSuivi App

This repository contains the PetitSuivi application stack:

- `PetitSuiviBackendV1`: Laravel API backend
- `PetitSuiviAdminFrontEndV1`: React admin frontend
- `PetitSuiviMobileFrontEndV1`: Flutter mobile app
- `copilot-api`: Copilot helper service
- `docker-compose.yml`: local Docker stack
- `switch_env.sh`: environment switching helper

## Requirements

- Docker
- Docker Compose

## Run With Docker

From the repository root:

```bash
docker compose up --build
```

Main local endpoints:

- React admin: `http://localhost:5000`
- Laravel API: `http://localhost:8000`
- phpMyAdmin: `http://localhost:8081`
- MySQL host access: `127.0.0.1:3307`
- Copilot API: `http://localhost:4141`

phpMyAdmin credentials:

- User: `root`
- Password: `root`

Or:

- User: `petitsuivi`
- Password: `petitsuivi`

## Services

The Docker stack starts these containers:

- `mysql`
- `backend`
- `frontreact`
- `copilot`
- `phpmyadmin`

The Flutter app is not run in Docker in the current setup.

## Environment Switching

Use the helper script from the repository root:

```bash
bash switch_env.sh local
```

or:

```bash
bash switch_env.sh prod
```

After switching frontend API values, rebuild the React container:

```bash
docker compose up -d --build frontreact
```

## Local App Structure

### Backend

```bash
cd PetitSuiviBackendV1
composer install
php artisan serve
```

### React Admin

```bash
cd PetitSuiviAdminFrontEndV1
npm install
npm start
```

### Flutter Mobile

```bash
cd PetitSuiviMobileFrontEndV1
flutter pub get
flutter run
```

## Notes

- Local `.env` files are ignored and are not committed.
- The backend container auto-runs migrations on startup.
- MySQL is exposed on `3307` because `3306` was already in use on the host.
