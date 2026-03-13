#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "$APP_DIR/.." && pwd)"

cd "$ROOT_DIR"
exec "$ROOT_DIR/scripts/check_flutter_file_sizes.sh" flutter_app
