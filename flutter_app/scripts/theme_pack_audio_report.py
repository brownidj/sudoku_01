from __future__ import annotations

from pathlib import Path

from theme_pack_audio_support import ThemeAudioResult, format_seconds
from theme_pack_common import format_bytes, relative, timestamped_report_path, utc_now_iso


def write_report(*, report_path: Path, results: list[ThemeAudioResult], args, failures: list[str]) -> None:
    lines: list[str] = [
        "# Theme Pack Audio Transformation Report",
        "",
        f"Generated at: `{utc_now_iso()}`",
        "",
        "## Inputs",
        "",
        f"- Themes: `{', '.join(args.themes)}`",
        f"- Source root: `{relative(args.source_root)}`",
        f"- Output root: `{relative(args.output_root)}`",
        f"- Tile duration: `{format_seconds(args.tile_duration)}`",
        f"- Tile bitrate: `{args.tile_bitrate}`",
        f"- Music bitrate: `{args.music_bitrate}`",
        f"- Sample rate: `{args.sample_rate}`",
        f"- Theme version: `{args.theme_version}`",
        f"- Dry run: `{args.dry_run}`",
        "",
        "## Summary",
        "",
    ]
    if results:
        for result in results:
            tile_source_total = sum(item.source_bytes for item in result.tile_audio)
            tile_output_total = sum(item.output_bytes for item in result.tile_audio)
            music_source_total = sum(item.source_bytes for item in result.music)
            music_output_total = sum(item.output_bytes for item in result.music)
            lines.append(
                f"- `{result.theme}`: {len(result.tile_audio)} tile clips "
                f"({format_bytes(tile_source_total)} to {format_bytes(tile_output_total)}), "
                f"{len(result.music)} music tracks "
                f"({format_bytes(music_source_total)} to {format_bytes(music_output_total)})."
            )
    else:
        lines.append("- No themes were transformed successfully.")
    if failures:
        lines.extend(["", "## Failures", ""])
        lines.extend(f"- {failure}" for failure in failures)
    for result in results:
        lines.extend(
            [
                "",
                f"## `{result.theme}`",
                "",
                f"- Source tile audio: `{relative(result.source_tile_dir)}`",
                f"- Source music: `{relative(result.source_music_dir)}`",
                f"- Output directory: `{relative(result.output_dir)}`",
                f"- Pack manifest: `{relative(result.manifest_path)}`",
                f"- Audio manifest: `{relative(result.audio_manifest_path)}`",
                "",
                "### Tile Audio",
                "",
            ]
        )
        if result.tile_audio:
            lines.extend(["| Digit | Source | Output | Source | Output |", "| --- | --- | --- | --- | --- |"])
            for item in result.tile_audio:
                lines.append(
                    f"| {item.digit} | `{relative(item.source_path)}` | `{relative(item.output_path)}` | "
                    f"{format_seconds(item.source_duration)}, {format_bytes(item.source_bytes)} | "
                    f"{format_seconds(item.output_duration)}, {format_bytes(item.output_bytes)} |"
                )
        else:
            lines.append("- Dry run only; no tile audio files were written.")
        lines.extend(["", "### Incidental Music", ""])
        if result.music:
            lines.extend(["| Source | Output | Source | Output |", "| --- | --- | --- | --- |"])
            for item in result.music:
                lines.append(
                    f"| `{relative(item.source_path)}` | `{relative(item.output_path)}` | "
                    f"{format_seconds(item.source_duration)}, {format_bytes(item.source_bytes)} | "
                    f"{format_seconds(item.output_duration)}, {format_bytes(item.output_bytes)} |"
                )
        else:
            lines.append("- No incidental music files were written.")
        if result.warnings:
            lines.extend(["", "### Warnings", ""])
            lines.extend(f"- {warning}" for warning in result.warnings)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def default_report_path(report_dir: Path) -> Path:
    return timestamped_report_path(report_dir, "theme_pack_audio_transform_report")
