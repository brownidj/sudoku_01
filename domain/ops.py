from __future__ import annotations

from typing import Optional

from domain.types import Board, Cell, Coord, Digit


def set_value(board: Board, coord: Coord, value: Optional[Digit]) -> Board:
    """Return a new board with the cell at `coord` set to `value`.

    Rules enforced (domain-level):
    - Givens are not editable; if the target cell is a given, returns the original board.
    - Setting a non-None value clears notes (common Sudoku behaviour).
    - Clearing (value=None) preserves notes.

    This function is pure: it does not mutate the input board.
    """

    cell = board.cell_at_coord(coord)

    if cell.given:
        return board

    if value is None:
        # Preserve notes on clear.
        new_cell = Cell(value=None, given=False, notes=cell.notes)
        if new_cell == cell:
            return board
        return board.with_cell(coord, new_cell)

    # Validate digit via Cell invariants.
    new_cell = Cell(value=value, given=False, notes=frozenset())
    if new_cell == cell:
        return board
    return board.with_cell(coord, new_cell)


def clear_value(board: Board, coord: Coord) -> Board:
    """Convenience wrapper: clear a cell's value (set to None)."""

    return set_value(board, coord, None)


def toggle_note(board: Board, coord: Coord, digit: Digit) -> Board:
    """Toggle a pencil-mark digit in the cell at `coord`.

    Rules enforced:
    - Givens are not editable; returns original board.
    - If the cell currently has a value, notes are not applicable; returns original board.
    - Otherwise, toggles `digit` in the notes set.

    Pure function: returns a new board only if something changes.
    """

    cell = board.cell_at_coord(coord)

    if cell.given:
        return board

    if cell.value is not None:
        return board

    notes = set(cell.notes)
    if digit in notes:
        notes.remove(digit)
    else:
        notes.add(digit)

    new_cell = Cell(value=None, given=False, notes=frozenset(notes))
    if new_cell == cell:
        return board

    return board.with_cell(coord, new_cell)
