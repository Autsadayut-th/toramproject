#!/usr/bin/env bash
set -euo pipefail

export CI=true

FLUTTER_DIR="/tmp/flutter"
if [ ! -d "${FLUTTER_DIR}" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter --disable-analytics
flutter config --enable-web
flutter pub get
flutter build web --release
