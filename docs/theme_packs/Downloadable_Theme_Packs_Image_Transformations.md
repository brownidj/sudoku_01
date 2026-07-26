# Downloadable Theme Packs Image Transformations

This document lists the image transformations implied by
`Downloadable_Theme_Packs_Architecture.md` and
`Downloadable_Theme_Packs_Implementation_Blueprint.md`.

The goal is to turn bundled game images into pack-owned, validated,
consistently sized media files that can be loaded through `ThemeDefinition`
rather than hard-coded Flutter asset paths.

## Required Transformations

1. Convert most tile images to WebP.

   Use WebP for photographic or detailed artwork. Current PNG theme images
   should usually become `.webp` files inside downloadable packs.

2. Keep PNG only where needed.

   Use PNG only for images that need transparency or exact lossless rendering.
   Otherwise avoid PNG to reduce pack size.

3. Resize images to their actual display size.

   Tile images should not be larger than the app can actually display. This is
   especially important for generated artwork that is only ever shown inside a
   Sudoku cell.

4. Remove unnecessary alpha channels.

   If an image does not need transparency, flatten it before encoding. This
   reduces file size and avoids wasted decoding work.

5. Deduplicate repeated assets.

   Remove duplicate images across bundled assets and downloadable packs. Avoid
   shipping the same image both inside the app bundle and inside a downloadable
   pack.

6. Create separate preview images.

   Each theme pack should have a lightweight `preview.webp`. Do not reuse full
   tile images as previews if a smaller preview will do.

7. Rename tile images into pack-safe canonical names.

   The recommended pack layout is:

   ```text
   tiles/
     tile_01.webp
     tile_02.webp
     tile_03.webp
     tile_04.webp
     tile_05.webp
     tile_06.webp
     tile_07.webp
     tile_08.webp
     tile_09.webp
   ```

   This is cleaner than relying on current app asset filenames such as
   `1_monarch.png`.

8. Normalize folder layout.

   Theme tile images should live under:

   ```text
   tiles/
   ```

   The preview should live at:

   ```text
   preview.webp
   ```

   Paths should be relative to the pack root so they can be listed safely in
   `manifest.json`.

9. Make dimensions and aspect ratio consistent.

   All nine tile images in a theme should have matching dimensions and square
   aspect ratio unless the theme manifest explicitly supports otherwise. This
   avoids layout inconsistency inside Sudoku cells.

10. Validate image dimensions before publishing.

    The publishing workflow should validate file names and dimensions. The
    installer should also reject oversized or unsupported images.

11. Separate bundled starter images from downloadable premium images.

    Starter themes remain in the app bundle. Full-version themes such as
    `butterflies`, `shells`, and `old_opera` should be transformed into pack
    assets and removed from bundled Flutter `assets/`.

12. Change app loading from bundled asset paths to file or pack paths.

    The game should stop assuming `assets/images/...`. Downloaded theme images
    should load from installed pack storage, or from platform-managed asset
    locations if using Google Play Asset Delivery or Apple-hosted assets.

13. Generate manifest entries for each transformed image.

    Each transformed tile needs a manifest record:

    ```json
    {
      "id": "monarch",
      "path": "tiles/tile_01.webp",
      "accessibility_label": "Monarch"
    }
    ```

14. Cache or store preview images separately from installed tiles.

    The theme browser should be able to show previews without loading full tile
    sets.

15. Apply size limits.

    The pack pipeline should enforce maximum compressed and uncompressed image
    sizes. Image conversion should target predictable pack sizes, not just
    visual quality.

## First Migration Targets

The first migration should transform the current Full Version themes:

```text
butterflies/
  bundled image assets
  -> square WebP tile_01.webp ... tile_09.webp
  -> preview.webp
  -> manifest tile paths

shells/
  bundled image assets
  -> square WebP tile_01.webp ... tile_09.webp
  -> preview.webp
  -> manifest tile paths

old_opera/
  bundled image assets
  -> square WebP tile_01.webp ... tile_09.webp
  -> preview.webp
  -> manifest tile paths
```

Then apply the same process to the next paid theme group:

```text
buttons/
fruit/
planets/
```

## Implementation Rule

Transform images into pack-owned, validated, consistently sized media files.
Then make the app load them through `ThemeDefinition` rather than hard-coded
Flutter asset paths.
