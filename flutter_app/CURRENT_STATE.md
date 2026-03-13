# Animal Sudoku Flutter App – Current Architecture State

## 1. High-Level Structure
The app is currently organized into four clear layers:

- **Domain/Application**: pure game rules, solver, puzzle generation, and board mutation
- **App/State**: orchestration, session persistence, settings, UI-facing state mapping
- **UI**: screens, widgets, UI-only coordinators/services, rendering
- **Assets/Rendering**: animal image loading, board painting, style/theme selection

The structure now matches the original architecture goals more closely than before:

- `main.dart` composition remains thin
- domain code does not import UI or persistence
- UI side effects are mostly behind small coordinators/services
- files are kept under the 400-line cap enforced by script

---

## 2. Domain and Application Layer
**Location:** `lib/application/*`, `lib/domain/*`

### Key Components
- **`GameService`**
  Owns board-edit operations, history transitions, undo, and new-game creation.
- **`CheckService`**
  Computes correctness markers used by check/solution flows.
- **`solver.dart`**
  Backtracking solver used by check/solution and puzzle support.
- **Domain ops**
  Pure board mutation functions for note toggling, clearing, and digit placement.

### Current Assessment
- This layer remains the cleanest part of the codebase.
- Logic is still mostly pure and testable.
- Dependencies remain one-way: domain/application does not depend on app/UI code.

---

## 3. App/State Layer
**Location:** `lib/app/*`

This layer has improved substantially since the earlier assessment.

### Controller Split
- **`SudokuController`**
  Now a thin facade and compatibility surface for the UI/tests.
  It wires dependencies and delegates to smaller controllers.
- **`GameController`**
  Owns runtime game/session flow:
  - startup/resume
  - history ownership
  - check/solution
  - correction flows
  - difficulty and puzzle mode transitions
  - debug scenario loading
- **`UiController`**
  Owns UI-driven interaction flow:
  - cell selection
  - digit/clear/place dispatch
  - notes mode toggling
  - content/style/animal-style changes

### Supporting Services
- **`SudokuControllerActionService`**
  Encapsulates gameplay actions that mutate runtime state.
- **`SudokuRuntimeStateService`**
  Encapsulates runtime-state helpers such as state mapping, reset helpers, and restored-settings application.
- **`CorrectionRecoveryService`**
  Owns dead-cell correction analysis and recovery selection.
- **`CandidateSelectionService`**
  App-layer holder for candidate-panel selection state; moved out of UI.
- **`ControllerStartupCoordinator`**
  Handles initial load/resume orchestration.
- **`GameSessionService` / `GameSessionCodec`**
  Persist and restore session state, including queued save flushing.
- **`SettingsController`**
  Persists and exposes user settings.

### State Models
- **`SudokuRuntimeState`**
  Explicit mutable runtime bag for game/session state.
- **`UiState`**
  Immutable UI-facing snapshot.
- **`SettingsState`**
  Immutable user-settings snapshot.

### Current Assessment
This layer now aligns much better with the intended architecture:

- orchestration is split into focused controllers/services
- explicit dependencies replaced most reach-through and `part`-file mutation patterns
- the old `sudoku_controller_internal.dart` split is gone
- the main facade is small again

Remaining weakness:
- `GameController` is improved, but it is still the densest orchestration class and the next likely place to accumulate policy if left unchecked

---

## 4. UI Layer
**Location:** `lib/ui/*`

### Main Screen
- **`SudokuScreen`**
  Now acts primarily as a composition/orchestration widget.
  It still owns some UI-only coordination:
  - candidate panel lifecycle hookup
  - tooltip overlays
  - debug tap gesture
  - correction prompt scheduling

### UI Helpers and Coordinators
- **`CandidatePanelCoordinator`**
  UI-only behavior for showing/hiding/refreshing the candidate panel.
- **`CorrectionPromptService`**
  Dialog scheduling/display for correction prompts.
- **`DebugToggleService`**
  Version-tap debug unlock logic.
- **`TooltipOverlayService`**
  Overlay tooltip behavior.
- **`AnimalAssetService`**
  Loads/caches the UI image bundle used by the screen.

### Widgets
- `SudokuBoardArea`
- `SudokuDrawer`
- `TopControls`
- `ActionBar`
- `Legend`
- `LaunchScreen`
- `HelpDialog`

### Current Assessment
- `SudokuScreen` is much smaller and cleaner than before.
- Candidate selection state is no longer incorrectly owned by the UI layer.
- UI logic is now mostly coordination rather than business logic.

Remaining weakness:
- `SudokuScreen` still coordinates several UI services directly, so it is not completely “dumb”

---

## 5. Rendering and Assets
**Location:** `lib/ui/board_*`, `lib/ui/animal_cache.dart`, `lib/ui/styles.dart`

### Key Parts
- **`BoardPainter`**
  Renders values, notes, selection, corrections, correctness states, and animals.
