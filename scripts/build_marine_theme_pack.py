#!/usr/bin/env python3
"""Build the Marine Life pilot with creature sounds and music for Apple.

Requires Pillow with WebP support. Does not change source images, bundle assets,
sign anything, upload content, or run Flutter/Xcode application builds.
"""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps, features


PROJECT = Path(__file__).resolve().parents[1]
TILES = (
    ("butterflyfish", "Butterflyfish"),
    ("octopus", "Octopus"),
    ("crab", "Crab"),
    ("seahorse", "Seahorse"),
    ("starfish", "Starfish"),
    ("walrus", "Walrus"),
    ("shark", "Shark"),
    ("jellyfish", "Jellyfish"),
    ("turtle", "Turtle"),
)


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(output, package_apple):
    if not features.check("webp"):
        raise RuntimeError("Pillow requires WebP encoding support.")
    version = re.search(
        r"^version:\s*\S+\+(\d+)\s*$",
        (PROJECT / "flutter_app/pubspec.yaml").read_text(),
        re.MULTILINE,
    )
    if version is None:
        raise ValueError("Cannot determine minimum app build from pubspec.yaml.")
    app_build = int(version.group(1))
    source = PROJECT / "flutter_app/assets/images/marine"
    root = output / "marine_v2"
    (root / "tiles").mkdir(parents=True, exist_ok=True)
    entries, images, source_hashes = [], [], {}
    for digit, (tile_id, label) in enumerate(TILES, start=1):
        input_path = source / f"{digit}_{tile_id}.png"
        source_hashes[input_path.name] = digest(input_path)
        with Image.open(input_path) as original:
            if max(original.size) > 8192:
                raise ValueError(f"Source image is too large: {input_path}")
            image = ImageOps.exif_transpose(original).convert("RGBA")
            image = ImageOps.contain(image, (512, 512), Image.Resampling.LANCZOS)
            square = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
            square.alpha_composite(
                image, ((512 - image.width) // 2, (512 - image.height) // 2)
            )
            if square.getchannel("A").getextrema() == (255, 255):
                square = square.convert("RGB")
            relative = f"tiles/tile_{digit:02d}.webp"
            square.save(root / relative, "WEBP", quality=86, method=6)
            images.append(square.copy())
        entries.append(
            {"id": tile_id, "path": relative, "accessibility_label": label}
        )

    preview = Image.new("RGB", (768, 768), "#F4FAFC")
    draw = ImageDraw.Draw(preview)
    for index, image in enumerate(images):
        x, y = (index % 3) * 256, (index // 3) * 256
        thumbnail = ImageOps.contain(image, (224, 216), Image.Resampling.LANCZOS)
        preview.paste(
            thumbnail,
            (x + (256 - thumbnail.width) // 2, y + 8),
            thumbnail.getchannel("A") if thumbnail.mode == "RGBA" else None,
        )
        draw.text((x + 128, y + 238), TILES[index][1], fill="#163F50", anchor="mm")
    preview.save(root / "preview.webp", "WEBP", quality=86, method=6)
    assets = ["preview.webp", *(entry["path"] for entry in entries)]
    image_assets = list(assets)
    audio_source = PROJECT / "flutter_app/assets/audio/marine"
    music_source = PROJECT / "flutter_app/assets/audio/unused/marine"
    tile_audio, music, audio_hashes = [], [], {}
    for digit, (tile_id, _) in enumerate(TILES, start=1):
        filename = "1_butterfly.mp3" if digit == 1 else f"{digit}_{tile_id}.mp3"
        source_path = audio_source / filename
        relative = f"audio/tiles/{digit:02d}.mp3"
        (root / relative).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_path, root / relative)
        audio_hashes[str(source_path.relative_to(PROJECT))] = digest(source_path)
        assets.append(relative)
        tile_audio.append({"digit": digit, "long_press": relative})
    # Include the nine original songs, without the numbered alternate takes.
    for source_path in sorted(music_source.glob("*.mp3")):
        if re.search(r"-\d+$", source_path.stem):
            continue
        relative = f"audio/music/{source_path.name}"
        (root / relative).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_path, root / relative)
        audio_hashes[str(source_path.relative_to(PROJECT))] = digest(source_path)
        assets.append(relative)
        music.append(relative)
    if len(music) != 9:
        raise ValueError("Expected nine original Marine Life background songs.")
    manifest = {
        "schema_version": 1,
        "theme_id": "marine",
        "theme_version": 2,
        "display_name": "Marine Life",
        "tile_count": 9,
        "tiles": entries,
        "preview_path": "preview.webp",
        "minimum_app_build": app_build,
        "audio": {"tiles": tile_audio, "music": music},
        "checksums": {name: digest(root / name) for name in assets},
    }
    write_json(root / "manifest.json", manifest)
    archive_path = output / "marine_v2.zip"
    with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for name in sorted(["manifest.json", *assets]):
            # Stable ZIP metadata makes unchanged inputs produce the same hash.
            info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, (root / name).read_bytes())

    catalogue = {
        "catalogue_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "minimum_supported_app_build": app_build,
        "themes": [
            {
                "id": "marine",
                "version": 2,
                "display_name": "Marine Life",
                "description": "Nine familiar sea creatures.",
                "apple_asset_pack_id": "marine",
                "archive_path": "ThemePacks/marine_v2.zip",
                "preview_path": "ThemePreviews/marine_v2.webp",
                "sha256": digest(archive_path),
                "file_size_bytes": archive_path.stat().st_size,
                "minimum_app_build": app_build,
                "is_free": True,
                "active": True,
            }
        ],
    }
    write_json(output / "catalogue.json", catalogue)
    apple_manifests = {
        "marine_v2": {
            "assetPackID": "marine",
            "downloadPolicy": {"onDemand": {}},
            "fileSelectors": [
                {
                    "fileSource": "marine_v2.zip",
                    "fileDestination": "ThemePacks/marine_v2.zip",
                }
            ],
            "platforms": ["iOS"],
        },
        "theme_catalogue_v2": {
            "assetPackID": "theme_catalogue",
            "downloadPolicy": {"onDemand": {}},
            "fileSelectors": [
                {"fileSource": "catalogue.json", "fileDestination": "ThemeCatalogue/catalogue.json"},
                {"fileSource": "marine_v2/preview.webp", "fileDestination": "ThemePreviews/marine_v2.webp"},
            ],
            "platforms": ["iOS"],
        },
    }
    for name, value in apple_manifests.items():
        write_json(output / f"{name}.apple.json", value)
        if package_apple:
            with tempfile.TemporaryDirectory(prefix="apple_pack_", dir=output) as stage:
                packaged = Path(stage) / f"{name}.aar"
                subprocess.run(
                    ["xcrun", "ba-package", f"{name}.apple.json", "-o", str(packaged)],
                    cwd=output,
                    check=True,
                )
                packaged.replace(output / f"{name}.aar")
    # Validate exactly the bytes that will be distributed, without invoking
    # application builds or the Flutter test runner.
    with zipfile.ZipFile(archive_path) as archive:
        if archive.testzip() is not None:
            raise ValueError("ZIP integrity check failed.")
        for name, checksum in manifest["checksums"].items():
            if hashlib.sha256(archive.read(name)).hexdigest() != checksum:
                raise ValueError(f"Asset checksum mismatch: {name}")
    for name in image_assets:
        with Image.open(root / name) as image:
            expected = (768, 768) if name == "preview.webp" else (512, 512)
            if image.size != expected:
                raise ValueError(f"Unexpected image dimensions: {name}")
    if any(digest(source / name) != checksum for name, checksum in source_hashes.items()):
        raise ValueError("A source image changed during packaging.")
    if any(digest(PROJECT / name) != checksum for name, checksum in audio_hashes.items()):
        raise ValueError("Source audio changed during packaging.")
    if archive_path.stat().st_size > 64 * 1024 * 1024:
        raise ValueError("Pilot ZIP exceeds the app's 64 MiB delivery limit.")
    report = {
        "theme": "marine",
        "content_version": 2,
        "minimum_app_build": app_build,
        "tile_count": 9,
        "audio_included": True,
        "creature_audio_count": len(tile_audio),
        "background_music_count": len(music),
        "audio_source_sha256": audio_hashes,
        "zip_bytes": archive_path.stat().st_size,
        "zip_sha256": digest(archive_path),
        "source_sha256": source_hashes,
        "apple_archives_created": package_apple,
    }
    write_json(output / "marine_v2.build_report.json", report)
    print(json.dumps({"output": str(output), **report}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=PROJECT / "flutter_app/build/theme_packs")
    parser.add_argument("--package-apple", action="store_true", help="Also create .aar files using Xcode's ba-package.")
    args = parser.parse_args()
    build(args.output.resolve(), args.package_apple)
