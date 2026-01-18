from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet

from domain.types import Coord

from application.state import History


@dataclass(frozen=True)
class MoveResult:
    """Result of applying a single user action (use-case).

    This is the application-layer response object that the Presenter consumes.

    Attributes:
        history: Updated history (including present state).
        conflicts: Coordinates to highlight as conflicting (may be empty).
        message: Short status message suitable for a status bar.
        solved: True if the current board is solved (filled, no conflicts).
    """

    history: History
    conflicts: FrozenSet[Coord]
    message: str
    solved: bool
