from __future__ import annotations

import tkinter as tk

from ui.contracts import Coord, Digit, IUserActions
from ui.presenter import Presenter
from ui.tk_view import TkSudokuView


class ActionsProxy(IUserActions):
    """Delegates user actions to the real Presenter once attached."""

    def __init__(self) -> None:
        self._target: Presenter | None = None

    def attach(self, target: Presenter) -> None:
        self._target = target

    def _t(self) -> Presenter:
        if self._target is None:
            raise RuntimeError("Presenter not attached")
        return self._target

    def on_cell_clicked(self, coord: Coord) -> None:
        self._t().on_cell_clicked(coord)

    def on_digit_pressed(self, digit: Digit) -> None:
        self._t().on_digit_pressed(digit)

    def on_clear_pressed(self) -> None:
        self._t().on_clear_pressed()

    def on_toggle_notes_mode(self) -> None:
        self._t().on_toggle_notes_mode()

    def on_undo(self) -> None:
        self._t().on_undo()

    def on_redo(self) -> None:
        self._t().on_redo()

    def on_new_game(self) -> None:
        self._t().on_new_game()

    def on_set_difficulty(self, difficulty: str) -> None:
        self._t().on_set_difficulty(difficulty)


def main() -> None:
    root = tk.Tk()

    proxy = ActionsProxy()
    view = TkSudokuView(root, actions=proxy)

    presenter = Presenter(view)
    proxy.attach(presenter)

    presenter.start()
    root.mainloop()


if __name__ == "__main__":
    main()