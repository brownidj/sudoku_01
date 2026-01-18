from __future__ import annotations

from dataclasses import dataclass
import random
from typing import Dict, Optional, Tuple

from domain.types import Digit

Grid = Tuple[Tuple[Optional[Digit], ...], ...]


@dataclass(frozen=True)
class Puzzle:
    """A Sudoku puzzle definition.

    - grid uses None for empty cells and 1..9 for givens.
    - difficulty is a simple label for now; refine later.
    """

    puzzle_id: str
    difficulty: str
    grid: Grid


# Seed puzzles (None for empty). These are valid Sudoku puzzles used as templates.
_EASY_GRID_01: Grid = (
    (5, 3, None, None, 7, None, None, None, None),
    (6, None, None, 1, 9, 5, None, None, None),
    (None, 9, 8, None, None, None, None, 6, None),
    (8, None, None, None, 6, None, None, None, 3),
    (4, None, None, 8, None, 3, None, None, 1),
    (7, None, None, None, 2, None, None, None, 6),
    (None, 6, None, None, None, None, 2, 8, None),
    (None, None, None, 4, 1, 9, None, None, 5),
    (None, None, None, None, 8, None, None, 7, 9),
)

# A medium template (classic example puzzle)
_MEDIUM_GRID_01: Grid = (
    (None, None, 3, None, 2, None, 6, None, None),
    (9, None, None, 3, None, 5, None, None, 1),
    (None, None, 1, 8, None, 6, 4, None, None),
    (None, None, 8, 1, None, 2, 9, None, None),
    (7, None, None, None, None, None, None, None, 8),
    (None, None, 6, 7, None, 8, 2, None, None),
    (None, None, 2, 6, None, 9, 5, None, None),
    (8, None, None, 2, None, 3, None, None, 9),
    (None, None, 5, None, 1, None, 3, None, None),
)

# A harder template (fewer givens)
_HARD_GRID_01: Grid = (
    (None, None, None, None, None, None, None, 1, 2),
    (None, None, None, None, 3, 5, None, None, None),
    (None, None, None, 7, None, None, 3, None, None),
    (None, 3, None, None, None, None, None, None, None),
    (1, None, None, None, None, None, None, None, 6),
    (None, None, None, None, None, None, None, 7, None),
    (None, None, 5, None, None, 8, None, None, None),
    (None, None, None, 2, 9, None, None, None, None),
    (7, 2, None, None, None, None, None, None, None),
)


_EASY_SEEDS: Tuple[Grid, ...] = (_EASY_GRID_01,)
_MEDIUM_SEEDS: Tuple[Grid, ...] = (_MEDIUM_GRID_01,)
_HARD_SEEDS: Tuple[Grid, ...] = (_HARD_GRID_01,)


_DIFFICULTY_SEEDS: Dict[str, Tuple[Grid, ...]] = {
    "easy": _EASY_SEEDS,
    "medium": _MEDIUM_SEEDS,
    "hard": _HARD_SEEDS,
}


PUZZLES: Dict[str, Puzzle] = {
    "starter": Puzzle(puzzle_id="starter", difficulty="easy", grid=_EASY_GRID_01),
}


def get_puzzle(puzzle_id: str = "starter") -> Puzzle:
    """Fetch a puzzle by id.

    Raises:
        KeyError: if the puzzle_id is not known.
    """

    return PUZZLES[puzzle_id]


def list_puzzles() -> Tuple[Puzzle, ...]:
    """Return all available puzzles as an immutable tuple."""

    # Build a tuple via comprehension so the element type is unambiguous
    return tuple(p for p in PUZZLES.values())



def _randomize_seed(seed: Grid, rng: random.Random) -> Grid:
    """Randomize a seed grid while preserving Sudoku validity.

    Uses only structure-preserving transforms:
    - digit relabeling (a permutation of 1..9)
    - row permutations within each 3-row band, plus band permutations
    - column permutations within each 3-col stack, plus stack permutations

    The pattern of filled cells remains unchanged.
    """

    # 1) Digit relabeling: create a bijection 1..9 -> 1..9
    perm = list(range(1, 10))
    rng.shuffle(perm)
    digit_map = {d: perm[d - 1] for d in range(1, 10)}

    # 2) Row ordering: shuffle bands and rows within each band
    bands = [0, 1, 2]
    rng.shuffle(bands)
    row_order = []
    for b in bands:
        rows = [0, 1, 2]
        rng.shuffle(rows)
        row_order.extend([b * 3 + r for r in rows])

    # 3) Column ordering: shuffle stacks and cols within each stack
    stacks = [0, 1, 2]
    rng.shuffle(stacks)
    col_order = []
    for s in stacks:
        cols = [0, 1, 2]
        rng.shuffle(cols)
        col_order.extend([s * 3 + c for c in cols])

    # 4) Apply permutations
    new_rows = []
    for r in row_order:
        row = []
        for c in col_order:
            v = seed[r][c]
            if v is None:
                row.append(None)
            else:
                row.append(digit_map[v])
        new_rows.append(tuple(row))

    return tuple(new_rows)

