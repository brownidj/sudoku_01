import math
import random
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
DURATION_SECONDS = 10.0
SAMPLE_COUNT = int(SAMPLE_RATE * DURATION_SECONDS)

ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = ROOT / "flutter_app" / "assets" / "images" / "butterflies"
AUDIO_DIR = ROOT / "flutter_app" / "assets" / "audio" / "butterflies"
AUDIO_DIR.mkdir(parents=True, exist_ok=True)

N = {
    "C3": 130.81, "D3": 146.83, "E3": 164.81, "F3": 174.61, "G3": 196.00,
    "A3": 220.00, "B3": 246.94,
    "C4": 261.63, "D4": 293.66, "D#4": 311.13, "E4": 329.63, "F4": 349.23,
    "F#4": 369.99, "G4": 392.00, "G#4": 415.30, "A4": 440.00, "A#4": 466.16,
    "B4": 493.88, "C5": 523.25, "D5": 587.33, "E5": 659.25, "F5": 698.46,
    "G5": 783.99, "A5": 880.00,
}


def sine(f: float, t: float) -> float:
    return math.sin(2 * math.pi * f * t)


def saw(f: float, t: float) -> float:
    return 2.0 * ((f * t) % 1.0) - 1.0


def tri(f: float, t: float) -> float:
    return 2.0 * abs(2.0 * ((f * t) % 1.0) - 1.0) - 1.0


def clamp(x: float) -> float:
    return max(-1.0, min(1.0, x))


def note_cursor(phrase, seconds_per_beat):
    phrase_secs = sum(beats * seconds_per_beat for _, beats in phrase)

    def at_time(t: float):
        local = t % phrase_secs
        c = 0.0
        for note, beats in phrase:
            d = beats * seconds_per_beat
            if local < c + d:
                return note, (local - c) / d
            c += d
        return phrase[-1][0], 0.0

    return at_time


def env(progress: float, attack: float, release: float) -> float:
    a = min(1.0, progress / max(attack, 1e-6))
    r = min(1.0, (1.0 - progress) / max(release, 1e-6))
    return min(a, r)


def theme_for(stem: str):
    s = stem.lower()
    if "monarch" in s:
        # Regal, triumphal
        return {
            "tempo": 72.0,
            "phrase": [("C4", 1), ("E4", 1), ("G4", 1), ("C5", 3), ("G4", 1), ("E4", 1), ("C4", 2)],
            "attack": 0.12, "release": 0.28, "vib_rate": 4.0, "vib_cents": 6.0,
            "trem_rate": 1.6, "trem_depth": 0.10, "noise": 0.003, "style": "brass",
        }
    if "swallowtail" in s:
        # Swooping
        return {
            "tempo": 94.0,
            "phrase": [("E4", 0.5), ("A4", 0.5), ("E5", 1), ("D5", 0.5), ("B4", 0.5), ("G4", 1)],
            "attack": 0.08, "release": 0.20, "vib_rate": 5.2, "vib_cents": 10.0,
            "trem_rate": 2.8, "trem_depth": 0.12, "noise": 0.003, "style": "glide",
        }
    if "blue_morpho" in s:
        # Jazzy
        return {
            "tempo": 108.0,
            "phrase": [("C4", 0.75), ("D#4", 0.75), ("F#4", 0.75), ("A4", 0.75), ("G4", 1), ("D#4", 1)],
            "attack": 0.10, "release": 0.24, "vib_rate": 4.6, "vib_cents": 8.0,
            "trem_rate": 2.2, "trem_depth": 0.10, "noise": 0.004, "style": "jazz",
        }
    if "glasswing" in s:
        # Tinkly
        return {
            "tempo": 84.0,
            "phrase": [("G4", 0.5), ("C5", 0.5), ("E5", 0.5), ("G5", 0.5), ("E5", 1), ("C5", 1)],
            "attack": 0.05, "release": 0.16, "vib_rate": 6.0, "vib_cents": 4.0,
            "trem_rate": 3.4, "trem_depth": 0.10, "noise": 0.002, "style": "bell",
        }
    if "peacock" in s:
        # Strutting two-step
        return {
            "tempo": 96.0,
            "phrase": [("C4", 1), ("E4", 1), ("G4", 1), ("E4", 1), ("A4", 1), ("G4", 1), ("E4", 2)],
            "attack": 0.10, "release": 0.26, "vib_rate": 4.3, "vib_cents": 7.0,
            "trem_rate": 2.0, "trem_depth": 0.10, "noise": 0.003, "style": "strut",
        }
    if "zebra" in s:
        # Old MacDonald vibe
        return {
            "tempo": 100.0,
            "phrase": [("G4", 1), ("G4", 1), ("G4", 1), ("D4", 1), ("E4", 1), ("E4", 1), ("D4", 2)],
            "attack": 0.09, "release": 0.22, "vib_rate": 4.2, "vib_cents": 6.0,
            "trem_rate": 1.8, "trem_depth": 0.09, "noise": 0.004, "style": "folk",
        }
    if "sulphur" in s:
        # Sparkly
        return {
            "tempo": 112.0,
            "phrase": [("A4", 0.5), ("C5", 0.5), ("E5", 0.5), ("A5", 0.5), ("E5", 0.5), ("C5", 0.5), ("A4", 1)],
            "attack": 0.05, "release": 0.16, "vib_rate": 6.2, "vib_cents": 5.0,
            "trem_rate": 4.0, "trem_depth": 0.12, "noise": 0.0025, "style": "sparkle",
        }
    if "leaf" in s:
        # Country
        return {
            "tempo": 88.0,
            "phrase": [("G3", 1), ("B3", 1), ("D4", 1), ("G4", 1), ("D4", 1), ("B3", 1), ("G3", 2)],
            "attack": 0.12, "release": 0.30, "vib_rate": 3.8, "vib_cents": 6.0,
            "trem_rate": 1.5, "trem_depth": 0.08, "noise": 0.005, "style": "country",
        }
    # metalmark: slow heavy metal
    return {
        "tempo": 56.0,
        "phrase": [("E3", 1), ("E3", 1), ("G3", 1), ("A3", 1), ("E3", 2), ("D3", 2)],
        "attack": 0.06, "release": 0.18, "vib_rate": 3.0, "vib_cents": 4.0,
        "trem_rate": 1.2, "trem_depth": 0.06, "noise": 0.006, "style": "metal",
    }


