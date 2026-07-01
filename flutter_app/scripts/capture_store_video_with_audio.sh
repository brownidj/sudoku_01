#!/usr/bin/env bash
set -euo pipefail
usage() {
  cat <<USAGE
Usage: ./scripts/capture_store_video_with_audio.sh --device <iphone|ipad> \
       --audio-device <avfoundation-audio-device> [--duration <seconds>] \
       [--output <filename>] [--theme <animals|butterflies>]
Records a clean simulator video with intro and disclosure frames.
USAGE
}
DEVICE=""; AUDIO_DEVICE=""; DURATION_SECONDS=8; OUTPUT_NAME=""; THEME="animals"
START_FRAME_SECONDS="1.5"; END_FRAME_SECONDS=2; FRAME_RATE=30
TARGET_BITRATE="11M"; MIN_BITRATE="10M"; MAX_BITRATE="12M"; BUFFER_SIZE="24M"
MAX_FILE_SIZE_BYTES=$((500 * 1024 * 1024))
FFMPEG_BIN="/opt/homebrew/bin/ffmpeg"; FFPROBE_BIN="/opt/homebrew/bin/ffprobe"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE="${2:-}"
      shift 2
      ;;
    --audio-device)
      AUDIO_DEVICE="${2:-}"
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
    --list-audio-devices)
      "$FFMPEG_BIN" -f avfoundation -list_devices true -i "" 2>&1 |
        sed -n '/AVFoundation audio devices:/,$p'
      exit 0
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
if [[ ! -x "$FFMPEG_BIN" || ! -x "$FFPROBE_BIN" ]]; then
  echo "ffmpeg and ffprobe are required at $FFMPEG_BIN and $FFPROBE_BIN" >&2
  exit 1
fi
if [[ "$DEVICE" != "iphone" && "$DEVICE" != "ipad" ]]; then
  echo "--device must be iphone or ipad" >&2
  exit 1
fi
if [[ "$THEME" != "animals" && "$THEME" != "butterflies" ]]; then
  echo "--theme must be animals or butterflies" >&2
  exit 1
fi
if [[ -z "$AUDIO_DEVICE" ]]; then
  echo "--audio-device is required. Use --list-audio-devices to inspect available inputs." >&2
  exit 1
fi
if ! [[ "$DURATION_SECONDS" =~ ^[0-9]+$ ]] || (( DURATION_SECONDS <= 0 )); then
  echo "--duration must be a positive integer" >&2
  exit 1
fi
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
VIDEO_ROOT="$REPO_ROOT/assets/videos"
cd "$ROOT_DIR"
source "$ROOT_DIR/scripts/store_video_capture_common.sh"
source "$ROOT_DIR/scripts/store_video_audio_capture_helpers.sh"
require_ffmpeg_tools
configure_store_video_target
if [[ -z "$OUTPUT_NAME" ]]; then
  OUTPUT_NAME="$(resolve_default_video_output_name "$THEME" "_with_audio")"
fi
READY_MARKER_NAME="$(resolve_default_video_output_name "$THEME")"
DONE_MARKER="SCREENSHOT_DONE:$READY_MARKER_NAME"
CELEBRATION_AUDIO_MARKER="SCREENSHOT_CELEBRATION_AUDIO:"
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
RAW_AUDIO_PATH="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_raw.m4a"
PROCESSED_PATH="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_processed.${OUTPUT_NAME##*.}"
DISCLOSURE_TEXT_FILE="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_disclosure.txt"
LOG_FILE="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_video.log"
RECORD_LOG="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_record.log"
AUDIO_LOG="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_audio.log"
FALLBACK_AUDIO_PATH="/tmp/${OUTPUT_NAME%.*}_${DEVICE}_fallback_audio.m4a"
rm -f "$OUTPUT_PATH" "$RAW_CAPTURE_PATH" "$RAW_AUDIO_PATH" "$PROCESSED_PATH" \
  "$DISCLOSURE_TEXT_FILE" "$LOG_FILE" "$RECORD_LOG" "$AUDIO_LOG" \
  "$FALLBACK_AUDIO_PATH"
