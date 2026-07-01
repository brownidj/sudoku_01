# SudoKu Playtime Release Checklist

## Purpose

Use this checklist before submitting the App Store build to confirm that the free version is playable, that paid features are visible but inaccessible, and that no debug-only entitlement reset path leaks into production.

## Expected Free vs Full Split

Free users should have access to:

- `EASY`
- `MEDIUM`
- Content modes: `animals`, `instruments`, `numbers`
- Basic puzzle completion flow
- Basic progress sheet showing completed puzzles count
- Restore Purchases entry point

Full Version should unlock:

- `MUCH HARDER`
- `NIGH IMPOSSIBLE`
- Extra themes: `butterflies`, `shells`, `old_opera`
- Extended progress tracking
- Personal best history
- Extra sounds and celebrations

## Patrol-Automated (Simulator)

- [x] Launch the app into free state and confirm the drawer shows `Free`.
- [x] Confirm the app is fully usable without paying.
- [x] Start a free game and confirm the main gameplay controls appear.
- [x] Confirm `MUCH HARDER` is visible in the UI for a free user.
- [x] Confirm `NIGH IMPOSSIBLE` is visible in the UI for a free user.
- [x] Tap `MUCH HARDER` and confirm the Full Version explanation sheet appears.
- [x] Tap `NIGH IMPOSSIBLE` and confirm the Full Version explanation sheet appears.
- [x] Confirm free themes `animals`, `instruments`, and `numbers` remain usable.
- [x] Confirm premium theme routing for `butterflies`.
- [x] Confirm premium theme routing for `shells`.
- [x] Confirm premium theme routing for `old_opera`.
- [x] Open the drawer and confirm locked premium entries are visible for free users.
- [x] Confirm `Progress Tracker` routes to the Full Version explanation sheet.
- [x] Confirm `Extra Themes` routes to the Full Version explanation sheet.
- [x] Confirm `Sounds & Celebrations` routes to the Full Version explanation sheet.
- [x] Confirm `Unlock Full Version` is visible.
- [x] Confirm `Restore Purchases` is visible.

Internal-only simulator automation candidates:

- [ ] Debug reset flow: enable debug tools, reset `Full` to `Free`, and re-run locked-feature checks.
- [ ] Release-build smoke: confirm the release build does not expose the `Debug` drawer section.

## Manual-Only

### Preflight

- [x] Confirm the App Store candidate is a release build.
- [x] Confirm the release build does **not** expose debug tools.
- [x] Confirm the release build does **not** enable `APP_DEBUG`.
- [x] Confirm the release build does **not** enable `ENABLE_RESET_TO_FREE`.
- [x] Confirm the iOS product id is still `premium_unlock`.
- [x] Run the simulator-based premium-gating automated tests before physical-device QA.

Suggested automated checks:

```bash
cd flutter_app
flutter test \
  test/premium_policy_service_test.dart \
  test/sudoku_screen_flow_actions_test.dart \
  test/sudoku_screen_lock_help_test.dart \
  test/sudoku_controller_startup_test.dart \
  test/sudoku_victory_overlay_test.dart \
  test/sudoku_victory_overlay_service_test.dart \
  test/sudoku_board_golden_test.dart \
  test/sudoku_screen_debug_toggle_test.dart
./scripts/check_premium_policy_usage.sh flutter_app
```

### Fresh Install Device Pass

- [x] Delete the app from the test device.
- [x] Install the App Store candidate fresh.
- [x] Launch the app without restoring any purchase.

### Free Gameplay Checks

- [x] Start a new `EASY` game and confirm it opens and plays normally.
- [x] Start a new `MEDIUM` game and confirm it opens and plays normally.
- [x] Complete at least one free puzzle and confirm the completion flow works.
- [x] Open the progress sheet in free mode and confirm it shows only free-safe progress information.
- [x] Confirm the free progress sheet does not expose premium-only best-time or extended history details.

### Purchase and Restore Safety Checks

- [x] From at least one locked entry point, open the purchase flow and cancel it.
- [x] Confirm cancellation leaves the app in `Free` state.
- [x] Confirm a cancelled purchase does not unlock any premium difficulty, theme, or metric.
- [x] If a previous purchase exists on the Apple ID, use `Restore Purchases` and confirm Full Version unlocks correctly.
- [x] If no previous purchase exists, confirm `Restore Purchases` does not falsely unlock Full Version.

### Post-Purchase Regression Checks

- [x] After a successful purchase or restore, confirm the drawer status changes from `Free` to `Full`.
- [x] Confirm `MUCH HARDER` and `NIGH IMPOSSIBLE` now open normally.
- [x] Confirm `butterflies`, `shells`, and `old_opera` can now be selected.
- [x] Confirm extended progress details become visible after Full Version is active.
- [x] Confirm the premium-only locked drawer items no longer appear as locked.

### Secret Reset Path For Retesting

This path is for internal QA only. It must not be reachable in the App Store production build.

