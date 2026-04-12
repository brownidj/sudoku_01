

# CURRENT_STATE

## Code prompt

### Architecture & Separation of Concerns
- Establish an architecture that sets explicit boundaries between UI, domain, and infrastructure layers. This should be reflected in the directory structure.
- Avoid dumping new files in the project root; just keep main.py there.
- `main.py` or `main.dart` must not contain any wiring, domain logic, or infrastructure.
- Keep UI wiring, domain logic, and infrastructure separated. Domain must not import infra or UI.
- Prefer thin orchestrators and small, focused services. Use explicit service helpers for UI side effects.
- Avoid direct dialog/widget mutations across layers; use adapters/services (for example, `CategoryManagerUIService`, `AddEditStateService`).
- Keep init/builders as composition roots; do not leak logic into UI builders.
- Prefer explicit dependencies via small dataclasses/services rather than hidden attribute reach-through.

### Readability & Maintainability
- Use clear, short functions with a single responsibility. Extract helpers when logic grows.
- Avoid `getattr`/duck typing in production flow unless truly necessary; prefer adapters/registries.
- Write defensive UI code (best-effort; never crash), but keep error handling narrow and intentional.
- Keep naming consistent with existing patterns: `*Service`, `*Controller`, `*Coordinator`, `*Effects`, `*Rules`.
- Always add explicit error types in try/catch.

### File Size Constraint
- Keep each file under 300 lines. If a file approaches 300, split it into focused modules.
- Make a script to do this at regular intervals, adjusted for the local project.

Example:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="${1:-.}"
if ! command -v rg >/dev/null 2>&1; then
  echo "rg (ripgrep) is required." >&2
  exit 1
fi
rg --files "$ROOT_DIR" \
  | rg -v "^${ROOT_DIR}/assets/" \
  | rg -v "^${ROOT_DIR}/pubspec.lock$" \
  | rg -v "^${ROOT_DIR}/ios/Runner.xcodeproj/project.pbxproj$" \
  | rg -v "^${ROOT_DIR}/macos/Runner.xcodeproj/project.pbxproj$" \
  | xargs wc -l \
  | awk '$2 != "total" && $1 > 300 {print $1, $2; found=1} END{exit found?1:0}'
