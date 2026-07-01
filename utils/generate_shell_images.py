from pathlib import Path
import argparse
import base64
from typing import Literal

from openai import OpenAI


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
OUTPUT_DIR = REPO_ROOT / "flutter_app/assets/images/shells"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

MODEL = "gpt-image-1"
IMAGE_SIZE: Literal[
    "auto",
    "1024x1024",
    "1536x1024",
    "1024x1536",
    "256x256",
    "512x512",
    "1792x1024",
    "1024x1792",
] = "1024x1024"


SHELLS = [
    (1, "cowrie", "Cowrie shell"),
    (2, "scallop", "Scallop shell"),
    (3, "murex", "Murex shell"),
    (4, "nautilus", "Nautilus shell"),
    (5, "cone", "Cone shell"),
    (6, "abalone", "Abalone shell"),
    (7, "turban", "Turban shell"),
    (8, "moon_snail", "Moon snail shell"),
    (9, "cockle", "Cockle shell"),
]


SHELL_DETAILS = {
    "cowrie": (
        "Compact oval, glossy, patterned, fills tile well. "
        "Tile color identity: warm golden yellow."
    ),
    "scallop": (
        "Broad fan shape, instantly recognisable. "
        "Tile color identity: coral pink."
    ),
    "murex": (
        "Spiky, ornate marine shell with strong silhouette. "
        "Tile color identity: blue and purple."
    ),
    "nautilus": (
        "Near-perfect circular spiral in a clear side-on profile view (not top-down). "
        "Tile color identity: brown and white with ivory undertones; avoid dominant orange cast. "
        "Emphasize crisp chamber banding, fine texture, and high natural detail."
    ),
    "cone": (
        "Strong geometric cone shape with bold patterns. "
        "Tile color identity: lavender."
    ),
    "abalone": (
        "Broad, colourful, iridescent oval. "
        "Tile color identity: blue-green iridescent."
    ),
    "turban": (
        "Rounded, chunky spiral with good square coverage. "
        "Tile color identity: seafoam green."
    ),
    "moon_snail": (
        "Smooth, round, compact spiral with strong tile fill. "
        "Tile color identity: powder blue."
    ),
    "cockle": (
        "Rounded heart-like shell with strong ribs; compact silhouette. "
        "Tile color identity: rose / raspberry pink."
    ),
}


PROMPT_TEMPLATE = """
Create a single photorealistic {shell_label}, isolated and centered.

Requirements:
- Transparent background (PNG with alpha), no shadow on a surface.
- Studio-quality realism with natural material texture and true-to-life color.
- The shell should appear complete, clean-edged, and fully inside frame.
- Composition should maximize tile usability: large subject coverage and clear silhouette.
- Orientation and framing should favor recognizability and compact icon usage.
- Key morphology and target color identity: {details}
- Keep colors moderately distinguishable between shells, but natural and not over-saturated.

Output constraints:
- One shell only.
- No text, watermark, border, frame, props, hands, sand, rocks, or scenery.
- No cartoon, illustration, painting, CGI look, or stylization.
""".strip()


client = OpenAI()


def generate_image(prompt: str, out_path: Path) -> None:
    result = client.images.generate(
        model=MODEL,
        prompt=prompt,
        size=IMAGE_SIZE,
        background="transparent",
    )
    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)
    out_path.write_bytes(image_bytes)
    print(f"Saved: {out_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate photorealistic shell PNGs with transparent background",
    )
    parser.add_argument(
        "--test",
        action="store_true",
        help="Generate only first 2 shells",
    )
    parser.add_argument(
        "--number",
        type=int,
        choices=range(1, 10),
        metavar="[1-9]",
        help="Generate exactly one shell by number (1..9)",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Regenerate images even if files already exist",
    )
    parser.add_argument(
        "--copy",
        action="store_true",
        help=(
            "Save as a numbered copy by appending a sequential suffix to the shell "
            "name (example: 4_nautilus_2.png, 4_nautilus_3.png)"
        ),
    )
    return parser.parse_args()


def resolve_output_path(
    output_dir: Path,
    idx: int,
    slug: str,
    copy_mode: bool,
) -> Path:
    base = output_dir / f"{idx}_{slug}.png"
    if not copy_mode:
        return base

    # Copy mode: preserve the original and create an incremented variant.
    copy_index = 2
    while True:
        candidate = output_dir / f"{idx}_{slug}_{copy_index}.png"
        if not candidate.exists():
            return candidate
        copy_index += 1


def main(
    test_run: bool = False,
    overwrite: bool = False,
    number: int | None = None,
    copy_mode: bool = False,
) -> None:
    if number is not None:
        shells = [entry for entry in SHELLS if entry[0] == number]
    else:
        shells = SHELLS[:2] if test_run else SHELLS

    for idx, slug, label in shells:
        out_file = resolve_output_path(OUTPUT_DIR, idx, slug, copy_mode)
        if out_file.exists() and not overwrite:
            print(f"Skipping (already exists): {out_file}")
            continue

        prompt = PROMPT_TEMPLATE.format(
            shell_label=label,
            details=SHELL_DETAILS[slug],
        )
        generate_image(prompt=prompt, out_path=out_file)


if __name__ == "__main__":
    args = parse_args()
    main(
        test_run=args.test,
        overwrite=args.overwrite,
        number=args.number,
        copy_mode=args.copy,
    )
