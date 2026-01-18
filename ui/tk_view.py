from __future__ import annotations


import json
import time
import tkinter as tk
from tkinter import filedialog, messagebox
from typing import Literal

from ui.contracts import IView, IUserActions, UiState

# Set True temporarily to debug UI wiring.
DEBUG_UI = True


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

        # Menu bar
        self._menubar = tk.Menu(master)
        self._file_menu = tk.Menu(self._menubar, tearoff=0)
        self._file_menu.add_command(label="Save…", command=self._on_save_clicked)
        self._file_menu.add_command(label="Load…", command=self._on_load_clicked)
        self._menubar.add_cascade(label="File", menu=self._file_menu)
        master.config(menu=self._menubar)

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
        # View-local transient status override (e.g. save/load confirmations)
        self._status_override: str | None = None
        self._status_override_job: str | None = None

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
        if self._status_override_job is not None:
            try:
                self.after_cancel(self._status_override_job)
            except Exception:
                pass
            self._status_override_job = None

        if ms > 0:
            self._status_override_job = self.after(ms, self._clear_status_override)

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
            try:
                if bool(getattr(state, "notes_mode", False)):
                    status = status + "   [NOTES]"
            except Exception:
                pass
            self._status.config(text=status)
            self._dbg("render: label set to presenter status=", self._status.cget("text"))
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

        # Notes mode badge (view-only)
        try:
            if state is not None and bool(getattr(state, "notes_mode", False)):
                bx = self._origin_x + 6
                by = self._origin_y + 6
                self._canvas.create_rectangle(bx, by, bx + 70, by + 22, outline="#1e5aa8", width=2, fill="#cfe8ff")
                self._canvas.create_text(bx + 35, by + 11, text="NOTES", font=("TkDefaultFont", 9, "bold"))
        except Exception:
            pass

    def _draw_cells(self, state: UiState) -> None:
        cell = self._cell
        ox = self._origin_x
        oy = self._origin_y

        # Colors (layered + distinct)
        color_default = "white"
        color_peer_rowcol = "#eef7ff"   # very light blue
        color_peer_box = "#f2f0ff"      # very light lavender
        color_selected = "#cfe8ff"      # light blue
        color_conflict = "salmon"       # conflict fill
        outline_selected = "#1e5aa8"
        outline_conflict = "#a00000"

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

        sel_r = None
        sel_c = None
        if isinstance(sel, tuple) and len(sel) == 2:
            try:
                sel_r = int(sel[0])
                sel_c = int(sel[1])
            except Exception:
                sel_r = None
                sel_c = None

        sel_box_r = (sel_r // 3) if sel_r is not None else None
        sel_box_c = (sel_c // 3) if sel_c is not None else None

        for r in range(9):
            for c in range(9):
                vm = state.board.cells[r][c]

                x0 = ox + c * cell
                y0 = oy + r * cell
                x1 = x0 + cell
                y1 = y0 + cell

                # Peer shading derived from current selection.
                peer_rowcol = False
                peer_box = False
                if sel_r is not None and sel_c is not None:
                    if (r == sel_r) or (c == sel_c):
                        peer_rowcol = True
                    if sel_box_r is not None and sel_box_c is not None:
                        if (r // 3 == sel_box_r) and (c // 3 == sel_box_c):
                            peer_box = True

                # Background precedence: conflict > selected > row/col peer > box peer > default
                if vm.conflicted:
                    bg = color_conflict
                elif vm.selected:
                    bg = color_selected
                elif peer_rowcol:
                    bg = color_peer_rowcol
                elif peer_box:
                    bg = color_peer_box
                else:
                    bg = color_default

                # Draw cell background
                self._canvas.create_rectangle(x0, y0, x1, y1, outline="", fill=bg)

                # Strong outlines (selected/conflict)
                if vm.conflicted:
                    self._canvas.create_rectangle(x0, y0, x1, y1, outline=outline_conflict, width=3)
                elif vm.selected:
                    self._canvas.create_rectangle(x0, y0, x1, y1, outline=outline_selected, width=3)

                # Content
                if vm.value is not None:
                    fill = "#111111" if vm.given else "#222222"
                    self._canvas.create_text(
                        (x0 + x1) / 2,
                        (y0 + y1) / 2,
                        text=str(vm.value),
                        font=self._font_given if vm.given else self._font_value,
                        fill=fill,
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

    def _current_selected(self) -> tuple[int, int] | None:
        """Return the currently selected cell coordinate, if any."""

        state = self._last_state
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

        # Fallback: some UiState variants may not expose a selected coordinate field.
        # In that case, infer it from the per-cell VM flags.
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

        # Navigation: arrow keys move selection.
        if keysym in ("Left", "Right", "Up", "Down"):
            cur = self._current_selected()
            if cur is None:
                r, c = 0, 0
            else:
                r, c = cur

            if keysym == "Left":
                c = max(0, c - 1)
            elif keysym == "Right":
                c = min(8, c + 1)
            elif keysym == "Up":
                r = max(0, r - 1)
            elif keysym == "Down":
                r = min(8, r + 1)

            self._actions.on_cell_clicked((r, c))
            return

        # Notes toggle: Enter or Space
        if keysym in ("Return", "space"):
            self._actions.on_toggle_notes_mode()
            return

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
