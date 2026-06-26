#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/capture_play_store_screenshots.sh --device <pixel8|pixel_tablet> [--file <filename>]
USAGE
}

DEVICE=""
LANGUAGE="en"
ONLY_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE="${2:-}"
      shift 2
      ;;
    --language)
      LANGUAGE="${2:-}"
      shift 2
      ;;
    --file)
      ONLY_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$DEVICE" != "pixel8" && "$DEVICE" != "pixel_tablet" && "$DEVICE" != "7_inch_tablet" ]]; then
  echo "--device must be pixel8, pixel_tablet, or 7_inch_tablet" >&2
  exit 1
fi

case "$LANGUAGE" in
  en|ja|de|fr|it|pt|hi|es)
    ;;
  *)
    echo "--language must be one of: en ja de fr it pt hi es" >&2
    exit 1
    ;;
esac

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
SCREENSHOT_ROOT="$REPO_ROOT/assets/images/screenshots"
cd "$ROOT_DIR"

caption_for() {
  local language="$1"
  local filename="$2"
  case "$language:$filename" in
    en:02_drawer_open.png) printf '%s\n' 'Language support' ;;
    en:03_new_game_numbers.png) printf '%s\n' 'Yes, you can play with boring old numbers...' ;;
    en:04_new_game_animals.png) printf '%s\n' 'but time for something different!' ;;
    en:05_new_game_butterflies.png) printf '%s\n' 'Pretty butterflies!' ;;
    en:06_shells_after_16_moves.png) printf '%s\n' 'Just two more!' ;;
    en:07_celebration.png) printf '%s\n' "Let's celebrate" ;;
    ja:02_drawer_open.png) printf '%s\n' '言語サポート' ;;
    ja:03_new_game_numbers.png) printf '%s\n' '普通の数字でも楽しめます…' ;;
    ja:04_new_game_animals.png) printf '%s\n' 'でも、ときには違う楽しさも！' ;;
    ja:05_new_game_butterflies.png) printf '%s\n' 'きれいな蝶々！' ;;
    ja:06_shells_after_16_moves.png) printf '%s\n' 'あと2つ！' ;;
    ja:07_celebration.png) printf '%s\n' 'お祝いしましょう' ;;
    de:02_drawer_open.png) printf '%s\n' 'Sprachunterstützung' ;;
    de:03_new_game_numbers.png) printf '%s\n' 'Ja, du kannst auch mit langweiligen alten Zahlen spielen…' ;;
    de:04_new_game_animals.png) printf '%s\n' 'aber jetzt ist Zeit für etwas anderes!' ;;
    de:05_new_game_butterflies.png) printf '%s\n' 'Schöne Schmetterlinge!' ;;
    de:06_shells_after_16_moves.png) printf '%s\n' 'Nur noch zwei!' ;;
    de:07_celebration.png) printf '%s\n' 'Lasst uns feiern' ;;
    *)
      return 1
      ;;
  esac
}

font_for_language() {
  local language="$1"
  case "$language" in
    ja)
      printf '%s\n' 'Hiragino-Sans-W6'
      ;;
    *)
      printf '%s\n' 'Verdana-Bold'
      ;;
  esac
}

caption_position_for() {
  local filename="$1"
  case "$filename" in
    06_shells_after_16_moves.png|07_celebration.png)
      printf '%s\n' 'top'
      ;;
    *)
      printf '%s\n' 'bottom'
      ;;
  esac
}

if [[ "$DEVICE" == "pixel8" ]]; then
  AVD_NAME="Pixel_8"
  OUTPUT_DIR="$SCREENSHOT_ROOT/$LANGUAGE/pixel_8"
  ROTATION_VALUE="0"
  WM_SIZE="1080x1920"
elif [[ "$DEVICE" == "7_inch_tablet" ]]; then
  AVD_NAME="7-inch_tablet"
  OUTPUT_DIR="$SCREENSHOT_ROOT/$LANGUAGE/7_inch_tablet"
  ROTATION_VALUE="0"
  WM_SIZE="1200x1920"
else
  AVD_NAME="Pixel_Tablet"
  OUTPUT_DIR="$SCREENSHOT_ROOT/$LANGUAGE/pixel_tablet"
  ROTATION_VALUE="0"
  WM_SIZE="1600x2560"
fi

mkdir -p "$OUTPUT_DIR"

PACKAGE_NAME="$(
  sed -n 's/.*applicationId = "\(.*\)".*/\1/p' android/app/build.gradle.kts | head -n 1
)"
if [[ -z "$PACKAGE_NAME" ]]; then
  echo "Unable to resolve Android applicationId from android/app/build.gradle.kts" >&2
  exit 1
fi

find_emulator_serial() {
  local expected_avd="$1"
  local serial
  local actual_avd
  while read -r serial; do
    if [[ -z "$serial" ]]; then
      continue
    fi
    actual_avd="$(
      adb -s "$serial" emu avd name 2>/dev/null | tr -d '\r' | head -n 1
    )"
    if [[ "$actual_avd" == "$expected_avd" ]]; then
      printf '%s\n' "$serial"
      return 0
    fi
  done < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')
  return 1
}

