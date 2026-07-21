#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: ./scripts/capture_app_store_screenshots.sh --device <iphone|ipad> [--file <filename>]
USAGE
}

DEVICE=""
LANGUAGE="en"
ORIENTATION="portrait"
ONLY_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE="${2:-}"
      shift 2
      ;;
    --file)
      ONLY_FILE="${2:-}"
      shift 2
      ;;
    --language)
      LANGUAGE="${2:-}"
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

if [[ "$DEVICE" != "iphone" && "$DEVICE" != "ipad" ]]; then
  echo "--device must be iphone or ipad" >&2
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
    fr:02_drawer_open.png) printf '%s\n' 'Prise en charge des langues' ;;
    fr:03_new_game_numbers.png) printf '%s\n' 'Oui, vous pouvez jouer avec de bons vieux chiffres...' ;;
    fr:04_new_game_animals.png) printf '%s\n' 'mais il est temps de changer !' ;;
    fr:05_new_game_butterflies.png) printf '%s\n' 'De jolis papillons !' ;;
    fr:06_shells_after_16_moves.png) printf '%s\n' 'Plus que deux !' ;;
    fr:07_celebration.png) printf '%s\n' 'Place à la fête' ;;
    es:02_drawer_open.png) printf '%s\n' 'Compatibilidad con idiomas' ;;
    es:03_new_game_numbers.png) printf '%s\n' 'Sí, puedes jugar con los números de siempre...' ;;
    es:04_new_game_animals.png) printf '%s\n' '¡pero es hora de algo diferente!' ;;
    es:05_new_game_butterflies.png) printf '%s\n' '¡Bonitas mariposas!' ;;
    es:06_shells_after_16_moves.png) printf '%s\n' '¡Solo faltan dos!' ;;
    es:07_celebration.png) printf '%s\n' 'Vamos a celebrar' ;;
    pt:02_drawer_open.png) printf '%s\n' 'Suporte de idiomas' ;;
    pt:03_new_game_numbers.png) printf '%s\n' 'Sim, podes jogar com os velhos números...' ;;
    pt:04_new_game_animals.png) printf '%s\n' 'mas está na hora de algo diferente!' ;;
    pt:05_new_game_butterflies.png) printf '%s\n' 'Borboletas bonitas!' ;;
    pt:06_shells_after_16_moves.png) printf '%s\n' 'Só faltam duas!' ;;
    pt:07_celebration.png) printf '%s\n' 'Vamos celebrar' ;;
    it:02_drawer_open.png) printf '%s\n' 'Supporto lingue' ;;
    it:03_new_game_numbers.png) printf '%s\n' 'Sì, puoi giocare con i soliti numeri...' ;;
    it:04_new_game_animals.png) printf '%s\n' 'ma è il momento di qualcosa di diverso!' ;;
    it:05_new_game_butterflies.png) printf '%s\n' 'Belle farfalle!' ;;
    it:06_shells_after_16_moves.png) printf '%s\n' 'Ne mancano solo due!' ;;
    it:07_celebration.png) printf '%s\n' 'Festeggiamo' ;;
    hi:02_drawer_open.png) printf '%s\n' 'भाषा समर्थन' ;;
    hi:03_new_game_numbers.png) printf '%s\n' 'हाँ, आप पुराने अच्छे नंबरों से खेल सकते हैं...' ;;
    hi:04_new_game_animals.png) printf '%s\n' 'लेकिन अब कुछ अलग करने का समय है!' ;;
    hi:05_new_game_butterflies.png) printf '%s\n' 'सुंदर तितलियाँ!' ;;
    hi:06_shells_after_16_moves.png) printf '%s\n' 'बस दो और!' ;;
    hi:07_celebration.png) printf '%s\n' 'आइए जश्न मनाएँ' ;;
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
    hi)
      printf '%s\n' 'Devanagari-Sangam-MN-Bold'
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

