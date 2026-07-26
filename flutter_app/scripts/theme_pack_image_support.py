from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from theme_pack_common import (
    DEFAULT_OUTPUT_ROOT,
    DEFAULT_REPORT_DIR,
    REPO_ROOT,
    format_bytes,
    relative,
    timestamped_report_path,
    utc_now_iso,
)

try:
    from PIL import Image, ImageOps
except ImportError as exc:  # pragma: no cover - exercised by user environment.
    raise SystemExit("Pillow is required. Install it with: python3 -m pip install Pillow") from exc


DEFAULT_SOURCE_ROOT = REPO_ROOT / "flutter_app" / "assets" / "images"
SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}

KNOWN_THEME_FILES = {
    "butterflies": [
        "1_monarch.png",
        "2_swallowtail.png",
        "3_blue_morpho.png",
        "4_glasswing.png",
        "5_peacock.png",
        "6_zebra_longwing.png",
        "7_sulphur.png",
        "8_leaf.png",
        "9_metalmark.png",
    ],
    "shells": [
        "1_cowrie.png",
        "2_scallop.png",
        "3_murex.png",
        "4_nautilus.png",
        "5_cone.png",
        "6_abalone.png",
        "7_turban.png",
        "8_moon_snail.png",
        "9_cockle.png",
    ],
    "old_opera": [
        "bass.png",
        "baritone.png",
        "tenor.png",
        "mezzo_soprano.png",
        "soprano.png",
        "royal_court_singer.png",
        "modern_opera.png",
        "masked_phantom_style.png",
        "opera_diva_comic.png",
    ],
}


@dataclass
class TileResult:
    digit: int
    tile_id: str
    label: str
    source_path: Path
    output_path: Path
    source_size: tuple[int, int]
    output_size: tuple[int, int]
    source_bytes: int
    output_bytes: int
    source_sha256: str
    output_sha256: str
    had_alpha: bool
    kept_alpha: bool


@dataclass
class ThemeResult:
    theme: str
    source_dir: Path
    output_dir: Path
    manifest_path: Path
    preview_path: Path
    tiles: list[TileResult]
    duplicate_source_groups: list[list[TileResult]]
    warnings: list[str]


def discover_theme_files(theme: str, source_dir: Path) -> list[Path]:
    known = KNOWN_THEME_FILES.get(theme)
    if known is not None:
        return [source_dir / name for name in known]
    candidates = [
        path
        for path in source_dir.iterdir()
        if path.is_file()
        and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
        and re.match(r"^[1-9][_\-]", path.name)
    ]
    return sorted(candidates, key=lambda path: int(path.name[0]))[:9]


def require_exactly_nine_tiles(theme: str, paths: list[Path]) -> None:
    if len(paths) != 9:
        raise ValueError(f"{theme}: expected 9 tile source images, found {len(paths)}")
    missing = [path for path in paths if not path.exists()]
    if missing:
        formatted = "\n".join(f"  - {path}" for path in missing)
        raise FileNotFoundError(f"{theme}: missing source image(s):\n{formatted}")


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def has_meaningful_alpha(image: Image.Image) -> bool:
    if image.mode not in ("RGBA", "LA") and "transparency" not in image.info:
        return False
    extrema = image.convert("RGBA").getchannel("A").getextrema()
    return extrema[0] < 255


def prepare_square_image(source: Image.Image, *, size: int, preserve_alpha: bool) -> Image.Image:
    image = ImageOps.exif_transpose(source)
    if preserve_alpha:
        image = image.convert("RGBA")
        background = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        image = image.convert("RGB")
        background = Image.new("RGB", (size, size), (255, 255, 255))
    image.thumbnail((size, size), Image.Resampling.LANCZOS)
    left = (size - image.width) // 2
    top = (size - image.height) // 2
    background.paste(image, (left, top), image if preserve_alpha else None)
    return background


def save_webp(image: Image.Image, path: Path, *, quality: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "WEBP", quality=quality, method=6)


def tile_id_from_source(path: Path, fallback_digit: int) -> str:
    stem = re.sub(r"^[1-9][_\-]?", "", path.stem.lower())
    stem = re.sub(r"[^a-z0-9]+", "_", stem).strip("_")
    return stem or f"tile_{fallback_digit:02d}"


def label_from_tile_id(tile_id: str) -> str:
    if tile_id == "old_opera":
        return "Opera"
    return " ".join(part.capitalize() for part in tile_id.split("_") if part)