wait_for_emulator() {
  local expected_avd="$1"
  local timeout_seconds=180
  local start_time
  local serial
  start_time="$(date +%s)"
  while true; do
    if serial="$(find_emulator_serial "$expected_avd")"; then
      adb -s "$serial" wait-for-device >/dev/null 2>&1
      if [[ "$(adb -s "$serial" shell getprop sys.boot_completed | tr -d '\r')" == "1" ]]; then
        printf '%s\n' "$serial"
        return 0
      fi
    fi
    if (( $(date +%s) - start_time > timeout_seconds )); then
      echo "Timed out waiting for emulator $expected_avd" >&2
      return 1
    fi
    sleep 2
  done
}

ensure_emulator_running() {
  local expected_avd="$1"
  if find_emulator_serial "$expected_avd" >/dev/null 2>&1; then
    return 0
  fi
  flutter emulators --launch "$expected_avd" >/dev/null
}

prepare_emulator() {
  local serial="$1"
  local rotation_value="$2"
  local wm_size="$3"
  adb -s "$serial" shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  adb -s "$serial" shell wm dismiss-keyguard >/dev/null 2>&1 || true
  adb -s "$serial" shell wm size "$wm_size" >/dev/null
  adb -s "$serial" shell settings put system accelerometer_rotation 0 >/dev/null
  adb -s "$serial" shell settings put system user_rotation "$rotation_value" >/dev/null
  adb -s "$serial" shell settings put global window_animation_scale 0 >/dev/null
  adb -s "$serial" shell settings put global transition_animation_scale 0 >/dev/null
  adb -s "$serial" shell settings put global animator_duration_scale 0 >/dev/null
  sleep 2
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

cleanup_run() {
  local serial="$1"
  local pid="$2"
  adb -s "$serial" shell am force-stop "$PACKAGE_NAME" >/dev/null 2>&1 || true
  pkill -P "$pid" >/dev/null 2>&1 || true
  if kill -0 "$pid" >/dev/null 2>&1; then
    kill -TERM "$pid" >/dev/null 2>&1 || true
    wait "$pid" >/dev/null 2>&1 || true
  fi
}

SCENES=(
  "home|none|0|01_home.png"
  "drawer_open|none|0|02_drawer_open.png"
  "new_game|numbers|0|03_new_game_numbers.png"
  "new_game|animals|0|04_new_game_animals.png"
  "new_game|butterflies|0|05_new_game_butterflies.png"
  "partial_progress|shells|0|06_shells_after_16_moves.png"
  "celebration|animals|0|07_celebration.png"
)

ensure_emulator_running "$AVD_NAME"
ANDROID_SERIAL="$(wait_for_emulator "$AVD_NAME")"
prepare_emulator "$ANDROID_SERIAL" "$ROTATION_VALUE" "$WM_SIZE"

generated_count=0
for entry in "${SCENES[@]}"; do
  IFS='|' read -r scene theme moves filename <<< "$entry"
  if [[ -n "$ONLY_FILE" && "$filename" != "$ONLY_FILE" ]]; then
    continue
  fi

  generated_count=$((generated_count + 1))
  log_file="/tmp/${filename%.png}_${DEVICE}_android.log"
  rm -f "$log_file"

  adb -s "$ANDROID_SERIAL" uninstall "$PACKAGE_NAME" >/dev/null 2>&1 || true
  prepare_emulator "$ANDROID_SERIAL" "$ROTATION_VALUE" "$WM_SIZE"

  cmd=(
    flutter run
    --no-pub
    -d "$ANDROID_SERIAL"
    --dart-define=SCREENSHOT_MODE=true
    --dart-define=SCREENSHOT_SCENE="$scene"
    --dart-define=SCREENSHOT_DEVICE="$DEVICE"
    --dart-define=SCREENSHOT_BRAND_PLATFORM=android
    --dart-define=SCREENSHOT_ORIENTATION=portrait
    --dart-define=SCREENSHOT_LANGUAGE="$LANGUAGE"
    --dart-define=SCREENSHOT_MOVES="$moves"
  )
  if [[ "$theme" != "none" ]]; then
    cmd+=(--dart-define=SCREENSHOT_THEME="$theme")
  fi

  echo "Capturing $filename on $DEVICE"
  ("${cmd[@]}" >"$log_file" 2>&1) &
  run_pid=$!

  if ! wait_for_ready "$log_file" "SCREENSHOT_READY:$filename"; then
    cleanup_run "$ANDROID_SERIAL" "$run_pid"
    exit 1
  fi

  sleep 1
  adb -s "$ANDROID_SERIAL" shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  adb -s "$ANDROID_SERIAL" shell wm dismiss-keyguard >/dev/null 2>&1 || true
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$OUTPUT_DIR/$filename"
  if caption_text="$(caption_for "$LANGUAGE" "$filename" 2>/dev/null)"; then
    caption_font="$(font_for_language "$LANGUAGE")"
    caption_position="$(caption_position_for "$filename")"
    "${ROOT_DIR}/scripts/caption_store_screenshot.sh" \
      --input "$OUTPUT_DIR/$filename" \
      --output "$OUTPUT_DIR/${filename%.png}_t.png" \
      --caption "$caption_text" \
      --position "$caption_position" \
      --font "$caption_font"
  fi
  cleanup_run "$ANDROID_SERIAL" "$run_pid"
done

if [[ -n "$ONLY_FILE" && "$generated_count" -eq 0 ]]; then
  echo "Requested screenshot is not defined in this script: $ONLY_FILE" >&2
  exit 1
fi

echo "Saved screenshots to $OUTPUT_DIR"
