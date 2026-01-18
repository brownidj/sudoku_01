from __future__ import annotations

from typing import Optional

from application.game_service import GameService
from application import puzzles

from domain.types import Coord, Digit
from ui.contracts import BoardVM, CellVM, IView, IUserActions, UiState


class Presenter(IUserActions):
    """Presenter (UI logic only).

    Responsibilities:
    - Own UI state (selection, notes mode)
    - Delegate game actions to the application layer (GameService)
    - Map domain/application state to UI view-models (UiVM)

    The Presenter must remain GUI-toolkit-agnostic (no tkinter imports).
    """

    def __init__(self, view: IView) -> None:
        self._view = view

        # UI state
        self._selected: Optional[Coord] = None
        self._notes_mode: bool = False

        # Difficulty is Presenter-owned UI state (not a Tk variable).
        self._difficulty: str = "easy"

        # Policy state: difficulty can be changed only before the first successful player entry.
        self._difficulty_locked: bool = False

        # Application layer
        self._service = GameService()
        self._history = self._service.initial_history()

        # Rendering aids
        self._last_conflicts: frozenset[Coord] = frozenset()
        self._last_solved: bool = False

    # -------- Lifecycle --------

    def start(self) -> None:
        # Start with a real puzzle (givens) from the puzzle bank.
        p = puzzles.generate_puzzle(self._difficulty)
        res = self._service.new_game_from_grid(p.grid)
        self._selected = None
        self._last_conflicts = frozenset()
        self._last_solved = False
        self._difficulty_locked = False
        self._apply_result(res)
        # Make it obvious to the player that this is a fresh (randomized) puzzle.
        self._render("New game (" + p.difficulty + "): " + p.puzzle_id)

    # -------- IUserActions --------

    def on_cell_clicked(self, coord: Coord) -> None:
        self._selected = coord
        self._render("Cell selected")

    def on_digit_pressed(self, digit: Digit) -> None:
        if self._selected is None:
            self._render("Select a cell")
            return

        before = self._history
        if self._notes_mode:
            res = self._service.toggle_note(self._history, self._selected, digit)
        else:
            res = self._service.place_digit(self._history, self._selected, digit)

        self._apply_result(res)
        self._lock_difficulty_if_first_player_change(before, self._history)

    def on_clear_pressed(self) -> None:
        if self._selected is None:
            self._render("Select a cell")
            return

        before = self._history
        res = self._service.clear_cell(self._history, self._selected)
        self._apply_result(res)
        self._lock_difficulty_if_first_player_change(before, self._history)

    def on_toggle_notes_mode(self) -> None:
        self._notes_mode = not self._notes_mode
        self._render("Notes mode on" if self._notes_mode else "Notes mode off")

    def on_undo(self) -> None:
        res = self._service.undo(self._history)
        self._apply_result(res)

    def on_redo(self) -> None:
        res = self._service.redo(self._history)
        self._apply_result(res)

    def on_set_difficulty(self, difficulty: str) -> None:
        d = (difficulty or "easy").strip().lower()
        if d not in ("easy", "medium", "hard"):
            self._render("Unknown difficulty: " + difficulty)
            return

        # Policy: once the player has made a first successful entry, difficulty switching
        # is disabled until a new game starts.
        if self._difficulty_locked:
            self._render("Finish or start a new game before changing difficulty")
            return

        # Update Presenter-owned difficulty
        self._difficulty = d

        # Immediately start a new game at the selected difficulty
        p = puzzles.generate_puzzle(self._difficulty)
        res = self._service.new_game_from_grid(p.grid)

        self._selected = None
        self._last_conflicts = frozenset()
        self._last_solved = False
        self._difficulty_locked = False

        self._apply_result(res)
        self._render("New game (" + p.difficulty + "): " + p.puzzle_id)

    def on_new_game(self) -> None:
        p = puzzles.generate_puzzle(self._difficulty)
        res = self._service.new_game_from_grid(p.grid)
        self._selected = None
        self._last_conflicts = frozenset()
        self._last_solved = False
        self._difficulty_locked = False
        self._apply_result(res)
        self._render("New game (" + p.difficulty + "): " + p.puzzle_id)

    def on_save_requested(self) -> None:
        """Handle a save request from the View.

        The Presenter exports a JSON-safe payload via the application layer and
        passes it back to the View for actual persistence.
        """

        payload = self._service.export_save(self._history)
        self._view.present_save_payload(payload)

    def on_load_requested(self, data: dict) -> None:
        """Handle a load request from the View.

        Args:
            data: A JSON-decoded dictionary produced by a prior save operation.
        """

        res = self._service.import_save(data)
        self._selected = None
        self._last_conflicts = frozenset()
        self._last_solved = False

        # Once a game is loaded, difficulty changes should be locked
        # if the loaded history already has player moves.
        self._difficulty_locked = res.history.can_undo()

        self._apply_result(res)

    # -------- Internal helpers --------

    def _lock_difficulty_if_first_player_change(self, before_history, after_history) -> None:
        """Lock difficulty after the first successful player-initiated board change.

        We treat any successful push to history (undo becomes available) originating from
        a player entry action (digit/place, clear, note toggle) as the lock trigger.
        """

        if self._difficulty_locked:
            return

        if (not before_history.can_undo()) and after_history.can_undo():
            self._difficulty_locked = True

    def _apply_result(self, res) -> None:
        self._history = res.history
        self._last_conflicts = res.conflicts
        self._last_solved = res.solved
        self._render(res.message)

    def _render(self, status: str) -> None:
        board = self._history.present.board
        selected = self._selected
        conflicts = self._last_conflicts

        cells = []
        for r in range(9):
            row = []
            for c in range(9):
                coord = (r, c)
                cell = board.cell_at(r, c)

                highlighted = False
                if selected is not None:
                    sr, sc = selected
                    highlighted = (
                        r == sr
                        or c == sc
                        or ((r // 3) == (sr // 3) and (c // 3) == (sc // 3))
                    )

                row.append(
                    CellVM(
                        coord=coord,
                        value=cell.value,
                        given=cell.given,
                        notes=tuple(sorted(cell.notes)),
                        selected=(coord == selected),
                        conflicted=(coord in conflicts),
                        highlighted=highlighted,
                    )
                )
            cells.append(tuple(row))

        vm = UiState(
            board=BoardVM(cells=tuple(cells)),
            status_text=status,
            notes_mode=self._notes_mode,
            can_undo=self._history.can_undo(),
            can_redo=self._history.can_redo(),
            solved=self._last_solved,
            difficulty=self._difficulty,
            can_change_difficulty=(not self._difficulty_locked),
        )

        self._view.render(vm)