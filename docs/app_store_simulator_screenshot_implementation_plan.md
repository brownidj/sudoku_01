# App Store Simulator Screenshot Implementation Plan

## Purpose

This plan defines how to generate repeatable App Store screenshots for **SudoKu Playtime** using the iOS Simulator.

The screenshot workflow must:

- support **iPad Pro 13-inch**
- support **iPhone 17 Pro Max**
- run **one device family at a time**
- let the user choose device family with a **switch**
- let the user choose **portrait** or **landscape**
- save output under `assets/images/screenshots/...`

The required output structure is:

```text
assets/images/screenshots/
  ipad_13/
     01_home.png
     02_drawer_open.png
     03_new_game_numbers.png
     04_new_game_animals.png
     05_new_game_butterflies.png
     06_shells_after_16_moves.png
     07_celebration.png
  iphone_69/
     01_home.png
     02_drawer_open.png
     03_new_game_numbers.png
     04_new_game_animals.png
     05_new_game_butterflies.png
     06_shells_after_16_moves.png
     07_celebration.png
```

---

## Stage 1 — Confirm Simulator Availability

The required simulators are available in the installed Simulator device list.

Confirmed available:

```text
iPad Pro 13-inch (M5)   iOS 26.5   UDID: 1446C2EF-6E1C-4498-834F-7E56131F2F21
iPhone 17 Pro Max       iOS 26.5   UDID: 1BC13A7B-A414-40A0-B061-97A159348EF8
```

Useful check command:

```zsh
xcrun simctl list devices available | grep -E "iPad Pro 13-inch|iPhone 17 Pro Max"
```

If these exact simulator runtimes disappear after an Xcode update, the script should fail early with a clear message instead of silently using a different model.

---

## Stage 2 — One Device Family At A Time

The workflow must run **one device family at a time**.

Do not attempt to produce iPhone and iPad screenshots in one run.

Required selection:

- `iphone`
- `ipad`

Recommended interface:

- a script argument or shell switch

Example:

```zsh
./scripts/capture_app_store_screenshots.sh --device iphone
./scripts/capture_app_store_screenshots.sh --device ipad
```

The script should reject invalid values and print the accepted options.

---

## Stage 3 — Orientation Must Be Selectable

Both device families must support:

- `portrait`
- `landscape`

Recommended interface:

```zsh
./scripts/capture_app_store_screenshots.sh --device iphone --orientation portrait
./scripts/capture_app_store_screenshots.sh --device iphone --orientation landscape
./scripts/capture_app_store_screenshots.sh --device ipad --orientation portrait
./scripts/capture_app_store_screenshots.sh --device ipad --orientation landscape
```

The script should:

- boot the chosen simulator
- force the requested orientation before capturing
- verify the orientation change succeeded

Useful commands:

```zsh
xcrun simctl io <udid> rotate left
xcrun simctl io <udid> rotate right
```

If orientation is difficult to reason about using rotate commands alone, reset the simulator to portrait first and then apply a deterministic rotation step.

---

## Stage 4 — Fixed Output Paths

Save files only to these directories:

```text
assets/images/screenshots/ipad_13/
assets/images/screenshots/iphone_69/
```

Mapping:

- `ipad` → `assets/images/screenshots/ipad_13/`
- `iphone` → `assets/images/screenshots/iphone_69/`

Required filenames:

```text
     01_home.png
     02_drawer_open.png
     03_new_game_numbers.png
     04_new_game_animals.png
     05_new_game_butterflies.png
     06_shells_after_16_moves.png
     07_celebration.png
```

The script should overwrite existing files for the selected target only.

It should not delete the other device family’s screenshots.

---

## Stage 5 — Device Configuration Mapping

Use exact simulator targets:

### iPad

```text
Simulator name: iPad Pro 13-inch (M5)
UDID: 1446C2EF-6E1C-4498-834F-7E56131F2F21
Output folder: assets/images/screenshots/ipad_13/
```

### iPhone

```text
Simulator name: iPhone 17 Pro Max
UDID: 1BC13A7B-A414-40A0-B061-97A159348EF8
Output folder: assets/images/screenshots/iphone_69/
```

The implementation should centralize this mapping in one place so it is easy to maintain.

Example conceptual structure:

```text
if device == ipad:
    udid = "1446C2EF-6E1C-4498-834F-7E56131F2F21"
    output_dir = "assets/images/screenshots/ipad_13"
elif device == iphone:
    udid = "1BC13A7B-A414-40A0-B061-97A159348EF8"
    output_dir = "assets/images/screenshots/iphone_69"
else:
    fail
```

---

## Stage 6 — Screenshot Output List

The screenshot set for each selected device/orientation must produce these output files:

```text
   - 01_home.png
   - 02_drawer_open.png
   - 03_new_game_numbers.png
   - 04_new_game_animals.png
   - 05_new_game_butterflies.png
   - 06_shells_after_16_moves.png
   - 07_celebration.png
```

These should map directly to deterministic in-app states plus theme selection where required, with a description of the state in the brackets:
01_home.png (Show the clean app home/start state.)
02_drawer_open.png (Show the drawer open with free-version status visible.)
03_new_game_numbers.png (Show a fresh playable puzzle immediately after starting a game with Numbers theme)
04_new_game_animals.png (Show a fresh playable puzzle immediately after starting a game with Animals theme)
05_new_game_butterflies.png (Show a fresh playable puzzle immediately after starting a game with Butterflies theme)
06_shells_after_16_moves.png (Show a partially completed puzzle with exactly 16 deterministic moves applied.)
07_celebration.png (Show a celebration state for Animals at a deterministic midpoint, not at an arbitrary animation frame.)

