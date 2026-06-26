#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/caption_store_screenshot.sh --input <png> --output <png> --caption <text> [--position <top|bottom>] [--offset-adjust <px>] [--box-height <px>]
USAGE
}

INPUT=""
OUTPUT=""
CAPTION=""
POSITION="bottom"
OFFSET_ADJUST="0"
BOX_HEIGHT_OVERRIDE=""
FONT="Verdana-Bold"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    --caption)
      CAPTION="${2:-}"
      shift 2
      ;;
    --position)
      POSITION="${2:-}"
      shift 2
      ;;
    --offset-adjust)
      OFFSET_ADJUST="${2:-}"
      shift 2
      ;;
    --box-height)
      BOX_HEIGHT_OVERRIDE="${2:-}"
      shift 2
      ;;
    --font)
      FONT="${2:-}"
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

if [[ -z "$INPUT" || -z "$OUTPUT" || -z "$CAPTION" ]]; then
  usage >&2
  exit 1
fi

if [[ "$POSITION" != "top" && "$POSITION" != "bottom" ]]; then
  echo "--position must be top or bottom" >&2
  exit 1
fi

MAGICK_BIN="/opt/homebrew/bin/magick"
MAX_POINTSIZE=48

if [[ ! -f "$INPUT" ]]; then
  echo "Input file not found: $INPUT" >&2
  exit 1
fi

DIMENSIONS="$("$MAGICK_BIN" identify -format "%w %h" "$INPUT")"
read -r WIDTH HEIGHT <<< "$DIMENSIONS"

PADDING_X=$(( WIDTH / 18 ))
BOX_WIDTH=$(( WIDTH - (2 * PADDING_X) ))
BOX_HEIGHT=$(( HEIGHT / 11 ))
if [[ -n "$BOX_HEIGHT_OVERRIDE" ]]; then
  BOX_HEIGHT="$BOX_HEIGHT_OVERRIDE"
fi
PADDING_Y=$(( HEIGHT / 70 ))
OFFSET_Y=$(( HEIGHT / 7 ))
RADIUS=$(( HEIGHT / 60 ))
OFFSET_Y=$(( OFFSET_Y + OFFSET_ADJUST ))

measure_text_width() {
  local pointsize="$1"
  "$MAGICK_BIN" -background none -fill white -font "$FONT" \
    -pointsize "$pointsize" label:"$CAPTION" -format "%w" info:
}

POINTSIZE="$MAX_POINTSIZE"
while (( POINTSIZE > 12 )); do
  TEXT_WIDTH="$(measure_text_width "$POINTSIZE")"
  if (( TEXT_WIDTH <= BOX_WIDTH - (2 * PADDING_X) )); then
    break
  fi
  POINTSIZE=$(( POINTSIZE - 1 ))
done

"$MAGICK_BIN" "$INPUT" \
  \( \
    -size "${BOX_WIDTH}x${BOX_HEIGHT}" xc:none \
    -fill "#1F2937D9" \
    -draw "roundrectangle 0,0 $(( BOX_WIDTH - 1 )),$(( BOX_HEIGHT - 1 )) $RADIUS,$RADIUS" \
    -fill white \
    -stroke none \
    -gravity center \
    -font "$FONT" \
    -pointsize "$POINTSIZE" \
    -annotate +0+0 "$CAPTION" \
  \) \
  -gravity "$([[ "$POSITION" == "top" ]] && echo north || echo south)" \
  -geometry +0+"$OFFSET_Y" \
  -composite \
  "$OUTPUT"
