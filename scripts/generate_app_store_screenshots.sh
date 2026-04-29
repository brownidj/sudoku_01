#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_IMAGE="${ROOT_DIR}/assets/images/ZuDoKu+01.png"
OUTPUT_DIR="${ROOT_DIR}/assets/images"

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required. Install it and retry." >&2
  exit 1
fi

if [[ ! -f "${INPUT_IMAGE}" ]]; then
  echo "Input image not found: ${INPUT_IMAGE}" >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

generate_variant() {
  local width="$1"
  local height="$2"
  local label="$3"
  local output_file="${OUTPUT_DIR}/ZuDoKu+01_${label}_${width}x${height}.png"

  magick "${INPUT_IMAGE}" \
    -auto-orient \
    -resize "${width}x${height}^" \
    -gravity center \
    -extent "${width}x${height}" \
    "${output_file}"

  echo "Generated ${output_file}"
}

# Accepted iPhone screenshot dimensions commonly used for App Store Connect.
generate_variant 1290 2796 "iphone_6_9"
generate_variant 1284 2778 "iphone_6_5"
generate_variant 1179 2556 "iphone_6_3"
generate_variant 1170 2532 "iphone_6_1"