---

## Stage 7 — Screenshot Mode In App

The app should expose a deterministic screenshot mode using `--dart-define`.

Recommended flags:

```zsh
--dart-define=SCREENSHOT_MODE=true
--dart-define=SCREENSHOT_SCENE=home
--dart-define=SCREENSHOT_THEME=numbers
--dart-define=SCREENSHOT_DEVICE=iphone
--dart-define=SCREENSHOT_ORIENTATION=portrait
--dart-define=SCREENSHOT_MOVES=16
```

`SCREENSHOT_SCENE` should represent the UI state, not the output filename and not the theme.

Recommended scene values:

- `home`
- `drawer_open`
- `new_game`
- `partial_progress`
- `celebration`

`SCREENSHOT_THEME` should represent the active theme when a scene depends on theme selection.

Recommended theme values:

- `numbers`
- `animals`
- `butterflies`
- `shells`

Suggested Dart reads:

```dart
const screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');
const screenshotScene = String.fromEnvironment('SCREENSHOT_SCENE');
const screenshotTheme = String.fromEnvironment('SCREENSHOT_THEME');
const screenshotDevice = String.fromEnvironment('SCREENSHOT_DEVICE');
const screenshotOrientation = String.fromEnvironment('SCREENSHOT_ORIENTATION');
const screenshotMoves = int.fromEnvironment('SCREENSHOT_MOVES', defaultValue: 0);
```

This must not affect normal production gameplay unless `SCREENSHOT_MODE=true` is supplied.

Recommended mapping from output filenames to screenshot-mode inputs:

```text
01_home.png                    -> SCENE=home
02_drawer_open.png             -> SCENE=drawer_open
03_new_game_numbers.png        -> SCENE=new_game, THEME=numbers
04_new_game_animals.png        -> SCENE=new_game, THEME=animals
05_new_game_butterflies.png    -> SCENE=new_game, THEME=butterflies
06_shells_after_16_moves.png   -> SCENE=partial_progress, THEME=shells, MOVES=16
07_celebration.png             -> SCENE=celebration, THEME=animals
```

---

## Stage 8 — Deterministic Move Filling

For `06_shells_after_16_moves.png`, the app should not "play" Sudoku in a human way. It should fill correct values from the known solution grid.

Use a deterministic rule so screenshots are stable:

```text
1. Find all unfinished 3×3 blocks.
2. Prefer blocks with at least 2 empty cells.
3. Choose the block with the fewest empty cells.
4. Tie-break toward the centre.
5. If still tied, choose the upper-left-most block.
6. Fill the first empty cell in reading order from the solution grid.
7. Repeat until 16 moves have been applied.
```

This produces a believable partly completed board without randomness.

---

## Stage 9 — Automation Approach

Use a script plus integration automation.

Recommended entrypoint:

```text
flutter_app/scripts/capture_app_store_screenshots.sh
```

Responsibilities:

- validate `--device`
- validate `--orientation`
- verify the required simulator exists
- boot the selected simulator
- apply requested orientation
- launch the app in screenshot mode for each required scene/theme combination
- wait for each target state to stabilize
- capture the screenshot
- save into the correct output folder

Recommended command shape:

```zsh
./scripts/capture_app_store_screenshots.sh --device iphone --orientation portrait
./scripts/capture_app_store_screenshots.sh --device ipad --orientation landscape
```

---

## Stage 10 — Capture Mechanism

Preferred capture command:

```zsh
xcrun simctl io <udid> screenshot <output-path>
```

Use PNG output.

Before each capture:

- wait until the target UI is fully visible
- dismiss tooltips or overlays that should not appear
- ensure no transient animation frame is mid-transition unless intentionally capturing `07_celebration`

---

## Stage 11 — Validation Rules

For each generated screenshot:

- file exists in correct folder
- filename matches required sequence
- image is full simulator resolution
- no transparency
- no simulator chrome
- correct orientation
- correct device family output directory

If any screenshot fails validation, the script should fail with a clear message.

---

## Stage 12 — Recommended Implementation Order

1. Add script argument parsing for `--device` and `--orientation`.
2. Add simulator existence checks for:
   - `iPad Pro 13-inch (M5)`
   - `iPhone 17 Pro Max`
3. Create output directories:
   - `assets/images/screenshots/ipad_13/`
   - `assets/images/screenshots/iphone_69/`
4. Add screenshot mode flags in app code.
5. Implement the required output files using deterministic scene/theme inputs:
   - 01_home.png
   - 02_drawer_open.png
   - 03_new_game_numbers.png
   - 04_new_game_animals.png
   - 05_new_game_butterflies.png
   - 06_shells_after_16_moves.png
   - 07_celebration.png
6. Add screenshot capture automation.
7. Run one complete pass for:
   - `iphone portrait`
   - `iphone landscape`
   - `ipad portrait`
   - `ipad landscape`
8. Verify output files manually before App Store upload.

---

## Acceptance Criteria

The implementation is complete when:

- the script checks that the required simulator exists before running
- the user chooses exactly one device family via switch
- the user chooses portrait or landscape via switch
- screenshots are saved under `assets/images/screenshots/ipad_13/` or `assets/images/screenshots/iphone_69/`
- all seven required screenshot outputs are generated deterministically from the defined scene/theme inputs
- rerunning the same command produces the same screenshot set
