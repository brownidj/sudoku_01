from __future__ import annotations

import tkinter as tk
from dataclasses import dataclass
from typing import Callable, Literal

from ui.styles import STYLE_CLASSIC, STYLE_HIGH_CONTRAST, STYLE_MODERN, Style


Difficulty = Literal["easy", "medium", "hard"]
StyleName = Literal["Modern", "Classic", "High Contrast"]
ContentMode = Literal["numbers", "animals_chatGpT"]


@dataclass(frozen=True)
class ControlsState:
    difficulty: Difficulty
    can_change_difficulty: bool
    style_name: StyleName
    content_mode: ContentMode


class TopControlsPanel(tk.Frame):
    """
    View-only controls: New Game (left), Difficulty / Style / Mode (right).
    """

    def __init__(
            self,
            master: tk.Misc,
            *,
            on_new_game: Callable[[], None],
            on_set_difficulty: Callable[[str], None],
            on_style_changed: Callable[[StyleName], None],
            on_content_mode_changed: Callable[[ContentMode], None],
    ):
        super().__init__(master)

        self._on_new_game = on_new_game
        self._on_set_difficulty = on_set_difficulty
        self._on_style_changed = on_style_changed
        self._on_content_mode_changed = on_content_mode_changed

        # ---- Left: New Game ----
        tk.Button(self, text="New Game", command=self._handle_new_game).pack(side="left")

        # ---- Right container ----
        right = tk.Frame(self)
        right.pack(side="right")

        # Mode: Numbers / Animals (vertical group)
        mode_frame = tk.Frame(right)
        mode_frame.pack(side="left", padx=(0, 10))

        tk.Label(mode_frame, text="Mode:").pack(anchor="w")

        self._content_mode_var = tk.StringVar(value="numbers")

        tk.Radiobutton(
            mode_frame,
            text="Numbers",
            variable=self._content_mode_var,
            value="numbers",
            command=self._handle_content_mode_changed,
        ).pack(anchor="w")

        tk.Radiobutton(
            mode_frame,
            text="Animals",
            variable=self._content_mode_var,
            value="animals_chatGpT",
            command=self._handle_content_mode_changed,
        ).pack(anchor="w")

        # Difficulty
        self._difficulty_var = tk.StringVar(value="easy")
        tk.Label(right, text="Difficulty:").pack(side="left", padx=(10, 4))
        self._difficulty_menu = tk.OptionMenu(
            right,
            self._difficulty_var,
            "easy",
            "medium",
            "hard",
            command=self._handle_difficulty_selected,
        )
        self._difficulty_menu.pack(side="left")

        # Style
        self._style_var = tk.StringVar(value="Modern")
        tk.Label(right, text="Style:").pack(side="left", padx=(12, 4))
        self._style_menu = tk.OptionMenu(
            right,
            self._style_var,
            "Modern",
            "Classic",
            "High Contrast",
            command=self._handle_style_selected,
        )
        self._style_menu.pack(side="left")

    # ---------- Public API ----------

    def apply_state(self, state: ControlsState) -> None:
        self._difficulty_var.set(state.difficulty)
        self._style_var.set(state.style_name)
        self._content_mode_var.set(state.content_mode)

        enabled = bool(state.can_change_difficulty)
        self._difficulty_menu.configure(state="normal" if enabled else "disabled")
        menu = self._difficulty_menu["menu"]
        for i in range(3):
            try:
                menu.entryconfigure(i, state="normal" if enabled else "disabled")
            except Exception:
                pass

    def current_style(self) -> Style:
        name = self._style_var.get()
        if name == "Classic":
            return STYLE_CLASSIC
        if name == "High Contrast":
            return STYLE_HIGH_CONTRAST
        return STYLE_MODERN

    # ---------- Handlers ----------

    def _handle_new_game(self) -> None:
        self._on_new_game()

    def _handle_difficulty_selected(self, _ignored: object) -> None:
        self._on_set_difficulty(self._difficulty_var.get())

    def _handle_style_selected(self, _ignored: object) -> None:
        self._on_style_changed(self._style_var.get())  # type: ignore[arg-type]

    def _handle_content_mode_changed(self) -> None:
        value = self._content_mode_var.get()
        if value not in ("numbers", "animals_chatGpT"):
            value = "numbers"
        self._on_content_mode_changed(value)  # type: ignore[arg-type]