# Testing Types In This Repository

This project uses several different kinds of testing. They overlap on purpose: each layer catches a different class of problem.

## 1. Unit Tests

These are the most common tests in `flutter_app/test/`.

They focus on small pieces of logic in isolation:

- puzzle and solver behavior
- controller state transitions
- entitlement and monetization rules
- persistence and session codecs
- localization/data completeness checks
- service-layer behavior such as audio, tooltips, and victory logic

Examples:

- `flutter_app/test/solver_test.dart`
- `flutter_app/test/sudoku_controller_gameplay_test.dart`
- `flutter_app/test/premium_policy_service_test.dart`
- `flutter_app/test/l10n_arb_completeness_test.dart`

Run:

```bash
cd flutter_app
flutter test
```

Use unit tests when the risk is mostly business logic or state management.

## 2. Widget Tests

These also live in `flutter_app/test/`, but they render Flutter widgets and verify UI behavior without needing a real device.

They cover things like:

- drawer contents
- action bar behavior
- launch screen behavior
- board area layout
- premium lock messaging
- localization in widgets

Examples:

- `flutter_app/test/action_bar_test.dart`
- `flutter_app/test/launch_screen_test.dart`
- `flutter_app/test/sudoku_screen_premium_sheet_test.dart`
- `flutter_app/test/top_controls_labels_test.dart`

Use widget tests when the risk is UI composition, visibility, labels, or interaction wiring.

## 3. Golden Tests

Golden tests are snapshot-based widget tests. They compare rendered UI output against checked-in reference images.

In this repo they are mainly used for board rendering:

- `flutter_app/test/sudoku_board_golden_test.dart`
- baselines in `flutter_app/test/goldens/`
- failure diffs in `flutter_app/test/failures/`

These are useful for catching visual regressions such as:

- spacing changes
- drawing errors
- highlight state regressions
- theme/rendering drift

Run a focused golden test:

```bash
cd flutter_app
flutter test test/sudoku_board_golden_test.dart
```

Use golden tests when layout or rendering precision matters.

## 4. Integration Tests

These live in `flutter_app/integration_test/` and exercise longer app flows than a normal widget test.

Current example:

- `flutter_app/integration_test/app_flow_test.dart`

This test checks end-to-end in-app flows such as:

- launching the app
- starting and resuming games
- opening help
- opening the drawer
- switching content modes
- reaching gameplay controls

Run:

```bash
cd flutter_app
flutter test integration_test/app_flow_test.dart -d <device-id>
```

Use integration tests when the value comes from validating a user journey rather than one widget or one service.

## 5. Patrol Device Tests

These live in `flutter_app/patrol_test/` and run on real/simulated devices using Patrol.

They are the closest thing in this repo to device-driven UI automation. They are used for:

- smoke coverage
- release checklist validation
- premium lock and drawer behavior on device

Important files:

- `flutter_app/patrol_test/smoke_test.dart`
- `flutter_app/patrol_test/release_checklist_test.dart`
- `flutter_app/patrol_test/release_checklist_drawer_test.dart`
- `flutter_app/patrol_test/release_checklist_difficulties_test.dart`
- `flutter_app/patrol_test/release_checklist_themes_test.dart`

Patrol configuration is in [flutter_app/pubspec.yaml](/Users/david/PycharmProjects/Sudoku_01/flutter_app/pubspec.yaml).

Run a smoke test:

```bash
cd flutter_app
patrol test patrol_test/smoke_test.dart
```

Run the release-checklist suite:

```bash
cd flutter_app
./scripts/run_patrol_release_checklist.sh
```

Use Patrol when the question is "does this behave correctly on an actual device runtime?"

## 6. Build Validation

A successful release build is also a test.

For Android, one important gate is:

```bash
cd flutter_app
flutter build appbundle --release
```

This catches problems that ordinary tests may miss:

- release-only build failures
- asset packaging issues
- signing/configuration problems
- platform plugin packaging issues

This is especially relevant before distribution.

## 7. Manual QA And Release Checklists

Not everything is automated. Some checks are documented and run manually.

Relevant docs include:

- [docs/app_store_free_version_release_checklist.md](/Users/david/PycharmProjects/Sudoku_01/docs/app_store_free_version_release_checklist.md)
- [docs/google_play_distribution_checklist_free_and_full.md](/Users/david/PycharmProjects/Sudoku_01/docs/google_play_distribution_checklist_free_and_full.md)
- [docs/qa/S4_phase4_free_premium_validation.md](/Users/david/PycharmProjects/Sudoku_01/docs/qa/S4_phase4_free_premium_validation.md)

These cover things automated tests usually do not fully prove:

- store-readiness
- premium/free presentation
- localized copy review
- final release candidate sanity checks
- simulator/device-specific UI inspection

## How The Layers Fit Together

In practice:

- unit tests protect logic
- widget tests protect UI behavior
- golden tests protect visual output
- integration tests protect user flows
- Patrol tests protect device-level interaction
- release builds protect packaging/distribution
- manual QA protects the last-mile product quality

No single test type is enough on its own. The point of the stack is to fail early on cheap checks and reserve slower device/manual checks for higher-risk release validation.
