# Animal Sudoku Flutter App – Architecture Overview

## 1. High‑Level Structure
The app is organized into clear layers to keep responsibilities separated:

- **Application/Domain Services**: Pure logic for game rules, moves, and puzzle generation.
- **State Management**: Controllers + immutable state models that bridge domain logic to UI.
- **UI Widgets**: Composable widgets that render state and forward user actions.
- **Rendering**: Custom painter + layout helpers for board visuals and hit‑testing.
- **Assets/Media**: Cached images (animals + notes variants), icons, and style definitions.

This layered approach makes the app maintainable and reduces cross‑cutting concerns.

---

## 2. Application & Domain Layer
**Location:** `lib/application/*`, `lib/domain/*`

### Key Components
- **`GameService`**  
  Orchestrates game actions: place digit, toggle note, clear notes, validation, history.

- **`CheckService`**  
  Verifies board correctness, identifies incorrect/correct/given/solution cells.

- **`GridUtils`**  
  Utility functions for grid extraction/copy (kept small and focused).

- **Domain Ops (`domain/ops.dart`)**  
  Pure functions for board state mutation (e.g., `toggleNote`, `clearNotes`).

- **Solver (`application/solver.dart`)**  
  Backtracking solver used for check/solution.

### Maintainability Notes
- All logic is stateless and side‑effect free.
- Easy to test, and changes won’t impact UI rendering.

---

## 3. State Management
**Location:** `lib/app/*`

### Controllers
- **`SudokuController`**
  - The orchestration hub for gameplay.
  - Holds `History`, selection, conflicts, solution grids.
  - Builds `UiState` for UI consumption.
  - Dependencies injectable for testability.
- **`SettingsController`**
  - Manages content mode (animals/numbers), style, difficulty, and notes mode.
  - Persists to `PreferencesStore`.

### State Models
- **`UiState` (lib/app/ui_state.dart)**  
  Immutable state snapshot for UI.
- **`SettingsState`**  
  Persistent user settings.

### Maintainability Notes
- `SudokuController` remains the largest class but now isolated from UI widget logic.
- Injection makes unit tests feasible without heavy setup.

---

## 4. UI & Widgets
**Location:** `lib/ui/*`

### Screen & Components
- **`SudokuScreen`**
  - Main game screen.
  - Coordinates controller + UI widgets.
  - Handles candidate panel lifecycle (via `CandidateSelectionController`).

- **Extracted Widgets**
  - `TopControls`, `ActionBar`, `Legend`
  - `CandidatePanel`
  - `SudokuBoard` (board gestures + painting)
  - `LaunchScreen`

### Maintainability Notes
- Large UI responsibilities have been broken into focused, reusable widgets.
- `SudokuScreen` is now primarily orchestration, not UI complexity.

---

## 5. Rendering Layer
**Location:** `lib/ui/board_*`

### Key Parts
- **`BoardPainter`**
  - Responsible for rendering board cells, values, notes, and highlights.
  - Uses `BoardTheme` to isolate styling logic.

- **`BoardLayout`**
  - Converts gesture offsets into board coordinates.

- **`BoardTheme`**
  - Centralized decision model for background colors and highlights.

### Notes Rendering
- Notes are rendered using pre‑generated image variants:
  - `16/20/24/32 px` grayscale assets.
  - Rendered in 2x2 or 3x3 grid depending on note count.

### Maintainability Notes
- Rendering logic is cleanly separated from controller state.
- Reusable layout utilities reduce duplication.

---

## 6. Assets & Caching
**Location:** `lib/ui/animal_cache.dart`

### Cache Responsibilities
- Loads full‑size animal icons (cute/simple).
- Loads note icons (multi‑size monochrome).
- Provides per‑variant maps for fast rendering.

### Maintainability Notes
- Cache centralization avoids repeated decoding.
- Notes icons are decoupled to avoid blocking main image load.

---

## 7. Tests
**Location:** `test/*`

### Coverage
- **Domain ops**: `notes_ops_test.dart`
- **Solver**: `solver_test.dart`
- **Preferences**: `preferences_test.dart`
- **UI + Notes**: `notes_ui_test.dart`
- **Note layout selection**: `note_layout_test.dart`
- **Notes asset presence**: `notes_assets_test.dart`

### Maintainability Notes
- Critical game logic and state behaviors are tested.
- UI behavior tested in a minimal widget environment.

---

## 8. Maintainability Strengths
- **Separation of concerns** is clear and intentional.
- **Testability** improved via dependency injection and pure functions.
- **Rendering** isolated from state (painter + theme).
- **Caching** centralized and predictable.

---

## 9. Remaining Pressure Points
- `SudokuController` still aggregates many responsibilities (selection, history, game flow).
- `SudokuScreen` retains candidate panel orchestration and tooltip overlays.

These are manageable now, but should be the first refactor targets if complexity grows.

---

## 10. Suggested Future Refactors (Optional)
- Extract a **CandidateSelectionService** into app/state layer.
- Further split `SudokuController` into:
  - `GameController` (history, check/solution)
  - `UiController` (selection + note display logic)

---

## Summary
The current architecture is clean, layered, and maintainable. It supports feature growth without major rewrites, and core logic is isolated from UI details. The codebase is in strong shape for continued development.
