#!/usr/bin/env python3
"""Transform Sudoku Playtime theme audio into pack-ready assets."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from theme_pack_audio_support import (
    DEFAULT_OUTPUT_ROOT,
    DEFAULT_REPORT_DIR,
    DEFAULT_SOURCE_ROOT,
    ThemeAudioResult,
    TileAudioResult,
    build_audio_manifest,
    discover_music_files,
    discover_tile_audio_files,
    format_seconds,
    probe_duration,
    require_exactly_nine_tile_clips,
    require_tool,
    result_for_output,
    safe_stem,
    source_folder_for_theme,
    transcode_aac,
    update_manifest,
)
from theme_pack_audio_report import default_report_path, write_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Transform theme audio folders into theme-pack assets.")
    parser.add_argument("themes", nargs="+", help="Theme IDs to transform, for example: butterflies shells old_opera")
    parser.add_argument("--source-root", type=Path, default=DEFAULT_SOURCE_ROOT, help=f"Root audio directory. Default: {DEFAULT_SOURCE_ROOT}")
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT, help=f"Generated pack root. Default: {DEFAULT_OUTPUT_ROOT}")
    parser.add_argument("--report-dir", type=Path, default=DEFAULT_REPORT_DIR, help=f"Markdown report directory. Default: {DEFAULT_REPORT_DIR}")
    parser.add_argument("--report-file", type=Path, default=None, help="Optional explicit Markdown report path.")
    parser.add_argument("--theme-version", type=int, default=1, help="Theme version used in the output directory. Default: 1")
    parser.add_argument("--tile-duration", type=float, default=8.0, help="Seconds for tile long-press and celebration clips. Default: 8.0")
    parser.add_argument("--tile-bitrate", default="64k", help="AAC bitrate for 8-second tile clips. Default: 64k")
    parser.add_argument("--music-bitrate", default="96k", help="AAC bitrate for incidental music. Default: 96k")
    parser.add_argument("--sample-rate", type=int, default=44100, help="Output sample rate in Hz. Default: 44100")
    parser.add_argument("--force", action="store_true", help="Replace existing generated audio output for each theme.")
    parser.add_argument("--dry-run", action="store_true", help="Validate inputs and write a report without transcoding files.")
    return parser.parse_args()


def transform_theme(*, theme: str, source_root: Path, output_root: Path, theme_version: int, tile_duration: float, tile_bitrate: str, music_bitrate: str, sample_rate: int, force: bool, dry_run: bool) -> ThemeAudioResult:
    source_folder = source_folder_for_theme(theme)
    source_tile_dir = source_root / source_folder
    source_music_dir = source_root / "background" / source_folder
    if not source_tile_dir.exists():
        raise FileNotFoundError(f"{theme}: source audio directory does not exist: {source_tile_dir}")
    tile_sources = discover_tile_audio_files(theme, source_tile_dir)
    require_exactly_nine_tile_clips(theme, tile_sources)
    music_sources = discover_music_files(source_music_dir)
    output_dir = output_root / f"{theme}_v{theme_version}"
    audio_dir = output_dir / "audio"
    if audio_dir.exists():
        if not force and not dry_run:
            raise FileExistsError(f"{theme}: output audio directory already exists: {audio_dir}. Use --force to replace it.")
        if force and not dry_run:
            shutil.rmtree(audio_dir)
    tile_results: list[TileAudioResult] = []
    music_results = []
    warnings: list[str] = []
    for index, source_path in enumerate(tile_sources, start=1):
        source_duration = probe_duration(source_path)
        if source_duration < tile_duration:
            warnings.append(f"{source_path.name}: source duration {format_seconds(source_duration)} is shorter than target {format_seconds(tile_duration)}")
        output_path = audio_dir / "tiles" / f"tile_{index:02d}.m4a"
        if not dry_run:
            transcode_aac(source_path=source_path, output_path=output_path, bitrate=tile_bitrate, sample_rate=sample_rate, duration=tile_duration)
            base = result_for_output(source_path=source_path, output_path=output_path, source_duration=source_duration)
            tile_results.append(TileAudioResult(digit=index, **base.__dict__))
    for source_path in music_sources:
        source_duration = probe_duration(source_path)
        output_path = audio_dir / "music" / f"{safe_stem(source_path)}.m4a"
        if not dry_run:
            transcode_aac(source_path=source_path, output_path=output_path, bitrate=music_bitrate, sample_rate=sample_rate, duration=None)
            music_results.append(result_for_output(source_path=source_path, output_path=output_path, source_duration=source_duration))
    manifest_path = output_dir / "manifest.json"
    audio_manifest_path = output_dir / "audio_manifest.json"
    if not dry_run:
        audio_manifest = build_audio_manifest(theme=theme, tile_results=tile_results, music_results=music_results, tile_duration=tile_duration)
        output_dir.mkdir(parents=True, exist_ok=True)
        audio_manifest_path.write_text(json.dumps(audio_manifest, indent=2) + "\n", encoding="utf-8")
        update_manifest(manifest_path, audio_manifest)
    return ThemeAudioResult(theme=theme, source_tile_dir=source_tile_dir, source_music_dir=source_music_dir, output_dir=output_dir, manifest_path=manifest_path, audio_manifest_path=audio_manifest_path, tile_audio=tile_results, music=music_results, warnings=warnings)


def main() -> int:
    args = parse_args()
    args.source_root = args.source_root.resolve()
    args.output_root = args.output_root.resolve()
    args.report_dir = args.report_dir.resolve()
    if args.theme_version <= 0:
        raise SystemExit("--theme-version must be positive")
    if args.tile_duration <= 0:
        raise SystemExit("--tile-duration must be positive")
    if args.sample_rate <= 0:
        raise SystemExit("--sample-rate must be positive")
    require_tool("ffmpeg")
    require_tool("ffprobe")
    args.themes = [theme.strip().lower().replace("-", "_") for theme in args.themes]
    results: list[ThemeAudioResult] = []
    failures: list[str] = []
    for theme in args.themes:
        try:
            results.append(transform_theme(theme=theme, source_root=args.source_root, output_root=args.output_root, theme_version=args.theme_version, tile_duration=args.tile_duration, tile_bitrate=args.tile_bitrate, music_bitrate=args.music_bitrate, sample_rate=args.sample_rate, force=args.force, dry_run=args.dry_run))
        except Exception as exc:  # pragma: no cover
            failures.append(f"`{theme}`: {exc}")
    report_path = args.report_file.resolve() if args.report_file is not None else default_report_path(args.report_dir)
    write_report(report_path=report_path, results=results, args=args, failures=failures)
    print(f"Wrote report: {report_path}")
    for result in results:
        print(f"Transformed {result.theme}: {result.output_dir}")
    if failures:
        for failure in failures:
            print(f"Failed {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