# --- Randomized starter generator


def generate_puzzle(difficulty: str = "easy", rng: random.Random | None = None) -> Puzzle:
    """Generate a puzzle for the requested difficulty.

    This generates a full solved grid and then masks cells according to difficulty.

    Args:
        difficulty: "easy" | "medium" | "hard" (case-insensitive).
        rng: Optional random generator (injectable for deterministic tests).

    Returns:
        A new Puzzle instance.

    Raises:
        KeyError: if the difficulty is unknown.
    """

    if rng is None:
        rng = random.Random()

    diff = (difficulty or "easy").strip().lower()
    if diff not in ("easy", "medium", "hard"):
        raise KeyError(diff)

    solution = _generate_full_solution(rng)
    grid = _mask_solution(solution, diff, rng)

    puzzle_id = diff + "_gen_" + format(rng.getrandbits(32), "08x")
    return Puzzle(puzzle_id=puzzle_id, difficulty=diff, grid=grid)


def generate_random_starter(rng: random.Random | None = None) -> Puzzle:
    """Backward-compatible alias for an easy randomized starter."""

    return generate_puzzle("easy", rng=rng)


# --- Local legality checker and full-solution generator


def _is_legal(grid: list[list[Optional[Digit]]], r: int, c: int, d: Digit) -> bool:
    """Return True iff placing digit d at (r, c) does not violate Sudoku constraints."""

    # Row
    for cc in range(9):
        if grid[r][cc] == d:
            return False

    # Column
    for rr in range(9):
        if grid[rr][c] == d:
            return False

    # Box
    br = (r // 3) * 3
    bc = (c // 3) * 3
    for rr in range(br, br + 3):
        for cc in range(bc, bc + 3):
            if grid[rr][cc] == d:
                return False

    return True


def _generate_full_solution(rng: random.Random) -> Grid:
    """Generate a complete solved Sudoku grid using randomized backtracking."""

    work: list[list[Optional[Digit]]] = [[None] * 9 for _ in range(9)]
    digits: list[Digit] = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    def find_empty() -> tuple[int, int] | None:
        for rr in range(9):
            for cc in range(9):
                if work[rr][cc] is None:
                    return rr, cc
        return None

    def fill() -> bool:
        spot = find_empty()
        if spot is None:
            return True

        rr, cc = spot
        candidates = digits[:]
        rng.shuffle(candidates)

        for val in candidates:
            if _is_legal(work, rr, cc, val):
                work[rr][cc] = val
                if fill():
                    return True
                work[rr][cc] = None

        return False

    if not fill():
        raise RuntimeError("Unable to generate a solved Sudoku grid")

    return tuple(tuple(work[r][c] for c in range(9)) for r in range(9))


# --- Phase 2: Masking a solved grid into a puzzle

# Target givens per difficulty (initial heuristic; refine later)
_TARGET_GIVENS: Dict[str, int] = {
    "easy": 40,
    "medium": 32,
    "hard": 26,
}


def _mask_solution(solution: Grid, difficulty: str, rng: random.Random) -> Grid:
    """Mask (remove) values from a solved grid to form a puzzle.

    Guarantees at least one solution (the provided solution). Uniqueness is NOT
    enforced yet.
    """

    diff = (difficulty or "easy").strip().lower()
    target = _TARGET_GIVENS.get(diff, _TARGET_GIVENS["easy"])

    work: list[list[Optional[Digit]]] = [list(row) for row in solution]

    # Rotational symmetry (180°): remove (r, c) together with (8-r, 8-c).
    # We iterate only over half the grid (including the center cell) to avoid duplicates.
    coords = [(r, c) for r in range(9) for c in range(9) if (r < 4) or (r == 4 and c <= 4)]
    rng.shuffle(coords)

    givens = 81
    for r, c in coords:
        if givens <= target:
            break

        r2, c2 = 8 - r, 8 - c

        # Determine how many givens would be removed by this symmetric step.
        # Center cell (4,4) maps to itself.
        if r == r2 and c == c2:
            removal = 1
        else:
            removal = 2

        # Do not overshoot below the target; preserve symmetry.
        if givens - removal < target:
            continue

        # Remove the symmetric pair if present.
        old1 = work[r][c]
        old2 = work[r2][c2]

        if old1 is None and old2 is None:
            continue

        work[r][c] = None
        work[r2][c2] = None
        givens -= removal

    return tuple(tuple(work[r][c] for c in range(9)) for r in range(9))
