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


def _is_legal(grid, r, c, value):
    # Row
    for cc in range(9):
        if grid[r][cc] == value:
            return False
    # Column
    for rr in range(9):
        if grid[rr][c] == value:
            return False
    # Box
    br = (r // 3) * 3
    bc = (c // 3) * 3
    for rr in range(br, br + 3):
        for cc in range(bc, bc + 3):
            if grid[rr][cc] == value:
                return False
    return True


def _find_best_empty(grid):
    best = None
    best_candidates = None
    for r in range(9):
        for c in range(9):
            if grid[r][c] is not None:
                continue
            candidates = [d for d in range(1, 10) if _is_legal(grid, r, c, d)]
            if not candidates:
                return (r, c), []
            if best is None or len(candidates) < len(best_candidates):
                best = (r, c)
                best_candidates = candidates
                if len(best_candidates) == 1:
                    return best, best_candidates
    if best is None:
        return None, []
    return best, best_candidates


def _is_solvable(grid):
    # Use a simple backtracking solver to verify at least one solution exists.
    work = [list(row) for row in grid]

    def solve():
        spot, candidates = _find_best_empty(work)
        if spot is None:
            return True
        r, c = spot
        for val in candidates:
            work[r][c] = val
            if solve():
                return True
            work[r][c] = None
        return False

    return solve()


def test_generate_puzzle_is_solvable():
    rng = random.Random(42)
    for difficulty in ("easy", "medium", "hard"):
        puzzle = generate_puzzle(difficulty, rng=rng)
        assert _is_solvable(puzzle.grid) is True
