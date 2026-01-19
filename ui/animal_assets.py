from __future__ import annotations

from pathlib import Path
from typing import Optional

import tkinter as tk


from pathlib import Path

_ANIMALS_DIR = Path(__file__).resolve().parents[1] / "assets" / "images" / "animals"

ANIMAL_BY_DIGIT: dict[int, str] = {
    1: "ape",
    2: "buffalo",
    3: "camel",
    4: "dolphin",
    5: "elephant",
    6: "frog",
    7: "giraffe",
    8: "hippo",
    9: "ibis",
}

# Cache images so they are not GC'd and to avoid reloading on every redraw.
# Keyed by (digit, target_px).
_CACHE: dict[tuple[int, int], tk.PhotoImage] = {}


def animal_image_for(digit: int, target_px: int) -> Optional[tk.PhotoImage]:
    """
    Return a Tk PhotoImage for the given digit rendered as an animal icon,
    scaled down (integer subsample) so its width is <= target_px.

    Returns None if the file is missing or cannot be loaded.
    """
    name = ANIMAL_BY_DIGIT.get(digit)
    if name is None:
        return None

    key = (digit, int(target_px))
    cached = _CACHE.get(key)
    if cached is not None:
        return cached

    path = _ANIMALS_DIR / (f"{digit}_{name}.png")
    try:
        img = tk.PhotoImage(file=str(path))
    except Exception:
        return None

    # PhotoImage only supports integer subsampling. Subsample so width <= target_px.
    try:
        w = int(img.width())
        if w > 0 and target_px > 0 and w > target_px:
            factor = max(1, int(round(w / float(target_px))))
            if factor > 1:
                img = img.subsample(factor, factor)
    except Exception:
        pass

    _CACHE[key] = img
    return img