#!/usr/bin/env bash

require_ffmpeg_tools() {
  if [[ ! -x "$FFMPEG_BIN" || ! -x "$FFPROBE_BIN" ]]; then
    echo "ffmpeg and ffprobe are required at $FFMPEG_BIN and $FFPROBE_BIN" >&2
    exit 1
  fi
}

find_or_create_simulator() {
  local requested_name="$1"
  local runtime_identifier="$2"
  local device_type_identifier="$3"
  local existing_udid
  existing_udid="$(xcrun simctl list devices available | sed -n "s/.*${requested_name} (\([A-F0-9-]*\)) (.*/\1/p" | head -n 1)"
  if [[ -n "$existing_udid" ]]; then
    printf '%s\n' "$existing_udid"
    return 0
  fi
  xcrun simctl create "$requested_name" "$device_type_identifier" "$runtime_identifier"
}

shutdown_other_iphone_simulators() {
  while IFS= read -r udid; do
    if [[ -n "$udid" && "$udid" != "$SIM_UDID" ]]; then
      xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
    fi
  done < <(xcrun simctl list devices | sed -n 's/.*iPhone[^()]* (\([A-F0-9-]*\)) (.*/\1/p')
}

configure_store_video_target() {
  if [[ "$DEVICE" == "iphone" ]]; then
    SIM_NAME="iPhone 13 Pro Max"
    SIM_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-18-4"
    SIM_DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-13-Pro-Max"
    SIM_UDID="$(find_or_create_simulator "$SIM_NAME" "$SIM_RUNTIME" "$SIM_DEVICE_TYPE")"
    OUTPUT_DIR="$VIDEO_ROOT/iphone_13_max_pro"
  else
    SIM_NAME="iPad Pro 13-inch (M5)"
    SIM_UDID="1446C2EF-6E1C-4498-834F-7E56131F2F21"
    OUTPUT_DIR="$VIDEO_ROOT/ipad_13"
  fi

  mkdir -p "$OUTPUT_DIR"
}

resolve_app_preview_dimensions() {
  if [[ "$DEVICE" == "iphone" ]]; then
    printf '886 1920\n'
  else
    printf '1200 1600\n'
  fi
}

resolve_default_video_output_name() {
  local theme="$1"
  local suffix="${2:-}"
  if [[ "$theme" == "animals" ]]; then
    printf '01_finish_and_celebration%s.mp4\n' "$suffix"
  else
    printf '02_finish_and_celebration_butterflies%s.mp4\n' "$suffix"
  fi
}

resolve_bundle_id() {
  local bundle_id
  bundle_id="$({ /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' ios/Runner/Info.plist; } 2>/dev/null)"
  if [[ -z "$bundle_id" ]]; then
    echo "Unable to resolve CFBundleIdentifier from ios/Runner/Info.plist" >&2
    exit 1
  fi
  printf '%s\n' "$bundle_id"
}

boot_capture_simulator() {
  if [[ "$DEVICE" == "iphone" ]]; then
    shutdown_other_iphone_simulators
  else
    xcrun simctl shutdown "$SIM_UDID" >/dev/null 2>&1 || true
  fi

  open -a Simulator >/dev/null 2>&1 || true
  xcrun simctl boot "$SIM_UDID" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null
  xcrun simctl uninstall "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
}

cleanup_run() {
  local pid="$1"
  xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  pkill -P "$pid" >/dev/null 2>&1 || true
  if kill -0 "$pid" >/dev/null 2>&1; then
    kill -TERM "$pid" >/dev/null 2>&1 || true
    wait "$pid" >/dev/null 2>&1 || true
  fi
}

wait_for_ready() {
  local log_file="$1"
  local ready_marker="$2"
  local timeout_seconds=180
  local start_time
  start_time="$(date +%s)"
  while true; do
    if grep -Fq "$ready_marker" "$log_file" 2>/dev/null; then
      return 0
    fi
    if [[ -f "$log_file" ]] && grep -Eq "^(Error:|Unhandled exception:|Flutter run key commands\.)" "$log_file"; then
      tail -n 80 "$log_file" >&2 || true
    fi
    if (( $(date +%s) - start_time > timeout_seconds )); then
      echo "Timed out waiting for $ready_marker" >&2
      tail -n 120 "$log_file" >&2 || true
      return 1
    fi
    sleep 1
  done
}

wait_for_marker() {
  local log_file="$1"
  local marker="$2"
  local timeout_seconds="${3:-180}"
  local start_time
  start_time="$(date +%s)"
  while true; do
    if grep -Fq "$marker" "$log_file" 2>/dev/null; then
      return 0
    fi
    if (( $(date +%s) - start_time > timeout_seconds )); then
      echo "Timed out waiting for $marker" >&2
      tail -n 120 "$log_file" >&2 || true
      return 1
    fi
    sleep 1
  done
}

find_font_file() {
  local candidates=(
    "/System/Library/Fonts/Supplemental/Arial.ttf"
    "/System/Library/Fonts/Supplemental/Helvetica.ttc"
    "/System/Library/Fonts/SFNS.ttf"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

write_disclosure_text() {
  local theme="$1"
  local output_path="$2"
  if [[ "$theme" == "animals" ]]; then
    cat >"$output_path" <<'EOF'
Included in Free content.
EOF
  else
    cat >"$output_path" <<'EOF'
Includes Full Version content.
Available as an in-app purchase.
EOF
  fi
}
