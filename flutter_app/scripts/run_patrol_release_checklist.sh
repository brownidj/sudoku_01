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

# Patrol 4.4 resolves simulator destinations by name and OS. Its default
# OS=latest misses older runtimes even when --device is an explicit UUID.
SIMULATOR_OS="$(xcrun simctl list devices available --json | /usr/bin/ruby -rjson -e '
  runtime = JSON.parse(STDIN.read).fetch("devices").find do |_, devices|
    devices.any? { |device| device["udid"] == ARGV.fetch(0) }
  end
  abort "Simulator UUID not found" unless runtime
  puts runtime.first.split(".iOS-").last.tr("-", ".")
' "${SIMULATOR_ID}")"

# Bundle the checklist into one native run. Xcode shuts the simulator down after
# a run, so separate invocations can lose the selected device between targets.
TARGET_ARGS=()
for target in "${TARGETS[@]}"; do
  TARGET_ARGS+=(--target "${target}")
done
patrol test "${TARGET_ARGS[@]}" --device "${SIMULATOR_ID}" --ios "${SIMULATOR_OS}"
