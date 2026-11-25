import json
import tempfile
import unittest
from pathlib import Path
from scripts import build_theme_pack_catalogue as builder


class CombinedCatalogueTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.paths = []
        for theme, version in [('marine', 5), ('planets', 1)]:
            source = self.root / theme
            preview = source / f'{theme}_v{version}' / 'preview.webp'
            preview.parent.mkdir(parents=True)
            preview.write_bytes(b'preview')
            archive = source / f'{theme}_v{version}.zip'
            archive.write_bytes(theme.encode())
            path = source / 'catalogue.json'
            path.write_text(json.dumps({'catalogue_version': 1, 'themes': [{
                'id': theme, 'version': version, 'product_id': f'theme_{theme}', 'is_free': False,
                'minimum_app_build': 400, 'archive_path': f'ThemePacks/{archive.name}',
                'preview_path': f'ThemePreviews/{theme}_v{version}.webp',
                'sha256': builder.packaging.digest(archive), 'file_size_bytes': archive.stat().st_size,
            }]}))
            self.paths.append(path)

    def test_both_products_and_previews_survive_the_merge(self):
        output = self.root / 'out'
        catalogue = builder.build(self.paths, output, 6)
        self.assertEqual([entry['id'] for entry in catalogue['themes']], ['marine', 'planets'])
        self.assertEqual([entry['product_id'] for entry in catalogue['themes']], ['theme_marine', 'theme_planets'])
        apple = json.loads((output / 'theme_catalogue_v6.apple.json').read_text())
        self.assertEqual(apple['assetPackID'], 'theme_catalogue')
        self.assertEqual(len(apple['fileSelectors']), 3)
        for selector in apple['fileSelectors']:
            self.assertTrue((output / selector['fileSource']).is_file())
        self.assertTrue((output / 'marine_v5.zip').is_file())
        self.assertTrue((output / 'planets_v1.zip').is_file())

    def test_duplicate_theme_or_free_pilot_cannot_replace_paid_catalogue(self):
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            builder.build([self.paths[0], self.paths[0]], self.root / 'out', 6)
        data = json.loads(self.paths[0].read_text())
        data['themes'][0]['product_id'] = None
        data['themes'][0]['is_free'] = True
        self.paths[0].write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, 'paid binding'):
            builder.build(self.paths, self.root / 'out', 6)

    def test_modified_archive_is_rejected_before_publishing_catalogue(self):
        (self.paths[1].parent / 'planets_v1.zip').write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError, 'mismatch'):
            builder.build(self.paths, self.root / 'out', 6)
        self.assertFalse((self.root / 'out/catalogue.json').exists())
