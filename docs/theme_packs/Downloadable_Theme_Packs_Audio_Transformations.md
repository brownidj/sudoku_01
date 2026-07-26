# Downloadable Theme Packs Audio Transformations

This document defines the process for moving theme-specific sound effects and
incidental music out of bundled Flutter assets and into downloadable theme
packs.

The first migration targets are:

```text
butterflies
shells
old_opera
```

The goal is to make each pack own its tile sounds and incidental music in a
compact, validated layout that can be loaded through `ThemeDefinition` rather
than hard-coded Flutter asset paths.

## Required Transformations

1. Convert theme tile sounds to compact M4A/AAC files.

   Use `.m4a` with AAC-LC for generated pack audio. This is more compact than
   WAV and has broad native support on iOS and Android.

2. Set tile sound duration to 8 seconds.

   Each tile sound should be trimmed to 8 seconds. The same 8-second clip is
   used for:

   ```text
   long-press tile preview
   celebration audio
   ```

   Do not create duplicate long-press and celebration files unless there is a
   specific product reason for different audio.

3. Store tile sounds under `audio/tiles/`.

   The canonical pack layout is:

   ```text
   audio/
     tiles/
       tile_01.m4a
       tile_02.m4a
       tile_03.m4a
       tile_04.m4a
       tile_05.m4a
       tile_06.m4a
       tile_07.m4a
       tile_08.m4a
       tile_09.m4a
   ```

4. Store incidental music under `audio/music/`.

   Incidental/background music remains full length unless a separate product
   decision sets a maximum track length.

   ```text
   audio/
     music/
       track_name.m4a
       another_track.m4a
   ```

5. Use pack-safe file names.

   Generated files should use lowercase ASCII names with underscores. Avoid
   spaces, punctuation, apostrophes, and title-case names inside packs.

6. Update the pack manifest audio section.

   The manifest should list tile audio by digit and list all incidental music
   tracks. The long-press and celebration paths may point to the same file:

   ```json
   {
     "audio": {
       "tiles": [
         {
           "digit": 1,
           "long_press": "audio/tiles/tile_01.m4a",
           "celebration": "audio/tiles/tile_01.m4a"
         }
       ],
       "music": [
         "audio/music/track_name.m4a"
       ]
     }
   }
   ```

7. Generate an audio report.

   The report should record source paths, output paths, durations, file sizes,
   and any warnings. This makes pack size decisions auditable.

8. Keep source audio unchanged.

   The transformation pipeline should read from `flutter_app/assets/audio/`
   and write generated pack assets under `flutter_app/build/theme_packs/`.

## Source Mapping

The initial theme source folders are:

```text
flutter_app/assets/audio/butterflies/
  -> butterflies tile audio

flutter_app/assets/audio/shells/
  -> shells tile audio

flutter_app/assets/audio/opera/
  -> old_opera tile audio

flutter_app/assets/audio/background/butterflies/
  -> butterflies incidental music

flutter_app/assets/audio/background/shells/
  -> shells incidental music

flutter_app/assets/audio/background/opera/
  -> old_opera incidental music
```

`old_opera` uses the existing `opera` audio source folders.

## Script

Use:

```bash
python3 flutter_app/scripts/transform_theme_pack_audio.py butterflies shells old_opera --force
```

Default output:

```text
flutter_app/build/theme_packs/butterflies_v1/audio/
flutter_app/build/theme_packs/shells_v1/audio/
flutter_app/build/theme_packs/old_opera_v1/audio/
```

The script also writes:

```text
audio_manifest.json
docs/theme_packs/theme_pack_audio_transform_report_<timestamp>.md
```

If an image pack manifest already exists, only its `audio` field is updated.
If no `manifest.json` exists yet, the script leaves that file alone and writes
`audio_manifest.json` for the later manifest-generation step.

## Current Defaults

```text
Tile clip duration: 8 seconds
Tile clip bitrate: 64k AAC
Incidental music bitrate: 96k AAC
Sample rate: 44100 Hz
Container: .m4a
```

## Implementation Rule

Transform sounds into pack-owned, validated, consistently named media files.
Then make the app load tile long-press sounds, celebration sounds, and
incidental music through `ThemeDefinition` rather than hard-coded bundled asset
paths.
