#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

DEFAULT_SIMULATOR_ID="0964BE76-B88B-4875-8682-8C7C17609DBA"
SIMULATOR_ID="${1:-${PATROL_SIMULATOR_ID:-${DEFAULT_SIMULATOR_ID}}}"

TARGETS=(
  "patrol_test/release_checklist_drawer_test.dart"
  "patrol_test/release_checklist_difficulties_test.dart"
  "patrol_test/release_checklist_themes_test.dart"
)

echo "Using simulator: ${SIMULATOR_ID}"

xcrun simctl boot "${SIMULATOR_ID}" >/dev/null 2>&1 || true
open -a Simulator >/dev/null 2>&1 || true
xcrun simctl bootstatus "${SIMULATOR_ID}" -b

for target in "${TARGETS[@]}"; do
  echo
  echo "Running ${target}"
  patrol test --target "${target}" --device "${SIMULATOR_ID}"
done
