"""Planets packaging regressions: filename identity, variants, paid binding and bytes."""
import contextlib
import hashlib
import io
import json
import tempfile
import unittest
import wave
import zipfile
from pathlib import Path
from unittest.mock import patch

from PIL import Image
from scripts import build_planets_theme_pack as builder

PLANETS = ['mars', 'venus', 'earth', 'mercury', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto']
TAKES = [3, 3, 3, 4, 2, 2, 2, 2, 3]


class PlanetsPackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.project = Path(self.temp.name)
        self.images = self.project / 'flutter_app/assets/images/planets'
        self.audio = self.project / 'flutter_app/assets/audio/planets'
        self.images.mkdir(parents=True)
        self.audio.mkdir(parents=True)
        (self.project / 'flutter_app/pubspec.yaml').write_text('version: 2.0.1+400\n')
        for digit in range(9, 0, -1):
            name = PLANETS[digit - 1]
            Image.new('RGB', (32, 24), (digit * 20, 80, 120)).save(self.images / f'{digit}_{name}_01.png')
            for take in range(TAKES[digit - 1], 0, -1):
                with wave.open(str(self.audio / f'{digit}_{name}_{take}.wav'), 'wb') as wav:
                    wav.setnchannels(1)
                    wav.setsampwidth(2)
                    wav.setframerate(8000)
                    wav.writeframes(bytes(1600))
        self.project_patch = patch.object(builder.packaging, 'PROJECT', self.project)
        self.project_patch.start()
        self.addCleanup(self.project_patch.stop)

    def build(self):
        output = self.project / 'output'
        with contextlib.redirect_stdout(io.StringIO()):
            builder.build(output)
        return output

    def test_paid_archive_links_all_nine_images_and_24_tunes(self):
        output = self.build()
        with zipfile.ZipFile(output / 'planets_v1.zip') as archive:
            manifest = json.loads(archive.read('manifest.json'))
            self.assertEqual(manifest['theme_id'], 'planets')
            self.assertEqual(manifest['theme_version'], 1)
            self.assertEqual(manifest['product_id'], 'theme_planets')
            self.assertEqual([tile['accessibility_label'] for tile in manifest['tiles']], [name.title() for name in PLANETS])
            self.assertEqual([tile['id'] for tile in manifest['tiles']], PLANETS)
            playlist = []
            for digit, (name, count, entry) in enumerate(zip(PLANETS, TAKES, manifest['audio']['tiles']), 1):
                expected = [f'audio/tunes/{digit}_{name}_{take}.m4a' for take in range(1, count + 1)]
                self.assertEqual(entry['digit'], digit)
                self.assertEqual(entry['long_press_variants'], expected)
                self.assertEqual(entry['long_press'], expected[0])
                playlist.extend(expected)
                with Image.open(io.BytesIO(archive.read(manifest['tiles'][digit - 1]['path']))) as image:
                    self.assertEqual(image.size, (512, 512))
                    self.assertLess(abs(image.getpixel((256, 256))[0] - digit * 20), 5)
            self.assertEqual(manifest['audio']['music'], playlist)
            self.assertEqual(len(playlist), 24)
            for path in playlist:
                self.assertEqual(archive.read(path)[4:8], b'ftyp')
            for path, checksum in manifest['checksums'].items():
                self.assertEqual(hashlib.sha256(archive.read(path)).hexdigest(), checksum)
        catalogue = json.loads((output / 'catalogue.json').read_text())['themes'][0]
        self.assertEqual(catalogue['id'], 'planets')
        self.assertEqual(catalogue['product_id'], 'theme_planets')
        self.assertFalse(catalogue['is_free'])
        self.assertEqual(catalogue['archive_path'], 'ThemePacks/planets_v1.zip')
        self.assertEqual(catalogue['sha256'], builder.packaging.digest(output / 'planets_v1.zip'))
        apple = json.loads((output / 'planets_v1.apple.json').read_text())
        self.assertEqual(apple['assetPackID'], 'planets')
        self.assertEqual(apple['downloadPolicy'], {'onDemand': {}})
        report = json.loads((output / 'planets_v1.build_report.json').read_text())
        self.assertEqual(report['background_music_count'], 24)
        self.assertEqual(report['tile_preview_mapping_count'], 9)
        self.assertEqual(len(report['source_sha256']), 9)
        self.assertEqual(len(report['audio_source_sha256']), 24)

    def test_missing_or_duplicate_image_is_rejected(self):
        path = self.images / '9_pluto_01.png'
        path.unlink()
        with self.assertRaisesRegex(ValueError, 'each digit'):
            builder.discover_tiles(self.images)
        Image.new('RGB', (32, 32)).save(path)
        Image.new('RGB', (32, 32)).save(self.images / '1_mars_02.png')
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            builder.discover_tiles(self.images)

    def test_wrong_digit_or_planet_name_in_audio_is_rejected(self):
        (self.audio / '1_mars_1.wav').rename(self.audio / '4_mars_1.wav')
        with self.assertRaisesRegex(ValueError, 'digit/name'):
            builder.discover_audio(self.audio, builder.discover_tiles(self.images))

    def test_planet_without_any_tunes_is_rejected(self):
        for path in self.audio.glob('8_*'):
            path.unlink()
        with self.assertRaisesRegex(ValueError, 'each planet'):
            builder.discover_audio(self.audio, builder.discover_tiles(self.images))

    def test_take_order_is_numeric_and_duplicate_formats_are_rejected(self):
        (self.audio / '1_mars_1.wav').rename(self.audio / '1_mars_10.wav')
        audio = builder.discover_audio(self.audio, builder.discover_tiles(self.images))
        self.assertEqual([path.stem for path in audio[1]], ['1_mars_2', '1_mars_3', '1_mars_10'])
        (self.audio / '1_mars_2.mp3').write_bytes(b'duplicate')
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            builder.discover_audio(self.audio, builder.discover_tiles(self.images))

    def test_paid_product_id_is_required(self):
        with self.assertRaisesRegex(ValueError, 'paid product'):
            builder.build(self.project / 'out', product_id=None)


if __name__ == '__main__':
    unittest.main()
