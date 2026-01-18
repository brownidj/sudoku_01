from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Protocol, Tuple

# Framework-agnostic core types (no Tkinter imports)
Digit = int            # 1..9
Row = int              # 0..8
Col = int              # 0..8
Coord = Tuple[Row, Col]


@dataclass(frozen=True)
class CellVM:
    """UI-friendly, toolkit-agnostic view-model for one Sudoku cell."""

    coord: Coord
    value: Optional[Digit]
    given: bool
    notes: Tuple[Digit, ...]     # sorted digits for display
    selected: bool
    conflicted: bool
    highlighted: bool            # row/col/box highlight


@dataclass(frozen=True)
class BoardVM:
    """UI-friendly 9x9 board view-model."""

    cells: Tuple[Tuple[CellVM, ...], ...]


@dataclass(frozen=True)
class UiState:
    """Top-level UI state the Presenter asks the View to render."""

    board: BoardVM
    status_text: str
    notes_mode: bool
    can_undo: bool
    can_redo: bool
    solved: bool

    # Presenter-owned difficulty UI state (View reads this to display/disable controls)
    difficulty: str
    can_change_difficulty: bool


class IView(Protocol):
    """View contract. Concrete implementations (e.g., Tkinter) live in the UI layer."""

    def render(self, vm: UiState) -> None:
        ...

    def set_key_capture_enabled(self, enabled: bool) -> None:
        """Optional: Presenter can enable/disable keyboard capture based on focus."""
        ...


class IUserActions(Protocol):
    """Events the View forwards to the Presenter (no Tkinter event objects)."""

    def on_cell_clicked(self, coord: Coord) -> None:
        ...

    def on_digit_pressed(self, digit: Digit) -> None:
        ...

    def on_clear_pressed(self) -> None:
        ...

    def on_toggle_notes_mode(self) -> None:
        ...

    def on_undo(self) -> None:
        ...

    def on_redo(self) -> None:
        ...

    def on_set_difficulty(self, difficulty: str) -> None:
        """Set the desired puzzle difficulty (e.g. 'easy', 'medium', 'hard')."""
        ...

    def on_new_game(self) -> None:
        """Start a new game (puzzle selection is handled by the Presenter/application layer)."""
        ...