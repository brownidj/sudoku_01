#!/bin/bash
# Start Apple's HTTPS mock server. Uses an existing trusted TLS identity;
# never creates certificates, changes trust settings, or builds the app.
set -euo pipefail

pack_project_root="$(cd "$(dirname "$0")/.." && pwd)"
pack_output="$pack_project_root/flutter_app/build/theme_packs"
pack_host="${1:-localhost}"
pack_port="${2:-63245}"

for pack_archive in marine_v4.aar theme_catalogue_v4.aar; do
  if [[ ! -f "$pack_output/$pack_archive" ]]; then
    echo "Missing $pack_archive. From the repository root, run:" >&2
    echo "python3 scripts/build_marine_theme_pack.py --package-apple" >&2
    exit 1
  fi
done

echo "Starting the Marine Life asset server at https://$pack_host:$pack_port"
echo "Selecting a TLS identity automatically for $pack_host (no identity picker)."
echo "The identity must be trusted by your Mac and test device."
echo "Set the device's Background Assets Development URL Override to that base URL."
echo "For a physical iPhone, pass this Mac's reachable hostname or LAN IP."

exec xcrun ba-serve serve \
  "$pack_output/marine_v4.aar" \
  "$pack_output/theme_catalogue_v4.aar" \
  --asset-pack-versions 4 4 \
  --host "$pack_host" \
  --port "$pack_port" \
  --choose-identity-automatically
