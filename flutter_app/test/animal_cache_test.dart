import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/animal_cache.dart';

void main() {
  test('displayNameForDigit returns instrument names in instruments mode', () {
    expect(AnimalImageCache.displayNameForDigit('instruments', 1), 'piano');
    expect(AnimalImageCache.displayNameForDigit('instruments', 6), 'drums');
    expect(AnimalImageCache.displayNameForDigit('instruments', 9), 'ukulele');
  });

  test('tileLabelForDigit returns instrument initials in instruments mode', () {
    expect(AnimalImageCache.tileLabelForDigit('instruments', 1), 'P');
    expect(AnimalImageCache.tileLabelForDigit('instruments', 2), 'B');
    expect(AnimalImageCache.tileLabelForDigit('instruments', 7), 'S');
  });

  test('tileLabelForDigit keeps numeric labels outside instruments mode', () {
    expect(AnimalImageCache.tileLabelForDigit('numbers', 4), '4');
    expect(AnimalImageCache.tileLabelForDigit('animals', 4), '4');
  });
}
