#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: ./scripts/capture_store_video.sh --device <iphone|ipad> [--duration <seconds>] [--output <filename>]
                                     [--theme <animals|butterflies>]

Captures a short simulator video that starts with two remaining moves and ends on
the celebration overlay, then appends a theme-appropriate disclosure end frame.
USAGE
}

DEVICE=""
DURATION_SECONDS=8
OUTPUT_NAME=""
THEME="animals"
START_FRAME_SECONDS="1.5"
END_FRAME_SECONDS=2
FRAME_RATE=30
TARGET_BITRATE="11M"
MIN_BITRATE="10M"
MAX_BITRATE="12M"
BUFFER_SIZE="24M"
MAX_FILE_SIZE_BYTES=$((500 * 1024 * 1024))

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE="${2:-}"
      shift 2
      ;;
    --duration)
      DURATION_SECONDS="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_NAME="${2:-}"
      shift 2
      ;;
    --theme)
      THEME="${2:-}"
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

if [[ "$THEME" != "animals" && "$THEME" != "butterflies" ]]; then
  echo "--theme must be animals or butterflies" >&2
  exit 1
fi

if ! [[ "$DURATION_SECONDS" =~ ^[0-9]+$ ]] || (( DURATION_SECONDS <= 0 )); then
  echo "--duration must be a positive integer" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
VIDEO_ROOT="$REPO_ROOT/assets/videos"
FFMPEG_BIN="/opt/homebrew/bin/ffmpeg"
FFPROBE_BIN="/opt/homebrew/bin/ffprobe"
cd "$ROOT_DIR"
source "$ROOT_DIR/scripts/store_video_capture_common.sh"

require_ffmpeg_tools
configure_store_video_target

if [[ -z "$OUTPUT_NAME" ]]; then
  OUTPUT_NAME="$(resolve_default_video_output_name "$THEME" "")"
fi

case "${OUTPUT_NAME##*.}" in
  mp4|m4v|mov)
    ;;
  *)
    echo "--output must end in .mp4, .m4v, or .mov" >&2
    exit 1
    ;;
esac

OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"
RAW_CAPTURE_PATH="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_raw.mov"
PROCESSED_PATH="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_processed.${OUTPUT_NAME##*.}"
DISCLOSURE_TEXT_FILE="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_disclosure.txt"
LOG_FILE="/tmp/${OUTPUT_NAME%.mp4}_${DEVICE}_video.log"
RECORD_LOG="/tmp/${OUTPUT_NAME%.mp4}_${DEVICE}_record.log"
rm -f "$OUTPUT_PATH" "$RAW_CAPTURE_PATH" "$PROCESSED_PATH" \
  "$DISCLOSURE_TEXT_FILE" "$LOG_FILE" "$RECORD_LOG"

BUNDLE_ID="$(resolve_bundle_id)"
boot_capture_simulator

post_process_video() {
  local raw_path="$1"
  local output_path="$2"
  local disclosure_text="$3"
  local font_file="$4"
  local width
  local height
  local fontsize
  local intro_fontsize

  read -r width height < <(resolve_app_preview_dimensions)
  if [[ -z "$width" || -z "$height" ]]; then
    echo "Unable to determine captured video dimensions." >&2
    exit 1
  fi

  fontsize=$(( width / 18 ))
  if (( fontsize < 42 )); then
    fontsize=42
  fi
  intro_fontsize=$(( width / 10 ))
  if (( intro_fontsize < 56 )); then
    intro_fontsize=56
  fi

  "$FFMPEG_BIN" -y \
    -i "$raw_path" \
    -f lavfi -t "$START_FRAME_SECONDS" -i "color=c=white:s=${width}x${height}:r=${FRAME_RATE}" \
    -f lavfi -t "$END_FRAME_SECONDS" -i "color=c=white:s=${width}x${height}:r=${FRAME_RATE}" \
    -filter_complex "\
[1:v]drawtext=fontfile='${font_file}':text='Celebrate!':fontcolor=black:fontsize=${intro_fontsize}:x=(w-text_w)/2:y=(h-text_h)/2,format=yuv420p[v0];\
[0:v]fps=${FRAME_RATE},scale=${width}:${height}:flags=lanczos,setsar=1,format=yuv420p[v1];\
[2:v]drawtext=fontfile='${font_file}':textfile='${disclosure_text}':fontcolor=black:fontsize=${fontsize}:line_spacing=18:x=(w-text_w)/2:y=(h-text_h)/2,format=yuv420p[v2];\
[v0][v1][v2]concat=n=3:v=1:a=0[v]" \
    -map "[v]" \
    -an \
    -c:v libx264 \
    -profile:v high \
    -pix_fmt yuv420p \
    -r "$FRAME_RATE" \
    -b:v "$TARGET_BITRATE" \
    -minrate "$MIN_BITRATE" \
    -maxrate "$MAX_BITRATE" \
    -bufsize "$BUFFER_SIZE" \
    -x264-params "nal-hrd=cbr:force-cfr=1:filler=1" \
    -movflags +faststart \
    "$output_path" >/dev/null 2>&1
}

cmd=(
  flutter run
  -d "$SIM_UDID"
  --dart-define=SCREENSHOT_MODE=true
  --dart-define=SCREENSHOT_SCENE=video_finish_celebration
  --dart-define=SCREENSHOT_THEME="$THEME"
  --dart-define=SCREENSHOT_DEVICE="$DEVICE"
  --dart-define=SCREENSHOT_ORIENTATION=portrait
)

echo "Capturing store video on $DEVICE portrait ($THEME)"
("${cmd[@]}" >"$LOG_FILE" 2>&1) &
run_pid=$!

if ! wait_for_ready "$LOG_FILE" "SCREENSHOT_READY:$OUTPUT_NAME"; then
  cleanup_run "$run_pid"
  exit 1
fi

xcrun simctl io "$SIM_UDID" recordVideo --codec=h264 "$RAW_CAPTURE_PATH" >"$RECORD_LOG" 2>&1 &
record_pid=$!
sleep "$DURATION_SECONDS"
kill -INT "$record_pid" >/dev/null 2>&1 || true
wait "$record_pid" >/dev/null 2>&1 || true

cleanup_run "$run_pid"

if [[ ! -f "$RAW_CAPTURE_PATH" ]]; then
  echo "Video capture failed: $RAW_CAPTURE_PATH was not created." >&2
  tail -n 80 "$RECORD_LOG" >&2 || true
  exit 1
fi

FONT_FILE="$(find_font_file || true)"
if [[ -z "$FONT_FILE" ]]; then
  echo "Could not find a system font for the disclosure end frame." >&2
  exit 1
fi

write_disclosure_text "$THEME" "$DISCLOSURE_TEXT_FILE"

post_process_video "$RAW_CAPTURE_PATH" "$PROCESSED_PATH" "$DISCLOSURE_TEXT_FILE" "$FONT_FILE"
mv "$PROCESSED_PATH" "$OUTPUT_PATH"

OUTPUT_SIZE_BYTES="$(stat -f%z "$OUTPUT_PATH")"
if (( OUTPUT_SIZE_BYTES > MAX_FILE_SIZE_BYTES )); then
  echo "Processed video exceeds Apple's 500 MB limit: $OUTPUT_PATH" >&2
  exit 1
fi

echo "Saved video to $OUTPUT_PATH"
