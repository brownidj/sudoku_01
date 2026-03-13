#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$APP_DIR"

if [[ ! -f pubspec.yaml || ! -d lib ]]; then
  echo "run_everything must be run from flutter_app/ context" >&2
  exit 1
fi

ANDROID_DEVICE="${ANDROID_DEVICE:-}"
IOS_INTEGRATION_DEVICE="${IOS_INTEGRATION_DEVICE:-A1D4B926-7DB8-436F-B648-16E26157B06B}"
IOS_PATROL_DEVICE="${IOS_PATROL_DEVICE:-}"
INTEGRATION_TEST_TARGET="${INTEGRATION_TEST_TARGET:-integration_test/app_flow_test.dart}"
PATROL_TEST_TARGET="${PATROL_TEST_TARGET:-patrol_test/smoke_test.dart}"

log_step() {
  echo
  echo "==> $*"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

detect_android_device() {
  flutter devices --machine | ruby -rjson -e '
    devices = JSON.parse(STDIN.read)
    device = devices.find { |item| item["targetPlatform"].to_s.start_with?("android") }
    abort("No Android device found. Start an emulator or connect a device.") unless device
    puts device["id"]
  '
}

detect_latest_ios_simulator() {
  xcrun simctl list devices available -j | ruby -rjson -e '
    data = JSON.parse(STDIN.read)
    candidates = []
    data.fetch("devices").each do |runtime, devices|
      next unless runtime.start_with?("com.apple.CoreSimulator.SimRuntime.iOS-")
      version = runtime.sub("com.apple.CoreSimulator.SimRuntime.iOS-", "").tr("-", ".")
      devices.each do |device|
        next unless device["isAvailable"]
        next unless device["name"].start_with?("iPhone")
        candidates << [Gem::Version.new(version), device]
      end
    end
    abort("No available iOS simulator found.") if candidates.empty?
    best = candidates.max_by { |version, _device| version }
    puts best[1]["udid"]
  '
}

wait_for_patrol_device() {
  local device_id="$1"
  local devices_output
  for _ in $(seq 1 30); do
    devices_output="$(patrol devices 2>/dev/null || true)"
    if grep -Fq "$device_id" <<<"$devices_output"; then
      return 0
    fi
    sleep 1
  done
  echo "Patrol device did not attach: $device_id" >&2
  return 1
}

run_patrol_test() {
  local device_id="$1"
  local platform_label="$2"
  local log_file
  local pid
  local success_seen_at=0

  log_file="$(mktemp)"
  log_step "patrol test $PATROL_TEST_TARGET on $platform_label ($device_id)"

  set +e
  patrol test --target "$PATROL_TEST_TARGET" --device "$device_id" \
    > >(tee "$log_file") 2>&1 &
  pid=$!
  set -e

  while kill -0 "$pid" 2>/dev/null; do
    if grep -q "Some tests failed." "$log_file"; then
      kill -TERM "$pid" 2>/dev/null || true
      wait "$pid" || true
      rm -f "$log_file"
      echo "Patrol tests failed on $platform_label." >&2
      return 1
    fi

    if grep -q "All tests passed!" "$log_file"; then
      if [[ "$success_seen_at" -eq 0 ]]; then
        success_seen_at="$(date +%s)"
      elif (( $(date +%s) - success_seen_at >= 5 )); then
        kill -TERM "$pid" 2>/dev/null || true
        wait "$pid" || true
        rm -f "$log_file"
        return 0
      fi
    fi

    sleep 2
  done

  set +e
  wait "$pid"
  local status=$?
  set -e

  if grep -q "All tests passed!" "$log_file"; then
    rm -f "$log_file"
    return 0
  fi

  rm -f "$log_file"
  return "$status"
}

require_command flutter
require_command patrol
require_command ruby
require_command xcrun

ANDROID_DEVICE="${ANDROID_DEVICE:-$(detect_android_device)}"
IOS_PATROL_DEVICE="${IOS_PATROL_DEVICE:-$(detect_latest_ios_simulator)}"

log_step "using Android device: $ANDROID_DEVICE"
log_step "using iOS integration simulator: $IOS_INTEGRATION_DEVICE"
log_step "using iOS Patrol simulator: $IOS_PATROL_DEVICE"

log_step "./scripts/check_file_sizes.sh"
./scripts/check_file_sizes.sh

log_step "flutter clean"
flutter clean

log_step "flutter pub get"
flutter pub get

log_step "pod install"
(
  cd ios
  pod install
)

log_step "flutter test"
flutter test

log_step "boot iOS simulator"
xcrun simctl boot "$IOS_INTEGRATION_DEVICE" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$IOS_INTEGRATION_DEVICE" -b
xcrun simctl boot "$IOS_PATROL_DEVICE" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$IOS_PATROL_DEVICE" -b

log_step "flutter integration tests on Android"
flutter test "$INTEGRATION_TEST_TARGET" -d "$ANDROID_DEVICE"

log_step "flutter integration tests on iOS"
flutter test "$INTEGRATION_TEST_TARGET" -d "$IOS_INTEGRATION_DEVICE"

wait_for_patrol_device "$ANDROID_DEVICE"
run_patrol_test "$ANDROID_DEVICE" "Android"

wait_for_patrol_device "$IOS_PATROL_DEVICE"
run_patrol_test "$IOS_PATROL_DEVICE" "iOS"

log_step "all checks passed"
