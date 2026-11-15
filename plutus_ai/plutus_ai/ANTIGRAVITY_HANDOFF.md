# Antigravity handoff — PLUTUS AI

This is the existing Claude-generated project, repaired and prepared for continued development. Do not regenerate it from scratch.

## What is already prepared

- Flutter app entry point and `ProviderScope`.
- Demo/API environment setting in `lib/config/env_config.dart`.
- GoRouter provider with all 11 routes in `lib/router/app_router.dart`.
- Responsive desktop sidebar and compact drawer navigation in `lib/core/widgets/shell_scaffold.dart`.
- Shared in-progress module scaffold in `lib/core/widgets/feature_placeholder.dart`.
- Existing feature screens are connected to the shared scaffold and describe their intended functionality.
- Theme compile fixes for current Flutter component theme APIs.
- Asset declarations removed because no assets are present yet.

## Do not do these things

- Do not create a new Flutter project over this one.
- Do not delete the existing theme, app shell, routes, feature folders or package configuration.
- Do not add every screen to one Dart file.
- Do not create a Django backend inside the Flutter project.
- Do not put Groq, market-data or Supabase secrets in Flutter source.
- Do not claim live market data or working backend functionality while using mock data.
- Do not mark IEM, TimeFormer or MTSM as trained or validated unless real implementations and evaluation outputs exist.

## Required workflow

1. Open this existing `plutus_ai` folder as the project workspace.
2. Run `flutter doctor -v`, `flutter pub get`, `flutter analyze` and `flutter test`.
3. Fix only verified environment or code issues first. Report the exact command outputs.
4. Implement the dashboard as the first full module, keeping the shared app shell intact.
5. Run analysis and tests again before moving to the next module.
6. Implement one module per task in this order: Dashboard; Market Terminal; Portfolio; Watchlists; PLUTUS AI Assistant; Behavioural Finance; Risk Intelligence; Wealth & Tax; Research Intelligence; Alerts; Settings.
7. Maintain a consistent demo data source shared across modules, with a visible DEMO label.
8. Use typed models and repository interfaces so later Django REST API integration does not require rewriting widgets.

## First implementation task: Dashboard

Implement only the Financial Command Center in `lib/features/dashboard/` plus any reusable widgets or mock fixtures it genuinely needs. Do not modify other feature modules unless a shared component is required.

Dashboard requirements:

- Premium dark fintech visual design, not a generic repeated card grid.
- Portfolio total, invested capital, daily P&L, overall P&L and return percentage, all clearly labelled DEMO.
- Portfolio performance chart with 1W, 1M, 3M, 6M, 1Y and ALL ranges.
- Asset allocation visualisation.
- Market snapshot for selected example indices, labelled sample/historical demo data.
- Holdings summary and recent transactions.
- Risk summary and recent AI insight preview.
- Functional period selector, tabs or filters where presented.
- Responsive layout for desktop, tablet and mobile.
- No invented live quote, external API connection, portfolio guarantee or backend success.

Architecture requirements:

- Keep presentation widgets separate from demo fixtures and domain models.
- Use a feature-level repository/provider abstraction, even if it initially returns demo fixtures.
- Do not add another state-management system; use Riverpod already declared in `pubspec.yaml`.
- Keep charts readable with tooltips, axes/labels and useful empty states.
- Add widget tests for important interactions.

Finish by listing changed files and the real results of `flutter analyze` and `flutter test`. Stop after the dashboard is complete; wait for the next module task.
