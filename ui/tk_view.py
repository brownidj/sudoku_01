from __future__ import annotations


import tkinter as tk
from typing import Literal

from ui.contracts import IView, IUserActions, UiState

# Set True temporarily to debug UI wiring.
DEBUG_UI = False


class TkSudokuView(tk.Frame, IView):
    """Tkinter View implementation (Canvas-based).

    Responsibilities:
    - Translate Tk events (mouse/keyboard) into IUserActions
    - Render UiState using a Canvas (no game logic)

    Rendering features:
    - Thick 3×3 grid lines
    - Notes rendered as 3×3 mini-grids
    - Clear highlighting: selected cell, row/col/box highlight, conflicts
    """

    def __init__(self, master: tk.Tk, actions: IUserActions):
        super().__init__(master)
        self._actions = actions

        master.title("Sudoku")

        # Top controls
        self._topbar = tk.Frame(self)
        self._topbar.pack(side="top", fill="x")

        self._btn_new_game = tk.Button(self._topbar, text="New Game", command=self._on_new_game_clicked)
        self._btn_new_game.pack(side="left")

        # Difficulty dropdown (View-local state only; Presenter owns the authoritative difficulty).
        self._difficulty_var = tk.StringVar(value="easy")
        tk.Label(self._topbar, text="Difficulty:").pack(side="left", padx=(10, 4))
        self._difficulty_menu = tk.OptionMenu(
            self._topbar,
            self._difficulty_var,
            "easy",
            "medium",
            "hard",
            command=self._on_difficulty_selected,
        )
        self._difficulty_menu.pack(side="left")

        # Status bar (bottom)
        self._status = tk.Label(self, text="", anchor="w")
        self._status.pack(side="bottom", fill="x")

        # Canvas board (top)
        self._canvas = tk.Canvas(self, highlightthickness=0)
        self._canvas.pack(side="top", fill="both", expand=True)

        # Fonts
        self._font_value = ("TkDefaultFont", 18, "normal")
        self._font_given = ("TkDefaultFont", 18, "bold")
        self._font_notes = ("TkDefaultFont", 9, "normal")

        # Cached state for redraw
        self._last_state: UiState | None = None

        # Layout cache (computed from canvas size)
        self._origin_x = 0
        self._origin_y = 0
        self._cell = 40
        self._board_px = 9 * self._cell

        # Event bindings
        self._canvas.bind("<Button-1>", self._on_click)
        self.bind_all("<Key>", self._on_key)
        self._canvas.bind("<Configure>", self._on_resize)

        self.pack(fill="both", expand=True)

    # ---------------- IView ----------------

    def render(self, state: UiState) -> None:
        """Render the UI state provided by the Presenter."""

        self._last_state = state
        self._status.config(text=state.status_text)
        # Keep difficulty dropdown in sync with Presenter-owned state and disable it mid-game.
        try:
            self._difficulty_var.set(state.difficulty)
        except (tk.TclError, ValueError):
            pass

        try:
            enabled = bool(state.can_change_difficulty)

            # OptionMenu is a Menubutton; set its state.
            menu_state: Literal["normal", "disabled"] = "normal" if enabled else "disabled"
            self._difficulty_menu.configure(state=menu_state)

            # Also disable the underlying menu entries (more reliable across Tk builds).
            menu = self._difficulty_menu["menu"]
            entry_state: Literal["normal", "disabled"] = "normal" if enabled else "disabled"
            try:
                menu.entryconfigure("easy", state=entry_state)
                menu.entryconfigure("medium", state=entry_state)
                menu.entryconfigure("hard", state=entry_state)
            except (tk.TclError, ValueError):
                # Fallback: by index
                for i in range(3):
                    try:
                        menu.entryconfigure(i, state=entry_state)
                    except (tk.TclError, ValueError):
                        pass

            if DEBUG_UI:
                try:
                    print("[TkView] render: difficulty=", state.difficulty, " can_change=", state.can_change_difficulty,
                          " menubutton_state=", self._difficulty_menu.cget("state"))
                except (tk.TclError, ValueError):
                    print("[TkView] render: difficulty sync/disable attempted")
        except Exception as e:
            if DEBUG_UI:
                print("[TkView] render: difficulty disable failed:", e)

        self._redraw()

    def set_key_capture_enabled(self, enabled: bool) -> None:
        """Enable/disable keyboard capture (placeholder for later focus control)."""

        # Keyboard capture currently uses bind_all; keep method for interface completeness.
        pass

    # ---------------- Internal: layout & drawing ----------------

    def _on_resize(self, _event: tk.Event) -> None:
        self._recompute_layout()
        self._redraw()

    def _recompute_layout(self) -> None:
        w = int(self._canvas.winfo_width())
        h = int(self._canvas.winfo_height())

        # Tk can briefly report tiny transient sizes during menu interactions; ignore them.
        if w < 50 or h < 50:
            return

        # Keep a small margin around the board
        margin = 10
        usable_w = max(50, w - 2 * margin)
        usable_h = max(50, h - 2 * margin)

        board_px = min(usable_w, usable_h)
        cell = max(20, board_px // 9)
        board_px = cell * 9

        self._cell = cell
        self._board_px = board_px
        self._origin_x = (w - board_px) // 2
        self._origin_y = (h - board_px) // 2

    def _redraw(self) -> None:
        # Ensure layout is valid even before first Configure
        self._recompute_layout()

        state = self._last_state
        self._canvas.delete("all")

        # Background board fill
        x0 = self._origin_x
        y0 = self._origin_y
        x1 = x0 + self._board_px
        y1 = y0 + self._board_px
        self._canvas.create_rectangle(x0, y0, x1, y1, outline="", fill="white")

        # Cells
        if state is not None:
            self._draw_cells(state)

        # Grid lines on top
        self._draw_grid_lines()

    def _draw_cells(self, state: UiState) -> None:
        cell = self._cell
        ox = self._origin_x
        oy = self._origin_y

        # Colors (simple and distinct)
        color_default = "white"
        color_highlight = "#f5f5dc"  # light beige
        color_selected = "#cfe8ff"   # light blue
        color_conflict = "salmon"

        for r in range(9):
            for c in range(9):
                vm = state.board.cells[r][c]

                x0 = ox + c * cell
                y0 = oy + r * cell
                x1 = x0 + cell
                y1 = y0 + cell

                # Background precedence: conflict > selected > highlight > default
                if vm.conflicted:
                    bg = color_conflict
                elif vm.selected:
                    bg = color_selected
                elif vm.highlighted:
                    bg = color_highlight
                else:
                    bg = color_default

                self._canvas.create_rectangle(x0, y0, x1, y1, outline="", fill=bg)

                # Content
                if vm.value is not None:
                    self._canvas.create_text(
                        (x0 + x1) / 2,
                        (y0 + y1) / 2,
                        text=str(vm.value),
                        font=self._font_given if vm.given else self._font_value,
                        fill="black",
                    )
                else:
                    self._draw_notes(x0, y0, cell, vm.notes)

    def _draw_notes(self, x0: int, y0: int, cell: int, notes: tuple[int, ...]) -> None:
        if not notes:
            return

        # Render notes in a 3×3 mini-grid.
        # Positions map digits 1..9 onto (row, col) = ((d-1)//3, (d-1)%3)
        sub = max(8, cell // 3)
        # Slight inset so notes don't touch borders
        inset = max(2, cell // 12)

        for d in notes:
            if d < 1 or d > 9:
                continue
            rr = (d - 1) // 3
            cc = (d - 1) % 3

            cx = x0 + inset + cc * sub + sub / 2
            cy = y0 + inset + rr * sub + sub / 2

            self._canvas.create_text(
                cx,
                cy,
                text=str(d),
                font=self._font_notes,
                fill="black",
            )

    def _draw_grid_lines(self) -> None:
        cell = self._cell
        ox = self._origin_x
        oy = self._origin_y
        size = self._board_px

        # Thin lines
        for i in range(10):
            x = ox + i * cell
            y = oy + i * cell
            self._canvas.create_line(ox, y, ox + size, y, width=1)
            self._canvas.create_line(x, oy, x, oy + size, width=1)

        # Thick 3x3 box lines
        for i in (0, 3, 6, 9):
            x = ox + i * cell
            y = oy + i * cell
            self._canvas.create_line(ox, y, ox + size, y, width=3)
            self._canvas.create_line(x, oy, x, oy + size, width=3)

    # ---------------- Internal: input handling ----------------

    def _on_difficulty_selected(self, _ignored: tk.StringVar) -> object | None:
        """Handle difficulty selection from the dropdown.

        Tk's OptionMenu type stubs commonly annotate `command` as accepting a `StringVar`.
        In practice, Tk passes the selected value string. We therefore ignore the argument
        and read the current value from our local StringVar.
        """

        value = self._difficulty_var.get()

        if DEBUG_UI:
            try:
                print("[TkView] difficulty selected:", value, " widget_state=", self._difficulty_menu.cget("state"))
            except (tk.TclError, ValueError):
                print("[TkView] difficulty selected:", value)

        self._actions.on_set_difficulty(value)
        return None

    def _on_new_game_clicked(self) -> None:
        self._actions.on_new_game()

    def _on_click(self, event: tk.Event) -> None:
        coord = self._coord_from_xy(event.x, event.y)
        if coord is None:
            return
        self._actions.on_cell_clicked(coord)

    def _coord_from_xy(self, x: int, y: int) -> tuple[int, int] | None:
        ox = self._origin_x
        oy = self._origin_y
        size = self._board_px
        cell = self._cell

        if x < ox or y < oy or x >= ox + size or y >= oy + size:
            return None

        c = (x - ox) // cell
        r = (y - oy) // cell

        if 0 <= r <= 8 and 0 <= c <= 8:
            return int(r), int(c)
        return None

    def _on_key(self, event: tk.Event) -> None:
        """Translate raw Tk events into domain-level user actions."""

        ch = event.char or ""
        keysym = (event.keysym or "")

        # Digits: prefer keysym (works for keypad), fall back to char.
        # IMPORTANT: do NOT use `ch in "123456789"` because "" is considered a substring of any string.
        digit_text = ""
        if keysym.isdigit():
            digit_text = keysym
        elif len(ch) == 1 and ch.isdigit():
            digit_text = ch

        if digit_text in ("1", "2", "3", "4", "5", "6", "7", "8", "9"):
            self._actions.on_digit_pressed(int(digit_text))
            return

        # Clear: Backspace/Delete or explicit '0'
        if keysym in ("BackSpace", "Delete") or digit_text == "0" or ch == "0":
            self._actions.on_clear_pressed()
            return

        # Notes mode toggle (example: 'n')
        if ch.lower() == "n":
            self._actions.on_toggle_notes_mode()
            return

        # Undo / Redo shortcuts (Ctrl+Z / Ctrl+Y)
        if (event.state & 0x4) != 0 and keysym.lower() == "z":
            self._actions.on_undo()
            return

        if (event.state & 0x4) != 0 and keysym.lower() == "y":
            self._actions.on_redo()
            return