- **`BoardLayout`**
  Converts screen offsets to board coordinates.
- **`BoardTheme`**
  Encapsulates board visual styling decisions.
- **`AnimalCache`**
  Resolves animal display names and cached image access patterns.

### Current Assessment
- Rendering remains well separated from state orchestration.
- Custom painting concerns have not leaked back into controllers.
- Asset loading is handled through dedicated UI services/cache paths.

---

## 6. Testing
**Location:** `test/*`, `integration_test/*`, `patrol_test/*`

### Coverage Strengths
- domain mutation behavior
- solver behavior
- preferences persistence
- session persistence and save flushing
- correction recovery
- startup/resume flows
- gameplay flows
- notes UI behavior
- candidate panel behavior
- runtime-state helper behavior
- launch/play flows
- drawer/help flows
- board tooltip flows
- resume vs new-game flows

### Current Assessment
- The refactors were supported by small focused tests rather than only large widget tests.
- New helper/service layers now have direct coverage.
- The codebase is in a better position for test-driven extractions than it was previously.

### Current Regime
- **Unit and widget tests** remain in `test/*` and cover most pure logic, controller/services behavior, and focused widget interactions.
- **Flutter integration tests** now live in `integration_test/*` and are the primary end-to-end regression layer for normal app behavior on both Android and iOS.
  Current coverage includes:
  - launch and play
  - drawer and help
  - board tooltips
  - resume saved session
  - new game vs saved session
- **Patrol tests** remain in `patrol_test/*`, but their role is narrower:
  - Android coverage remains supported
  - iOS Patrol is reserved for flows that must touch native/system UI
  - for ordinary Flutter UI flows, `integration_test` is the preferred path because it is more stable on iOS

### Execution
- The repo now supports a single full-run script from `flutter_app/`:
  - `./scripts/run_everything.sh`
- That script runs:
  - file-size checks
  - `flutter clean`
  - `flutter pub get`
  - `pod install`
  - `flutter test`
  - Flutter integration tests
  - Patrol tests for Android and iOS
- iOS execution is intentionally split:
  - Flutter integration tests run on the normal working simulator
  - iOS Patrol runs on a latest-runtime simulator, because Patrol’s iOS destination handling is stricter and more brittle than standard Flutter integration testing

---

## 7. File Size and Structural Guardrails
The repo now has an explicit file-size guard:

- `scripts/check_flutter_file_sizes.sh`
- `flutter_app/scripts/check_file_sizes.sh` (local wrapper for running from `flutter_app/`)
- `flutter_app/scripts/run_everything.sh` (full verification entrypoint)

This enforces the agreed `> 400 lines` failure threshold and is currently passing for `flutter_app`.

### Current Assessment
- This is an important improvement because the architecture is now supported by an enforcement mechanism, not just convention.

---

## 8. Current Strengths
- Layering is materially better than the earlier state.
- `SudokuController` is now a thin facade instead of a large orchestration hub.
- `GameController` / `UiController` separation is in place.
- Candidate selection state has been moved into the app/state layer.
- The old controller `part` split has been replaced by explicit services.
- Runtime state is explicit rather than spread across many private controller fields.
- Session persistence is more robust because pending saves can be flushed.
- Test coverage followed the refactors instead of being left behind.

---

## 9. Remaining Pressure Points
These are the main areas to watch next:

### `GameController`
It is now within the size cap and clearly better structured, but it still concentrates:
- startup flow
- debug scenario flow
- undo behavior
- difficulty/puzzle-mode transitions
- save/render triggering

If complexity grows further, this should be split by workflow rather than by arbitrary file split.

### `SudokuScreen`
The screen is much cleaner, but it still wires together:
- candidate panel interactions
- correction prompt scheduling
- tooltip display
- debug gesture handling

This is acceptable today, but future UI features should continue to land in focused services/coordinators rather than back into the screen.

### Settings/UI action overlap
`UiController` is appropriately small, but some “display setting” actions still directly proxy `SettingsController`. That is fine for now, though if settings-related UI flows grow, they may deserve a dedicated app-layer coordinator.

---

## 10. Recommended Next Refactors
Only if complexity continues to grow:

1. Extract a small `GameFlowEffects` or similarly named helper from `GameController` for save/render/status triggering.
2. Move more `SudokuScreen` prompt/overlay orchestration behind a single screen-level coordinator if additional overlays or dialogs are added.
3. Add direct tests for `UiController` and `GameController` behavior if those classes grow significantly.

---

## Summary
The architecture is in a meaningfully better state than the previous snapshot.

The biggest earlier issues have been addressed:
- thin facade controller restored
- app-layer candidate selection service added
- controller responsibilities split into `GameController` and `UiController`
- explicit services replace internal mutation helpers
- file-size guard is active

The codebase is now aligned with the intended architecture to a much greater degree. The main remaining concern is not structural failure, but preventing `GameController` and `SudokuScreen` from becoming the next aggregation points as new features are added.