- [x] Use an internal build with debug tools enabled.
- [x] Enable both `APP_DEBUG` and `ENABLE_RESET_TO_FREE` for that build, or use a debug build where those flags default on.
- [x] Launch the app and unlock or restore Full Version first.
- [x] Tap the version label **7 times within 4 seconds**.
- [x] Open the drawer.
- [x] Scroll to the `Debug` section.
- [x] Tap `Reset Full Version (Debug)`.
- [x] Confirm the drawer status returns to `Free`.
- [x] Re-run the locked-feature checks after reset.

### Production Safety Signoff

- [x] Confirm the App Store release build does not show a `Debug` section in the drawer.
- [x] Confirm the App Store release build does not expose `Reset Full Version (Debug)`.
- [x] Confirm there is no hidden path that downgrades or upgrades entitlement locally in production.
- [x] Capture screenshots or notes for free-state, locked-state, purchase-cancel, restore, and post-reset verification.
- [x] Do not submit until every item above has been manually checked on a real iPhone or iPad.

## Submit In App Store Connect

Use this once all checklist items above are complete.

### Prepare The Build

- [x] Archive the release build from Xcode or your normal release pipeline.
- [x] Upload the archive to App Store Connect.
- [x] Wait for the build to finish processing in App Store Connect.
- [x] Confirm the uploaded build number matches the intended release candidate.

### Open The App Version

- [ ] Sign in to App Store Connect with an `Account Holder`, `Admin`, or `App Manager` role.
- [ ] Open `Apps`.
- [ ] Select `SudoKu Playtime`.
- [ ] In the left sidebar, select the app version you want to submit.

### Complete Metadata

- [ ] Confirm the version number is correct.
- [ ] Confirm subtitle, description, keywords, support URL, and marketing URL are complete.
- [ ] Confirm screenshots and app previews are present for the required device sizes.
- [ ] Confirm age rating, category, and content rights are complete.
- [ ] Confirm pricing and availability are correct.
- [ ] Confirm App Privacy answers are complete and current.
- [ ] Confirm export compliance is complete.
- [ ] Confirm the in-app purchase metadata for `premium_unlock` is complete if it is being submitted with this version.

### Attach The Build

- [ ] Scroll to the `Build` section on the app version page.
- [ ] Select the correct processed build for this version.
- [ ] Confirm the selected build is the release candidate you tested.

### App Review Information

- [ ] Confirm App Review contact details are filled in.
- [ ] Provide review notes that explain the app clearly.
- [ ] Include the internal review note that the free version intentionally shows premium features in a locked state.
- [ ] If Apple needs to verify premium behavior, explain how `premium_unlock` is expected to work.
- [ ] Do not include the internal debug reset gesture in review notes for the production build.

### Add For Review

- [ ] Click `Add for Review` in the top-right.
- [ ] If prompted, add the app version to a new draft submission unless you intentionally want to combine it with another item.
- [ ] Confirm the app version status changes to `Ready for Review`.

### Submit For Review

- [ ] Open the draft submission.
- [ ] Review all included items one final time.
- [ ] Click `Submit for Review`.
- [ ] Confirm the submission status changes to `Waiting for Review`.

### After Submission

- [ ] Monitor App Store Connect for status changes such as `In Review`, `Rejected`, or `Pending Apple Release`.
- [ ] If Apple raises questions, respond in the Resolution Center.
- [ ] If you must change the build or metadata materially, remove the submission from review and resubmit.

Reference:
- Apple App Store Connect Help: [Submit an app](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)
- Apple App Store Connect Help: [Overview of submitting for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/overview-of-submitting-for-review/)
- Apple App Store Connect Help: [Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase)

## Running Patrol

Current Patrol specs:

- `flutter_app/patrol_test/release_checklist_drawer_test.dart`
- `flutter_app/patrol_test/release_checklist_difficulties_test.dart`
- `flutter_app/patrol_test/release_checklist_themes_test.dart`

Run it on an explicit iOS simulator:

```bash
cd flutter_app
flutter devices
./scripts/run_patrol_release_checklist.sh <simulator-id>
```

If you omit the simulator id, the script uses the current default:

```bash
cd flutter_app
./scripts/run_patrol_release_checklist.sh
```

Equivalent manual commands:

```bash
cd flutter_app
patrol test --target patrol_test/release_checklist_drawer_test.dart --device <simulator-id>
patrol test --target patrol_test/release_checklist_difficulties_test.dart --device <simulator-id>
patrol test --target patrol_test/release_checklist_themes_test.dart --device <simulator-id>
```

Useful notes:

- Patrol should be run against a clean free-state simulator install when you want the free-user checklist behavior.
- The helper script boots the simulator first and runs the three checklist specs sequentially.
- Physical iPhone or iPad checks remain manual for this release checklist.
- Real App Store purchase confirmation and restore flows remain manual even if the UI around them is automated.
