

import pytest

from domain.ops import clear_value, set_value, toggle_note
from domain.types import Board, Cell


# ---------- helpers ----------

def board_with_given_at(coord, value=5):
    """Create a board with a single given at coord."""
    empty = Board.empty()
    r, c = coord
    cell = Cell(value=value, given=True, notes=frozenset())
    return empty.with_cell(coord, cell)


# ---------- tests ----------


def test_set_value_on_empty_cell():
    board = Board.empty()
    new_board = set_value(board, (0, 0), 3)

    assert board.cell_at(0, 0).value is None
    assert new_board.cell_at(0, 0).value == 3


def test_set_value_clears_notes():
    board = Board.empty()
    board = toggle_note(board, (0, 0), 1)
    board = toggle_note(board, (0, 0), 2)

    assert board.cell_at(0, 0).notes == frozenset({1, 2})

    new_board = set_value(board, (0, 0), 4)
    cell = new_board.cell_at(0, 0)

    assert cell.value == 4
    assert cell.notes == frozenset()


def test_clear_value_preserves_notes():
    board = Board.empty()
    board = toggle_note(board, (0, 0), 7)

    cleared = clear_value(board, (0, 0))

    assert cleared.cell_at(0, 0).value is None
    assert cleared.cell_at(0, 0).notes == frozenset({7})


def test_given_cell_cannot_be_modified():
    board = board_with_given_at((1, 1), value=9)

    after_set = set_value(board, (1, 1), 3)
    after_clear = clear_value(board, (1, 1))
    after_note = toggle_note(board, (1, 1), 1)

    assert after_set == board
    assert after_clear == board
    assert after_note == board


def test_toggle_note_adds_and_removes():
    board = Board.empty()

    board = toggle_note(board, (2, 2), 4)
    assert board.cell_at(2, 2).notes == frozenset({4})

    board = toggle_note(board, (2, 2), 4)
    assert board.cell_at(2, 2).notes == frozenset()


def test_toggle_note_ignored_if_value_present():
    board = Board.empty()
    board = set_value(board, (0, 0), 6)

    after = toggle_note(board, (0, 0), 2)

    assert after == board