```

### Testing & Refactors
- Always consider adding new tests, even small ones, and always make appropriate suggestions.
- Add small pure tests for new services/helpers when behavior might regress.
- Preserve behavior; refactors should be test-driven and avoid hidden side effects.
- Add Flutter integration tests to test the UI, especially for iOS.
- Consider using Patrol for Android UI tests.
- Remind me to run tests when appropriate.
- Remind me to run manual tests when appropriate.
- Avoid leaving brittle wrappers behind when refactoring code.
- Always start major refactoring in a new branch.

### Coding Style
- Prefer explicit imports. Avoid large inline logic inside UI event handlers.
- Keep log noise low; log failures only in hot paths.

### Output
- Make changes in one pass; keep diffs minimal and focused.
- Maintain a `CURRENT_STATE.md` file that contains this prompt at the top of the file, then the state of the code base architecture, then a report of running any tests.

### Debugging
- Add a debugging code system that allows all debug code to be turned off.
- When debug code is added, make sure it complies with this prerequisite.

### Git
- Remind me to commit and push when appropriate.
- Before doing large-scale refactoring, remind me to change to a refactoring branch.

## If a database is required

### Database requirements
- Use the built-in `sqlite3` library unless there is a strong reason otherwise.
- Organize the code clearly, with separation between:
  1. database connection/setup
  2. schema creation
  3. CRUD operations
  4. utility/helper functions
- Include clear comments throughout.
- Use parameterized queries everywhere to prevent SQL injection.
- Use context managers or another safe pattern to ensure connections and transactions are handled correctly.
- Include proper error handling for database operations.
- Design the code so it can be reused in a larger application.

### Database expectations
- Create the database file if it does not already exist.
- Define a schema using `CREATE TABLE IF NOT EXISTS`.
- Include a primary key for each table.
- Add appropriate foreign keys, unique constraints, default values, and indexes where sensible.
- Enable foreign key enforcement.
- Include a function to initialize the database schema.

### Database coding expectations
- Use classes or well-structured functions, whichever is more appropriate for clarity and maintainability.
- Include type hints where reasonable.
- Avoid overly clever abstractions; prefer readable, practical code.
- Make the design easy to extend with additional tables later.
- Return query results in a convenient format, such as tuples, dictionaries, or lightweight objects, and be consistent.

### Database functionality to include
- Connect to the SQLite database.
- Initialize schema.
- Insert records.
- Fetch one record.
- Fetch multiple records.
- Update records.
- Delete records.
- Optionally search/filter records.
- Optionally support soft delete if appropriate.

### Database testing/demo expectations
- Include a short example showing how to initialize the database and perform basic CRUD operations.
- Include sample table definitions and example usage data.

### Database output expectations
- After the code, briefly explain the structure and design decisions.
- Do not omit important implementation details.

## Code base architecture state

Assessment date: 2026-04-12

### Overall status
- The architecture is in a good state overall and largely follows the target layering (`lib/domain`, `lib/application`, `lib/app`, `lib/ui`).
- Core gaps against this prompt remain around the file-size rule (300 lines), script enforcement threshold (currently 400), and a few broad/untyped catches.

### Architecture and separation of concerns
- `main.dart` is thin and only does framework setup + `runApp`:
  - `flutter_app/lib/main.dart`
- Composition is primarily done in app-level wiring (`SudokuApp` and `SudokuController`), not in UI builders:
  - `flutter_app/lib/app/sudoku_app.dart`
  - `flutter_app/lib/app/sudoku_controller.dart`
- Domain/application imports remain one-way; no domain imports from UI/infra were found in `lib/domain` or `lib/application`.
- UI side effects are now mostly encapsulated behind UI services/coordinators (`SudokuScreenEffectsCoordinator`, `SudokuCorrectionFlowCoordinator`, `SudokuVictoryAudioService`, etc.), but `SudokuScreen` still coordinates many services directly.

### Readability and maintainability
- Naming is consistent with the requested patterns (`*Service`, `*Controller`, `*Coordinator`).
- Helper extraction is materially improved versus earlier snapshots.
- Remaining readability pressure points:
  - `flutter_app/lib/ui/sudoku_screen.dart` still acts as a heavy screen orchestrator.
  - `flutter_app/lib/ui/board_painter.dart` is still dense.
- Error handling is partially compliant:
  - Typed catch exists in some places (`on Exception catch` in `animal_asset_service.dart`).
  - Broad catches remain (`catch (_)`) in:
    - `flutter_app/lib/ui/services/app_version_service.dart`
    - `flutter_app/lib/ui/services/sudoku_victory_audio_service.dart`

### File-size constraint compliance
- Prompt target: each file must be under 300 lines.
- Current largest files:
  - `324` lines: `flutter_app/lib/ui/board_painter.dart`
  - `310` lines: `flutter_app/lib/ui/sudoku_screen.dart`
- Result: current codebase does **not** fully comply with the 300-line rule.
- Additional mismatch: `scripts/check_file_sizes.sh` currently fails only above `400` lines, so guardrail does not enforce the prompt requirement yet.

### Testing and refactor posture
- Test coverage remains broad across unit/widget tests, with additional integration/patrol paths available via:
  - `scripts/run_everything.sh`
- The script includes file-size check, `flutter test`, Android+iOS integration test, and Android patrol test.
- Integration/device-dependent suites were not run in this pass.

### Debug gating status
- Central debug gate exists:
  - `flutter_app/lib/app/app_debug.dart` (`APP_DEBUG` + `kDebugMode`)
- Some debug output remains outside `AppDebug.log`:
  - `flutter_app/lib/ui/launch_screen.dart`
  - `flutter_app/lib/ui/services/app_version_service.dart`
- This is functional but not fully unified under one debug logging path.

## Tests run

Run date: 2026-04-12

1. `./scripts/check_file_sizes.sh flutter_app`
- Result: pass (no files above the current script threshold of 400 lines).

2. `flutter test test/sudoku_board_area_test.dart`
- Result: pass (`4` tests passed).

3. `flutter test test/sudoku_victory_overlay_test.dart`
- Result: pass (`3` tests passed).

4. `flutter test test/sudoku_screen_debug_toggle_test.dart`
- Result: pass (`3` tests passed).

Notes:
- `flutter test` runs reported dependency update notices (`15 packages have newer versions incompatible with dependency constraints`), but test execution completed successfully.
- Full integration and patrol runs were not executed in this assessment pass.

## Shorebird
```zsh
cd /Users/david/PycharmProjects/Sudoku_01/flutter_app
flutter clean
flutter pub get
cd ios
pod install
cd ..
shorebird release android
shorebird release ios
```
