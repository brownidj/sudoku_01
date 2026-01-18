

import pytest

from application.state import GameState, History, new_game_state_empty
from domain.types import Board


# ---------- helpers ----------

def state_with_value(coord, value):
    """Create a GameState with a single value placed on an empty board."""
    board = Board.empty()
    r, c = coord
    board = board.with_cell(coord, board.cell_at(r, c).__class__(value=value, given=False, notes=frozenset()))
    return GameState(board=board)


# ---------- tests ----------

def test_initial_history():
    state = new_game_state_empty()
    history = History.initial(state)

    assert history.present == state
    assert history.past == tuple()
    assert history.future == tuple()
    assert history.can_undo() is False
    assert history.can_redo() is False


def test_push_adds_to_past_and_clears_future():
    s1 = new_game_state_empty()
    h1 = History.initial(s1)

    s2 = state_with_value((0, 0), 1)
    h2 = h1.push(s2)

    assert h2.present == s2
    assert h2.past == (s1,)
    assert h2.future == tuple()


def test_push_idempotent_when_same_state():
    s1 = new_game_state_empty()
    h1 = History.initial(s1)

    h2 = h1.push(s1)
    assert h2 is h1


def test_undo_moves_present_to_future():
    s1 = new_game_state_empty()
    s2 = state_with_value((0, 0), 2)

    h = History.initial(s1).push(s2)
    h_undo = h.undo()

    assert h_undo.present == s1
    assert h_undo.past == tuple()
    assert h_undo.future == (s2,)


def test_undo_noop_when_no_past():
    s1 = new_game_state_empty()
    h = History.initial(s1)

    assert h.undo() is h


def test_redo_moves_future_to_present():
    s1 = new_game_state_empty()
    s2 = state_with_value((0, 0), 3)

    h = History.initial(s1).push(s2)
    h = h.undo()
    h_redo = h.redo()

    assert h_redo.present == s2
    assert h_redo.past == (s1,)
    assert h_redo.future == tuple()


def test_redo_noop_when_no_future():
    s1 = new_game_state_empty()
    h = History.initial(s1)

    assert h.redo() is h


def test_push_after_undo_clears_redo_stack():
    s1 = new_game_state_empty()
    s2 = state_with_value((0, 0), 4)
    s3 = state_with_value((0, 1), 5)

    h = History.initial(s1).push(s2)
    h = h.undo()
    h = h.push(s3)

    assert h.present == s3
    assert h.past == (s1,)
    assert h.future == tuple()