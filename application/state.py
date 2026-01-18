from __future__ import annotations

from dataclasses import dataclass
from typing import Tuple

from domain.types import Board


@dataclass(frozen=True)
class GameState:
    """Application-level snapshot of the game.

    At this stage it only contains the current Board. Add metadata later
    (difficulty, elapsed time, mistakes, etc.) without changing the UI layer.
    """

    board: Board


@dataclass(frozen=True)
class History:
    """Undo/redo history for GameState.

    - past: older states (stack; last element is the most recent past)
    - present: current state
    - future: redo states (stack; first element is the next redo)

    This is immutable; operations return new History objects.
    """

    past: Tuple[GameState, ...]
    present: GameState
    future: Tuple[GameState, ...]

    @staticmethod
    def initial(state: GameState) -> History:
        return History(past=tuple(), present=state, future=tuple())

    def can_undo(self) -> bool:
        return len(self.past) > 0

    def can_redo(self) -> bool:
        return len(self.future) > 0

    def push(self, new_present: GameState) -> History:
        """Push a new present state; clears the redo stack."""

        if new_present == self.present:
            return self

        return History(
            past=self.past + (self.present,),
            present=new_present,
            future=tuple(),
        )

    def undo(self) -> History:
        """Step back one state if possible; otherwise return self."""

        if not self.can_undo():
            return self

        prev = self.past[-1]
        new_past = self.past[:-1]
        new_future = (self.present,) + self.future
        return History(past=new_past, present=prev, future=new_future)

    def redo(self) -> History:
        """Step forward one state if possible; otherwise return self."""

        if not self.can_redo():
            return self

        nxt = self.future[0]
        new_future = self.future[1:]
        new_past = self.past + (self.present,)
        return History(past=new_past, present=nxt, future=new_future)


def new_game_state_empty() -> GameState:
    """Convenience factory: a new empty board game state."""

    return GameState(board=Board.empty())