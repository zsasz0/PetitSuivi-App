# Backend API Documentation

Base URL: `/api`

Authentication:
- Protected endpoints use `Authorization: Bearer <token>`
- Backend auth is based on Laravel Sanctum
- Main route groups are protected by role middleware:
  - admin: `auth:sanctum`, `role:admin`
  - teacher: `auth:sanctum`, `role:teacher`
  - parent: `auth:sanctum`, `role:parent`

## Public Authentication

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/login` | Admin login |
| POST | `/register` | Mobile registration |
| POST | `/login/teacher` | Teacher mobile login |
| POST | `/login/parent` | Parent mobile login |
| GET | `/parameters` | Public app parameters |
| GET | `/payment-methods` | Public payment methods |

## Shared Authenticated Routes

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/logout` | Logout current user |
| GET | `/me` | Current authenticated user |

## Mobile Shared Routes

### Classes, Attendance, Evaluations

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/teachers/{cin}/classes/by-planning` | Teacher classes by planning |
| GET | `/teachers/{cin}/classes` | Alias of classes by planning |
| GET | `/teachers/{cin}/classes/{classId}/activities` | Class activities |
| PATCH | `/teachers/{cin}/classes/{classId}/activities/{activityId}/status` | Update activity status |
| GET | `/classes/{classId}/presences` | Presence list |
| POST | `/classes/{classId}/presences` | Create presences |
| PUT | `/classes/{classId}/presences/{presenceId}` | Update presence |
| GET | `/classes/{classId}/students` | Students in class |
| GET | `/classes/{classId}/activities/date/{date}` | Activities by date |
| GET | `/children/{id}/evaluations/date/{date}` | Child evaluations by date |
| GET | `/children/{id}/evaluations/parent-view` | Parent child evaluation view |
| POST | `/evaluations` | Create one evaluation |
| POST | `/evaluations/bulk` | Create evaluations in bulk |

### Signalements

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/children/{id}/signalements` | Child signalements |
| GET | `/children/{childId}/ai-summaries` | AI summaries for child signalements |
| POST | `/signalements` | Create signalement |

### Parent Mobile Core

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/parents/{cin}/children` | Parent children and inscriptions |
| POST | `/parents/{cin}/children` | Register new child |
| POST | `/parents/{cin}/children/{childId}/re-register` | Re-register existing child |
| GET | `/parents/{cin}/profile` | Parent profile |
| PUT | `/parents/{cin}/profile` | Update parent profile |
| GET | `/parents/{cin}/payments` | Parent payment history |
| GET | `/children/{childId}/presences` | Parent child presences |
| GET | `/children/{childId}/photos` | Parent child photos |
| GET | `/photos/{photoId}/download` | Download photo |
| POST | `/notifications/pickup` | Parent pickup notification |
| GET | `/parents/notifications` | Parent notifications |
| PATCH | `/parents/notifications/mark-all-read` | Mark all parent notifications read |
| PATCH | `/parents/notifications/{id}/read` | Mark one parent notification read |
| GET | `/parents/notifications/unread-count` | Parent unread count |
| POST | `/password/change` | Parent password change |

## Admin Routes

Prefix: `/api/admin`

### Accounts, Teachers, Parents, Children

| Method | Path | Purpose |
| --- | --- | --- |
| GET/POST/PUT/PATCH | `/accounts` | Account CRUD except delete |
| GET/POST/PUT/DELETE | `/teachers` | Teacher CRUD |
| PATCH | `/teachers/{cin}/toggle-archive` | Archive/unarchive teacher |
| GET/POST/PUT/DELETE | `/parents` | Parent CRUD |
| PATCH | `/parents/{cin}/approval-status` | Parent approval status |
| PATCH | `/parents/{cin}/toggle-archive` | Archive/unarchive parent |
| GET/PUT | `/children` | Child list and update |

### Classes and Planning

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/class-types` | Class types |
| GET/POST | `/classes` | Class list and create |
| GET/PUT/DELETE | `/classes/{id}` | Class detail/update/delete |
| PATCH | `/classes/{id}/toggle-archive` | Archive/unarchive class |
| POST | `/plannings/archive-current-year` | Archive active planning year |
| GET/POST | `/plannings` | Planning list/create |
| GET/PUT/DELETE | `/plannings/{id}` | Planning detail/update/delete |

