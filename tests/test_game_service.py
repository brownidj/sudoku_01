

import pytest

from application.game_service import GameService
from application.state import History
from domain.types import Board


# ---------- helpers ----------

def empty_history():
    service = GameService()
    return service.initial_history(), service


# ---------- tests ----------

def test_new_game_empty_initialises_history():
    service = GameService()
    res = service.new_game_empty()

    history = res.history
    assert history.past == tuple()
    assert history.future == tuple()
    assert history.present.board == Board.empty()
    assert res.conflicts == frozenset()
    assert res.solved is False


def test_place_digit_updates_board_and_history():
    history, service = empty_history()

    res = service.place_digit(history, (0, 0), 5)

    new_board = res.history.present.board
    assert new_board.cell_at(0, 0).value == 5
    assert res.history.can_undo() is True
    assert res.message in ("Digit placed.", "Conflict.")


def test_soft_mode_conflict_is_reported():
    history, service = empty_history()

    # Place first digit
    res1 = service.place_digit(history, (0, 0), 5)

    # Place conflicting digit in same row
    res2 = service.place_digit(res1.history, (0, 1), 5)

    assert (0, 0) in res2.conflicts
    assert (0, 1) in res2.conflicts
    assert res2.message == "Conflict."


def test_undo_and_redo_via_service():
    history, service = empty_history()

    res1 = service.place_digit(history, (0, 0), 3)
    res2 = service.place_digit(res1.history, (0, 1), 4)

    # Undo
    undo_res = service.undo(res2.history)
    board_after_undo = undo_res.history.present.board
    assert board_after_undo.cell_at(0, 1).value is None
    assert board_after_undo.cell_at(0, 0).value == 3

    # Redo
    redo_res = service.redo(undo_res.history)
    board_after_redo = redo_res.history.present.board
    assert board_after_redo.cell_at(0, 1).value == 4


def test_solved_detection_through_service():
    service = GameService()

    solved_grid = (
        (5, 3, 4, 6, 7, 8, 9, 1, 2),
        (6, 7, 2, 1, 9, 5, 3, 4, 8),
        (1, 9, 8, 3, 4, 2, 5, 6, 7),
        (8, 5, 9, 7, 6, 1, 4, 2, 3),
        (4, 2, 6, 8, 5, 3, 7, 9, 1),
        (7, 1, 3, 9, 2, 4, 8, 5, 6),
        (9, 6, 1, 5, 3, 7, 2, 8, 4),
        (2, 8, 7, 4, 1, 9, 6, 3, 5),
        (3, 4, 5, 2, 8, 6, 1, 7, 9),
    )

    res = service.new_game_from_grid(solved_grid)

    # A fully filled valid grid should be detected as solved
    assert res.solved is True