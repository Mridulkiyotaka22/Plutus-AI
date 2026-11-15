# PLUTUS AI — Flutter Frontend

PLUTUS AI is an AI-powered financial intelligence and wealth-management application. This repository contains the Flutter frontend foundation.

## Current state

- Flutter application shell and responsive navigation are wired.
- All 11 main application routes are registered.
- Demo mode is the default.
- Individual feature screens are currently scaffold pages and must be implemented in focused development phases.
- No Django backend, Supabase database, market-data feed, or Groq connection is included yet.

## Requirements

- Flutter SDK (Dart 3 compatible)
- A supported editor such as Android Studio or VS Code

Verify the local environment:

```bash
flutter doctor -v
flutter --version
```

## Run

```bash
flutter pub get
flutter run -d chrome
```

For a desktop target, enable the corresponding Flutter platform in your local Flutter installation and run using that target.

## Configuration

Demo mode is the safe default in `lib/main.dart`.

When the Django API is ready, configure its base URL at build time:

```bash
flutter run --dart-define=PLUTUS_API_BASE_URL=http://127.0.0.1:8000/api/v1
```

The environment configuration currently exposes the base URL only. Real authentication and API repositories still need to be implemented.

## Main routes

| Route | Module |
|---|---|
| `/` | Overview |
| `/markets` | Market Terminal |
| `/portfolio` | My Portfolio |
| `/watchlists` | Watchlists |
| `/ai` | PLUTUS AI Assistant |
| `/behaviour` | Behavioural Finance |
| `/risk` | Risk Intelligence |
| `/wealth` | Wealth & Tax Optimisation |
| `/research` | Research Intelligence |
| `/alerts` | Alerts & Activity |
| `/settings` | Settings |

## Development sequence

Implement modules individually, retaining the existing app shell and route structure. Use consistent demo fixtures until the Django API is available. Clearly label sample financial data as DEMO; never present it as live market data.