### Inscriptions and Payments

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/inscriptions` | Inscriptions list |
| GET | `/registrations` | Alias of inscriptions list |
| GET | `/inscriptions/{id}` | Inscription detail |
| PATCH | `/inscriptions/{id}/status` | Update inscription status |
| PATCH | `/inscriptions/{id}/toggle-archive` | Archive/unarchive inscription |
| PUT | `/inscriptions/{childId}/ai-comments` | Save AI comments |
| POST | `/inscriptions/{childId}/rescan-medical` | Rescan medical form |
| POST | `/inscriptions/{childId}/scan-meals` | Scan meals |
| POST | `/inscriptions/{childId}/save-food-exceptions` | Save food exceptions |
| POST | `/inscriptions/custom-api` | Proxy custom AI call |
| GET/POST | `/payments` | Payments list/create |
| GET/PUT | `/payments/{id}` | Payment detail/update |
| POST | `/payments/{inscriptionId}/{childId}/transactions` | Create partial payment transaction |
| GET | `/partials` | Partial payments list |
| PATCH | `/inscriptions/{id}/frais` | Toggle frais inscription state |
| GET | `/plannings/{id}/payment-report` | Planning payment report |
| GET | `/plannings/{id}/payment-report/month/{month}` | Monthly payment detail report |

### Activities and Criteria

| Method | Path | Purpose |
| --- | --- | --- |
| GET/POST | `/activities` | Activities list/create |
| PUT/DELETE | `/activities/{id}` | Update/delete activity template |
| GET/POST | `/criteria` | Criteria list/create |
| DELETE | `/criteria/{id}` | Delete criteria |
| GET | `/plannings/{id}/activities` | Planned activities for planning |
| POST | `/plannings/{id}/activities` | Create planned activity |
| DELETE | `/plannings/{id}/activities/{activityId}` | Delete planned activity |
| GET | `/activities/by-date/{date}` | Activities by date |
| POST | `/ai/suggest-activity-criteria` | AI criteria suggestions |

### Meals and Food Exceptions

| Method | Path | Purpose |
| --- | --- | --- |
| GET/POST | `/meals` | Meals list/create |
| GET | `/meals/by-week/{date}` | Meals by week |
| POST | `/meals/check-exceptions` | Check dietary conflicts |
| POST | `/meals/save-exceptions` | Save exceptions |
| DELETE | `/meals/{id}` | Delete meal |
| GET/POST | `/food-exceptions` | Food exceptions list/create |
| DELETE | `/food-exceptions/{id}` | Delete food exception |
| GET/POST | `/menu-plannings` | Meal preset list/create |
| POST | `/menu-plannings/apply-week` | Apply preset to week |
| GET/DELETE | `/menu-plannings/{id}` | Preset detail/delete |
| GET/POST | `/child-food-exception-overrides` | Week override list/save |

### Events, Notifications, Parameters

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/events/upcoming` | Upcoming events |
| GET | `/events/check-conflict` | Event conflict check |
| PATCH | `/events/{id}/status` | Toggle event status |
| GET/POST/PUT/DELETE | `/events` | Event CRUD except show |
| GET/POST | `/notifications` | Admin notifications list/create |
| GET | `/parameters` | Parameter list |
| PUT | `/parameters` | Bulk parameter update |

### Reports and AI

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/dashboard/stats` | Dashboard stats |
| GET | `/report-analysis` | Analysis history index |
| GET | `/report-analysis/{id}` | Analysis history detail |
| GET | `/plannings/{id}/report` | Behavioral report by planning |
| GET | `/reports/analysis-history` | Behavioral analysis history by planning |
| POST | `/reports/analysis-history` | Save behavioral analysis history |
| POST | `/ai/analyze-reports` | AI report analysis |
| POST | `/copilot/prompt` | Admin copilot prompt |

## Teacher Routes

Actual prefix: `/api/teacher/teacher`

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/attendance` | Create attendance |
| PATCH | `/attendance/{id}` | Update attendance |
| GET | `/attendance/report` | Daily attendance report |
| GET | `/daily-plan` | Teacher daily plan |
| GET | `/daily-plan/{id}` | Daily plan detail |
| PATCH | `/daily-plan/{id}/status` | Update daily plan status |
| GET/POST/PUT | `/evaluations` | Teacher evaluations CRUD except delete |
| GET/POST | `/signalements` | Teacher signalements list/create |
| GET/POST | `/photos` | Class photo list/upload |
| DELETE | `/photos/{id}` | Delete class photo |
| GET | `/pickup-notifications` | Pickup notifications |
| PATCH | `/pickup-notifications/{id}/complete` | Complete pickup notification |
| GET | `/notifications` | Teacher system notifications |
| PATCH | `/notifications/mark-all-read` | Mark all teacher notifications read |
| PATCH | `/notifications/{id}/read` | Mark one teacher notification read |
| GET | `/notifications/unread-count` | Teacher unread count |
| GET/POST | `/activity-suggestions` | Suggestion list/create |
| GET | `/activity-suggestions/ai` | AI activity suggestions |
| GET/PUT | `/profile/{cin}` | Teacher profile show/update |
| POST | `/profile/change-password` | Teacher password change |

## Parent Routes

Actual prefix: `/api/parent/parent`

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/dashboard` | Parent dashboard |
| GET | `/children` | Parent child profiles |
| GET | `/children/{id}` | Child profile detail |
| PUT | `/children/{id}` | Update child profile |
| GET | `/finances` | Parent finances |
| GET | `/finances/{id}` | Finance detail |
| POST | `/pickup-alerts` | Create pickup alert |
| GET | `/pickup-alerts/{id}` | Pickup alert detail |
| POST | `/food-exceptions` | Create parent food exception |
| DELETE | `/food-exceptions/{id}` | Delete parent food exception |
| GET | `/events-notifications` | Parent event notifications |
| PATCH | `/notifications/{id}/read` | Mark parent event notification read |

## Notes

- This file is route-based documentation generated from the current Laravel route files.
- Some endpoints also have richer controller docblocks with request/response examples in `app/Http/Controllers/Api/**`.
- The teacher and parent route files each add an internal prefix (`teacher`, `parent`) inside `routes/api.php`, so the real URLs are `/api/teacher/teacher/...` and `/api/parent/parent/...`.