BUNDLE_ID="$(resolve_bundle_id)"
ORIGINAL_OUTPUT_DEVICE_INFO="$(get_current_audio_device output)"
ORIGINAL_SYSTEM_OUTPUT_DEVICE_INFO="$(get_current_audio_device system)"
ORIGINAL_OUTPUT_DEVICE_ID="${ORIGINAL_OUTPUT_DEVICE_INFO%%$'\t'*}"
ORIGINAL_SYSTEM_OUTPUT_DEVICE_ID="${ORIGINAL_SYSTEM_OUTPUT_DEVICE_INFO%%$'\t'*}"
restore_audio_devices() {
  set_audio_device_by_id output "$ORIGINAL_OUTPUT_DEVICE_ID" >/dev/null 2>&1 || true
  set_audio_device_by_id system "$ORIGINAL_SYSTEM_OUTPUT_DEVICE_ID" >/dev/null 2>&1 || true
}
trap restore_audio_devices EXIT
set_audio_device_by_name output "$AUDIO_DEVICE"
set_audio_device_by_name system "$AUDIO_DEVICE"
boot_capture_simulator
post_process_video_with_audio() {
  local raw_video_path="$1"
  local raw_audio_path="$2"
  local output_path="$3"
  local disclosure_text="$4"
  local font_file="$5"
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
    -i "$raw_video_path" \
    -i "$raw_audio_path" \
    -f lavfi -t "$START_FRAME_SECONDS" -i "color=c=white:s=${width}x${height}:r=${FRAME_RATE}" \
    -f lavfi -t "$START_FRAME_SECONDS" -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
    -f lavfi -t "$END_FRAME_SECONDS" -i "color=c=white:s=${width}x${height}:r=${FRAME_RATE}" \
    -f lavfi -t "$END_FRAME_SECONDS" -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
    -filter_complex "\
[2:v]drawtext=fontfile='${font_file}':text='Celebrate!':fontcolor=black:fontsize=${intro_fontsize}:x=(w-text_w)/2:y=(h-text_h)/2,format=yuv420p[v0];\
[0:v]fps=${FRAME_RATE},scale=${width}:${height}:flags=lanczos,setsar=1,format=yuv420p[v1];\
[4:v]drawtext=fontfile='${font_file}':textfile='${disclosure_text}':fontcolor=black:fontsize=${fontsize}:line_spacing=18:x=(w-text_w)/2:y=(h-text_h)/2,format=yuv420p[v2];\
[3:a]aresample=48000[a0];\
[1:a]aresample=48000[a1];\
[5:a]aresample=48000[a2];\
[v0][a0][v1][a1][v2][a2]concat=n=3:v=1:a=1[v][a]" \
    -map "[v]" \
    -map "[a]" \
    -c:v libx264 \
    -profile:v high \
    -pix_fmt yuv420p \
    -r "$FRAME_RATE" \
    -b:v "$TARGET_BITRATE" \
    -minrate "$MIN_BITRATE" \
    -maxrate "$MAX_BITRATE" \
    -bufsize "$BUFFER_SIZE" \
    -x264-params "nal-hrd=cbr:force-cfr=1:filler=1" \
    -c:a aac \
    -b:a 192k \
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
  --dart-define=SCREENSHOT_CAPTURE_AUDIO=true
)

echo "Capturing store video with audio on $DEVICE portrait ($THEME)"
("${cmd[@]}" >"$LOG_FILE" 2>&1) &
run_pid=$!
if ! wait_for_ready "$LOG_FILE" "SCREENSHOT_READY:$READY_MARKER_NAME"; then
  cleanup_run "$run_pid"
  exit 1
fi

xcrun simctl io "$SIM_UDID" recordVideo --codec=h264 "$RAW_CAPTURE_PATH" >"$RECORD_LOG" 2>&1 &
record_pid=$!
"$FFMPEG_BIN" -y -f avfoundation -i ":$AUDIO_DEVICE" -ac 2 -ar 48000 -c:a aac \
  -b:a 192k "$RAW_AUDIO_PATH" >"$AUDIO_LOG" 2>&1 &
