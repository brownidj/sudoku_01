

import pytest

from domain.rules import conflicts_for_cell, has_any_conflicts, is_legal_placement, is_solved
from domain.types import Board


# ---------- helpers ----------

def board_from_rows(rows):
    """Helper to build a board from a 9x9 grid using None for empty cells."""
    return Board.from_grid(tuple(tuple(r) for r in rows), givens=False)


# ---------- tests: conflicts_for_cell ----------

def test_conflicts_for_cell_row_conflict():
    board = board_from_rows([
        [1, 1, None, None, None, None, None, None, None],
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    conflicts = conflicts_for_cell(board, (0, 0))
    assert (0, 1) in conflicts
    assert (0, 0) not in conflicts


def test_conflicts_for_cell_col_conflict():
    board = board_from_rows([
        [2, None, None, None, None, None, None, None, None],
        [2, None, None, None, None, None, None, None, None],
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    conflicts = conflicts_for_cell(board, (0, 0))
    assert (1, 0) in conflicts


def test_conflicts_for_cell_box_conflict():
    board = board_from_rows([
        [3, None, None, None, None, None, None, None, None],
        [None, 3, None, None, None, None, None, None, None],
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    conflicts = conflicts_for_cell(board, (0, 0))
    assert (1, 1) in conflicts


def test_conflicts_for_cell_empty_cell_has_no_conflicts():
    board = Board.empty()
    assert conflicts_for_cell(board, (0, 0)) == set()


# ---------- tests: has_any_conflicts ----------

def test_has_any_conflicts_true():
    board = board_from_rows([
        [4, 4] + [None] * 7,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    assert has_any_conflicts(board) is True


def test_has_any_conflicts_false():
    board = board_from_rows([
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    assert has_any_conflicts(board) is False


# ---------- tests: is_legal_placement ----------

def test_is_legal_placement_true():
    board = Board.empty()
    assert is_legal_placement(board, (0, 0), 5) is True


def test_is_legal_placement_false_due_to_row():
    board = board_from_rows([
        [5, None] + [None] * 7,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    assert is_legal_placement(board, (0, 1), 5) is False


def test_is_legal_placement_same_digit_is_idempotent():
    board = board_from_rows([
        [7] + [None] * 8,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    assert is_legal_placement(board, (0, 0), 7) is True


# ---------- tests: is_solved ----------

def test_is_solved_false_when_incomplete():
    board = Board.empty()
    assert is_solved(board) is False


def test_is_solved_false_when_conflicts():
    board = board_from_rows([
        [1, 1, 2, 3, 4, 5, 6, 7, 8],
        [9] + [None] * 8,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
        [None] * 9,
    ])

    assert is_solved(board) is False


def test_is_solved_true_for_valid_complete_board():
    board = board_from_rows([
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ])

    assert is_solved(board) is True