def style_voice(style: str, freq: float, t: float) -> float:
    if style == "brass":
        return 0.60 * sine(freq, t) + 0.25 * sine(freq * 2.0, t) + 0.10 * sine(freq * 3.0, t)
    if style == "glide":
        return 0.55 * sine(freq, t) + 0.20 * tri(freq * 0.5, t) + 0.12 * sine(freq * 2.0, t)
    if style == "jazz":
        return 0.45 * tri(freq, t) + 0.20 * sine(freq * 1.5, t) + 0.18 * sine(freq * 2.0, t)
    if style == "bell":
        return 0.40 * sine(freq, t) + 0.24 * sine(freq * 2.0, t) + 0.20 * sine(freq * 3.0, t)
    if style == "strut":
        return 0.52 * sine(freq, t) + 0.20 * saw(freq * 0.5, t) + 0.14 * sine(freq * 2.0, t)
    if style == "folk":
        return 0.50 * sine(freq, t) + 0.18 * tri(freq, t) + 0.10 * sine(freq * 2.0, t)
    if style == "sparkle":
        return 0.42 * sine(freq, t) + 0.20 * sine(freq * 2.0, t) + 0.18 * sine(freq * 4.0, t)
    if style == "country":
        return 0.52 * sine(freq, t) + 0.18 * tri(freq * 0.5, t) + 0.12 * sine(freq * 2.0, t)
    # metal
    return 0.34 * saw(freq * 0.5, t) + 0.28 * tri(freq, t) + 0.20 * sine(freq * 2.0, t)


def render_for(stem: str, seed: int) -> bytes:
    cfg = theme_for(stem)
    rng = random.Random(seed)
    spb = 60.0 / cfg["tempo"]
    at_time = note_cursor(cfg["phrase"], spb)
    out = bytearray()

    for i in range(SAMPLE_COUNT):
        t = i / SAMPLE_RATE
        note, progress = at_time(t)
        f = N[note]
        vib = cfg["vib_cents"] * math.sin(2 * math.pi * cfg["vib_rate"] * t)
        f *= 2 ** (vib / 1200.0)

        e = env(progress, cfg["attack"], cfg["release"])
        trem = (1 - cfg["trem_depth"]) + cfg["trem_depth"] * (0.5 * (1 + math.sin(2 * math.pi * cfg["trem_rate"] * t)))

        voice = style_voice(cfg["style"], f, t)
        noise = (rng.random() * 2 - 1) * cfg["noise"]

        sample = (voice + noise) * e * trem * 0.72
        out.extend(struct.pack("<h", int(clamp(sample) * 32767)))
    return bytes(out)


def main():
    pngs = sorted(p for p in IMAGES_DIR.iterdir() if p.suffix.lower() == ".png")
    if len(pngs) != 9:
        print(f"Warning: expected 9 butterfly PNGs, found {len(pngs)}")

    for idx, png in enumerate(pngs, start=1):
        wav_path = AUDIO_DIR / f"{png.stem}.wav"
        audio = render_for(png.stem, 1000 + idx)
        with wave.open(str(wav_path), "w") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(SAMPLE_RATE)
            wf.writeframes(audio)
        print(f"Wrote {wav_path}")


if __name__ == "__main__":
    main()
