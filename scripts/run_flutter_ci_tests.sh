#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${REPO_DIR}/flutter_app"

INTEGRATION_TARGET="${INTEGRATION_TARGET:-integration_test/app_flow_test.dart}"
INTEGRATION_DEVICE="${INTEGRATION_DEVICE:-macos}"

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd" >&2
    exit 1
  fi
}

assert_device_available() {
  local device_id="$1"
  python3 - "$device_id" <<'PY'
import json
import subprocess
import sys

device_id = sys.argv[1]
result = subprocess.run(
    ["flutter", "devices", "--machine"],
    capture_output=True,
    text=True,
    check=False,
)
if result.returncode != 0:
    sys.exit(1)

try:
    devices = json.loads(result.stdout)
except json.JSONDecodeError:
    sys.exit(1)

for device in devices:
    if device.get("id") == device_id:
        sys.exit(0)
sys.exit(2)
PY
}

require_command flutter
require_command python3

cd "$REPO_DIR"
echo "==> premium policy guard"
./scripts/check_premium_policy_usage.sh flutter_app

cd "$APP_DIR"

if ! assert_device_available "$INTEGRATION_DEVICE"; then
  echo "Integration device '${INTEGRATION_DEVICE}' not available." >&2
  echo "Set INTEGRATION_DEVICE to one from: flutter devices" >&2
  exit 1
fi

echo "==> flutter test"
flutter test

echo "==> flutter integration test (${INTEGRATION_DEVICE})"
flutter test "$INTEGRATION_TARGET" -d "$INTEGRATION_DEVICE"