if [[ "$DEVICE" == "iphone" ]]; then
  SIM_NAME="iPhone 13 Pro Max"
  SIM_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-18-4"
  SIM_DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-13-Pro-Max"
  SIM_UDID="$(find_or_create_simulator "$SIM_NAME" "$SIM_RUNTIME" "$SIM_DEVICE_TYPE")"
  OUTPUT_DIR="$SCREENSHOT_ROOT/$LANGUAGE/iphone_13_max_pro"
else
  SIM_NAME="iPad Pro 13-inch (M5)"
  SIM_UDID="1446C2EF-6E1C-4498-834F-7E56131F2F21"
  OUTPUT_DIR="$SCREENSHOT_ROOT/$LANGUAGE/ipad_13"
fi

mkdir -p "$OUTPUT_DIR"
BUNDLE_ID="$({ /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' ios/Runner/Info.plist; } 2>/dev/null)"
if [[ -z "$BUNDLE_ID" ]]; then
  echo "Unable to resolve CFBundleIdentifier from ios/Runner/Info.plist" >&2
  exit 1
fi

if [[ "$DEVICE" == "iphone" ]]; then
  shutdown_other_iphone_simulators
else
  xcrun simctl shutdown "$SIM_UDID" >/dev/null 2>&1 || true
fi

open -a Simulator >/dev/null 2>&1 || true
xcrun simctl boot "$SIM_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null

SCENES=(
  "home|none|0|01_home.png"
  "drawer_open|none|0|02_drawer_open.png"
  "new_game|numbers|0|03_new_game_numbers.png"
  "new_game|animals|0|04_new_game_animals.png"
  "new_game|butterflies|0|05_new_game_butterflies.png"
  "partial_progress|shells|0|06_shells_after_16_moves.png"
  "celebration|animals|0|07_celebration.png"
)

generated_count=0

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

for entry in "${SCENES[@]}"; do
  IFS='|' read -r scene theme moves filename <<< "$entry"
  if [[ -n "$ONLY_FILE" && "$filename" != "$ONLY_FILE" ]]; then
    continue
  fi
  generated_count=$((generated_count + 1))
  log_file="/tmp/${filename%.png}_${DEVICE}_${ORIENTATION}.log"
  rm -f "$log_file"
  xcrun simctl uninstall "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true

  cmd=(
    flutter run
    -d "$SIM_UDID"
    --dart-define=SCREENSHOT_MODE=true
    --dart-define=SCREENSHOT_SCENE="$scene"
    --dart-define=SCREENSHOT_DEVICE="$DEVICE"
    --dart-define=SCREENSHOT_BRAND_PLATFORM=ios
    --dart-define=SCREENSHOT_ORIENTATION=portrait
    --dart-define=SCREENSHOT_LANGUAGE="$LANGUAGE"
    --dart-define=SCREENSHOT_MOVES="$moves"
  )
  if [[ "$theme" != "none" ]]; then
    cmd+=(--dart-define=SCREENSHOT_THEME="$theme")
  fi

  echo "Capturing $filename on $DEVICE portrait"
  ("${cmd[@]}" >"$log_file" 2>&1) &
  run_pid=$!
  if ! wait_for_ready "$log_file" "SCREENSHOT_READY:$filename"; then
    cleanup_run "$run_pid"
    exit 1
  fi
  sleep 1
  xcrun simctl io "$SIM_UDID" screenshot "$OUTPUT_DIR/$filename" >/dev/null
  /opt/homebrew/bin/magick "$OUTPUT_DIR/$filename" -background white -alpha remove -alpha off "$OUTPUT_DIR/$filename"
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
  cleanup_run "$run_pid"
done

if [[ -n "$ONLY_FILE" && "$generated_count" -eq 0 ]]; then
  echo "Requested screenshot is not defined in this script: $ONLY_FILE" >&2
  exit 1
fi

echo "Saved screenshots to $OUTPUT_DIR"
