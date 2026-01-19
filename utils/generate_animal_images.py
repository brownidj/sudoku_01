from pathlib import Path
import base64
from openai import OpenAI

# ---------------- Configuration ----------------

OUTPUT_DIR = Path("../assets/images/animals_chatGPT")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

MODEL = "gpt-image-1"  # DALL·E image model
IMAGE_SIZE = "1024x1024"

ANIMALS = [
    "ape",
    "buffalo",
    "camel",
    "dolphin",
    "elephant",
    "frog",
    "giraffe",
    "hippo",
    "ibis",
]

BASE_PROMPT = """
Using DALL-E, create a simple, clean line-drawing illustration of a {animal}'s face,
three-quarter-facing to the right and centered.

Use smooth, confident black outlines with minimal detail.
Apply a small amount of flat, muted colour only where appropriate
(e.g. ears, nose, markings), avoiding gradients or shading.

The style should be modern, neutral expression, and icon-like —
suitable for educational materials or UI icons.
Transparent background.

Emphasise clear shapes, symmetry, recognisable features,
anatomically recognisable features, restrained colour palette.

No photorealism.
No shading or gradients.
No complex textures.
No background scenes.
No text or watermark.
No sketchy lines or cross-hatching.
No realism or heavy textures.
""".strip()

# ---------------- Client ----------------

client = OpenAI()

# ---------------- Helpers ----------------

def generate_image(prompt: str, out_path: Path) -> None:
    """Generate one image and save it to disk."""
    result = client.images.generate(
        model=MODEL,
        prompt=prompt,
        size=IMAGE_SIZE,
        background="transparent",
    )

    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)

    out_path.write_bytes(image_bytes)
    print(f"Saved: {out_path.name}")

# ---------------- Main ----------------

def main() -> None:
    for animal in ANIMALS:
        prompt = BASE_PROMPT.format(animal=animal)
        out_file = OUTPUT_DIR / f"{animal}.png"
        generate_image(prompt, out_file)


if __name__ == "__main__":
    main()