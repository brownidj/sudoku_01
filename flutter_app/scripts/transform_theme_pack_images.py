#!/usr/bin/env python3
"""Transform Sudoku Playtime theme images into pack-ready assets."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from PIL import Image, ImageOps

from theme_pack_common import normalize_theme_id, source_folder_for_theme
from theme_pack_image_support import (
    DEFAULT_OUTPUT_ROOT,
    DEFAULT_REPORT_DIR,
    DEFAULT_SOURCE_ROOT,
    ThemeResult,
    TileResult,
    build_preview,
    default_report_path,
    discover_theme_files,
    duplicate_groups,
    file_sha256,
    generate_manifest,
    has_meaningful_alpha,
    label_from_tile_id,
    prepare_square_image,
    require_exactly_nine_tiles,
    save_webp,
    tile_id_from_source,
    write_report,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Transform theme image folders into theme-pack assets.")
    parser.add_argument("themes", nargs="+", help="Theme IDs to transform, for example: butterflies shells old_opera buttons fruit planets")
    parser.add_argument("--source-root", type=Path, default=DEFAULT_SOURCE_ROOT, help=f"Root image directory. Default: {DEFAULT_SOURCE_ROOT}")
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT, help=f"Generated pack root. Default: {DEFAULT_OUTPUT_ROOT}")
    parser.add_argument("--report-dir", type=Path, default=DEFAULT_REPORT_DIR, help=f"Markdown report directory. Default: {DEFAULT_REPORT_DIR}")
    parser.add_argument("--report-file", type=Path, default=None, help="Optional explicit Markdown report path.")
    parser.add_argument("--theme-version", type=int, default=1, help="theme_version written to every generated manifest. Default: 1")
    parser.add_argument("--schema-version", type=int, default=1, help="schema_version written to every generated manifest. Default: 1")
    parser.add_argument("--minimum-app-build", type=int, default=120, help="minimum_app_build written to every generated manifest. Default: 120")
    parser.add_argument("--tile-size", type=int, default=512, help="Square output tile size in pixels. Default: 512")
    parser.add_argument("--preview-size", type=int, default=768, help="Square output preview size in pixels. Default: 768")
    parser.add_argument("--quality", type=int, default=86, help="WebP quality from 1 to 100. Default: 86")
    parser.add_argument("--force", action="store_true", help="Delete any existing generated output directory for a theme.")
    return parser.parse_args()


def transform_theme(*, theme: str, source_root: Path, output_root: Path, theme_version: int, schema_version: int, minimum_app_build: int, tile_size: int, preview_size: int, quality: int, force: bool) -> ThemeResult:
    source_dir = source_root / source_folder_for_theme(theme)
    if not source_dir.exists():
        raise FileNotFoundError(f"{theme}: source directory does not exist: {source_dir}")
    source_paths = discover_theme_files(theme, source_dir)
    require_exactly_nine_tiles(theme, source_paths)
    output_dir = output_root / f"{theme}_v{theme_version}"
    if output_dir.exists():
        if not force:
            raise FileExistsError(f"{theme}: output directory already exists: {output_dir}. Use --force to replace it.")
        shutil.rmtree(output_dir)
    tiles_dir = output_dir / "tiles"
    tiles_dir.mkdir(parents=True, exist_ok=True)
    warnings: list[str] = []
    tiles: list[TileResult] = []
    for index, source_path in enumerate(source_paths, start=1):
        source_bytes = source_path.stat().st_size
        source_sha = file_sha256(source_path)
        with Image.open(source_path) as source_image:
            source_image = ImageOps.exif_transpose(source_image)
            source_size = source_image.size
            had_alpha = source_image.mode in ("RGBA", "LA") or "transparency" in source_image.info
            keep_alpha = has_meaningful_alpha(source_image)
            if had_alpha and not keep_alpha:
                warnings.append(f"{source_path.name}: removed unused alpha channel")
            output_image = prepare_square_image(source_image, size=tile_size, preserve_alpha=keep_alpha)
        output_path = tiles_dir / f"tile_{index:02d}.webp"
        save_webp(output_image, output_path, quality=quality)
        tile_id = tile_id_from_source(source_path, index)
        tiles.append(TileResult(digit=index, tile_id=tile_id, label=label_from_tile_id(tile_id), source_path=source_path, output_path=output_path, source_size=source_size, output_size=output_image.size, source_bytes=source_bytes, output_bytes=output_path.stat().st_size, source_sha256=source_sha, output_sha256=file_sha256(output_path), had_alpha=had_alpha, kept_alpha=keep_alpha))
    preview_path = output_dir / "preview.webp"
    build_preview([tile.output_path for tile in tiles], preview_path, preview_size=preview_size, quality=quality)
    manifest = generate_manifest(theme=theme, display_name=" ".join(part.capitalize() for part in theme.split("_")), theme_version=theme_version, schema_version=schema_version, minimum_app_build=minimum_app_build, tiles=tiles)
    manifest_path = output_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return ThemeResult(theme=theme, source_dir=source_dir, output_dir=output_dir, manifest_path=manifest_path, preview_path=preview_path, tiles=tiles, duplicate_source_groups=duplicate_groups(tiles), warnings=warnings)


def main() -> int:
    args = parse_args()
    args.source_root = args.source_root.resolve()
    args.output_root = args.output_root.resolve()
    args.report_dir = args.report_dir.resolve()
    if args.tile_size <= 0 or args.preview_size <= 0:
        raise SystemExit("--tile-size and --preview-size must be positive")
    if not 1 <= args.quality <= 100:
        raise SystemExit("--quality must be between 1 and 100")
    args.themes = [normalize_theme_id(theme) for theme in args.themes]
    results: list[ThemeResult] = []
    failures: list[str] = []
    for theme in args.themes:
        try:
            results.append(transform_theme(theme=theme, source_root=args.source_root, output_root=args.output_root, theme_version=args.theme_version, schema_version=args.schema_version, minimum_app_build=args.minimum_app_build, tile_size=args.tile_size, preview_size=args.preview_size, quality=args.quality, force=args.force))
        except Exception as exc:  # pragma: no cover
            failures.append(f"`{theme}`: {exc}")
    report_path = args.report_file.resolve() if args.report_file is not None else default_report_path(args.report_dir)
    write_report(report_path=report_path, results=results, args=args, failures=failures)
    print(f"Wrote report: {report_path}")
    for result in results:
        print(f"Transformed {result.theme}: {result.output_dir}")
    if failures:
        for failure in failures:
            print(f"FAILED {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
