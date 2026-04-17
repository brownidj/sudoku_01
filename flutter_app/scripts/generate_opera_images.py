#!/usr/bin/env python3
"""Generate opera singer tile images via OpenAI Images API.

Requirements:
- OPENAI_API_KEY set in environment
- Python 3.9+

Usage:
  python3 scripts/generate_opera_images.py
  python3 scripts/generate_opera_images.py --output-dir assets/images/opera --model gpt-image-1
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API_URL = "https://api.openai.com/v1/images/generations"

GLOBAL_CONSTRAINTS = (
    "Create one single subject only, centered, fully visible, not cropped. "
    "Composition: chest-up portrait only (head, shoulders, upper torso), no full body. "
    "Keep silhouette compact and square-friendly with no long limbs extending outward. "
    "Style: clean polished semi-realistic 3D illustration, bright high-contrast colours, "
    "crisp edges, smooth shading, subtle highlights, moderate detail for small mobile game tiles. "
    "No text, no watermark, no logo, no border, no frame, no shadow. "
    "Frontal three-quarter view. "
    "Subject should fill about 80-90% of the canvas with minimal empty margin. "
    "Transparent background only (alpha), no shadows outside object."
)

IMAGE_SPECS = [
    (
        "soprano.png",
        "Elegant soprano singer, chest-up portrait only (head, shoulders, upper torso), mid high note, compact square composition, palette gold and ivory.",
    ),
    (
        "mezzo_soprano.png",
        "Dramatic female opera singer with richer costume tones, warm lyrical expression, palette burgundy and plum.",
    ),
    (
        "tenor.png",
        "Male opera singer in formal tuxedo with expressive heroic gesture, palette cobalt blue, crimson, and gold accents.",
    ),
    (
        "baritone.png",
        "Distinguished male opera singer with cape or period attire, deep resonant expression, palette navy and charcoal.",
    ),
    (
        "bass.png",
        "Elderly male opera singer with grand presence and commanding posture, palette dark green and black.",
    ),
    (
        "opera_diva_comic.png",
        "Comic opera diva in exaggerated dramatic pose holding a fan, vibrant theatrical expression, palette red and gold.",
    ),
    (
        "masked_phantom_style.png",
        "Mysterious opera singer with half-mask and cape, dramatic operatic pose, palette deep purple, emerald, and silver accents.",
    ),
    (
        "royal_court_singer.png",
        "Royal court singer in baroque-inspired costume and wig, regal aria posture, palette royal blue and gold.",
    ),
    (
        "modern_opera_performer.png",
        "Modern opera performer in contemporary concert dress, clean sustained-note posture, palette teal and black.",
    ),
]

SAFE_RETRY_SUFFIX = (
    "All-ages educational game art. Fully clothed character only. "
    "No nudity, no sexual content, no violence, no weapons, no gore, no horror."
)


def build_prompt(subject_prompt: str) -> str:
    return f"{subject_prompt} {GLOBAL_CONSTRAINTS}"


def build_safe_retry_prompt(prompt: str) -> str:
    softened = prompt.replace("female", "adult").replace("male", "adult")
    return f"{softened} {SAFE_RETRY_SUFFIX}"


def build_ssl_context(ca_bundle: str | None) -> ssl.SSLContext:
    if ca_bundle:
        return ssl.create_default_context(cafile=ca_bundle)

    try:
        import certifi

        return ssl.create_default_context(cafile=certifi.where())
    except Exception:
        return ssl.create_default_context()


def generate_png(
    api_key: str,
    model: str,
    prompt: str,
    size: str,
    timeout_sec: int,
    ssl_context: ssl.SSLContext,
) -> bytes:
    payload = {
        "model": model,
        "prompt": prompt,
        "size": size,
        "output_format": "png",
        "background": "transparent",
    }

    req = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout_sec, context=ssl_context) as resp:
            raw = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {e.code}: {body}") from e
    except urllib.error.URLError as e:
        if isinstance(getattr(e, "reason", None), ssl.SSLCertVerificationError):
            raise RuntimeError(
                "TLS certificate verification failed. Provide a CA bundle with "
                "--ca-bundle /path/to/cacert.pem or install certifi."
            ) from e
        raise RuntimeError(f"Network error: {e}") from e

    parsed = json.loads(raw)
    data = parsed.get("data") or []
    if not data:
        raise RuntimeError(f"Unexpected API response: {parsed}")

    b64 = data[0].get("b64_json")
    if not b64:
        raise RuntimeError(f"Missing b64_json in API response: {parsed}")

    return base64.b64decode(b64)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate opera PNG icons with OpenAI image API")
    parser.add_argument("--output-dir", default="assets/images/opera", help="Output directory")
    parser.add_argument("--model", default="gpt-image-1", help="Image model")
    parser.add_argument("--api-key", default=os.getenv("OPENAI_API_KEY"), help="OpenAI API key (defaults to OPENAI_API_KEY)")
    parser.add_argument(
        "--ca-bundle",
        default=os.getenv("SSL_CERT_FILE"),
        help="Path to CA bundle PEM file (defaults to SSL_CERT_FILE, then certifi if installed)",
    )
    parser.add_argument("--size", default="1024x1024", help="Image size")
    parser.add_argument("--timeout", type=int, default=180, help="HTTP timeout in seconds")
    parser.add_argument("--sleep", type=float, default=0.5, help="Delay between requests")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing files")
    parser.add_argument(
        "--stop-on-error",
        action="store_true",
        help="Stop immediately on first generation error (default is continue)",
    )
    args = parser.parse_args()

    api_key = args.api_key
    if not api_key:
        print("Error: Missing API key. Set OPENAI_API_KEY or pass --api-key.", file=sys.stderr)
        return 1

    ssl_context = build_ssl_context(args.ca_bundle)
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    for filename, subject in IMAGE_SPECS:
        out_path = out_dir / filename
        if out_path.exists() and not args.overwrite:
            print(f"skip {filename} (exists, use --overwrite)")
            continue

        prompt = build_prompt(subject)
        print(f"generating {filename}...")
        try:
            png_bytes = generate_png(
                api_key=api_key,
                model=args.model,
                prompt=prompt,
                size=args.size,
                timeout_sec=args.timeout,
                ssl_context=ssl_context,
            )
        except RuntimeError as e:
            message = str(e)
            if "moderation_blocked" in message:
                print(f"moderation blocked for {filename}; retrying with safer prompt...")
                safe_prompt = build_safe_retry_prompt(prompt)
                try:
                    png_bytes = generate_png(
                        api_key=api_key,
                        model=args.model,
                        prompt=safe_prompt,
                        size=args.size,
                        timeout_sec=args.timeout,
                        ssl_context=ssl_context,
                    )
                except RuntimeError as retry_error:
                    print(f"error {filename}: {retry_error}", file=sys.stderr)
                    if args.stop_on_error:
                        return 1
                    continue
            else:
                print(f"error {filename}: {e}", file=sys.stderr)
                if args.stop_on_error:
                    return 1
                continue

        out_path.write_bytes(png_bytes)
        print(f"saved {out_path}")
        time.sleep(args.sleep)

    print("done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
