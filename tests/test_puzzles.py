import random

from application.puzzles import _generate_full_solution, generate_puzzle
from domain.rules import has_any_conflicts, is_solved
from domain.types import Board


def test_generate_full_solution_is_valid_and_complete():
    rng = random.Random(123)
    grid = _generate_full_solution(rng)

    # Complete means no Nones
    assert all(v is not None for row in grid for v in row)

    # Valid means it is a solved Sudoku
    board = Board.from_grid(grid, givens=True)
    assert is_solved(board) is True


def test_generate_puzzle_easy_has_no_conflicts_and_has_blanks():
    rng = random.Random(1)
    p = generate_puzzle("easy", rng=rng)

    # Must have blanks after masking
    assert any(v is None for row in p.grid for v in row)

    board = Board.from_grid(p.grid, givens=True)
    assert has_any_conflicts(board) is False

    givens = sum(1 for row in p.grid for v in row if v is not None)
    assert 36 <= givens <= 45


def test_generate_puzzle_medium_givens_range():
    rng = random.Random(2)
    p = generate_puzzle("medium", rng=rng)

    board = Board.from_grid(p.grid, givens=True)
    assert has_any_conflicts(board) is False

    givens = sum(1 for row in p.grid for v in row if v is not None)
    assert 28 <= givens <= 35


def test_generate_puzzle_hard_givens_range():
    rng = random.Random(3)
    p = generate_puzzle("hard", rng=rng)

    board = Board.from_grid(p.grid, givens=True)
    assert has_any_conflicts(board) is False

    givens = sum(1 for row in p.grid for v in row if v is not None)
    assert 22 <= givens <= 30


def test_generate_puzzle_has_rotational_symmetry_in_blanks():
    rng = random.Random(10)
    p = generate_puzzle("medium", rng=rng)

    for r in range(9):
        for c in range(9):
            r2, c2 = 8 - r, 8 - c
            is_blank = p.grid[r][c] is None
            is_blank_sym = p.grid[r2][c2] is None
            assert is_blank == is_blank_sym