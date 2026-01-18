

from __future__ import annotations

from dataclasses import asdict, is_dataclass
from typing import Any, Dict, Iterable, List, Optional, Tuple

from domain.types import Board, Cell, Digit
from application.state import GameState, History


SchemaDict = Dict[str, Any]


def serialize_history(history: History) -> SchemaDict:
    """Serialize the full undo/redo history into a JSON-safe dict.

    Notes:
        - This is pure and does not touch the filesystem.
        - Intended to be encoded with json.dumps by the caller.
    """

    return {
        "schema": "sudoku.save.v1",
        "past": [serialize_game_state(s) for s in history.past],
        "present": serialize_game_state(history.present),
        "future": [serialize_game_state(s) for s in history.future],
    }


def deserialize_history(data: SchemaDict) -> History:
    """Deserialize a History previously produced by serialize_history."""

    _require_schema(data, expected="sudoku.save.v1")

    past = tuple(deserialize_game_state(x) for x in _require_list(data, "past"))
    present = deserialize_game_state(_require_dict(data, "present"))
    future = tuple(deserialize_game_state(x) for x in _require_list(data, "future"))

    return History(past=past, present=present, future=future)


def serialize_game_state(state: GameState) -> SchemaDict:
    """Serialize a GameState into a JSON-safe dict."""

    return {
        "board": serialize_board(state.board),
        # Be forward-compatible: include any extra dataclass fields if present.
        "extras": _serialize_unknown_dataclass_fields(state, known_keys={"board"}),
    }


def deserialize_game_state(data: SchemaDict) -> GameState:
    """Deserialize a GameState previously produced by serialize_game_state."""

    board = deserialize_board(_require_dict(data, "board"))

    # Construct using only the fields we know about. If GameState evolves,
    # this keeps persistence robust.
    return GameState(board=board)


def serialize_board(board: Board) -> SchemaDict:
    """Serialize a Board into a JSON-safe dict."""

    cells = []
    for r in range(9):
        row = []
        for c in range(9):
            row.append(serialize_cell(board.cell_at(r, c)))
        cells.append(row)

    return {
        "rows": cells,
    }


def deserialize_board(data: SchemaDict) -> Board:
    """Deserialize a Board previously produced by serialize_board."""

    rows = _require_list(data, "rows")
    if len(rows) != 9:
        raise ValueError("Board must have 9 rows")

    cell_rows: List[Tuple[Cell, ...]] = []
    for r, row in enumerate(rows):
        if not isinstance(row, list) or len(row) != 9:
            raise ValueError("Each board row must be a list of 9 cells")
        cell_row: List[Cell] = []
        for c, cell_data in enumerate(row):
            if not isinstance(cell_data, dict):
                raise ValueError("Cell must be an object")
            cell_row.append(deserialize_cell(cell_data))
        cell_rows.append(tuple(cell_row))

    return Board(cells=tuple(cell_rows))


def serialize_cell(cell: Cell) -> SchemaDict:
    """Serialize a Cell into a JSON-safe dict."""

    notes_sorted = sorted(int(n) for n in cell.notes)
    return {
        "value": int(cell.value) if cell.value is not None else None,
        "given": bool(cell.given),
        "notes": notes_sorted,
    }


def deserialize_cell(data: SchemaDict) -> Cell:
    """Deserialize a Cell previously produced by serialize_cell."""

    value = data.get("value", None)
    if value is None:
        val: Optional[Digit] = None
    else:
        if not isinstance(value, int) or value < 1 or value > 9:
            raise ValueError("Cell value must be 1..9 or null")
        val = value

    given = bool(data.get("given", False))

    notes_raw = data.get("notes", [])
    if notes_raw is None:
        notes_raw = []
    if not isinstance(notes_raw, list):
        raise ValueError("Cell notes must be a list")

    notes: List[Digit] = []
    for n in notes_raw:
        if not isinstance(n, int) or n < 1 or n > 9:
            raise ValueError("Each note must be 1..9")
        notes.append(n)

    return Cell(value=val, given=given, notes=frozenset(notes))


# -----------------
# Small validators
# -----------------


def _require_schema(data: SchemaDict, expected: str) -> None:
    schema = data.get("schema")
    if schema != expected:
        raise ValueError("Unsupported save schema: " + repr(schema))


def _require_dict(data: SchemaDict, key: str) -> SchemaDict:
    v = data.get(key)
    if not isinstance(v, dict):
        raise ValueError("Expected object for key: " + key)
    return v


def _require_list(data: SchemaDict, key: str) -> List[Any]:
    v = data.get(key)
    if not isinstance(v, list):
        raise ValueError("Expected list for key: " + key)
    return v


def _serialize_unknown_dataclass_fields(obj: Any, known_keys: set[str]) -> Dict[str, Any]:
    """Capture extra dataclass fields for forward compatibility.

    We do not currently rehydrate these into GameState; they are stored so a
    future migration can recover them.
    """

    if not is_dataclass(obj):
        return {}

    raw = asdict(obj)
    extras: Dict[str, Any] = {}
    for k, v in raw.items():
        if k in known_keys:
            continue
        # Keep only json-safe primitives/containers.
        if _is_json_safe(v):
            extras[k] = v
        else:
            extras[k] = repr(v)

    return extras


def _is_json_safe(v: Any) -> bool:
    if v is None:
        return True
    if isinstance(v, (bool, int, float, str)):
        return True
    if isinstance(v, list):
        return all(_is_json_safe(x) for x in v)
    if isinstance(v, dict):
        return all(isinstance(k, str) and _is_json_safe(x) for k, x in v.items())
    return False