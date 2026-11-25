#!/usr/bin/env python3
"""Combine paid theme catalogues into one Apple catalogue and upload directory.

Apple delivers one active theme_catalogue pack per distribution context. Merge
entries rather than replacing Marine Life with a Planets-only catalogue.
"""
import argparse
import json
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path

if __package__:
    from . import build_marine_theme_pack as packaging
else:
    import build_marine_theme_pack as packaging


def build(inputs, output, version, package_apple=False):
    if version < 1:
        raise ValueError('Catalogue delivery version must be positive.')
    entries, sources = {}, {}
    for path in inputs:
        catalogue = json.loads(path.read_text())
        if catalogue.get('catalogue_version') != 1:
            raise ValueError(f'Unsupported catalogue: {path}')
        for entry in catalogue['themes']:
            theme_id, content_version = entry['id'], entry['version']
            if not re.fullmatch(r'[a-z][a-z0-9_]{2,63}', theme_id) or not isinstance(content_version, int) or content_version < 1:
                raise ValueError('Invalid theme identity/version.')
            if theme_id in entries:
                raise ValueError(f'Duplicate theme: {theme_id}')
            if entry.get('is_free') is not False or not entry.get('product_id'):
                raise ValueError(f'Release catalogue requires a paid binding: {theme_id}')
            pack_name = f'{theme_id}_v{content_version}'
            archive = path.parent / f'{pack_name}.zip'
            if (entry.get('archive_path') != f'ThemePacks/{pack_name}.zip'
                    or entry.get('preview_path') != f'ThemePreviews/{pack_name}.webp'
                    or packaging.digest(archive) != entry['sha256']
                    or archive.stat().st_size != entry['file_size_bytes']):
                raise ValueError(f'Archive identity/hash/size mismatch: {theme_id}')
            preview = path.parent / pack_name / 'preview.webp'
            if not preview.is_file():
                raise ValueError(f'Missing preview: {theme_id}')
            if package_apple and not (path.parent / f'{pack_name}.aar').is_file():
                raise ValueError(f'Missing Apple archive: {theme_id}')
            entries[theme_id] = entry
            sources[theme_id] = (path.parent, pack_name, preview)
    if not entries:
        raise ValueError('At least one paid theme is required.')
    output.mkdir(parents=True, exist_ok=True)
    selectors = [{'fileSource': 'catalogue.json', 'fileDestination': 'ThemeCatalogue/catalogue.json'}]
    for theme_id in sorted(entries):
        source, pack_name, preview = sources[theme_id]
        target = output / 'previews' / f'{pack_name}.webp'
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(preview, target)
        selectors.append({'fileSource': f'previews/{pack_name}.webp',
                          'fileDestination': entries[theme_id]['preview_path']})
        for suffix in ('.zip', '.aar'):
            asset = source / f'{pack_name}{suffix}'
            if asset.is_file() and asset.resolve() != (output / asset.name).resolve():
                shutil.copyfile(asset, output / asset.name)
    catalogue = {
        'catalogue_version': 1,
        'generated_at': datetime.now(timezone.utc).isoformat(),
        'minimum_supported_app_build': min(entry['minimum_app_build'] for entry in entries.values()),
        'themes': [entries[key] for key in sorted(entries)],
    }
    packaging.write_json(output / 'catalogue.json', catalogue)
    name = f'theme_catalogue_v{version}'
    packaging.write_json(output / f'{name}.apple.json', {
        'assetPackID': 'theme_catalogue', 'downloadPolicy': {'onDemand': {}},
        'fileSelectors': selectors, 'platforms': ['iOS'],
    })
    if package_apple:
        subprocess.run(['xcrun', 'ba-package', f'{name}.apple.json', '-o', f'{name}.aar'],
                       cwd=output, check=True)
    return catalogue


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalogue', type=Path, action='append', required=True)
    parser.add_argument('--output', type=Path, default=packaging.PROJECT / 'flutter_app/build/theme_packs_store')
    parser.add_argument('--version', type=int, required=True)
    parser.add_argument('--package-apple', action='store_true')
    args = parser.parse_args()
    result = build([path.resolve() for path in args.catalogue], args.output.resolve(), args.version, args.package_apple)
    print(json.dumps({'output': str(args.output), 'themes': [entry['id'] for entry in result['themes']]}))
