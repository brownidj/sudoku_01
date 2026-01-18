from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Optional, Tuple

# ---- Core domain types ----
Digit = int  # 1..9
Row = int    # 0..8
Col = int    # 0..8
Coord = Tuple[Row, Col]


def _is_valid_digit(digit: Digit) -> bool:
    return digit in (1, 2, 3, 4, 5, 6, 7, 8, 9)


def _is_valid_coord(coord: Coord) -> bool:
    r, c = coord
    return 0 <= r <= 8 and 0 <= c <= 8


@dataclass(frozen=True)
class Cell:
    """A single Sudoku cell.

    - `value` is None for empty or 1..9 when filled.
    - `given` is True if the value is a puzzle clue (not editable).
    - `notes` is a frozen set of candidate digits (pencil marks).

    This is a pure domain object: no GUI state, no validation UI concerns.
    """

    value: Optional[Digit]
    given: bool
    notes: FrozenSet[Digit]

    def __post_init__(self) -> None:
        if self.value is not None and not _is_valid_digit(self.value):
            raise ValueError("Cell value must be None or 1..9")

        for d in self.notes:
            if not _is_valid_digit(d):
                raise ValueError("Cell notes must contain only digits 1..9")

        # Domain invariant: if a cell has a value, it should not have notes.
        # (Some variants keep notes; we enforce the common rule for now.)
        if self.value is not None and self.notes:
            raise ValueError("Cell cannot have notes when a value is set")

        # Domain invariant: givens must have a value.
        if self.given and self.value is None:
            raise ValueError("Given cells must have a value")


@dataclass(frozen=True)
class Board:
    """An immutable 9x9 Sudoku board."""

    cells: Tuple[Tuple[Cell, ...], ...]  # rows-major, 9 rows x 9 cols

    def __post_init__(self) -> None:
        if len(self.cells) != 9:
            raise ValueError("Board must have exactly 9 rows")

        for row in self.cells:
            if len(row) != 9:
                raise ValueError("Each board row must have exactly 9 cells")

    def cell_at(self, r: Row, c: Col) -> Cell:
        return self.cells[r][c]

    def cell_at_coord(self, coord: Coord) -> Cell:
        if not _is_valid_coord(coord):
            raise ValueError("Coord must be within 0..8, 0..8")
        r, c = coord
        return self.cell_at(r, c)

    def with_cell(self, coord: Coord, new_cell: Cell) -> Board:
        """Return a new board with one cell replaced."""
        if not _is_valid_coord(coord):
            raise ValueError("Coord must be within 0..8, 0..8")

        r, c = coord
        row = self.cells[r]
        new_row = row[:c] + (new_cell,) + row[c + 1 :]
        new_cells = self.cells[:r] + (new_row,) + self.cells[r + 1 :]
        return Board(cells=new_cells)

    @staticmethod
    def empty() -> Board:
        """Create an empty editable board (no givens)."""
        row = tuple(Cell(value=None, given=False, notes=frozenset()) for _ in range(9))
        cells = tuple(row for _ in range(9))
        return Board(cells=cells)

    @staticmethod
    def from_grid(values: Tuple[Tuple[Optional[Digit], ...], ...], *, givens: bool = True) -> Board:
        """Create a board from a 9x9 grid of values.

        Args:
            values: 9x9 tuple grid of None or digits 1..9.
            givens: if True, non-None values are marked as given clues.
        """
        if len(values) != 9:
            raise ValueError("values must be a 9x9 grid")

        rows = []
        for r in range(9):
            if len(values[r]) != 9:
                raise ValueError("values must be a 9x9 grid")
            row = []
            for c in range(9):
                v = values[r][c]
                if v is not None and not _is_valid_digit(v):
                    raise ValueError("values must contain only None or digits 1..9")
                is_given = bool(givens and v is not None)
                row.append(Cell(value=v, given=is_given, notes=frozenset()))
            rows.append(tuple(row))

        return Board(cells=tuple(rows))
