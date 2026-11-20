#!/usr/bin/env bash
# Build the Flutter web app on Vercel.
# Vercel's build image does not include Flutter, so clone stable once per build.
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Installing Flutter..."
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version
flutter pub get
flutter build web --release

# Never ship the local runtime credential file if one exists.
rm -f build/web/config.json
