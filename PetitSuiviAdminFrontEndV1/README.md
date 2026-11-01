# PetitSuivi Admin

React dashboard for **PetitSuivi**, the daycare management platform. Used by administrators and staff to manage children, classes, inscriptions, activities, meals, payments, events and reports.

## Requirements

- Node.js **18+**
- npm

## Setup

```bash
npm install --legacy-peer-deps
```

Create `.env` in this folder:

```dotenv
REACT_APP_API_URL=http://localhost:8000/api
```

The API URL is inlined at build time, so restart the dev server after changing it.

## Scripts

| Command | Description |
| --- | --- |
| `npm start` / `npm run dev` | Dev server on http://localhost:5000 (hot reload) |
| `npm run build` | Production build into `build/` |
| `npm test` | CRA test runner (watch mode) |
| `npm run eject` | Eject CRA config (irreversible) |

> `start` and `dev` use Unix `PORT=5000` syntax. On Windows PowerShell use `$env:PORT=5000; npm start`, or run Git Bash.

## Tech stack

- **React 18** with Create React App (`react-scripts` 5)
- **MUI 5** (`@mui/material`, `@mui/icons-material`, `@mui/x-data-grid`)
- **axios** for API calls; token handled through `AuthContext`
- **FullCalendar 5** for activity and event calendars
- **Nivo**, **Chart.js** and **recharts** for dashboard charts
- **Formik + Yup** for forms and validation
- **React Router 6** for routing
- `react-pro-sidebar` for the sidebar layout

## Structure

```text
src/
├── api/axios.js                 configured axios instance
├── components/                  shared Header, StatBox, ProgressCircle
├── context/AuthContext.jsx      login state, token, current user
├── interfaces/
│   ├── dashboard/               stats cards, charts, feeds
│   ├── classes/                 kindergarten + preschool class management
│   ├── inscriptions/            enrolment review, approval, medical forms
│   ├── activities/              activities, criteria, planning timeline
│   ├── events/                  event CRUD + calendar
│   ├── food/                    meals, food exceptions, weekly schedule
│   ├── payments/                payments and partial payments
│   ├── ParentAndTeacher/        accounts management
│   ├── parameters/              app settings
│   ├── reports/                 payment, behaviour and history reports
│   ├── login/                   auth screens
│   └── global/                  Sidebar, Topbar, global styles
├── utils/                       helpers + validation
├── App.js
├── theme.js
└── index.js
```

Each feature under `interfaces/` uses the same layout:

