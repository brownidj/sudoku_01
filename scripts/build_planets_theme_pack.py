#!/usr/bin/env python3
"""Build the paid Planets v1 pack from the nine numbered images and matching tunes.

Uses the existing Marine Life packaging pipeline. Requires Pillow/WebP and
ffmpeg. Originals are preserved; audio is distributed as 128 kbps AAC copies.
"""
import argparse
import re
from pathlib import Path

if __package__:
    from . import build_marine_theme_pack as packaging
else:
    import build_marine_theme_pack as packaging

CONTENT_VERSION = 1
PRODUCT_ID = "theme_planets"


def discover_tiles(source):
    tiles = {}
    names = set()
    for path in sorted(source.glob("*.png")):
        match = re.fullmatch(r"([1-9])_([a-z]+(?:_[a-z]+)*)_([0-9]+)\.png", path.name)
        if not match:
            raise ValueError(f"Invalid planet image filename: {path.name}")
        digit, name = int(match.group(1)), match.group(2)
        if digit in tiles or name in names:
            raise ValueError(f"Duplicate planet digit/name: {path.name}")
        tiles[digit] = (name, name.replace("_", " ").title(), path)
        names.add(name)
    if set(tiles) != set(range(1, 10)):
        raise ValueError("Expected exactly one numbered planet image for each digit 1–9.")
    return [tiles[digit] for digit in range(1, 10)]


def discover_audio(source, tiles):
    audio = {}
    takes = set()
    for path in sorted(source.iterdir()):
        if path.suffix.lower() not in {".mp3", ".wav", ".m4a"}:
            continue
        match = re.fullmatch(r"([1-9])_([a-z]+(?:_[a-z]+)*)_([1-9][0-9]*)", path.stem)
        if not match:
            raise ValueError(f"Invalid planet audio filename: {path.name}")
        digit, name, take = int(match.group(1)), match.group(2), int(match.group(3))
        if tiles[digit - 1][0] != name:
            raise ValueError(f"Planet audio does not match digit/name: {path.name}")
        if (digit, take) in takes:
            raise ValueError(f"Duplicate planet audio take: {path.name}")
        takes.add((digit, take))
        audio.setdefault(digit, []).append(path)
    if set(audio) != set(range(1, 10)):
        raise ValueError("Expected at least one matching tune for each planet.")
    return {digit: sorted(audio[digit], key=lambda path: int(path.stem.rsplit("_", 1)[1]))
            for digit in range(1, 10)}


def build(output, package_apple=False, product_id=PRODUCT_ID):
    if not product_id or not product_id.strip():
        raise ValueError("Planets requires a paid product ID.")
    return packaging.build(
        output, package_apple, product_id,
        theme_id="planets", display_name="Planets", content_version=CONTENT_VERSION,
        description="Nine Solar System tiles with matching tunes and background music, including Pluto.",
        tile_discovery=discover_tiles, audio_discovery=discover_audio, transcode_audio=True,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path,
                        default=packaging.PROJECT / "flutter_app/build/theme_packs_planets")
    parser.add_argument("--package-apple", action="store_true")
    parser.add_argument("--product-id", default=PRODUCT_ID)
    args = parser.parse_args()
    build(args.output.resolve(), args.package_apple, args.product_id)
