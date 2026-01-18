from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Optional

from application.results import MoveResult
from application.state import GameState, History
from domain import ops, rules
from domain.types import Board, Coord, Digit

from application import puzzles


@dataclass(frozen=True)
class GameService:
    """Application-layer use-cases for Sudoku.

    This class orchestrates domain operations and history management.
    It is UI-agnostic and pure with respect to the GUI framework.
    """

    def initial_history(self) -> History:
        """Create a fresh History with an empty board."""
        return History.initial(GameState(board=Board.empty()))

    def new_game_empty(self) -> MoveResult:
        history = self.initial_history()
        return MoveResult(
            history=history,
            conflicts=frozenset(),
            message="New game.",
            solved=False,
        )

    def new_game_from_grid(self, grid) -> MoveResult:
        """Start a new game from a given 9x9 grid of values (None or 1..9).

        All non-None values are treated as givens.
        """
        board = Board.from_grid(grid, givens=True)
        history = History.initial(GameState(board=board))
        return self._result(history, None, "New game started.")

    def new_game(self, puzzle_id: str = "starter") -> MoveResult:
        """Start a new game from a named puzzle."""
        puzzle = puzzles.get_puzzle(puzzle_id)
        return self.new_game_from_grid(puzzle.grid)

    def place_digit(self, history: History, coord: Coord, digit: Digit) -> MoveResult:
        """Place a digit using *soft enforcement*.

        Soft mode policy (application layer):
        - Always apply the move if the cell is editable (domain ops will refuse givens).
        - If the placement violates Sudoku constraints, still apply it but return a message
          indicating a conflict (the UI will highlight conflicts via `_result`).

        This method calls `rules.is_legal_placement` to make the policy explicit and to
        support an easy future switch to hard enforcement.
        """

        before = history.present.board

        # Legality is a Sudoku-rule check only (does not consider givens).
        legal = rules.is_legal_placement(before, coord, digit)

        after = ops.set_value(before, coord, digit)

        if after == before:
            return self._result(history, coord, "No change.")

        new_history = history.push(GameState(board=after))

        # Soft mode: move is applied regardless; message reflects legality.
        msg = "Digit placed." if legal else "Conflict."
        return self._result(new_history, coord, msg)

    def clear_cell(self, history: History, coord: Coord) -> MoveResult:
        before = history.present.board
        after = ops.clear_value(before, coord)

        if after == before:
            return self._result(history, coord, "No change.")

        new_history = history.push(GameState(board=after))
        return self._result(new_history, coord, "Cell cleared.")

    def toggle_note(self, history: History, coord: Coord, digit: Digit) -> MoveResult:
        before = history.present.board
        after = ops.toggle_note(before, coord, digit)

        if after == before:
            return self._result(history, None, "No change.")

        new_history = history.push(GameState(board=after))
        return self._result(new_history, None, "Note toggled.")

    def undo(self, history: History) -> MoveResult:
        if not history.can_undo():
            return self._result(history, None, "Nothing to undo.")

        new_history = history.undo()
        return self._result(new_history, None, "Undone.")

    def redo(self, history: History) -> MoveResult:
        if not history.can_redo():
            return self._result(history, None, "Nothing to redo.")

        new_history = history.redo()
        return self._result(new_history, None, "Redone.")

    def _result(self, history: History, coord: Optional[Coord], message: str) -> MoveResult:
        board = history.present.board

        conflicts: FrozenSet[Coord]
        if coord is None:
            conflicts = frozenset()
        else:
            other = rules.conflicts_for_cell(board, coord)
            if other:
                # Include the target coord so the UI can highlight the cell itself too.
                other.add(coord)
            conflicts = frozenset(other)

        solved = rules.is_solved(board)

        if solved:
            message = "Solved."

        return MoveResult(
            history=history,
            conflicts=conflicts,
            message=message,
            solved=solved,
        )