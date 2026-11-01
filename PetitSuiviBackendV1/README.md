# PetitSuivi Backend

Laravel REST API for **PetitSuivi**, the daycare management platform. Serves both the React admin dashboard and the Flutter mobile app (parents + teachers).

## Requirements

- PHP **8.3+** (the Docker image uses 8.4)
- Composer **2.8+**
- MySQL **8** (or SQLite for a quick start)

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
```

Configure the database in `.env`. The example defaults to SQLite; for MySQL:

```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=petitsuivi
DB_USERNAME=petitsuivi
DB_PASSWORD=petitsuivi
```

Then migrate and serve:

```bash
php artisan migrate --force
php artisan serve --host=0.0.0.0 --port=8000
```

> Only two migrations are committed. The authoritative schema is the SQL dump at the repository root (`bkpetitsuivi8.sql`) — import it to get the full schema and data:
> `mysql -u petitsuivi -p petitsuivi < ../bkpetitsuivi8.sql`

## Configuration

Key environment variables beyond the Laravel defaults:

| Variable | Purpose |
| --- | --- |
| `FRONTEND_URL` | Origin allowed by CORS (default `http://localhost:5000`) |
| `COPILOT_API_URL` | URL of the `copilot-api` service for AI features (default `http://copilot:4141`) |
| `SESSION_DRIVER` / `CACHE_STORE` | `file` in the Docker stack, `database` by default |
| `QUEUE_CONNECTION` | `sync` in the Docker stack |

See `.env.example` for the full list.

## API routes

Routes are split by audience and mounted under `/api`:

| File | Prefix | Audience |
| --- | --- | --- |
| `routes/api.php` | `/api` | Public auth, shared endpoints, parent + teacher mobile API |
| `routes/admin.php` | `/api/admin` | Admin dashboard |
| `routes/teacher.php` | `/api/teacher` | Teacher |

Auth uses **Laravel Sanctum** bearer tokens. Public endpoints include `POST /login`, `/login/parent`, `/login/teacher`, `/register`, `/password/forgot`, and `GET /parameters`, `/payment-methods`, `/plannings/active-check`.

Full reference: [`docs/BACKEND_API.md`](docs/BACKEND_API.md).

## Code structure

```text
app/
├── Http/
│   ├── Controllers/Api/
│   │   ├── *.php                 admin controllers
│   │   ├── Auth/                 AuthController (login/register/logout, all roles)
│   │   └── Mobile/
│   │       ├── Parent/           parent app controllers
│   │       └── Teacher/          teacher app controllers
│   └── Middleware/
├── Models/                       ~55 Eloquent models
├── Mail/
├── Providers/
└── Support/
```

Domain areas: children, classes (`SchoolClass`, `Classtype`, `TeacherClass`), inscriptions (+ status/type), accounts (`Account`, `Person`, `Parent`, `Teacher`, `Role`), payments (`Payment`, `Partialpayment`, `Paymentmethod`), food (`Meals`, `Mealplan`, `Menuplanning`, `Childfoodexception` + overrides), activities (`Activity`, `Planday`, `Plandayactivity`, `Criteria`), evaluations (`Evaluation`, `Grade`, `Gradestatus`), presence/attendance, `Events`, `Notification`, `Pickupnotifications`, `Signalement`, `Medicalform`, `Childphoto`.

## AI features

`CopilotController`, `AiSuggestionController`, `ActivitySuggestionController`, and `ReportAnalysisController` call the `copilot-api` service (GitHub Copilot exposed as an OpenAI-compatible API) configured by `COPILOT_API_URL`. It powers activity suggestions, behavioural summaries, and report analysis.

## Documentation

API docs are generated with **Scribe**:

```bash
php artisan scribe:generate
```

Output is written to `docs/` (see `docs/BACKEND_API.md`).

## Testing and style

```bash
php artisan test       # PHPUnit
vendor/bin/pint        # Laravel Pint code style
```

## Docker

The `Dockerfile` uses a two-stage build: Composer installs dependencies in a `composer:2.8` image, then the app is copied into `php:8.4-cli-alpine` with the `intl`, `pdo_mysql`, and `zip` extensions installed.

`docker/entrypoint.sh` runs on container start and:

1. Creates `.env` from `.env.example` if missing.
2. Overrides `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` from the container environment.
3. Sets `SESSION_DRIVER`, `CACHE_STORE`, and `COPILOT_API_URL` when provided.
4. Runs `php artisan optimize:clear`.
5. Generates `APP_KEY` if absent.
6. Runs `php artisan migrate --force`.
7. Execs the container command (`php artisan serve --host=0.0.0.0 --port=8000`).

In the Compose stack the service is named `backend` and depends on a healthy `mysql` container.