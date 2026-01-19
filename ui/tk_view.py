from __future__ import annotations


import json
import time
import tkinter as tk
from tkinter import filedialog, messagebox
from ui.contracts import IView, IUserActions, UiState
from ui.styles import STYLE_MODERN, Style
from typing import cast
from ui.controls import TopControlsPanel, ControlsState, Difficulty, StyleName, ContentMode
from ui.layout import BoardLayout, compute_layout, coord_from_xy
from ui.canvas_renderer import SudokuCanvasRenderer

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

        # Default window sized to comfortably fit a 60px-cell board plus UI chrome.
        # Board: 9*60 = 540; with margins and UI bars this lands around ~640–720px tall.
        try:
            master.geometry("620x740")
            master.minsize(560, 680)
        except Exception:
            pass

        self._style: Style = STYLE_MODERN
        self._content_mode: ContentMode = "numbers"

        # Menu bar
        self._menubar = tk.Menu(master)
        self._file_menu = tk.Menu(self._menubar, tearoff=0)
        self._file_menu.add_command(label="Save…", command=self._on_save_clicked)
        self._file_menu.add_command(label="Load…", command=self._on_load_clicked)
        self._menubar.add_cascade(label="File", menu=self._file_menu)
        master.config(menu=self._menubar)

        # Controls host (full width) and a fixed-width centered panel above the grid.
        self._controls_host = tk.Frame(self)
        self._controls_host.pack(side="top", fill="x")

        self._controls_panel = tk.Frame(self._controls_host)
        self._controls_panel.pack(side="top")
        self._controls_panel.pack_propagate(False)

        # View-only controls widget
        self._controls = TopControlsPanel(
            self._controls_panel,
            on_new_game=self._on_new_game_clicked,
            on_set_difficulty=self._on_controls_set_difficulty,
            on_style_changed=self._on_controls_style_changed,
            on_content_mode_changed=self._on_controls_content_mode_changed,
        )
        self._controls.pack(side="top", fill="both", expand=True)

        # Status bar (bottom)
        self._status = tk.Label(self, text="", anchor="w")
        self._status.pack(side="bottom", fill="x")

        # Canvas board (top)
        self._canvas = tk.Canvas(self, highlightthickness=0)
        self._renderer = SudokuCanvasRenderer(self._canvas, self._style)
        self._canvas.pack(side="top", fill="both", expand=True)
        self._ensure_canvas_focus()

        # Fonts (from style)
        self._font_value = self._style.value_font
        self._font_given = self._style.given_font
        self._font_notes = self._style.notes_font

        # Cached state for redraw
        self._last_state: UiState | None = None
        # View-local transient status override (e.g. save/load confirmations)
        self._status_override: str | None = None
        self._status_override_job: str | None = None

        # Layout cache (computed from canvas size)
        self._layout: BoardLayout | None = None

        # Event bindings
        self._canvas.bind("<Button-1>", self._on_click)
        self.bind_all("<Key>", self._on_key)
        self._canvas.bind("<Configure>", self._on_resize)

        self.pack(fill="both", expand=True)

    # ---------------- IView ----------------

    def _dbg(self, *parts: object) -> None:
        if not DEBUG_UI:
            return
        try:
            stamp = time.strftime("%H:%M:%S")
        except Exception:
            stamp = "?"
        try:
            print("[TkView %s]" % stamp, *parts)
        except Exception:
            pass

    def _set_status_override(self, text: str, ms: int = 3000) -> None:
        """Show a temporary status message without fighting Presenter renders."""

        self._dbg("_set_status_override:", text, "ms=", ms)
        self._status_override = text
        self._status.config(text=text)
        self._dbg("_set_status_override: label set to=", self._status.cget("text"))
        try:
            self._status.update_idletasks()
        except Exception:
            pass

        # Cancel any pending clear
        job = self._status_override_job
        if job is not None:
            try:
                self.after_cancel(job)
            except Exception:
                pass
            self._status_override_job = None

        if ms > 0:
            # Use a zero-arg lambda to keep static type checkers happy about Tk's `after(..., func, *args)` signature.
            self._status_override_job = self.after(ms, lambda: self._clear_status_override())

    def _clear_status_override(self) -> None:
        self._dbg("_clear_status_override")
        self._status_override = None
        self._status_override_job = None
        if self._last_state is not None:
            self._status.config(text=self._last_state.status_text)
        else:
            self._status.config(text="")

        try:
            self._status.update_idletasks()
        except Exception:
            pass

    def present_save_payload(self, payload: dict) -> None:
        """Prompt the user to save a JSON-safe payload to disk."""

        self._dbg("present_save_payload: begin")
        path = filedialog.asksaveasfilename(
            title="Save Sudoku",
            defaultextension=".json",
            filetypes=[("Sudoku save", "*.json"), ("JSON", "*.json"), ("All files", "*.*")],
        )
        self._dbg("present_save_payload: path=", path)
        if not path:
            return

        try:
            self._dbg("present_save_payload: writing")
            with open(path, "w", encoding="utf-8") as f:
                json.dump(payload, f, ensure_ascii=False, indent=2)
            self._dbg("present_save_payload: wrote ok")
        except OSError as e:
            messagebox.showerror("Save failed", "Unable to save file.\n\n" + str(e))
            return

        # Status feedback (Presenter remains pure)
        self._dbg("present_save_payload: setting status override")
        self._set_status_override("Saved: " + path)
        self._dbg("present_save_payload: label now=", self._status.cget("text"))

    def render(self, state: UiState) -> None:
        """Render the UI state provided by the Presenter."""

        self._last_state = state
        self._dbg("render: status_text=", state.status_text, " override=", self._status_override)
        if self._status_override is None:
            status = state.status_text
            # View-only indicator for Notes mode (Presenter remains authoritative for game state)
            if self._notes_mode_active(state):
                status = status + "   [NOTES]"
            self._status.config(text=status)
            self._dbg("render: label set to presenter status=", self._status.cget("text"))
        try:
            diff_str = state.difficulty
            if diff_str not in ("easy", "medium", "hard"):
                diff_str = "easy"
            difficulty = cast(Difficulty, diff_str)
            style_str = "Modern"
            try:
                name = str(getattr(self._style, "name", ""))
                if name == "Classic":
                    style_str = "Classic"
                elif name in ("High Contrast", "HighContrast", "High-Contrast"):
                    style_str = "High Contrast"
                else:
                    style_str = "Modern"
            except Exception:
                style_str = "Modern"

            if style_str not in ("Modern", "Classic", "High Contrast"):
                style_str = "Modern"
            style_name = cast(StyleName, style_str)

            mode_str = self._content_mode
            if mode_str not in ("numbers", "animals_chatGpT"):
                mode_str = "numbers"
            content_mode = cast(ContentMode, mode_str)

            self._controls.apply_state(
                ControlsState(
                    difficulty=difficulty,
                    can_change_difficulty=bool(state.can_change_difficulty),
                    style_name=style_name,
                    content_mode=content_mode,
                )
            )
        except Exception:
            pass

        # Ensure style-driven widget visuals stay consistent
        self._apply_style_to_widgets()

        self._redraw()

    def set_key_capture_enabled(self, enabled: bool) -> None:
        """Enable/disable keyboard capture (placeholder for later focus control)."""

        # Keyboard capture currently uses bind_all; keep method for interface completeness.
        pass

    # ---------------- Internal: layout & drawing ----------------

    def _on_resize(self, _event: tk.Event) -> None:
        self._redraw()

    def _redraw(self) -> None:
        if self._last_state is None:
            return

        layout = compute_layout(self._canvas, min_cell=60, margin=10)
        if layout is None:
            return

        self._layout = layout

        # Center the controls panel to the exact grid width.
        # Height must accommodate vertical controls (e.g., Mode radio group).
        try:
            # Ensure requested geometry is up-to-date before measuring.
            self._controls.update_idletasks()
            req_h = int(self._controls.winfo_reqheight())
            panel_h = max(44, req_h)
            self._controls_panel.configure(width=layout.board_px, height=panel_h)
        except Exception:
            # Fallback: keep prior size rather than crashing.
            try:
                self._controls_panel.configure(width=layout.board_px)
            except Exception:
                pass

        self._renderer.update_style(self._style)
        self._renderer.draw(self._last_state, layout, content_mode=self._content_mode)

    # ---------------- Internal: input handling ----------------

    def _ensure_canvas_focus(self) -> None:
        try:
            self._canvas.focus_set()
        except Exception:
            pass

    def _is_selectable(self, r: int, c: int) -> bool:
        """A cell is selectable if it is not a given in the current state."""

        state = self._last_state
        if state is None:
            return True
        try:
            vm = state.board.cells[r][c]
            return not bool(getattr(vm, "given", False))
        except Exception:
            return True

    def _first_selectable(self) -> tuple[int, int] | None:
        """Return the first non-given cell (row-major), or None if none exist."""

        state = self._last_state
        if state is None:
            return (0, 0)
        try:
            for rr in range(9):
                for cc in range(9):
                    if self._is_selectable(rr, cc):
                        return rr, cc
        except Exception:
            pass
        return None

    def _selected_coord_from_state(self, state: UiState | None) -> tuple[int, int] | None:
        """Infer selected (r,c) from UiState, supporting multiple UiState layouts."""

        if state is None:
            return None

        sel = None
        try:
            sel = getattr(state, "selected", None)
        except Exception:
            sel = None

        if sel is None:
            try:
                sel = getattr(state, "selected_coord", None)
            except Exception:
                sel = None

        if isinstance(sel, tuple) and len(sel) == 2:
            try:
                r = int(sel[0])
                c = int(sel[1])
                if 0 <= r <= 8 and 0 <= c <= 8:
                    return r, c
            except Exception:
                return None

        # Fallback: infer from per-cell VM flags.
        try:
            board = getattr(state, "board", None)
            cells = getattr(board, "cells", None) if board is not None else None
            if cells is not None:
                for rr in range(9):
                    row = cells[rr]
                    for cc in range(9):
                        try:
                            if bool(getattr(row[cc], "selected", False)):
                                return rr, cc
                        except Exception:
                            pass
        except Exception:
            pass

        return None

    def _current_selected(self) -> tuple[int, int] | None:
        """Return the currently selected cell coordinate, if any."""
        return self._selected_coord_from_state(self._last_state)

    def _on_save_clicked(self) -> None:
        """Menu action: request a save from the Presenter."""

        self._dbg("_on_save_clicked: requesting save")
        self._actions.on_save_requested()
        self._dbg("_on_save_clicked: returned from presenter")

    def _on_load_clicked(self) -> None:
        """Menu action: load a previously saved game."""

        path = filedialog.askopenfilename(
            title="Load Sudoku",
            filetypes=[("Sudoku save", "*.json"), ("JSON", "*.json"), ("All files", "*.*")],
        )
        if not path:
            return

        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            messagebox.showerror("Load failed", "Unable to load file.\n\n" + str(e))
            return

        if not isinstance(data, dict):
            messagebox.showerror("Load failed", "Save file format not recognised.")
            return

        self._set_status_override("Loaded: " + path)
        self._actions.on_load_requested(data)


    def _on_controls_set_difficulty(self, value: str) -> None:
        self._actions.on_set_difficulty(value)

    def _on_controls_style_changed(self, name: str) -> None:
        # Controls panel provides one of: "Modern", "Classic", "High Contrast"
        if name == "Classic":
            try:
                from ui.styles import STYLE_CLASSIC
                self._style = STYLE_CLASSIC
            except Exception:
                self._style = STYLE_MODERN
        elif name == "High Contrast":
            try:
                from ui.styles import STYLE_HIGH_CONTRAST
                self._style = STYLE_HIGH_CONTRAST
            except Exception:
                self._style = STYLE_MODERN
        else:
            self._style = STYLE_MODERN

        self._apply_style_to_widgets()
        self._ensure_canvas_focus()
        self._redraw()

    def _on_controls_content_mode_changed(self, mode: str) -> None:
        # View-only for now; no Presenter/game logic changes yet.
        if mode not in ("numbers", "animals_chatGpT"):
            mode = "numbers"
        self._content_mode = mode
        self._ensure_canvas_focus()
        self._redraw()

    def _on_new_game_clicked(self) -> None:
        self._actions.on_new_game()

    def _on_click(self, event: tk.Event) -> None:
        if self._layout is None:
            self._layout = compute_layout(self._canvas, min_cell=60, margin=10)
        if self._layout is None:
            return
        coord = coord_from_xy(self._layout, event.x, event.y)
        if coord is None:
            return
        r, c = coord
        if not self._is_selectable(r, c):
            return
        self._actions.on_cell_clicked(coord)
        self._ensure_canvas_focus()
    def _apply_style_to_widgets(self) -> None:
        try:
            self._font_value = self._style.value_font
            self._font_given = self._style.given_font
            self._font_notes = self._style.notes_font
            self._status.configure(bg=self._style.status_bg)
        except Exception:
            pass


    # (Removed _coord_from_xy; now use coord_from_xy from ui.layout)

    def _on_key(self, event: tk.Event) -> None:
        """Translate raw Tk events into domain-level user actions."""

        ch = event.char or ""
        keysym = (event.keysym or "")

        # Navigation: arrow keys move selection, skipping givens.
        if keysym in ("Left", "Right", "Up", "Down"):
            cur = self._current_selected()
            if cur is None:
                first = self._first_selectable()
                if first is None:
                    return
                r, c = first
            else:
                r, c = cur

            dr = 0
            dc = 0
            if keysym == "Left":
                dc = -1
            elif keysym == "Right":
                dc = 1
            elif keysym == "Up":
                dr = -1
            elif keysym == "Down":
                dr = 1

            rr = r
            cc = c
            while True:
                nr = rr + dr
                nc = cc + dc
                if nr < 0 or nr > 8 or nc < 0 or nc > 8:
                    # No selectable cell in this direction
                    return
                rr = nr
                cc = nc
                if self._is_selectable(rr, cc):
                    self._actions.on_cell_clicked((rr, cc))
                    return

        # Notes toggle: Enter or Space
        if keysym in ("Return", "space"):
            self._actions.on_toggle_notes_mode()
            return

        # Block edits when the selection is a given (given cells are unselectable, but keep this as a safety net).
        cur_sel = self._current_selected()
        if cur_sel is not None:
            try:
                if not self._is_selectable(cur_sel[0], cur_sel[1]):
                    return
            except Exception:
                pass

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

    def _notes_mode_active(self, state: UiState | None) -> bool:
        try:
            return state is not None and bool(getattr(state, "notes_mode", False))
        except Exception:
            return False