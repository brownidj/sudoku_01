#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-flutter_app}"
LIB_DIR="$ROOT_DIR/lib"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required for premium policy checks" >&2
  exit 2
fi

FAIL=0

echo "Checking for direct entitlement comparisons outside policy layer..."
ENTITLEMENT_HITS="$(rg -n "==\s*Entitlement\.|Entitlement\.[a-z_]+\s*==" "$LIB_DIR" || true)"
if [[ -n "$ENTITLEMENT_HITS" ]]; then
  echo "$ENTITLEMENT_HITS"
  FAIL=1
fi

echo "Checking for scattered PremiumFeature usage outside model/policy files..."
PREMIUM_FEATURE_HITS="$(
  rg -n "PremiumFeature\." "$LIB_DIR" \
    -g '!**/domain/types.dart' \
    -g '!**/app/premium_policy_service.dart' \
    || true
)"
if [[ -n "$PREMIUM_FEATURE_HITS" ]]; then
  echo "$PREMIUM_FEATURE_HITS"
  FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
  echo "Premium policy guard failed. Route checks through PremiumPolicyService." >&2
  exit 1
fi

echo "Premium policy guard passed."