audio_pid=$!

if ! celebration_delay_seconds="$(
  wait_for_done_and_capture_delay "$LOG_FILE" "$DONE_MARKER" "$CELEBRATION_AUDIO_MARKER" "$((DURATION_SECONDS + 20))"
)"; then
  kill -INT "$record_pid" >/dev/null 2>&1 || true
  kill -INT "$audio_pid" >/dev/null 2>&1 || true
  wait "$record_pid" >/dev/null 2>&1 || true
  wait "$audio_pid" >/dev/null 2>&1 || true
  cleanup_run "$run_pid"
  exit 1
fi

kill -INT "$record_pid" >/dev/null 2>&1 || true
kill -INT "$audio_pid" >/dev/null 2>&1 || true
wait "$record_pid" >/dev/null 2>&1 || true
wait "$audio_pid" >/dev/null 2>&1 || true

cleanup_run "$run_pid"
restore_audio_devices

if [[ ! -f "$RAW_CAPTURE_PATH" ]]; then
  echo "Video capture failed: $RAW_CAPTURE_PATH was not created." >&2
  tail -n 80 "$RECORD_LOG" >&2 || true
  exit 1
fi

if [[ ! -f "$RAW_AUDIO_PATH" ]]; then
  echo "Audio capture failed: $RAW_AUDIO_PATH was not created." >&2
  tail -n 80 "$AUDIO_LOG" >&2 || true
  exit 1
fi

if ! audio_is_audible "$RAW_AUDIO_PATH" "$FFMPEG_BIN"; then
  if [[ "$THEME" == "animals" ]]; then
    CELEBRATION_AUDIO_ASSET="$(extract_celebration_audio_track "$LOG_FILE")"
    if [[ -z "$CELEBRATION_AUDIO_ASSET" ]]; then
      echo "Captured audio is silent and no celebration audio asset was logged." >&2
      tail -n 120 "$LOG_FILE" >&2 || true
      exit 1
    fi
    build_delayed_loop_audio \
      "$CELEBRATION_AUDIO_ASSET" \
      "$RAW_CAPTURE_PATH" \
      "$FALLBACK_AUDIO_PATH" \
      "$ROOT_DIR" \
      "$FFMPEG_BIN" \
      "$FFPROBE_BIN" \
      "${celebration_delay_seconds:-0}"
  else
    BACKGROUND_TRACK_ASSET="$(extract_background_music_track "$LOG_FILE")"
    if [[ -z "$BACKGROUND_TRACK_ASSET" ]]; then
      echo "Captured audio is silent and no background track was logged." >&2
      tail -n 120 "$LOG_FILE" >&2 || true
      exit 1
    fi
    build_fallback_background_audio \
      "$BACKGROUND_TRACK_ASSET" \
      "$RAW_CAPTURE_PATH" \
      "$FALLBACK_AUDIO_PATH" \
      "$ROOT_DIR" \
      "$FFMPEG_BIN" \
      "$FFPROBE_BIN"
  fi
  RAW_AUDIO_PATH="$FALLBACK_AUDIO_PATH"
fi

FONT_FILE="$(find_font_file || true)"
if [[ -z "$FONT_FILE" ]]; then
  echo "Could not find a system font for the disclosure end frame." >&2
  exit 1
fi

write_disclosure_text "$THEME" "$DISCLOSURE_TEXT_FILE"

post_process_video_with_audio \
  "$RAW_CAPTURE_PATH" \
  "$RAW_AUDIO_PATH" \
  "$PROCESSED_PATH" \
  "$DISCLOSURE_TEXT_FILE" \
  "$FONT_FILE"

mv "$PROCESSED_PATH" "$OUTPUT_PATH"

OUTPUT_SIZE_BYTES="$(stat -f%z "$OUTPUT_PATH")"
if (( OUTPUT_SIZE_BYTES > MAX_FILE_SIZE_BYTES )); then
  echo "Processed video exceeds Apple's 500 MB limit: $OUTPUT_PATH" >&2
  exit 1
fi

echo "Saved video with audio to $OUTPUT_PATH"
