

"""fix_animal_images.py

Trim excess whitespace around cartoon animal images while keeping the output square.

Behaviour:
- For each PNG in the input directory, find the tight bounding box of the subject.
- Crop to that box (optionally with padding).
- Pad to a square canvas.
- Resize back to the original image dimensions (so all assets stay uniform, e.g. 512x512).

This is designed for assets like: assets/images/animals/1_ape.png, ..., 9_ibis.png

Requires: pillow
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Optional, Tuple


from PIL import Image


# --- Project root helpers for robust path handling ---
from pathlib import Path

def _project_root() -> Path:
    # This script lives in the repo (often in utils/). Project root is its parent (or grandparent).
    # We treat the directory containing this file as an anchor, then step up one.
    here = Path(__file__).resolve()
    # If the file is in a subfolder (e.g. utils, scripts, tools), parent of that is the project root.
    return here.parent.parent if here.parent.name in ("utils", "scripts", "tools") else here.parent


def _resolve_against_root(p: str, root: Path) -> Path:
    path = Path(p)
    if path.is_absolute():
        return path
    return (root / path).resolve()


def _nontransparent_bbox(img: Image.Image, alpha_threshold: int) -> Optional[Tuple[int, int, int, int]]:
    """Return bbox of pixels with alpha > threshold, or None if fully transparent."""
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    alpha = img.getchannel("A")
    # Convert to a binary mask; bbox() returns None if empty.
    mask = alpha.point(lambda a: 255 if a > alpha_threshold else 0)
    return mask.getbbox()


def _nonwhite_bbox(img: Image.Image, white_threshold: int) -> Optional[Tuple[int, int, int, int]]:
    """Fallback: return bbox of pixels that are not near-white."""
    if img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGBA")

    # Use RGB channels; treat pixels as background if all channels >= threshold.
    rgb = img.convert("RGB")

    def is_fg(px: Tuple[int, int, int]) -> int:
        r, g, b = px
        return 255 if (r < white_threshold or g < white_threshold or b < white_threshold) else 0

    mask = Image.new("L", rgb.size, 0)
    mask.putdata([is_fg(px) for px in list(rgb.getdata())])
    return mask.getbbox()


def _expand_bbox(bbox: Tuple[int, int, int, int], pad: int, w: int, h: int) -> Tuple[int, int, int, int]:
    l, t, r, b = bbox
    l2 = max(0, l - pad)
    t2 = max(0, t - pad)
    r2 = min(w, r + pad)
    b2 = min(h, b + pad)
    return l2, t2, r2, b2


def _square_pad(img: Image.Image, bg_rgba: Tuple[int, int, int, int]) -> Image.Image:
    w, h = img.size
    side = max(w, h)
    out = Image.new("RGBA", (side, side), bg_rgba)
    x = (side - w) // 2
    y = (side - h) // 2
    out.paste(img, (x, y), img if img.mode == "RGBA" else None)
    return out


def process_one(
    in_path: Path,
    out_path: Path,
    pad: int,
    alpha_threshold: int,
    white_threshold: int,
    bg_rgba: Tuple[int, int, int, int],
    keep_size: bool,
) -> bool:
    img = Image.open(str(in_path))

    orig_size = img.size

    bbox = None
    try:
        bbox = _nontransparent_bbox(img, alpha_threshold)
    except Exception:
        bbox = None

    if bbox is None:
        bbox = _nonwhite_bbox(img, white_threshold)

    # If still None, copy through unchanged.
    if bbox is None:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        img.save(str(out_path))
        return False

    bbox = _expand_bbox(bbox, pad, orig_size[0], orig_size[1])

    cropped = img.crop(bbox)
    if cropped.mode != "RGBA":
        cropped = cropped.convert("RGBA")

    squared = _square_pad(cropped, bg_rgba)

    if keep_size:
        # Keep original dimensions (typically square). If original isn't square,
        # we still resize to original to preserve your current asset sizing.
        squared = squared.resize(orig_size, Image.Resampling.LANCZOS)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    squared.save(str(out_path))
    return True


def main() -> None:
    parser = argparse.ArgumentParser(description="Trim whitespace around animal PNGs while keeping output square.")
    parser.add_argument(
        "--in-dir",
        default="assets/images/animals",
        help="Input directory containing animal PNGs.",
    )
    parser.add_argument(
        "--out-dir",
        default="assets/images/animals",
        help="Output directory for processed PNGs (ignored if --in-place).",
    )
    parser.add_argument(
        "--in-place",
        action="store_true",
        help="Overwrite files in --in-dir instead of writing to --out-dir.",
    )
    parser.add_argument(
        "--pad",
        type=int,
        default=0,
        help="Padding (pixels) to retain around the subject after trimming.",
    )
    parser.add_argument(
        "--alpha-threshold",
        type=int,
        default=0,
        help="Alpha threshold for foreground detection (0 keeps any non-zero alpha).",
    )
    parser.add_argument(
        "--white-threshold",
        type=int,
        default=250,
        help="Fallback: treat pixels as background if RGB all >= this value.",
    )
    parser.add_argument(
        "--keep-size",
        action="store_true",
        help="Resize output back to the original image dimensions.",
    )

    args = parser.parse_args()

    root = _project_root()

    in_dir = _resolve_against_root(args.in_dir, root)
    if not in_dir.exists():
        raise SystemExit(
            "Input directory does not exist: "
            + str(in_dir)
            + " (cwd="
            + str(Path.cwd())
            + ", project_root="
            + str(root)
            + ")"
        )

    out_dir = in_dir if args.in_place else _resolve_against_root(args.out_dir, root)

    bg_rgba = (0, 0, 0, 0)  # transparent

    pngs = sorted([p for p in in_dir.iterdir() if p.is_file() and p.suffix.lower() == ".png"])
    if not pngs:
        raise SystemExit("No PNG files found in: " + str(in_dir))

    changed = 0
    total = 0

    for p in pngs:
        total += 1
        out_path = p if args.in_place else (out_dir / p.name)
        did_change = process_one(
            in_path=p,
            out_path=out_path,
            pad=int(args.pad),
            alpha_threshold=int(args.alpha_threshold),
            white_threshold=int(args.white_threshold),
            bg_rgba=bg_rgba,
            keep_size=bool(args.keep_size),
        )
        if did_change:
            changed += 1

    print("Processed " + str(total) + " PNG(s). Changed=" + str(changed) + ". Output=" + str(out_dir))


if __name__ == "__main__":
    main()