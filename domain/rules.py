from __future__ import annotations

from typing import Set

from domain.types import Board, Coord, Digit


def _coords_in_row(row: int) -> Set[Coord]:
    return {(row, c) for c in range(9)}


def _coords_in_col(col: int) -> Set[Coord]:
    return {(r, col) for r in range(9)}


def _coords_in_box(coord: Coord) -> Set[Coord]:
    r, c = coord
    br = (r // 3) * 3
    bc = (c // 3) * 3
    return {(rr, cc) for rr in range(br, br + 3) for cc in range(bc, bc + 3)}


def conflicts_for_cell(board: Board, coord: Coord) -> Set[Coord]:
    """Return the set of coordinates that conflict with the cell at `coord`.

    A conflict exists when another cell in the same row, column, or 3x3 box
    contains the same digit.

    Notes:
    - If the target cell is empty, returns an empty set.
    - The returned set contains the *other* conflicting coordinates, not `coord` itself.
    - Pure function: does not mutate the board.
    """

    cell = board.cell_at_coord(coord)
    if cell.value is None:
        return set()

    digit: Digit = cell.value
    r, c = coord

    related = (_coords_in_row(r) | _coords_in_col(c) | _coords_in_box(coord))
    related.discard(coord)

    conflicts: Set[Coord] = set()
    for rr, cc in related:
        if board.cell_at(rr, cc).value == digit:
            conflicts.add((rr, cc))

    return conflicts


def is_legal_placement(board: Board, coord: Coord, digit: Digit) -> bool:
    """Return True if placing `digit` at `coord` would be legal.

    Legality definition (pure, domain-level):
    - The target cell must be empty OR already contain the same digit.
    - No other cell in the same row, column, or 3x3 box may contain `digit`.

    Notes:
    - This function does NOT check the `given` constraint; that is an
      application-level policy decision.
    - Pure function: does not mutate the board.
    """

    cell = board.cell_at_coord(coord)

    # Allow re-placing the same digit (idempotent)
    if cell.value == digit:
        return True

    # Cannot place over a different existing value
    if cell.value is not None:
        return False

    r, c = coord
    related = (_coords_in_row(r) | _coords_in_col(c) | _coords_in_box(coord))
    related.discard(coord)

    for rr, cc in related:
        if board.cell_at(rr, cc).value == digit:
            return False

    return True


def has_any_conflicts(board: Board) -> bool:
    """True if any filled cell conflicts with another filled cell."""

    for r in range(9):
        for c in range(9):
            coord = (r, c)
            if board.cell_at(r, c).value is None:
                continue
            if conflicts_for_cell(board, coord):
                return True
    return False


def is_solved(board: Board) -> bool:
    """True if the puzzle is completely filled and has no conflicts."""

    for r in range(9):
        for c in range(9):
            if board.cell_at(r, c).value is None:
                return False

    return not has_any_conflicts(board)