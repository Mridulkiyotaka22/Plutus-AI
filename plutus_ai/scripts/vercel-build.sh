#!/usr/bin/env bash
set -euo pipefail

# Vercel's standard build image does not include the Flutter SDK. Install the
# stable Flutter SDK in the build workspace, then produce a static web bundle.
FLUTTER_HOME="${FLUTTER_HOME:-${HOME}/flutter}"
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_HOME}"
  fi
  export PATH="${FLUTTER_HOME}/bin:${PATH}"
fi

flutter config --enable-web
flutter --version
flutter pub get

# API mode avoids inventing portfolio/market data. Set PLUTUS_API_BASE_URL in
# Vercel to the deployed Django API URL (including /api/v1/). The local fallback
# is useful only for local builds and will not connect for public visitors.
API_BASE_URL="${PLUTUS_API_BASE_URL:-http://127.0.0.1:8000/api/v1/}"

flutter build web --release \
  --dart-define=PLUTUS_ENV=api \
  --dart-define="PLUTUS_API_BASE_URL=${API_BASE_URL}"

test -s build/web/index.html
echo "Flutter Web build completed: build/web"
