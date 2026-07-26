from __future__ import annotations

import json
import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from theme_pack_common import DEFAULT_OUTPUT_ROOT, DEFAULT_REPORT_DIR, REPO_ROOT, source_folder_for_theme


DEFAULT_SOURCE_ROOT = REPO_ROOT / "flutter_app" / "assets" / "audio"

SUPPORTED_INPUT_EXTENSIONS = {".aac", ".aif", ".aiff", ".flac", ".m4a", ".mp3", ".ogg", ".opus", ".wav"}

KNOWN_TILE_AUDIO_FILES = {
    "butterflies": [
        "1_monarch.wav",
        "2_swallowtail.wav",
        "3_blue_morpho.wav",
        "4_glasswing.wav",
        "5_peacock.wav",
        "6_zebra_longwing.wav",
        "7_sulphur.wav",
        "8_leaf.wav",
        "9_metalmark.wav",
    ],
    "shells": [
        "1_cowrie.mp3",
        "2_scallop.mp3",
        "3_murex.mp3",
        "4_nautilus.mp3",
        "5_cone.mp3",
        "6_abalone.mp3",
        "7_turban.mp3",
        "8_moon_snail.mp3",
        "9_cockle.mp3",
    ],
    "old_opera": [
        "bass.mp3",
        "baritone.mp3",
        "tenor.mp3",
        "mezzo_soprano.mp3",
        "soprano.mp3",
        "royal_court_singer.mp3",
        "modern_opera.mp3",
        "masked_phantom_style.mp3",
        "opera_diva_comic.mp3",
    ],
}


@dataclass
class AudioFileResult:
    source_path: Path
    output_path: Path
    source_bytes: int
    output_bytes: int
    source_duration: float
    output_duration: float


@dataclass
class TileAudioResult(AudioFileResult):
    digit: int


@dataclass
class ThemeAudioResult:
    theme: str
    source_tile_dir: Path
    source_music_dir: Path
    output_dir: Path
    manifest_path: Path
    audio_manifest_path: Path
    tile_audio: list[TileAudioResult]
    music: list[AudioFileResult]
    warnings: list[str]


def require_tool(name: str) -> None:
    if shutil.which(name) is None:
        raise SystemExit(f"{name} is required. Install ffmpeg and try again.")


def run_command(command: list[str]) -> None:
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        details = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"Command failed: {' '.join(command)}\n{details}")


def probe_duration(path: Path) -> float:
    completed = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        details = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"Could not inspect duration for {path}: {details}")
    return float(completed.stdout.strip())


def discover_tile_audio_files(theme: str, source_dir: Path) -> list[Path]:
    known = KNOWN_TILE_AUDIO_FILES.get(theme)
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


def discover_music_files(source_dir: Path) -> list[Path]:
    if not source_dir.exists():
        return []
    return sorted(
        path
        for path in source_dir.iterdir()
        if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
    )


def require_exactly_nine_tile_clips(theme: str, paths: list[Path]) -> None:
    if len(paths) != 9:
        raise ValueError(f"{theme}: expected 9 tile audio clips, found {len(paths)}")
    missing = [path for path in paths if not path.exists()]
    if missing:
        formatted = "\n".join(f"  - {path}" for path in missing)
        raise FileNotFoundError(f"{theme}: missing source audio clip(s):\n{formatted}")


def safe_stem(path: Path) -> str:
    stem = path.stem.lower()
    stem = re.sub(r"[^a-z0-9]+", "_", stem).strip("_")
    return stem or "track"


def transcode_aac(*, source_path: Path, output_path: Path, bitrate: str, sample_rate: int, duration: float | None) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    audio_filter = (
        f"atrim=0:{duration},asetpts=N/SR/TB,"
        f"afade=t=in:st=0:d=0.05,afade=t=out:st={max(duration - 0.25, 0)}:d=0.25"
        if duration is not None
        else "asetpts=N/SR/TB"
    )
    run_command(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source_path),
            "-vn",
            "-ac",
            "2",
            "-ar",
            str(sample_rate),
            "-af",
            audio_filter,
            "-c:a",
            "aac",
            "-b:a",
            bitrate,
            "-movflags",
            "+faststart",
            str(output_path),
        ]
    )


def result_for_output(*, source_path: Path, output_path: Path, source_duration: float | None = None) -> AudioFileResult:
    return AudioFileResult(
        source_path=source_path,
        output_path=output_path,
        source_bytes=source_path.stat().st_size,
        output_bytes=output_path.stat().st_size,
        source_duration=source_duration if source_duration is not None else probe_duration(source_path),
        output_duration=probe_duration(output_path),
    )


def format_seconds(value: float) -> str:
    return f"{value:.2f}s"


def update_manifest(manifest_path: Path, audio_manifest: dict) -> bool:
    if not manifest_path.exists():
        return False
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest["audio"] = audio_manifest["audio"]
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return True


def build_audio_manifest(*, theme: str, tile_results: list[TileAudioResult], music_results: list[AudioFileResult], tile_duration: float) -> dict:
    return {
        "theme_id": theme,
        "generated_audio_format": "m4a/aac-lc",
        "tile_clip_duration_seconds": tile_duration,
        "audio": {
            "tiles": [
                {
                    "digit": tile.digit,
                    "long_press": f"audio/tiles/tile_{tile.digit:02d}.m4a",
                    "celebration": f"audio/tiles/tile_{tile.digit:02d}.m4a",
                }
                for tile in tile_results
            ],
            "music": [f"audio/music/{music.output_path.name}" for music in music_results],
        },
    }

