

from __future__ import annotations

from dataclasses import dataclass
import tkinter as tk


@dataclass(frozen=True)
class BoardLayout:
    """Immutable layout for a 9x9 Sudoku board rendered on a Tk Canvas."""

    origin_x: int
    origin_y: int
    cell: int
    board_px: int


def compute_layout(canvas: tk.Canvas, min_cell: int = 60, margin: int = 10) -> BoardLayout | None:
    """Compute a square 9x9 board layout that fits within the current canvas size.

    Args:
        canvas: The Tkinter Canvas to render into.
        min_cell: Minimum cell size in pixels.
        margin: Minimum outer margin around the board in pixels.

    Returns:
        BoardLayout if canvas has a usable size; otherwise None.
    """

    try:
        w = int(canvas.winfo_width())
        h = int(canvas.winfo_height())
    except Exception:
        return None

    # When the window first appears, Tk may report 1x1 briefly.
    if w <= 2 or h <= 2:
        return None

    usable_w = max(0, w - 2 * margin)
    usable_h = max(0, h - 2 * margin)
    board_px = min(usable_w, usable_h)

    if board_px <= 0:
        return None

    cell = max(int(min_cell), int(board_px // 9))
    board_px = int(cell * 9)

    origin_x = int((w - board_px) // 2)
    origin_y = int((h - board_px) // 2)

    return BoardLayout(origin_x=origin_x, origin_y=origin_y, cell=cell, board_px=board_px)


def coord_from_xy(layout: BoardLayout, x: int, y: int) -> tuple[int, int] | None:
    """Map canvas x/y to a Sudoku (row, col) coordinate.

    Returns None when (x,y) is outside the board.
    """

    if x < layout.origin_x or y < layout.origin_y:
        return None

    rel_x = x - layout.origin_x
    rel_y = y - layout.origin_y

    if rel_x < 0 or rel_y < 0:
        return None

    if rel_x >= layout.board_px or rel_y >= layout.board_px:
        return None

    c = int(rel_x // layout.cell)
    r = int(rel_y // layout.cell)

    if r < 0 or r > 8 or c < 0 or c > 8:
        return None

    return r, c