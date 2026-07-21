#!/usr/bin/env bash

set -u

paths=(
  "/Users/david/Library/Caches/Google/AndroidStudio2025.3.3/aia/codex/bin/codex-aarch64-apple-darwin"
  "/Users/david/Library/Caches/JetBrains/PyCharm2026.1/aia/codex/bin/codex-aarch64-apple-darwin"
  "/Users/david/Library/Caches/JetBrains/PyCharm2025.3/aia/codex/bin/codex-aarch64-apple-darwin"
  "/Users/david/.Trash/codex-aarch64-apple-darwin"
)

for path in "${paths[@]}"; do
  echo
  echo "=== $path ==="

  if [[ ! -e "$path" ]]; then
    echo "Missing: $path"
    continue
  fi

  xattr -l "$path" || true
  xattr -d com.apple.quarantine "$path" 2>/dev/null || true
  chmod u+x "$path" 2>/dev/null || true
  spctl --assess --verbose "$path" || true
  codesign -dv --verbose=4 "$path" || true
done
