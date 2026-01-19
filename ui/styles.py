from dataclasses import dataclass


@dataclass(frozen=True)
class Style:
    # Board
    board_bg: str

    # Cells
    cell_default: str
    cell_selected: str
    cell_peer_rowcol: str
    cell_peer_box: str
    cell_conflict: str

    outline_selected: str
    outline_conflict: str

    # Grid lines
    grid_thin: str
    grid_thick: str

    # Text
    value_color: str
    given_color: str
    notes_color: str

    # Fonts (logical sizes, Tk still resolves family)
    value_font: tuple
    given_font: tuple
    notes_font: tuple

    # Status / badges
    status_bg: str
    notes_badge_bg: str
    notes_badge_outline: str

STYLE_MODERN = Style(
    board_bg="white",

    cell_default="white",
    cell_selected="#cfe8ff",
    cell_peer_rowcol="#eef7ff",
    cell_peer_box="#f2f0ff",
    cell_conflict="#f6a5a5",

    outline_selected="#1e5aa8",
    outline_conflict="#a00000",

    grid_thin="#b0b0b0",
    grid_thick="#404040",

    value_color="#222222",
    given_color="#111111",
    notes_color="#555555",

    value_font=("TkDefaultFont", 18, "normal"),
    given_font=("TkDefaultFont", 18, "bold"),
    notes_font=("TkDefaultFont", 9, "normal"),

    status_bg="#f5f5f5",
    notes_badge_bg="#cfe8ff",
    notes_badge_outline="#1e5aa8",
)

STYLE_CLASSIC = Style(
    board_bg="#faf7f2",

    cell_default="#faf7f2",
    cell_selected="#e6ddc6",
    cell_peer_rowcol="#f1ead9",
    cell_peer_box="#ede4cf",
    cell_conflict="#e6a0a0",

    outline_selected="#6b5b3e",
    outline_conflict="#8b0000",

    grid_thin="#8c7b5a",
    grid_thick="#3e3626",

    value_color="#2b2b2b",
    given_color="#1a1a1a",
    notes_color="#6b6b6b",

    value_font=("TkDefaultFont", 18, "normal"),
    given_font=("TkDefaultFont", 18, "bold"),
    notes_font=("TkDefaultFont", 9, "normal"),

    status_bg="#efe9dc",
    notes_badge_bg="#e6ddc6",
    notes_badge_outline="#6b5b3e",
)

STYLE_HIGH_CONTRAST = Style(
    board_bg="white",

    cell_default="white",
    cell_selected="#ffff99",
    cell_peer_rowcol="#e0e0e0",
    cell_peer_box="#d0d0d0",
    cell_conflict="#ff6666",

    outline_selected="black",
    outline_conflict="black",

    grid_thin="black",
    grid_thick="black",

    value_color="black",
    given_color="black",
    notes_color="#333333",

    value_font=("TkDefaultFont", 20, "normal"),
    given_font=("TkDefaultFont", 20, "bold"),
    notes_font=("TkDefaultFont", 10, "normal"),

    status_bg="#e0e0e0",
    notes_badge_bg="#ffff99",
    notes_badge_outline="black",
)

DEFAULT_STYLE = STYLE_MODERN



