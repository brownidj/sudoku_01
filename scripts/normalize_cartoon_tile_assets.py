#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path
from statistics import median

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ANIMALS_DIR = ROOT / "flutter_app" / "assets" / "images" / "animals"

DIGIT_TO_NAME = {
    1: "ape",
    2: "buffalo",
    3: "cheetah",
    4: "dolphin",
    5: "elephant",
    6: "frog",
    7: "giraffe",
    8: "hippo",
    9: "iguana",
}


def alpha_coverage(image: Image.Image) -> float:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    hist = alpha.histogram()
    non_zero = sum(hist[1:])
    width, height = rgba.size
    return non_zero / float(width * height)


def main() -> None:
    inputs: dict[int, Image.Image] = {}
    coverages: dict[int, float] = {}

    for digit, name in DIGIT_TO_NAME.items():
        source_path = ANIMALS_DIR / f"{digit}_cartoon_{name}.png"
        image = Image.open(source_path).convert("RGBA")
        inputs[digit] = image
        coverages[digit] = alpha_coverage(image)

    target_coverage = median(coverages.values())
    print(f"Target alpha coverage (median): {target_coverage:.4f}")

    for digit, name in DIGIT_TO_NAME.items():
        source = inputs[digit]
        current_coverage = coverages[digit]
        if current_coverage <= 0:
            scale = 1.0
        else:
            scale = math.sqrt(target_coverage / current_coverage)

        width, height = source.size
        scaled_width = max(1, round(width * scale))
        scaled_height = max(1, round(height * scale))
        scaled = source.resize((scaled_width, scaled_height), Image.Resampling.LANCZOS)

        canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        left = (width - scaled_width) // 2
        top = (height - scaled_height) // 2
        canvas.alpha_composite(scaled, (left, top))

        out_path = ANIMALS_DIR / f"{digit}_cartoon_{name}_s.png"
        canvas.save(out_path)
        print(
            f"{digit}_cartoon_{name}_s.png: "
            f"scale={scale:.4f}, "
            f"coverage {current_coverage:.4f} -> {alpha_coverage(canvas):.4f}"
        )


if __name__ == "__main__":
    main()
