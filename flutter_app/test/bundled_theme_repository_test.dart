import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BundledThemeRepository', () {
    const repository = BundledThemeRepository();

    test('lists the current bundled themes in content-mode order', () async {
      final themes = await repository.getAvailableThemes();

      expect(themes.map((theme) => theme.id), BundledThemeRepository.themeIds);
      expect(
        themes.every((theme) => theme.source == ThemeSource.bundled),
        isTrue,
      );
      expect(themes.every((theme) => theme.isInstalled), isTrue);
      expect(themes.every((theme) => theme.isOwned), isTrue);
    });

    test('keeps the free starter theme IDs explicit', () {
      expect(BundledThemeRepository.freeThemeIds, {
        'animals',
        'instruments',
        'numbers',
      });
      expect(BundledThemeRepository.premiumThemeIds, {
        'butterflies',
        'shells',
        'old_opera',
      });
    });

    test('loads every bundled theme with nine tiles', () async {
      for (final themeId in BundledThemeRepository.themeIds) {
        final theme = await repository.loadTheme(themeId);

        expect(theme.id, themeId);
        expect(theme.version, 1);
        expect(theme.tiles, hasLength(9));
      }
    });

    test('preserves existing tile image mappings', () {
      expect(
        BundledThemeRepository.tileImagePath(
          themeId: 'animals',
          digit: 1,
          variant: 'cute',
        ),
        'assets/images/animals/1_cartoon_ape_s.png',
      );
      expect(
        BundledThemeRepository.tileImagePath(themeId: 'instruments', digit: 6),
        'assets/images/music/drum.png',
      );
      expect(
        BundledThemeRepository.tileImagePath(themeId: 'shells', digit: 9),
        'assets/images/shells/9_cockle.png',
      );
    });

    test('preserves existing tile preview audio mappings', () {
      expect(
        BundledThemeRepository.tilePreviewAudioAsset(
          themeId: 'animals',
          digit: 3,
        ),
        'audio/animals/cheetah.mp3',
      );
      expect(
        BundledThemeRepository.tilePreviewAudioAsset(
          themeId: 'old_opera',
          digit: 4,
        ),
        'audio/opera/mezzo_soprano.mp3',
      );
      expect(
        BundledThemeRepository.tilePreviewAudioAsset(
          themeId: 'numbers',
          digit: 1,
        ),
        isNull,
      );
    });

    test('preserves existing celebration media mappings', () {
      expect(
        BundledThemeRepository.celebrationImagePathsForTheme('animals')[2],
        'assets/images/animals_chatGpT/3_cartoon_camel.png',
      );
      expect(
        BundledThemeRepository.celebrationAudioAssetForImagePath(
          'assets/images/animals_chatGpT/3_cartoon_camel.png',
        ),
        'audio/animals/camel.mp3',
      );
      expect(
        BundledThemeRepository.celebrationImagePathsForTheme('numbers'),
        hasLength(45),
      );
    });

    test('throws a typed error for unknown themes', () {
      expect(
        () => BundledThemeRepository.themeDefinitionFor('missing'),
        throwsA(isA<UnknownThemeException>()),
      );
    });
  });
}
