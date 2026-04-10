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

## Container Architecture

The Docker stack is made of these services:

- `frontreact`: React admin frontend served by Nginx
- `backend`: Laravel API backend
- `mysql`: MySQL database
- `phpmyadmin`: database administration UI
- `copilot`: AI proxy service
- `petitsuivi-cloudflared`: Cloudflare Tunnel container running on the server

### How the containers communicate

Docker Compose creates an internal network for the services in `docker-compose.yml`.

Inside that Docker network, each service can reach the others by its Compose service name.

That means these hostnames work from one container to another:

- `backend`
- `mysql`
- `copilot`
- `frontreact`
- `phpmyadmin`

### Important rule: service names vs localhost

Use the Docker Compose service name when one container calls another container.

Examples:

- Laravel backend to MySQL:
  - correct: `mysql:3306`
  - wrong: `localhost:3306`

- Laravel backend to Copilot:
  - correct: `http://copilot:4141`
  - wrong: `http://localhost:4141`

Why:

- inside a container, `localhost` means that same container
- it does not mean the Docker host
- it does not mean another service container

So inside the `backend` container:

- `localhost` means the Laravel container itself
- `copilot` means the Copilot container
- `mysql` means the MySQL container

### Host machine access is different

From the server shell or from your PC through a tunnel, you use the published host ports instead of Compose service names.

Examples on the server host:

- frontend: `http://localhost:5001`
- backend: `http://localhost:8001`
- phpMyAdmin: `http://localhost:8081`
- Copilot: `http://localhost:4141`
- MySQL host port: `127.0.0.1:3307`

So the rule is:

- host machine to app: use published host ports
- container to container: use Compose service names

## Request Flow

### Public website flow

The public frontend flow is:

```text
Browser
  -> https://petitsuivi.me
  -> Cloudflare
  -> cloudflared on server
  -> frontreact container
```

The public API flow is:

```text
Browser
  -> https://api.petitsuivi.me
  -> Cloudflare
  -> cloudflared on server
  -> backend container
```

### React admin flow

The admin frontend is a static React build.

It sends API requests to the Laravel backend using `REACT_APP_API_URL`.

In production that resolves to the public API domain.

So the normal app request path is:

```text
Browser
  -> frontreact
  -> backend API
```

### Backend to database flow

Laravel talks to MySQL over the Docker network using:

```text
mysql:3306
```

This is why the backend database host must be `mysql`, not `localhost`.

### Backend to AI flow

Laravel talks to the AI proxy over the Docker network using:

```text
http://copilot:4141
```

This is controlled by:

```text
COPILOT_API_URL
```

Important production note:

- from inside `backend`, `localhost:4141` is wrong
- `copilot:4141` is correct

This exact issue caused the AI activity suggestion feature to fail until the backend was updated to use the Compose service name.

### phpMyAdmin flow

`phpmyadmin` connects internally to:

```text
mysql:3306
```

From your browser, you reach phpMyAdmin through the published host port or through an SSH tunnel.

### Cloudflare Tunnel flow

The Cloudflare Tunnel container does not serve the app itself.
It forwards public traffic to the local server ports.

Current tunnel targets on the server:

- `petitsuivi.me` -> `http://localhost:5001`
- `api.petitsuivi.me` -> `http://localhost:8001`

So Cloudflare points to host ports, not Docker service names directly.

## Architecture Summary

```text
Internet User
  -> Cloudflare
  -> cloudflared (server)
  -> host port 5001 -> frontreact container
  -> host port 8001 -> backend container

backend container
  -> mysql:3306
  -> copilot:4141

phpmyadmin container
  -> mysql:3306

Admin PC
  -> Tailscale / SSH tunnel
  -> server host ports
```

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

## Private Server Access With Tailscale

This project also uses Tailscale for private machine-to-machine access between the development PC and the home server.

Verified nodes:

- local PC: `100.115.223.114`
- server: `100.99.151.115`

Tailscale is used for:

- private SSH access to the server
- private SSH port forwarding
- accessing internal services without exposing them publicly

### Check Tailscale status

On either machine:

```bash
tailscale status
```

### SSH to the server over Tailscale

```bash
ssh test@100.99.151.115
```

If password automation is needed:

```bash
sshpass -p '<your-server-password>' ssh test@100.99.151.115
```

### Tunnel phpMyAdmin to your PC

phpMyAdmin runs on the server at `localhost:8081`.

To expose it on your local machine at `http://localhost:8080`:

```bash
sshpass -p '<your-server-password>' ssh -N -L 8080:localhost:8081 test@100.99.151.115
```

Then open:

```text
http://localhost:8080
```

### Other useful Tailscale SSH tunnels

Laravel API:

```bash
sshpass -p '<your-server-password>' ssh -N -L 8000:localhost:8001 test@100.99.151.115
```

React frontend:

```bash
sshpass -p '<your-server-password>' ssh -N -L 5000:localhost:5001 test@100.99.151.115
```

MySQL direct access:

```bash
sshpass -p '<your-server-password>' ssh -N -L 3307:localhost:3307 test@100.99.151.115
```

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

## Server Auto Start

The production server is configured to come back automatically after reboot.

### Docker stack systemd service

Systemd service file in the repo:

```text
deploy/systemd/petitsuivi-app.service
```

Installed on the server as:

```text
/etc/systemd/system/petitsuivi-app.service
```

This service starts the Docker stack from:

```text
/home/test/PetitSuivi-App
```

It runs:

```bash
docker compose up -d --remove-orphans
```

### Auto-start components after reboot

These are enabled on the server:

- `docker`
- `petitsuivi-app.service`
- `actions.runner.zsasz0-PetitSuivi-App.petitsuivi-app.service`

The containers also use Docker restart policies:

- `unless-stopped`

That means after a server reboot:

1. Docker starts
2. `petitsuivi-app.service` starts the PetitSuivi stack
3. Cloudflare tunnel comes back
4. the GitHub Actions runner comes back
5. CI/CD auto-deploy continues to work

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
