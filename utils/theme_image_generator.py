from pathlib import Path
import argparse
import base64
import re
from typing import Literal

from openai import OpenAI


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
IMAGES_ROOT = REPO_ROOT / "flutter_app/assets/images"
DEFAULT_PROMPT_FILE = SCRIPT_DIR / "code_prompt.txt"

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

BACKGROUND: Literal["transparent", "opaque", "auto"] = "transparent"

client = OpenAI()


def sanitize_slug(value: str, max_len: int = 28) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")
    if not slug:
        slug = "item"
    return slug[:max_len].rstrip("_")


def shorten_button_name(value: str) -> str:
    words = re.findall(r"[a-z0-9]+", value.lower())
    if not words:
        return "item"
    short_words = words[:2]
    short = "_".join(short_words)
    return short[:24].rstrip("_")


def parse_code_prompt(prompt_file: Path) -> tuple[str, list[str], str]:
    text = prompt_file.read_text(encoding="utf-8")
    lines = text.splitlines()

    theme = ""
    buttons: list[str] = []
    prompt_lines: list[str] = []
    section = ""

    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            if section == "prompt":
                prompt_lines.append("")
            continue
        if line.startswith("#"):
            continue

        lower = line.lower()
        if lower.startswith("theme:"):
            theme = line.split(":", 1)[1].strip()
            section = ""
            continue
        if lower == "images:":
            section = "images"
            continue
        if lower == "prompt:":
            section = "prompt"
            continue

        if section == "images":
            image_name = re.sub(r"^\d+\.\s*", "", line)
            buttons.append(image_name)
            continue
        if section == "prompt":
            prompt_lines.append(raw_line.rstrip())

    if not theme:
        raise ValueError("Missing `theme:` in code_prompt.txt")
    if len(buttons) != 9:
        raise ValueError(
            f"`images:` in {prompt_file.name} must contain exactly 9 entries. "
            f"Found {len(buttons)}."
        )

    prompt_template = "\n".join(prompt_lines).strip()
    if "{subject}" not in prompt_template:
        raise ValueError("Prompt template must include `{subject}` placeholder.")

    return theme, buttons, prompt_template


def build_prompt(prompt_template: str, index: int, label: str) -> str:
    return prompt_template.format(
        index=index,
        slug=shorten_button_name(label),
        label=label,
        subject=label,
    )


def generate_image(prompt: str, out_path: Path) -> None:
    result = client.images.generate(
        model=MODEL,
        prompt=prompt,
        size=IMAGE_SIZE,
        background=BACKGROUND,
    )
    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)
    out_path.write_bytes(image_bytes)
    print(f"Saved: {out_path}")


def resolve_output_path(
    output_dir: Path,
    idx: int,
    short_name: str,
    copy_mode: bool,
) -> Path:
    base = output_dir / f"{idx}_{short_name}.png"
    if not copy_mode:
        return base

    copy_index = 2
    while True:
        candidate = output_dir / f"{idx}_{short_name}_{copy_index}.png"
        if not candidate.exists():
            return candidate
        copy_index += 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate theme images using theme/buttons/prompt from code_prompt.txt."
        ),
    )
    parser.add_argument(
        "--prompt",
        "--prompt-file",
        dest="prompt_file",
        type=Path,
        default=DEFAULT_PROMPT_FILE,
        help=(
            "Path to <theme>_code_prompt.txt. Supports {subject}, {label}, "
            "{slug}, and {index} placeholders."
        ),
    )
    parser.add_argument(
        "--test",
        action="store_true",
        help="Generate only the first 2 items from the item list.",
    )
    parser.add_argument(
        "--number",
        type=int,
        help="Generate exactly one item by index value from the items file.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Regenerate image even if file already exists.",
    )
    parser.add_argument(
        "--copy",
        action="store_true",
        help=(
            "Save as numbered copy, preserving original output "
            "(example: 4_slug_2.png)."
        ),
    )
    return parser.parse_args()


def main(
    prompt_file: Path,
    test_run: bool = False,
    overwrite: bool = False,
    number: int | None = None,
    copy_mode: bool = False,
) -> None:
    theme_name, buttons, prompt_template = parse_code_prompt(prompt_file=prompt_file)
    theme_slug = sanitize_slug(theme_name)
    output_dir = IMAGES_ROOT / theme_slug
    output_dir.mkdir(parents=True, exist_ok=True)

    items = [(idx, label) for idx, label in enumerate(buttons, start=1)]
    if number is not None:
        selected_items = [entry for entry in items if entry[0] == number]
    else:
        selected_items = items[:2] if test_run else items

    if not selected_items:
        raise ValueError("No items matched the requested selection.")

    total = len(selected_items)
    for progress_index, (idx, label) in enumerate(selected_items, start=1):
        short_name = shorten_button_name(label)
        out_file = resolve_output_path(output_dir, idx, short_name, copy_mode)
        if out_file.exists() and not overwrite:
            print(f"[{progress_index}/{total}] Skipping (already exists): {out_file}")
            continue

        prompt = build_prompt(
            prompt_template=prompt_template,
            index=idx,
            label=label,
        )
        generate_image(prompt=prompt, out_path=out_file)
        print(f"[{progress_index}/{total}] Generated {idx}_{short_name}.png")


if __name__ == "__main__":
    args = parse_args()
    main(
        prompt_file=args.prompt_file,
        test_run=args.test,
        overwrite=args.overwrite,
        number=args.number,
        copy_mode=args.copy,
    )
