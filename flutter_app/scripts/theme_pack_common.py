from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT_ROOT = REPO_ROOT / "flutter_app" / "build" / "theme_packs"
DEFAULT_REPORT_DIR = REPO_ROOT / "docs" / "theme_packs"

THEME_ALIASES = {
    "old_opera": "opera",
}


def normalize_theme_id(raw: str) -> str:
    return raw.strip().lower().replace("-", "_")


def source_folder_for_theme(theme: str) -> str:
    return THEME_ALIASES.get(theme, theme)


def relative(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def format_bytes(value: int) -> str:
    if value < 1024:
        return f"{value} B"
    if value < 1024 * 1024:
        return f"{value / 1024:.1f} KB"
    return f"{value / (1024 * 1024):.2f} MB"


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def timestamped_report_path(report_dir: Path, prefix: str) -> Path:
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    return report_dir / f"{prefix}_{timestamp}.md"
