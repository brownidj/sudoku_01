# Internationalisation Plan

This document outlines a safe, incremental strategy to internationalise the Flutter app.

## Progress status

- [x] Phase 1: Inventory and centralize strings (first high-impact pass completed)
- [x] Phase 2: Enable Flutter localization (`gen_l10n`) and ARB scaffolding
- [x] Phase 3: Migrate strings to ARB keys
- [x] Phase 4: Wire app localization
- [~] Phase 5: Add additional languages (locale files added for Japanese, German, French, Italian, Portuguese)
- [~] Phase 6: Full localization QA pass across all screens/modes

## Goal

Move from hard-coded English UI text to locale-based translations, while keeping behavior stable and tests reliable.

## Recommended approach

Use Flutter's built-in localization tooling (`gen_l10n`) and ARB files.

Do this in phases so we avoid a large risky rewrite.

## Phase 1: Inventory and centralize strings

1. Find all user-facing strings in:
   - `flutter_app/lib/ui/**`
   - `flutter_app/lib/app/**` (messages surfaced in UI)
   - any dialog/sheet/snackbar/tooltip text
2. Create one temporary central strings layer (for example `flutter_app/lib/ui/ui_strings.dart`).
3. Replace inline literals with references from that layer.

Status:
- Completed for key gameplay and launch surfaces (action bar, metadata row, help, start instruction, launch hints/title/buttons).
- Remaining: continue extraction of lower-frequency strings in services/dialogs.

### What counts as user-facing text

- Button labels (`Notes`, `Undo`, `Clear`, etc.)
- Tooltips and long-press hints
- Snackbars/toasts
- Dialog/sheet titles and body text
- Dropdown labels
- Any instructional copy

## Phase 2: Enable Flutter localization

1. In `pubspec.yaml`, enable Flutter localization support (if not already):
   - `flutter_localizations` in dependencies
   - `generate: true` under `flutter`
2. Add `l10n.yaml` (optional, but recommended for explicit config).
3. Create ARB files under `flutter_app/lib/l10n/`:
   - `app_en.arb` (source language)
4. Define stable semantic keys (example: `tooltip_clear_tile`, not `text_14`).

Status:
- Completed.
- `flutter_localizations` + `flutter.generate` enabled.
- ARB files present for English and Japanese.

## Phase 3: Migrate strings to ARB keys

1. Move values from temporary strings layer into `app_en.arb`.
2. Replace temporary references with `AppLocalizations.of(context)!....`.
3. For dynamic text, use placeholders:
   - Example: `Corrections: {count}`
4. For count-based text, use ICU plurals in ARB.

Status:
- Completed.
- Centralized `UiStrings` resolves from generated localizations for UI presentation text.
- App-layer status messages surfaced via `render(...)` are now localized via ARB keys using locale-aware lookup (`l10n_lookup.dart`), including:
  - `game_configuration_service.dart`
  - `game_controller.dart`
  - `sudoku_resolution_action_service.dart`
  - `sudoku_gameplay_action_service.dart`
- UI-layer migration coverage includes action bar, metadata row, board/help/start overlays, launch screen, dialogs/sheets/snackbars, premium explainer, drawer sections, top controls, and info sheet.

## Phase 4: Wire app localization

In `MaterialApp`:

1. Add `localizationsDelegates` including:
   - `AppLocalizations.delegate`
   - `GlobalMaterialLocalizations.delegate`
   - `GlobalWidgetsLocalizations.delegate`
   - `GlobalCupertinoLocalizations.delegate`
2. Add `supportedLocales`.
3. Optionally add locale resolution behavior if needed.

Status:
- Completed.
- `MaterialApp` wiring includes delegates, supported locales, localized app title, explicit locale resolution fallback to English for unsupported locales, and persisted in-app language override support.
- App locale behavior now supports:
  - default to system language when no override exists
  - persist and apply user-selected in-app language
  - reset action to clear override and return to system language
- Added localization wiring test coverage in `test/sudoku_app_localization_test.dart` for:
  - Japanese locale selection when available
  - English fallback when the device locale is unsupported
  - persisted language override behavior and reset-to-system behavior

## Phase 5: Add additional languages

1. Create per-locale ARB files, e.g.:
   - `app_es.arb`
   - `app_fr.arb`
2. Translate values only, keep keys/placeholders identical.
3. Regenerate localization outputs.

Status:
- Added locale ARB files:
  - `app_ja.arb`
  - `app_de.arb`
  - `app_fr.arb`
  - `app_it.arb`
  - `app_pt.arb`
- `gen_l10n` now generates these locales into `AppLocalizations.supportedLocales`.
- Next step for full Phase 5 completion: replace placeholder English strings in new locale files with reviewed native translations.

## Phase 6: Test and QA

1. Run existing tests and update only text assertions that are expected to vary.
2. Prefer test `Key`s/semantics for robustness over raw text matching where possible.
3. Add localization coverage:
   - smoke test for locale switching
   - key screens in at least one non-English locale
4. Manually verify:
   - truncation/overflow on small screens
   - long strings in tooltips/dialogs/buttons
   - multiline spacing

Status:
- Automated QA coverage expanded and passing:
  - `sudoku_app_localization_test.dart`: locale selection + unsupported-locale fallback
  - `localization_qa_test.dart`: launch screen renders across `en/ja/de/fr/it/pt` locales; Japanese help dialog and progress sheet localization assertions
  - Full `flutter test` suite passes with localization changes.
- Outstanding manual/device QA remains:
  - visual review for truncation/wrapping across very small screens and tablets
  - locale-by-locale copy review for new `de/fr/it/pt` files (currently placeholder English content)
  - patrol/device flow checks in non-English locales

## Suggested key naming style

Use domain-based keys:

- `action.clear`
- `action.undo`
- `tooltip.notes`
- `tooltip.clear_tile`
- `label.corrections_count`
- `dialog.help_title`

(Use whichever key convention you prefer, but keep it consistent.)

## Practical migration notes for this repo

- The app currently has many inline tooltip/hint strings in widgets and services.
- Keep all gameplay logic unchanged during i18n migration; only text sources should move.
- Keep patrol/widget tests stable by asserting behavior and key presence where possible.

## Definition of done

Internationalisation is complete when:

1. No user-facing strings are hard-coded in UI/service presentation code.
2. English comes from `app_en.arb`.
3. At least one additional locale is fully wired and selectable.
4. Tests pass with updated localization-safe assertions.
