import 'package:flutter_app/ui/animal_cache_catalog.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_tracks.g.dart';
import 'package:flutter_app/ui/theme/bundled_theme_assets.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';

class BundledThemeFactory {
  const BundledThemeFactory._();

  static Map<String, ThemeDefinition> buildDefinitions() {
    return {
      'animals': ThemeDefinition(
        id: 'animals',
        displayName: 'Animals',
        tiles: _animalTiles(),
        audio: const ThemeAudio(
          tilePreviewAssets: bundledAnimalAudioAssets,
          tileCelebrationAssets: bundledAnimalCelebrationAudioAssets,
        ),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
      'instruments': ThemeDefinition(
        id: 'instruments',
        displayName: 'Instruments',
        tiles: _tilesFromNames(
          names: AnimalCacheCatalog.instrumentNames,
          ids: AnimalCacheCatalog.instrumentFileNames,
          pathForDigit: BundledThemeAssets.instrumentImagePath,
        ),
        audio: const ThemeAudio(
          tilePreviewAssets: bundledInstrumentAudioAssets,
        ),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
      'butterflies': ThemeDefinition(
        id: 'butterflies',
        displayName: 'Butterflies',
        tiles: _tilesFromNames(
          names: AnimalCacheCatalog.butterflyNames,
          ids: AnimalCacheCatalog.butterflyFileNames,
          pathForDigit: BundledThemeAssets.butterflyImagePath,
        ),
        audio: ThemeAudio(
          tilePreviewAssets: bundledButterflyAudioAssets,
          backgroundMusicAssets: _backgroundTracksForTheme('butterflies'),
        ),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
      'shells': ThemeDefinition(
        id: 'shells',
        displayName: 'Shells',
        tiles: _tilesFromNames(
          names: AnimalCacheCatalog.shellNames,
          ids: AnimalCacheCatalog.shellFileNames,
          pathForDigit: BundledThemeAssets.shellImagePath,
        ),
        audio: ThemeAudio(
          tilePreviewAssets: bundledShellAudioAssets,
          backgroundMusicAssets: _backgroundTracksForTheme('shells'),
        ),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
      'old_opera': ThemeDefinition(
        id: 'old_opera',
        displayName: 'Opera',
        tiles: _tilesFromNames(
          names: AnimalCacheCatalog.operaNames,
          ids: AnimalCacheCatalog.operaFileNames,
          pathForDigit: BundledThemeAssets.operaImagePath,
        ),
        audio: ThemeAudio(
          tilePreviewAssets: bundledOperaAudioAssets,
          backgroundMusicAssets: _backgroundTracksForTheme('opera'),
        ),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
      'numbers': ThemeDefinition(
        id: 'numbers',
        displayName: 'Numbers',
        tiles: _numberTiles(),
        audio: const ThemeAudio(),
        colours: const ThemeColours(),
        typography: null,
        version: 1,
      ),
    };
  }

  static List<String> _backgroundTracksForTheme(String folder) {
    return List<String>.unmodifiable(
      kBackgroundTracksByFolder[folder] ?? const <String>[],
    );
  }

  static List<ThemeTile> _animalTiles() {
    return List<ThemeTile>.generate(9, (index) {
      final digit = index + 1;
      final name = BundledThemeAssets.animalName(digit);
      return ThemeTile(
        id: name,
        imagePath: BundledThemeAssets.animalImagePath(digit, variant: 'simple'),
        accessibilityLabel: BundledThemeAssets.titleCase(name),
        displayName: name,
        label: digit.toString(),
        noteImagePath: BundledThemeAssets.animalNoteImagePath(
          digit,
          variant: 'simple',
        ),
        celebrationImagePath: BundledThemeAssets.animalCelebrationImagePath(
          digit,
        ),
        variantImagePaths: {
          'simple': BundledThemeAssets.animalImagePath(
            digit,
            variant: 'simple',
          ),
          'cute': BundledThemeAssets.animalImagePath(digit, variant: 'cute'),
        },
        variantNoteImagePaths: {
          'simple': BundledThemeAssets.animalNoteImagePath(
            digit,
            variant: 'simple',
          ),
          'cute': BundledThemeAssets.animalNoteImagePath(
            digit,
            variant: 'cute',
          ),
        },
      );
    }, growable: false);
  }

  static List<ThemeTile> _tilesFromNames({
    required List<String> names,
    required List<String> ids,
    required String Function(int digit) pathForDigit,
  }) {
    return List<ThemeTile>.generate(9, (index) {
      final digit = index + 1;
      final name = BundledThemeAssets.nameAt(
        digit,
        names,
        fallback: digit.toString(),
      );
      return ThemeTile(
        id: BundledThemeAssets.nameAt(digit, ids, fallback: name),
        imagePath: pathForDigit(digit),
        accessibilityLabel: BundledThemeAssets.titleCase(name),
        displayName: name,
        label: name.isEmpty ? digit.toString() : name[0].toUpperCase(),
        noteImagePath: pathForDigit(digit),
        celebrationImagePath: pathForDigit(digit),
      );
    }, growable: false);
  }

  static List<ThemeTile> _numberTiles() {
    return List<ThemeTile>.generate(9, (index) {
      final digit = '${index + 1}';
      return ThemeTile(
        id: digit,
        imagePath: '',
        accessibilityLabel: digit,
        displayName: digit,
        label: digit,
      );
    }, growable: false);
  }
}