def build_preview(tile_paths: Iterable[Path], preview_path: Path, *, preview_size: int, quality: int) -> None:
    preview = Image.new("RGB", (preview_size, preview_size), (255, 255, 255))
    gutter = max(8, preview_size // 48)
    cell = (preview_size - gutter * 4) // 3
    for index, tile_path in enumerate(tile_paths):
        image = Image.open(tile_path).convert("RGBA")
        image.thumbnail((cell, cell), Image.Resampling.LANCZOS)
        row = index // 3
        col = index % 3
        left = gutter + col * (cell + gutter) + (cell - image.width) // 2
        top = gutter + row * (cell + gutter) + (cell - image.height) // 2
        preview.paste(image, (left, top), image)
    save_webp(preview, preview_path, quality=quality)


def generate_manifest(*, theme: str, display_name: str, theme_version: int, schema_version: int, minimum_app_build: int, tiles: list[TileResult]) -> dict:
    return {
        "schema_version": schema_version,
        "theme_id": theme,
        "theme_version": theme_version,
        "display_name": display_name,
        "tile_count": 9,
        "tiles": [
            {"id": tile.tile_id, "path": f"tiles/tile_{tile.digit:02d}.webp", "accessibility_label": tile.label}
            for tile in tiles
        ],
        "preview_path": "preview.webp",
        "minimum_app_build": minimum_app_build,
    }


def duplicate_groups(tiles: list[TileResult]) -> list[list[TileResult]]:
    by_hash: dict[str, list[TileResult]] = {}
    for tile in tiles:
        by_hash.setdefault(tile.source_sha256, []).append(tile)
    return [group for group in by_hash.values() if len(group) > 1]


def write_report(*, report_path: Path, results: list[ThemeResult], args, failures: list[str]) -> None:
    lines: list[str] = [
        "# Theme Pack Image Transformation Report",
        "",
        f"Generated at: `{utc_now_iso()}`",
        "",
        "## Inputs",
        "",
        f"- Themes: `{', '.join(args.themes)}`",
        f"- Source root: `{relative(args.source_root)}`",
        f"- Output root: `{relative(args.output_root)}`",
        f"- Tile size: `{args.tile_size}px`",
        f"- Preview size: `{args.preview_size}px`",
        f"- WebP quality: `{args.quality}`",
        f"- Theme version: `{args.theme_version}`",
        f"- Schema version: `{args.schema_version}`",
        f"- Minimum app build: `{args.minimum_app_build}`",
        "",
        "## Summary",
        "",
    ]
    if results:
        for result in results:
            source_total = sum(tile.source_bytes for tile in result.tiles)
            output_total = sum(tile.output_bytes for tile in result.tiles)
            preview_bytes = result.preview_path.stat().st_size
            lines.append(
                f"- `{result.theme}`: transformed {len(result.tiles)} tiles "
                f"from {format_bytes(source_total)} to {format_bytes(output_total)}; "
                f"preview {format_bytes(preview_bytes)}."
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
                f"- Source directory: `{relative(result.source_dir)}`",
                f"- Output directory: `{relative(result.output_dir)}`",
                f"- Manifest: `{relative(result.manifest_path)}`",
                f"- Preview: `{relative(result.preview_path)}`",
                "",
                "| Digit | Source | Output | Source size | Output size | Alpha |",
                "| --- | --- | --- | --- | --- | --- |",
            ]
        )
        for tile in result.tiles:
            alpha = "kept" if tile.kept_alpha else ("removed" if tile.had_alpha else "none")
            lines.append(
                f"| {tile.digit} | `{relative(tile.source_path)}` | `{relative(tile.output_path)}` | "
                f"{tile.source_size[0]}x{tile.source_size[1]}, {format_bytes(tile.source_bytes)} | "
                f"{tile.output_size[0]}x{tile.output_size[1]}, {format_bytes(tile.output_bytes)} | {alpha} |"
            )
        lines.extend(["", "### Manifest Tile Entries", "", "```json"])
        manifest = json.loads(result.manifest_path.read_text(encoding="utf-8"))
        lines.append(json.dumps(manifest["tiles"], indent=2))
        lines.append("```")
        if result.duplicate_source_groups:
            lines.extend(["", "### Duplicate Source Images", ""])
            for group in result.duplicate_source_groups:
                lines.append("- " + ", ".join(f"`{tile.source_path.name}` (tile {tile.digit})" for tile in group))
        if result.warnings:
            lines.extend(["", "### Warnings", ""])
            lines.extend(f"- {warning}" for warning in result.warnings)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def default_report_path(report_dir: Path) -> Path:
    return timestamped_report_path(report_dir, "theme_pack_image_transform_report")
