#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${REPO_DIR}/flutter_app"

IOS_DEVICE_ID="${IOS_DEVICE_ID:-}"
ANDROID_DEVICE_ID="${ANDROID_DEVICE_ID:-}"

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd" >&2
    exit 1
  fi
}

run_step() {
  local description="$1"
  shift
  printf '\n==> %s\n' "$description"
  "$@"
}

require_command shorebird
require_command flutter

cd "$APP_DIR"

if [[ -n "$IOS_DEVICE_ID" ]]; then
  run_step "flutter run on iOS device (${IOS_DEVICE_ID})" flutter run -d "$IOS_DEVICE_ID"
else
  run_step "flutter run on iOS device" flutter run -d ios
fi

if [[ -n "$ANDROID_DEVICE_ID" ]]; then
  run_step "flutter run on Android device (${ANDROID_DEVICE_ID})" flutter run -d "$ANDROID_DEVICE_ID"
else
  run_step "flutter run on Android device" flutter run -d android
fi
