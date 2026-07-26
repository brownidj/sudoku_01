# Adding New Themes

This project supports theme-driven assets (images, tile audio, and optional background music).  
Follow this process for every new theme to avoid regressions.

## 1) Add assets

Use a single, stable theme id (example: `shells`) and keep filenames deterministic.

- Images: `flutter_app/assets/images/<theme_id>/`
- Tile audio: `flutter_app/assets/audio/<theme_id>/`
- Background music (optional): `flutter_app/assets/audio/background/<theme_id>/`

## 2) Register assets in `pubspec.yaml`

In `flutter_app/pubspec.yaml`, ensure the relevant directories are listed under `flutter/assets`.

At minimum for a full theme:

- `assets/images/<theme_id>/`
- `assets/audio/<theme_id>/`
- `assets/audio/background/<theme_id>/` (if background music exists)

## 3) Wire app-level theme references

Update the existing mode/theme wiring (content mode lists, labels, premium gating, and any tile-name maps) to include the new `theme_id`.

Keep all labels in ARB/localization files, not hardcoded strings.

## 4) Regenerate background music track map

Background music track lists are generated from directories and must not be hardcoded.

```bash
cd flutter_app
dart run tool/generate_background_music_tracks.dart
```

This updates:

- `lib/ui/services/sudoku_background_music_tracks.g.dart`

If a content mode name differs from its music folder name, add/update the alias mapping in:

- `lib/ui/services/sudoku_background_music_tracks.dart`

## 5) Run tests before commit

Required:

```bash
cd flutter_app
flutter test test/background_music_track_assets_test.dart
flutter test test/l10n_arb_completeness_test.dart
flutter test test/localization_bypass_guard_test.dart
```

Recommended: run any theme-specific widget/service tests you touched.

## 6) Expected failure mode (by design)

If someone adds/removes/renames background music files but forgets to regenerate,  
`test/background_music_track_assets_test.dart` will fail and instruct regeneration.
