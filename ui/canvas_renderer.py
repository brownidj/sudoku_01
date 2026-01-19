from __future__ import annotations

import tkinter as tk
from dataclasses import dataclass
from typing import Any

from ui.styles import Style
from ui.layout import BoardLayout
from ui.animal_assets import animal_image_for
from ui.controls import ContentMode


class SudokuCanvasRenderer:
    """Pure-ish renderer for the Sudoku canvas.

    This class owns *drawing only*. It does not bind events, it does not know about
    Presenter/actions, and it does not store game state.
    """

    def __init__(self, canvas: tk.Canvas, style: Style):
        self._canvas = canvas
        self._style = style

        # Fonts are derived from Style but cached here for convenience.
        self._font_value = style.value_font
        self._font_given = style.given_font
        self._font_notes = style.notes_font

    def update_style(self, style: Style) -> None:
        self._style = style
        self._font_value = style.value_font
        self._font_given = style.given_font
        self._font_notes = style.notes_font

    def draw(self, state: Any, layout: BoardLayout, content_mode: ContentMode = "numbers") -> None:
        """Redraw the entire board using the provided UiState-like object."""

        self._canvas.delete("all")

        x0 = layout.origin_x
        y0 = layout.origin_y
        x1 = x0 + layout.board_px
        y1 = y0 + layout.board_px

        # Board background
        self._canvas.create_rectangle(x0, y0, x1, y1, outline="", fill=self._style.board_bg)

        # Cells (backgrounds, values, notes, outlines)
        self._draw_cells(state, layout, content_mode)

        # Grid lines (thin + thick)
        self._draw_grid_lines(layout)

        # Notes badge (view-only)
        if self._notes_mode_active(state):
            self._draw_notes_badge(layout)

    # ---------------- internal helpers ----------------

    def _notes_mode_active(self, state: Any) -> bool:
        try:
            return bool(getattr(state, "notes_mode", False))
        except Exception:
            return False

    def _selected_coord_from_state(self, state: Any) -> tuple[int, int] | None:
        """Infer selected (r,c) from UiState-like object."""

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

    def _draw_cells(self, state: Any, layout: BoardLayout, content_mode: ContentMode) -> None:
        ox = layout.origin_x
        oy = layout.origin_y
        cell = layout.cell

        # Colors (from style)
        color_default = self._style.cell_default
        color_peer_rowcol = self._style.cell_peer_rowcol
        color_peer_box = self._style.cell_peer_box
        color_selected = self._style.cell_selected
        color_conflict = self._style.cell_conflict
        outline_selected = self._style.outline_selected
        outline_conflict = self._style.outline_conflict

        sel = self._selected_coord_from_state(state)
        sel_r = sel[0] if sel is not None else None
        sel_c = sel[1] if sel is not None else None
        sel_box_r = (sel_r // 3) if sel_r is not None else None
        sel_box_c = (sel_c // 3) if sel_c is not None else None

        try:
            board = getattr(state, "board")
            rows = getattr(board, "cells")
        except Exception:
            return

        for r in range(9):
            row = rows[r]
            for c in range(9):
                vm = row[c]

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

                vm_selected = bool(getattr(vm, "selected", False))
                vm_conflicted = bool(getattr(vm, "conflicted", False))

                # Background precedence: conflict > selected > row/col peer > box peer > default
                if vm_conflicted:
                    bg = color_conflict
                elif vm_selected:
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
                if vm_conflicted:
                    self._canvas.create_rectangle(x0, y0, x1, y1, outline=outline_conflict, width=3)
                elif vm_selected:
                    self._canvas.create_rectangle(x0, y0, x1, y1, outline=outline_selected, width=3)

                # Value or notes
                value = getattr(vm, "value", None)
                if value is not None:
                    given = bool(getattr(vm, "given", False))
                    fill = self._style.given_color if given else self._style.value_color
                    cx = (x0 + x1) / 2
                    cy = (y0 + y1) / 2
                    font = self._font_given if given else self._font_value

                    if content_mode == "animals_chatGpT" and int(value) in (1, 2, 3, 4, 5, 6, 7, 8, 9):
                        # Draw animal face icon centered in cell.
                        # Scale target: ~70% of cell width.
                        target = max(16, int(cell * 0.70))
                        img = animal_image_for(int(value), target)
                        if img is not None:
                            self._canvas.create_image(cx, cy, image=img)
                        else:
                            # Fall back to numeric text if the asset cannot be loaded.
                            self._canvas.create_text(cx, cy, text=str(value), font=font, fill=fill)
                    else:
                        self._canvas.create_text(cx, cy, text=str(value), font=font, fill=fill)
                else:
                    notes = getattr(vm, "notes", None)
                    if notes:
                        self._draw_notes(notes, x0, y0, cell)

    def _draw_notes(self, notes: Any, x0: int, y0: int, cell: int) -> None:
        """Render notes as a 3x3 mini grid inside the cell."""

        try:
            note_set = set(int(n) for n in notes)
        except Exception:
            return

        mini = cell / 3.0
        for d in range(1, 10):
            if d not in note_set:
                continue
            rr = (d - 1) // 3
            cc = (d - 1) % 3
            cx = x0 + (cc + 0.5) * mini
            cy = y0 + (rr + 0.5) * mini
            self._canvas.create_text(
                cx,
                cy,
                text=str(d),
                font=self._font_notes,
                fill=self._style.notes_color,
            )

    def _draw_grid_lines(self, layout: BoardLayout) -> None:
        ox = layout.origin_x
        oy = layout.origin_y
        size = layout.board_px
        cell = layout.cell

        # Thin lines
        for i in range(1, 9):
            x = ox + i * cell
            y = oy + i * cell
            self._canvas.create_line(ox, y, ox + size, y, width=1, fill=self._style.grid_thin)
            self._canvas.create_line(x, oy, x, oy + size, width=1, fill=self._style.grid_thin)

        # Thick 3x3 lines (including outer border)
        for i in range(0, 10, 3):
            x = ox + i * cell
            y = oy + i * cell
            self._canvas.create_line(ox, y, ox + size, y, width=3, fill=self._style.grid_thick)
            self._canvas.create_line(x, oy, x, oy + size, width=3, fill=self._style.grid_thick)

    def _draw_notes_badge(self, layout: BoardLayout) -> None:
        bx = layout.origin_x + 6
        by = layout.origin_y + 6
        self._canvas.create_rectangle(
            bx,
            by,
            bx + 70,
            by + 22,
            outline=self._style.notes_badge_outline,
            width=2,
            fill=self._style.notes_badge_bg,
        )
        self._canvas.create_text(bx + 35, by + 11, text="NOTES", font=("TkDefaultFont", 9, "bold"))