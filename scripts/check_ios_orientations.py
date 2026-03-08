#!/usr/bin/env python3
"""Validate required iOS orientation keys for App Store iPad multitasking."""

from __future__ import annotations

import argparse
import plistlib
import sys
from pathlib import Path


REQUIRED = [
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationPortraitUpsideDown",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
]


def _get_orientations(doc: dict, key: str) -> list[str]:
    value = doc.get(key, [])
    if not isinstance(value, list):
        return []
    return [v for v in value if isinstance(v, str)]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--plist",
        default="flutter_app/ios/Runner/Info.plist",
        help="Path to Runner Info.plist",
    )
    args = parser.parse_args()

    plist_path = Path(args.plist)
    if not plist_path.exists():
        print(f"ERROR: plist not found: {plist_path}")
        return 2

    with plist_path.open("rb") as f:
        doc = plistlib.load(f)

    failed = False
    for key in ("UISupportedInterfaceOrientations", "UISupportedInterfaceOrientations~ipad"):
        values = _get_orientations(doc, key)
        missing = [required for required in REQUIRED if required not in values]
        if missing:
            failed = True
            print(f"ERROR: {key} is missing: {', '.join(missing)}")
        else:
            print(f"OK: {key} contains all required orientations.")

    if failed:
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
