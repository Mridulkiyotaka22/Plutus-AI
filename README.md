# PLUTUS AI

PLUTUS AI is an educational financial-intelligence and portfolio-analysis platform. The repository is intended to contain the Flutter Web frontend and Django REST API backend.

## Architecture

- **Frontend:** Flutter / Dart, Riverpod, Dio, GoRouter and fl_chart.
- **Backend:** Python, Django and Django REST Framework.
- **Database:** PostgreSQL hosted by Supabase (Django ORM owns schema migrations and authentication tables).
- **Market data:** yfinance for best-effort historical/latest-available prices; it is not a guaranteed real-time exchange feed.
- **Finance assistant:** Groq API is optional and must be called from the backend only.

Django remains the authentication authority in this architecture. Supabase is the managed PostgreSQL host; do not add a second, conflicting Supabase Auth flow unless the architecture is deliberately migrated.

## Repository layout

```text
backend/       Django REST API and migrations
plutus_ai/     Flutter application
```

## Local development

### Backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
python manage.py check
python manage.py migrate
python manage.py seed_market_instruments
python manage.py runserver 127.0.0.1:8000
```

Edit `backend/.env` locally. Keep `SECRET_KEY`, `DATABASE_URL` and `GROQ_API_KEY` out of Git. For SQLite development, leave `DATABASE_URL` blank.

### Flutter

Open a second terminal:

```powershell
cd plutus_ai
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

The frontend defaults to API mode. For local Django, its default API base is `http://127.0.0.1:8000/api/v1/`. It can be overridden at build/run time:

```powershell
flutter run -d chrome --dart-define=PLUTUS_ENV=api --dart-define=PLUTUS_API_BASE_URL=http://127.0.0.1:8000/api/v1/
```

## Vercel Web deployment

The Vercel project should use **Root Directory** `plutus_ai`. The `plutus_ai/vercel.json` configuration runs `scripts/vercel-build.sh`, builds Flutter Web and publishes `build/web`.

Set the Vercel environment variable `PLUTUS_API_BASE_URL` to the deployed Django API base URL, including the trailing `/api/v1/`, for example `https://your-django-host.example/api/v1/`. Until a reachable Django backend is deployed and this variable is set, the public Flutter UI can load but sign-in and API-backed features will not work. Do not use localhost as the production API host.

## Current implementation boundaries

A successful web deployment proves the Flutter web bundle builds and is hosted; it does not prove the Django backend has been deployed or that every module is production-ready. Validate authentication, market quotes/history, portfolio writes, assistant responses and user-level data isolation against a deployed backend before describing the full platform as production-ready.

- Market-data availability and delay depend on Yahoo Finance/yfinance.
- A finance chatbot must restrict responses to finance-related topics and use trusted backend-provided facts.
- Risk metrics and research models must not be represented as validated if they are still illustrative or experimental.
- PLUTUS is educational financial software, not a licensed investment, brokerage or tax-advisory service.

## Security

Never commit `.env`, database files, virtual environments, API keys, access tokens, Supabase service-role/secret keys or user data. The root `.gitignore` excludes common local and secret artifacts.
