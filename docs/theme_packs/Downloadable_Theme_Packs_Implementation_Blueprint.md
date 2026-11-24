# Sudoku Playtime Downloadable Theme Packs
## Implementation Blueprint

## 1. Purpose

This document defines a practical architecture for adding downloadable theme packs to Sudoku Playtime without increasing the initial app download excessively.

The design assumes:

- several starter themes remain bundled with the app;
- additional themes are downloaded only when requested;
- downloadable packs contain media and configuration data only;
- the same theme system should work across iOS, Android and, where practical, macOS;
- paid packs are unlocked through the relevant platform store;
- downloaded packs can be updated, deleted and restored.

Hosting direction updated on 2026-11-24: investigate Apple-Hosted Background
Assets first for iOS/iPadOS 26 and later, with a separate HTTPS delivery route
for Android and older supported iOS versions. See the Phase 3 investigation in
section 22. References to a shared HTTPS downloader below describe the fallback
route; they do not mean Apple provides public ZIP hosting for other platforms.

The central design principle is that the game should work with a common `ThemeDefinition` model regardless of whether a theme is bundled or downloaded.

---

## 2. High-level architecture

```text
Remote theme catalogue
        ↓
ThemeCatalogueService
        ↓
ThemeRepository
        ↓
Theme browser / Theme selector
        ↓
ThemeEntitlementService
        ↓
ThemeDownloadService
        ↓
ThemeInstallationService
        ↓
Local theme storage
        ↓
ThemeLoader
        ↓
Sudoku game UI
```

The app should separate five concerns:

1. discovering available themes;
2. checking whether the player may use a theme;
3. downloading the selected pack;
4. validating and installing the pack;
5. loading the installed theme into the game.

---

## 3. Recommended Flutter services

### 3.1 `ThemeRepository`

The main interface used by the rest of the app.

Responsibilities:

- combine bundled and downloaded themes into one list;
- expose theme installation status;
- return a `ThemeDefinition` for a selected theme;
- notify the UI when themes are installed, removed or updated;
- hide storage and network details from the game screens.

Suggested interface:

```dart
abstract class ThemeRepository {
  Future<List<ThemeSummary>> getAvailableThemes();

  Future<ThemeDefinition> loadTheme(String themeId);

  Future<bool> isInstalled(String themeId);

  Future<void> installTheme(String themeId);

  Future<void> removeTheme(String themeId);

  Stream<List<ThemeSummary>> watchThemes();
}
```

### 3.2 `ThemeCatalogueService`

Responsibilities:

- download `catalogue.json`;
- cache the most recent valid catalogue;
- fall back to the cached catalogue when offline;
- compare remote versions with installed versions;
- expose pack URLs, preview URLs, prices and compatibility data.

Suggested interface:

```dart
abstract class ThemeCatalogueService {
  Future<ThemeCatalogue> fetchCatalogue({
    bool forceRefresh = false,
  });

  Future<ThemeCatalogue?> loadCachedCatalogue();
}
```

### 3.3 `ThemeEntitlementService`

Responsibilities:

- determine whether a theme is free, purchased or included in a bundle;
- request a purchase through the platform store;
- restore previous purchases;
- refresh entitlement status;
- avoid embedding purchase logic directly in theme screens.

Suggested interface:

```dart
abstract class ThemeEntitlementService {
  Future<ThemeEntitlement> getEntitlement(String themeId);

  Future<PurchaseResult> purchaseTheme(String themeId);

  Future<void> restorePurchases();

  Stream<Map<String, ThemeEntitlement>> watchEntitlements();
}
```

### 3.4 `ThemeDownloadService`

Responsibilities:

- download theme ZIP files;
- report progress;
- support cancellation;
- save to a temporary location;
- retry transient failures;
- verify the expected file size before installation.

Suggested interface:

```dart
abstract class ThemeDownloadService {
  Stream<ThemeDownloadProgress> downloadTheme({
    required ThemePackDescriptor pack,
    required String temporaryPath,
  });

  Future<void> cancelDownload(String themeId);
}
```

### 3.5 `ThemeInstallationService`

Responsibilities:

- verify checksum or signature;
- unzip the pack;
- validate `manifest.json`;
- ensure required files exist;
- install atomically;
- preserve the previous valid version until the new version succeeds;
- remove obsolete versions.

Suggested interface:

```dart
abstract class ThemeInstallationService {
  Future<InstalledTheme> install({
    required ThemePackDescriptor pack,
    required String archivePath,
  });

  Future<void> uninstall(String themeId);

  Future<List<InstalledTheme>> listInstalledThemes();

  Future<bool> validateInstallation(String themeId);
}
```

### 3.6 `ThemeLoader`

Responsibilities:

- load images and sounds from either bundled assets or local files;
- convert a manifest into a `ThemeDefinition`;
- expose a uniform API to widgets;
- provide placeholders if an asset is missing.

Suggested interface:

```dart
abstract class ThemeLoader {
  Future<ThemeDefinition> loadBundledTheme(String themeId);

  Future<ThemeDefinition> loadInstalledTheme(String themeId);
}
```

---

## 4. Core data models

### 4.1 `ThemeSummary`

Used by the theme browser.

```dart
class ThemeSummary {
  final String id;
  final String displayName;
  final String description;
  final String previewImage;
  final ThemeSource source;
  final bool isInstalled;
  final bool isOwned;
  final bool hasUpdate;
  final int version;
}
```

### 4.2 `ThemeDefinition`

Used by the Sudoku game.

```dart
class ThemeDefinition {
  final String id;
  final String displayName;
  final List<ThemeTile> tiles;
  final ThemeAudio? audio;
  final ThemeColours colours;
  final ThemeTypography? typography;
  final int version;
}
```

### 4.3 `ThemeTile`

```dart
class ThemeTile {
  final String id;
  final String imagePath;
  final String? accessibilityLabel;
}
```

### 4.4 `ThemePackDescriptor`

Represents a downloadable pack from the remote catalogue.

```dart
class ThemePackDescriptor {
  final String id;
  final int version;
  final String downloadUrl;
  final String sha256;
  final int fileSizeBytes;
  final int minimumAppBuild;
  final String? productId;
}
```

### 4.5 Suggested enums

```dart
enum ThemeSource {
  bundled,
  downloaded,
}

enum ThemeEntitlement {
  free,
  owned,
  availableForPurchase,
  unavailable,
}

enum ThemeInstallationState {
  notInstalled,
  downloading,
  installing,
  installed,
  updateAvailable,
  failed,
}
```

---

## 5. Remote catalogue format

Store a small JSON catalogue at a stable HTTPS URL.

Example:

```json
{
  "catalogue_version": 4,
  "generated_at": "2026-07-20T00:00:00Z",
  "minimum_supported_app_build": 120,
  "themes": [
    {
      "id": "garden",
      "version": 2,
      "display_name": "Garden",
      "description": "Flowers, leaves and garden favourites.",
      "preview_url": "https://example.com/themes/garden/preview_v2.webp",
      "download_url": "https://example.com/themes/garden/garden_v2.zip",
      "sha256": "REPLACE_WITH_SHA256",
      "file_size_bytes": 8421376,
      "minimum_app_build": 120,
      "product_id": "org.topository.sudoku.theme.garden",
      "is_free": false,
      "included_in_all_themes_bundle": true,
      "active": true
    }
  ]
}
```

### Required catalogue fields

At catalogue level:

- `catalogue_version`
- `generated_at`
- `themes`

For each theme:

- `id`
- `version`
- `display_name`
- `preview_url`
- `download_url`
- `sha256`
- `file_size_bytes`
- `minimum_app_build`
- `active`

Optional fields:

- `description`
- `product_id`
- `is_free`
- `included_in_all_themes_bundle`
- `region_restrictions`
- `language_availability`
- `release_notes`

### Catalogue rules

- Theme IDs must never change after release.
- New versions should increment the integer `version`.
- Removed themes should normally be marked inactive rather than deleted immediately.
- The app should ignore unknown fields for forward compatibility.
- The app should reject catalogue entries requiring a newer app build.

---

## 6. Theme pack layout

Recommended ZIP structure:

```text
manifest.json
preview.webp
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
  music/
    incidental_track.m4a
```

Do not place executable code in a pack.

Avoid:

- Dart files;
- native libraries;
- scripts;
- dynamically loaded code;
- files outside the approved pack schema.

---

## 7. Theme manifest format

Example `manifest.json`:

```json
{
  "schema_version": 1,
  "theme_id": "garden",
  "theme_version": 2,
  "display_name": "Garden",
  "tile_count": 9,
  "tiles": [
    {
      "id": "rose",
      "path": "tiles/tile_01.webp",
      "accessibility_label": "Rose"
    },
    {
      "id": "sunflower",
      "path": "tiles/tile_02.webp",
      "accessibility_label": "Sunflower"
    }
  ],
  "preview_path": "preview.webp",
  "audio": {
    "tiles": [
      {
        "digit": 1,
        "long_press": "audio/tiles/tile_01.m4a",
        "celebration": "audio/tiles/tile_01.m4a"
      },
      {
        "digit": 2,
        "long_press": "audio/tiles/tile_02.m4a",
        "celebration": "audio/tiles/tile_02.m4a"
      }
    ],
    "music": [
      "audio/music/incidental_track.m4a"
    ]
  },
  "colours": {
    "background": "#FFF8E8",
    "grid": "#625B4C",
    "highlight": "#F1D59B"
  },
  "minimum_app_build": 120
}
```

### Manifest validation rules

Before installation, verify that:

- `schema_version` is supported;
- `theme_id` matches the catalogue entry;
- `theme_version` matches the downloaded pack version;
- the theme has the required number of tiles;
- all referenced files exist;
- all paths remain inside the extracted theme directory;
- image formats are supported;
- file sizes are within safe limits;
- the pack does not contain unexpected executable files;
- the minimum app build is satisfied.

---

## 8. Local storage layout

Use the app's private application-support directory.

Example:

```text
application-support/
  themes/
    catalogue/
      catalogue.json
    installed/
      garden/
        current.json
        versions/
          1/
          2/
    temp/
      garden_v2.zip.part
    state/
      installations.json
```

Recommended approach:

```text
installed/<theme-id>/current.json
```

Example:

```json
{
  "active_version": 2,
  "installed_at": "2026-07-20T04:35:00Z",
  "validated": true
}
```

The application should not derive installation state only from SharedPreferences. The filesystem should remain the source of truth, with preferences or a local database used as an index.

---

## 9. Download workflow

### 9.1 Normal installation

```text
Player selects theme
        ↓
Check entitlement
        ↓
Check free storage
        ↓
Download to temporary .part file
        ↓
Verify expected file size
        ↓
Verify SHA-256 checksum
        ↓
Extract to temporary installation directory
        ↓
Validate manifest and assets
        ↓
Rename temporary directory into final location
        ↓
Update installation record
        ↓
Refresh theme repository
```

### 9.2 Atomic installation

Do not install directly over the active version.

Use:

```text
garden/
  versions/
    2.installing/
```

After validation:

```text
garden/
  versions/
    2/
```

Then update `current.json`.

If the install fails:

- delete `2.installing`;
- preserve the previous active version;
- display a recoverable error;
- allow retry.

### 9.3 Download progress model

```dart
class ThemeDownloadProgress {
  final String themeId;
  final int bytesReceived;
  final int? totalBytes;
  final ThemeDownloadStage stage;
  final String? errorMessage;
}
```

Suggested stages:

```dart
enum ThemeDownloadStage {
  waiting,
  downloading,
  verifying,
  extracting,
  validating,
  complete,
  cancelled,
  failed,
}
```

---

## 10. Updating installed themes

When the catalogue version is newer than the installed version:

1. show **Update available**;
2. allow the user to continue using the installed version;
3. download the new pack separately;
4. validate it completely;
5. switch `current.json` only after success;
6. optionally retain the previous version until the next clean startup;
7. remove obsolete versions after successful use.

Do not force an update unless the old pack is incompatible or unsafe.

---

## 11. Deleting and reinstalling themes

The player should be able to remove downloaded files without losing ownership.

Removing a theme should:

- delete the installed asset files;
- retain purchase entitlement;
- remove it from the active theme if currently selected;
- switch safely to a bundled default theme;
- preserve the ability to reinstall without paying again.

Suggested UI labels:

- **Download**
- **Buy**
- **Installed**
- **Update**
- **Remove Download**
- **Restore Purchases**

---

## 12. Purchase and entitlement design

### 12.1 Recommended purchase model

Each paid pack has its own non-consumable store product.

Examples:

```text
org.topository.sudoku.theme.garden
org.topository.sudoku.theme.vintage
org.topository.sudoku.theme.australia
org.topository.sudoku.theme.all_themes
```

### 12.2 Entitlement decision

A theme is available when one of these conditions is true:

```text
theme is free
OR individual theme product is owned
OR all-themes bundle is owned
OR user has a valid promotional entitlement
```

### 12.3 Purchase sequence

```text
Player taps Buy
        ↓
Store purchase sheet opens
        ↓
Purchase succeeds
        ↓
Entitlement service refreshes
        ↓
Download button becomes available
        ↓
Pack downloads and installs
```

The purchase and download should remain separate operations. A completed purchase must remain valid even if the subsequent download fails.

### 12.4 Restore Purchases

Restoring should:

- query the platform store;
- rebuild the entitlement map;
- unlock owned packs;
- not automatically download every owned pack;
- allow the user to choose which packs to reinstall.

---

## 13. Backend options

### Option A: Static hosting only

Use static HTTPS hosting for:

- `catalogue.json`;
- previews;
- ZIP files.

Advantages:

- simple;
- inexpensive;
- no custom server code;
- suitable for free packs and basic paid-pack delivery.

Limitation:

- the downloadable URLs may be discoverable;
- ownership enforcement remains primarily in the app.

### Option B: Static hosting plus entitlement backend

Use a backend to:

- verify store receipts or purchase tokens;
- issue short-lived signed download URLs;
- record promotional entitlements;
- reduce casual unauthorised downloading.

Advantages:

- stronger control;
- centralised entitlement logic;
- easier promotion management.

Disadvantages:

- more infrastructure;
- server maintenance;
- privacy and security obligations.

### Current hosting direction

Use Apple-Hosted Background Assets as the first delivery route to investigate
for iOS/iPadOS 26 and later. Retain static HTTPS hosting as the proposed delivery
route for Android and older supported iOS versions. Apple hosting cannot serve
as the shared public CDN for those clients.

Keep theme definitions, theme IDs, manifest validation, installation and
purchase entitlements independent of the delivery provider. Add an entitlement
backend only if download abuse, promotions or cross-platform entitlement
requirements justify it. The Apple-specific setup and remaining decisions are
recorded under Phase 3 in section 22.

---

## 14. Security and integrity

At minimum:

- use HTTPS;
- store a SHA-256 checksum in the catalogue;
- verify checksums before extraction;
- reject path traversal such as `../`;
- reject absolute file paths;
- restrict accepted file extensions;
- enforce maximum compressed and uncompressed sizes;
- validate image dimensions;
- avoid loading executable code;
- preserve the previous working version during updates.

For stronger protection:

- digitally sign manifests;
- embed the public verification key in the app;
- use short-lived signed download URLs;
- validate purchase receipts through a backend.

---

## 15. Offline behaviour

The app should remain usable offline.

Expected behaviour:

- bundled themes always work;
- installed downloaded themes continue to work;
- cached catalogue data may be shown;
- previews already cached may be displayed;
- purchase and download actions show that a connection is required;
- failed downloads can be retried later.

Never make theme catalogue availability a requirement for launching the game.

---

## 16. Startup behaviour

At startup:

1. load bundled theme definitions;
2. scan installed theme records;
3. validate only lightweight metadata;
4. restore the last selected valid theme;
5. fall back to a bundled default if necessary;
6. refresh the remote catalogue in the background after the main screen is usable;
7. refresh store entitlements when appropriate.

Avoid rehashing every theme file on each launch. Perform full validation during installation and only lightweight consistency checks later.

---

## 17. Theme selection UI

Each theme card should show:

- preview image;
- name;
- short description;
- bundled, free or paid status;
- download size;
- installation state;
- update state;
- price supplied by the platform store;
- download or purchase action.

Example states:

```text
Bundled
Free — Download
$1.99 — Buy
Owned — Download
Downloading — 48%
Installing
Installed
Update available
Unavailable for this app version
```

---

## 18. Compatibility and versioning

Use two separate versions:

```text
schema_version
theme_version
```

`schema_version` describes the manifest format.

`theme_version` describes the content release.

Example:

```json
{
  "schema_version": 1,
  "theme_version": 4
}
```

Rules:

- increment `theme_version` for image, sound or metadata changes;
- increment `schema_version` only when the manifest structure changes incompatibly;
- make parsers tolerant of unknown optional fields;
- reject unsupported required schema versions;
- include `minimum_app_build` in both catalogue and manifest.

---

## 19. Image and audio guidance

### Images

Recommended:

- WebP for photographic or detailed artwork;
- PNG only where transparency or exact lossless rendering is necessary;
- consistent dimensions and aspect ratio;
- no files larger than the actual display requirement;
- previews separate from full tile images.

### Audio

Recommended:

- M4A/AAC-LC for compact cross-platform pack audio;
- 8-second tile clips for both long-press preview and celebration audio;
- reuse the same tile clip for long-press and celebration unless the pack
  intentionally needs separate audio;
- incidental music under `audio/music/`, compressed but kept full length unless
  a product rule sets a maximum duration;
- consistent volume;
- optional audio entries in the manifest;
- graceful fallback if audio is missing.

---

## 20. Error handling

Provide clear, actionable errors.

Examples:

```text
The download was interrupted. Try again.
The theme file could not be verified.
This theme requires a newer version of Sudoku Playtime.
There is not enough storage space to install this theme.
The theme was purchased, but the download could not be completed.
The installed theme is damaged and has been disabled.
```

Log technical detail internally, but show simple messages to players.

---

## 21. Testing strategy

### Unit tests

Test:

- catalogue parsing;
- manifest parsing;
- compatibility checks;
- entitlement resolution;
- checksum validation;
- path traversal rejection;
- state transitions;
- update comparison;
- fallback behaviour.

### Integration tests

Test:

- successful download and install;
- cancelled download;
- interrupted download;
- corrupted ZIP;
- incorrect checksum;
- missing manifest;
- missing tile;
- duplicate theme ID;
- insufficient storage;
- update while old version is active;
- uninstall and reinstall;
- purchase restoration.

### Platform tests

Test separately on:

- iPhone;
- iPad;
- Android phone;
- Android tablet;
- macOS, if supported.

Also test:

- fresh install;
- upgrade from an older app version;
- offline launch;
- slow network;
- device restart during download;
- app termination during installation.

---

## 22. Suggested implementation phases

### Phase 1: Unify bundled theme handling

- Introduce `ThemeDefinition`.
- Introduce `ThemeRepository`.
- Load existing bundled themes through the new abstraction.
- Ensure the Sudoku game no longer references asset paths directly.

### Phase 2: Local pack installation

- [x] Define `manifest.json`.
- [x] Create a sample ZIP pack.
- [x] Install from a local test file.
- [x] Load theme assets from application storage.
- [x] Add uninstall support.

Phase 2 implementation status: complete.

Files created:

- `flutter_app/lib/ui/theme/composite_theme_repository.dart`
- `flutter_app/lib/ui/theme/installed_theme.dart`
- `flutter_app/lib/ui/theme/installed_theme_repository.dart`
- `flutter_app/lib/ui/theme/installed_theme_store.dart`
- `flutter_app/lib/ui/theme/local_theme_pack_developer_installer.dart`
- `flutter_app/lib/ui/theme/local_theme_pack_extractor.dart`
- `flutter_app/lib/ui/theme/local_theme_pack_installer.dart`
- `flutter_app/lib/ui/theme/theme_loader.dart`
- `flutter_app/lib/ui/theme/theme_manifest.dart`
- `flutter_app/lib/ui/theme/theme_pack_errors.dart`
- `flutter_app/lib/ui/theme/theme_pack_path_safety.dart`
- `flutter_app/lib/ui/theme/theme_pack_validator.dart`
- `flutter_app/lib/ui/theme/theme_storage_paths.dart`
- `flutter_app/test/local_theme_pack_installer_test.dart`

Files modified:

- `flutter_app/lib/main.dart`
- `flutter_app/pubspec.yaml`
- `flutter_app/pubspec.lock`
- `docs/theme_packs/Downloadable_Theme_Packs_Implementation_Blueprint.md`

Local installation flow:

1. A developer supplies a local ZIP file to `LocalThemePackInstaller.installFromZip`.
2. `LocalThemePackExtractor` verifies the ZIP exists, rejects invalid ZIP signatures, rejects unsafe archive paths, rejects symlinks and blocked executable/native/script extensions, and extracts into `themes/temp/<timestamp>.staging/`.
3. `ThemePackValidator` locates the single `manifest.json`, parses it into `ThemeManifest`, validates required fields, validates the supported schema version, validates theme id and version, checks referenced asset paths stay inside the extracted theme directory, checks image/audio extensions, confirms referenced assets exist, and verifies SHA-256 checksums where `checksums` entries are present.
4. `LocalThemePackInstaller` compares the incoming pack with bundled and installed themes. Duplicate theme ids are rejected and reported as incoming `newer`, `identical` or `older`; Phase 2 does not perform an update workflow.
5. The validated pack is copied to `installed/<theme-id>/versions/<version>.installing/`, then renamed to `installed/<theme-id>/versions/<version>/`.
6. `InstalledThemeStore` writes `installed/<theme-id>/current.json` after the version directory is complete.
7. Temporary staging and `.installing` directories are removed after success or failure.
8. `RepositoryThemeLoader`, `InstalledThemeRepository` and `CompositeThemeRepository` make the installed theme discoverable through the same `ThemeRepository`/`ThemeLoader` architecture as bundled themes.

Repository location and installed-pack structure:

```text
<application-support-directory>/
  themes/
    installed/
      <theme-id>/
        current.json
        versions/
          <version>/
            manifest.json
            preview.webp
            tiles/
            audio/
    temp/
      <timestamp>.staging/
```

`current.json` remains the active-version pointer:

```json
{
  "active_version": 2,
  "installed_at": "2026-07-29T00:00:00.000Z",
  "validated": true
}
```

Supported manifest version: `schema_version: 1`.

Validation and checksum behaviour:

- Required manifest fields are `schema_version`, `theme_id`, `theme_version`, `display_name`, `tile_count`, `tiles` and `preview_path`.
- `theme_id` must match `^[a-z][a-z0-9_-]{2,63}$`.
- `theme_version` must be greater than zero.
- `tile_count` must be `9`, and `tiles` must contain exactly nine entries.
- Referenced image assets must use `.jpg`, `.jpeg`, `.png` or `.webp`.
- Referenced audio assets must use `.m4a`, `.mp3` or `.wav`.
- Archive and manifest paths are normalized and rejected if absolute, empty or traversing outside the extracted theme directory.
- SHA-256 checksums are optional, but every manifest `checksums` entry must be a 64-character hexadecimal digest and must match the referenced file.

Developer-only local install mechanism:

```sh
flutter run \
  --dart-define=ENABLE_LOCAL_THEME_PACK_INSTALLER=true \
  --dart-define=LOCAL_THEME_PACK_ZIP=/absolute/path/to/theme.zip
```

This hook is isolated in `LocalThemePackDeveloperInstaller`, runs before `SudokuApp` starts, performs no networking, and is disabled unless both dart defines are supplied.

Tests added:

- successful installation of a valid local pack;
- invalid ZIP;
- missing ZIP file;
- missing manifest;
- malformed manifest;
- missing asset;
- checksum mismatch;
- duplicate pack;
- path traversal attempt;
- cleanup after failed installation;
- successful discovery by `ThemeLoader` and the shared repository.

Deviations:

- Phase 1 did not contain a concrete `ThemeLoader`; Phase 2 adds the minimal `ThemeLoader` interface and `RepositoryThemeLoader` implementation described by this blueprint so installed packs do not need a parallel loading path.
- The sample ZIP pack is generated inside `local_theme_pack_installer_test.dart` rather than checked in as a binary fixture. This keeps the repository small and lets the tests generate matching and mismatched checksums deterministically.

Phase 3: Apple-hosting investigation and the requested pilot preparation/native
bridge steps are implemented locally. Shared App Group setup and development
provisioning are complete. A debug-only delivery/install/offline test screen
now connects the native bridge to the shared installer. Runtime verification
and hosted delivery remain outstanding; distribution signing is not verified.
Phase 4 and later phases: not started.

### Phase 3: Remote catalogue and download

- [x] Investigate Apple hosting and record the platform split.
- [ ] Add a delivery-provider boundary shared by native Apple and HTTPS routes.
- [x] Add the native Apple Background Download extension target and Flutter bridge.
- [x] Configure the shared App Group, Apple hosting keys and development provisioning.
- [x] Prepare local Apple asset archives for the pilot catalogue and free theme pack.
- [x] Implement native-pilot catalogue caching and offline fallback.
- [x] Display native-pilot download progress in the developer test screen.
- [x] Add pilot ZIP size/checksum and catalogue-to-manifest identity verification.
- [ ] Add retry, cancellation and temporary-file cleanup.
- [ ] Configure and verify the HTTPS fallback for Android and older iOS.
- [ ] Verify the Apple pilot locally and through TestFlight.

#### Apple-hosting investigation — 2026-11-24

David selected exploration of Apple hosting before implementing the original
HTTPS-only Phase 3. This changes delivery, while retaining the shared theme
model, loader and Phase 2 installation validation.

Findings:

- Apple-Hosted Background Assets is intended for additional app content and
  includes up to 200 GB of compressed assets with Apple Developer Program
  membership. Production delivery is through TestFlight and the App Store.
- Managed Background Assets supports iOS/iPadOS 26 and later. The app currently
  has an iOS 15 deployment target; keep that target and gate the native delivery
  code by OS availability. The extension requires its own compatible target.
- Android and iOS 15–25 need a separate delivery provider. They cannot request
  Apple-hosted content using ordinary HTTPS ZIP links.
- This Mac has Xcode 27.2, the BackgroundAssets framework, the Apple-hosted
  Background Download extension template, `ba-package` and `ba-serve`.
- At investigation time, Runner had no Background Download extension or App
  Group entitlement. The extension has since been added in the implementation
  recorded below; App Group setup remains outstanding.

Proposed provider split:

| Client | Delivery provider | Game-facing theme representation |
| --- | --- | --- |
| iOS/iPadOS 26+ with configured Apple hosting | Native `AssetPackManager` through a Flutter platform channel | Existing `ThemeDefinition` and validated installed theme |
| iOS 15–25 | HTTPS catalogue and ZIP download | Same |
| Android | HTTPS catalogue and ZIP download | Same |
| macOS | Separate follow-up decision; retain existing bundled/local behaviour initially | Same |

Provider selection must consider OS support and native configuration. An Apple
download or purchase error must not silently bypass entitlement checks by
switching providers. Both providers use the same immutable theme IDs, content
versions and ownership rules.

Native integration plan (see implementation status below):

1. Add an Apple-hosted, managed Background Download extension to Runner.
2. Register a shared App Group for Runner and the extension under the existing
   developer team, then configure the matching signing profiles. The group ID
   and extension bundle ID have not been registered or changed by this work.
3. Configure `BAAppGroupID`, `BAHasManagedAssetPacks = YES` and
   `BAUsesAppleHosting = YES` in the host app as Apple documents.
4. Bridge pack discovery, availability, progress, cancellation and removal to
   Dart using `AssetPackManager`. Guard APIs by their actual OS availability;
   several newer convenience APIs require versions later than iOS 26.0.
5. Package one free, on-demand theme and a small catalogue pack. Keep theme
   catalogue metadata separate from Apple's packaging manifest. Apple-hosted
   packs do not support the packaging manifest's custom `userInfo` dictionary.
6. Exercise native delivery using Apple's local HTTPS mock server, then verify
   actual Apple delivery through TestFlight. Local testing requires a trusted
   server certificate and the device's Background Assets development override.
   No certificate, trust setting or development override has been changed.

Storage and installer integration proposal:

- Apple stores its downloaded asset-pack contents in system-managed storage;
  resolve files using its API rather than assuming a sandbox directory.
- For the first pilot, include the canonical theme ZIP inside the Apple asset
  pack. Both providers can then feed the same ZIP into the existing Phase 2
  installer without introducing a second manifest/asset validation path.
- The game's validated installation remains in the private Application Support
  directory at `themes/installed/<theme-id>/versions/<version>/`, with
  `current.json` as the active-version pointer. Files remain available offline.
- During native installation, both the Apple delivery copy and the extracted
  game installation may exist. Remove the Apple delivery copy only after the
  private installation succeeds; never remove a previous working theme first.
- An update to Apple's delivery copy does not automatically update the game's
  private installation. A later update action must validate and activate the
  new content. The Phase 4 update workflow must account for this explicitly.
- HTTPS catalogue caching belongs under `themes/catalogue/`; partial ZIP files
  belong under `themes/temp/`. iOS container UUIDs are not stable paths and must
  never be hard-coded.

Integrity and lifecycle work required for either route:

- Compare the ZIP's actual size and SHA-256 with trusted catalogue metadata.
- Compare the extracted manifest's theme ID, content version and minimum app
  build with the requested descriptor before writing `current.json`.
- Preserve the previous working installation on failure. Extend the existing
  installer rather than allowing downloaded content to bypass its validation.
- Abort and clean up partial transfers on cancellation. Report completion only
  after installation has committed successfully.
- Keep catalogue refresh and downloads off the app's critical launch path;
  cached and bundled themes must work without the network.
- Treat automatic Apple transport updates and game content updates as separate
  operations. Keep paid entitlements in Phase 5, independent of hosting.

Remaining external configuration:

- Register the App Group and extension identifier and configure provisioning.
- Create and upload the pilot asset packs in App Store Connect and test them.
- Choose an HTTPS host for the fallback catalogue, previews and ZIPs.

The investigation itself did not implement native delivery or publish hosting.
Provisional HTTPS implementation files were removed when the hosting direction
changed. Subsequent implementation is recorded separately below.

Verification performed for the investigation: read Apple's current
documentation, inspected the installed SDK/template and packaging-tool help,
and checked Runner's existing deployment and target configuration. No builds,
Flutter analysis, tests, signing changes, uploads or commits were performed.

Primary references:

- [Apple-hosted asset-pack overview](https://developer.apple.com/help/app-store-connect/manage-asset-packs/overview-of-apple-hosted-asset-packs)
- [Downloading Apple-hosted asset packs](https://developer.apple.com/documentation/backgroundassets/downloading-apple-hosted-asset-packs)
- [Creating managed asset packs](https://developer.apple.com/documentation/backgroundassets/creating-managed-asset-packs)
- [Testing asset packs locally](https://developer.apple.com/documentation/backgroundassets/testing-asset-packs-locally)

#### Steps 1 and 2 implementation — 2026-11-24

Scope requested: prepare the Marine Life pilot and add the Apple Background
Download extension plus Flutter bridge. App Group registration, signing,
runtime download/install testing and uploading are later steps.

Step 1: complete locally.

- Builder: `scripts/build_marine_theme_pack.py`; uses Pillow already listed in
  `requirements.txt` and does not modify the source images.
- Input: the nine images under `flutter_app/assets/images/marine/`, in the
  digit order documented in section 24.
- Output: nine square 512×512 WebP tiles, a 768×768 preview and schema-1
  `manifest.json`, including per-asset SHA-256 checksums. Padding preserves
  image aspect ratio and transparency. The pilot has no audio.
- The canonical `marine_v1.zip` is 566,590 bytes, with SHA-256
  `1fca72660f55e0b7939e4186af568521f85b814b3b41cab4611ea7b08d138876`.
  Content version is 1; minimum app build is 359. These values describe this
  build; use the generated report after rebuilding with a later app version.
- Apple on-demand archive `marine_v1.aar` uses asset-pack ID `marine` and
  exposes the ZIP as `ThemePacks/marine_v1.zip`.
- Apple on-demand archive `theme_catalogue_v1.aar` uses asset-pack ID
  `theme_catalogue`. It exposes `ThemeCatalogue/catalogue.json` and the separate
  browser preview at `ThemePreviews/marine_v1.webp`.
- The Apple pilot catalogue includes `apple_asset_pack_id`, `archive_path`,
  `preview_path`, ZIP checksum/size, content version and compatibility metadata.
  These provider-specific fields supplement the common theme identity. It is
  not an HTTPS catalogue with fabricated public download URLs.
- All generated artifacts are under `flutter_app/build/theme_packs/`, an ignored
  build-output directory. Keep the builder in Git and regenerate these files
  when needed; archive release artifacts separately before cleaning `build/`.
- No changes to `pubspec.yaml` are required: downloadable images are not added
  to the bundled Flutter asset list.

Rebuild from the repository root:

```sh
python3 scripts/build_marine_theme_pack.py --package-apple
```

Omit `--package-apple` to generate only the shared ZIP, preview, manifests and
catalogue on a machine without Xcode. Apple archives use `.aar` for Apple's
asset archive format; these are not Android library archives.

Step 2: source implementation complete; not app-built or runtime-verified.

Files created:

- `flutter_app/ios/ThemePackDownloader/DownloaderExtension.swift`
- `flutter_app/ios/ThemePackDownloader/Info.plist`
- `flutter_app/ios/Runner/AppleThemePackPlugin.swift`
- `flutter_app/lib/ui/theme/apple_theme_pack_delivery.dart`
- `flutter_app/test/apple_theme_pack_delivery_test.dart`
- `scripts/build_marine_theme_pack.py`

Files modified:

- `flutter_app/ios/Runner.xcodeproj/project.pbxproj`
- `flutter_app/ios/Runner/AppDelegate.swift`
- This blueprint.

The new `ThemePackDownloader` ExtensionKit target uses Xcode's
`StoreDownloaderExtension` pattern, targets iOS 26, and is a build dependency of
Runner embedded under the app's `Extensions/` directory. It supports Debug,
Release and Profile, with build/version values taken from Flutter's generated
configuration to match the host app. Its local bundle identifier is
`org.topository.animalsudoku.ThemePackDownloader`; it has not been registered in
the developer portal. Runner retains its existing iOS 15 minimum and weak-links
BackgroundAssets. No team, App Group entitlement or provisioning profile was
assigned to the extension.

`AppleThemePackPlugin` is registered with the existing implicit Flutter engine.
The method channel is `org.topository.animalsudoku/apple_theme_packs`; progress
uses the corresponding `/progress` event channel. The Dart API provides:

- `getConfiguration()`: OS support and App Group/hosting configuration status;
- `listAssetPacks()`: native pack IDs, Apple delivery versions and sizes;
- `ensureAvailable(assetPackId:, relativePath:)`: request delivery and resolve
  a pack-owned local file;
- `localPath(assetPackId:, relativePath:)`: resolve an existing file offline;
- `progress`: pack-tagged waiting/paused/downloading/available/cancelled/failed
  events;
- `cancelDownload(assetPackId)`: request native cancellation;
- `removeAssetPack(assetPackId)`: remove only the Apple-managed delivery copy.

The bridge checks OS availability, including APIs introduced after 26.0,
rejects unsafe IDs and relative paths, checks pack membership before returning
a file URL, rejects duplicate active requests, and returns platform errors to
the caller. Progress cancellation uses Apple's `Progress.cancel()` together
with the request task; it may finish asynchronously. Unsubscribing from progress
does not cancel a background request.

Nothing downloads during plugin registration or normal game startup. Until
step 3 configures the host's Background Assets keys and a valid shared App
Group, `getConfiguration()` reports `configured: false` and delivery operations
return `not_configured`. Android and pre-iOS-26 support queries return
unsupported rather than attempting an Apple download.

Example for the future installer/browser integration, after step 3:

```dart
final delivery = AppleThemePackDelivery();
final configuration = await delivery.getConfiguration();
if (configuration.supported && configuration.configured) {
  final path = await delivery.ensureAvailable(
    assetPackId: 'marine',
    relativePath: 'ThemePacks/marine_v1.zip',
  );
  // Next: verify ZIP size/SHA-256 and manifest identity, then invoke the shared
  // local installer. Native availability alone is not a validated install.
}
```

Step 3 setup plan (completed below for development provisioning):

1. Select the existing developer team for `ThemePackDownloader` in Xcode and
   register its bundle ID.
2. Register one App Group shared by Runner and ThemePackDownloader, enable the
   capability on both targets, and configure their entitlement files/profiles.
3. Add `BAAppGroupID` with that exact group ID,
   `BAHasManagedAssetPacks = YES` and `BAUsesAppleHosting = YES` to Runner's
   information property list as Apple documents. Do not invent a public
   `BAManifestURL` for Apple-hosted delivery.

Verification performed for steps 1–2:

- Built both Apple asset archives with the installed `ba-package` tool.
- Verified ZIP integrity, every image checksum and output dimensions, and
  checked that source image bytes were unchanged. Inspected the preview.
- Parsed the Swift sources, validated the property lists/project syntax, and
  inspected target dependency, embedding and build-configuration references.
- Formatted the Dart files and checked Git whitespace errors.

Tests created: bridge tests for configuration, unsupported platforms, missing
plugin, discovery, request forwarding, safe paths, error propagation, explicit
cancellation/removal and progress events.

Flutter analysis, unit tests and application builds run by AI Assistant:
**None — manual verification requested**, following `docs/CURRENT_STATE.md`.
Asset packaging above is not a successful Runner build or an Apple-hosted
download test.

Manual verification from `flutter_app/`:

```sh
flutter analyze
flutter test test/apple_theme_pack_delivery_test.dart
```

After step 3 signing/setup, build and run the iOS app, check that the new target
embeds correctly, and verify native delivery against Apple's local mock server
before TestFlight. The normal game should still launch without initiating any
pack requests. Full ZIP validation/installation integration, retry policy,
catalogue caching, HTTPS fallback and the Phase 4 browser remain outstanding.

Suggested commit message:

```text
Prepare Marine Life pilot and Apple theme delivery bridge
```

#### Step 3 implementation — 2026-11-24

Status: shared App Group and automatic signing are configured, and Xcode has
issued matching development profiles for both targets. A successful app build,
device runtime check and distribution signing are not claimed.

Identifiers:

| Setting | Value |
| --- | --- |
| Developer team | `QL5QBFGDB7` (existing David Browning team) |
| Host bundle ID | `org.topository.animalsudoku` |
| Extension bundle ID | `org.topository.animalsudoku.ThemePackDownloader` |
| Shared App Group | `group.org.topository.animalsudoku.theme-packs` |

Files created:

- `flutter_app/ios/Runner/Runner.entitlements`
- `flutter_app/ios/ThemePackDownloader/ThemePackDownloader.entitlements`

Both entitlement files declare the same single
`com.apple.security.application-groups` entry.

Files modified:

- `flutter_app/ios/Runner/Info.plist`: added `BAAppGroupID`,
  `BAHasManagedAssetPacks = true` and `BAUsesAppleHosting = true`; no unmanaged
  `BAManifestURL` was added.
- `flutter_app/ios/Runner.xcodeproj/project.pbxproj`: added both entitlement
  references, wired `CODE_SIGN_ENTITLEMENTS` for both targets in Debug, Release
  and Profile, selected the existing developer team and automatic signing, and
  enabled the App Groups capability on both targets.
- This blueprint: recorded implementation and verification status.

Provisioning performed:

- Opened Runner's Signing & Capabilities in Xcode. Both targets show David
  Browning, automatic signing, the shared App Group and an Xcode Managed Profile.
- Xcode issued fresh development profiles for the host and extension on
  2026-11-24. Decoded the profiles and verified that each has team `QL5QBFGDB7`,
  its expected application identifier and the exact shared group entitlement.
- This confirms Apple-side development registration/provisioning, rather than
  only local entitlement declarations. Profiles and signing credentials remain
  in Xcode's user-data storage and are not added to the repository.
- An older cached App Store distribution profile lacks the new group. Let
  automatic signing refresh distribution profiles when preparing the first
  archive; do not select that old profile manually. Distribution profile
  creation and an App Store archive have not been verified in this step.

Verification performed:

- Property-list and Xcode project syntax validation passed.
- Checked all six target/configuration combinations for matching team,
  automatic signing and entitlement paths; verified the group matches the host
  `BAAppGroupID` exactly.
- Verified matching Apple-issued development profiles for both bundle IDs.
- Git whitespace validation passed.

Tests created or modified: none; this step changes signing/configuration only.
Flutter analysis, unit tests and application builds run by AI Assistant:
**None — manual verification requested**, following `docs/CURRENT_STATE.md`.

Manual verification from `flutter_app/`:

```sh
flutter build ios --simulator --debug
```

Then select Runner and a physical iOS 26+ device in Xcode and build/run using
the new managed profiles. Check that the normal app still launches and that
the native bridge's `getConfiguration()` reports supported/configured on that
newly signed build. An older installed simulator/device build will not contain
the new information-property-list keys or entitlements until rebuilt.

Step 4's developer test harness is implemented below; running the real native
delivery/installation flow remains a manual verification task. Actual
Apple-hosted downloads require the later App Store Connect / TestFlight setup
or Apple's local development mock server. Phase 3 as a whole remains in
progress; the theme browser remains Phase 4.

Suggested commit message:

```text
Configure shared App Group and signing for Apple theme packs
```

#### Step 4 developer test harness — 2026-11-24

Implemented a debug-only **Theme pack test** entry in the existing developer
drawer section, enabled by seven version-title taps within four seconds. The
free Marine Life pilot requires no Full Version entitlement or store purchase.
The normal game startup performs no pilot network requests.

The screen checks native support/App Group configuration, loads existing local
metadata, fetches the pilot catalogue, displays native delivery progress and
installs through `LocalThemePackInstaller`. It can cancel an active request,
reload/validate installed assets offline, remove only the pilot installation,
or remove Apple's delivery copy after a private installation is verified.
The installed nine tiles are displayed using `RepositoryThemeLoader` and
file-backed images. This is a developer delivery/installation test, not the
Phase 4 theme browser or regular game theme-selection integration.

Integrity/lifecycle details:

- Only a unique, active, explicitly free `marine` entry is accepted, with the
  expected native pack ID, versioned relative ZIP path, bounded size, SHA-256
  and compatible app build. Paid or malformed entries are rejected.
- A valid native catalogue is cached atomically under
  `themes/catalogue/apple_pilot.json`. Failed refreshes preserve the old valid
  cache and show a warning when it is used. Cache reads and offline installation
  verification do not call the native delivery service.
- Copy the ZIP into an owned `themes/temp/marine_pilot_*/` directory before
  hashing/extraction, so native updates cannot replace bytes after verification.
  Verify exact size and SHA-256 before extraction.
- The shared installer now accepts optional expected theme ID/version, current
  app build and a cancellation callback, and checks them before activation.
  Existing local callers remain compatible. The extractor also enforces
  compressed, total extracted and entry-count limits.
- Keep both the previous installation and Apple's delivery copy on failure.
  Same-version installation is idempotent after validation. Different versions
  require explicit removal in this pilot; an update/replacement workflow remains
  future work. Temporary files are cleaned after success, failure/cancellation.
- Cancellation is accepted until activation begins. Once committed, a valid
  installation is not rolled back by a late cancellation. Removing the native
  delivery copy is a separate explicit action after local verification.
- Manual retry uses the same Fetch/Download buttons; no automatic retry policy
  or general HTTPS fallback is implemented by this harness.

Files created:

- `flutter_app/lib/ui/debug/marine_theme_pack_test_screen.dart`
- `flutter_app/lib/ui/theme/marine_theme_pack_pilot.dart`
- `flutter_app/test/marine_theme_pack_pilot_test.dart`
- `flutter_app/test/marine_theme_pack_test_screen_test.dart`
- `scripts/serve_marine_theme_packs.sh`
- `docs/theme_packs/Marine_Life_Pilot_Testing.md`

Files modified:

- `flutter_app/lib/ui/sudoku_screen.dart`
- `flutter_app/lib/ui/sudoku_screen_builders.dart`
- `flutter_app/lib/ui/widgets/sudoku_drawer.dart`
- `flutter_app/lib/ui/widgets/sudoku_drawer_aux_sections.dart`
- `flutter_app/lib/ui/theme/local_theme_pack_installer.dart`
- `flutter_app/lib/ui/theme/local_theme_pack_extractor.dart`
- `flutter_app/test/sudoku_screen_debug_toggle_test.dart`
- This blueprint.

Tests added cover service installation/discovery, offline loading, catalogue
fallback, invalid size/SHA-256, manifest identity/version/build mismatch,
cancellation and cleanup, retaining a valid installation, damaged assets,
explicit delivery removal and rejecting paid/incompatible catalogue entries.
The screen test checks unsupported setup, disabled download actions and the
offline action. The existing screen test now checks the seven-tap menu gate.

Verification performed: Dart formatting/parser checks, shell syntax validation
for the server helper and Git whitespace checks. Tests, Flutter analysis, native
downloads and application builds run by AI Assistant: **None — manual
verification requested**, following `docs/CURRENT_STATE.md`.

From `flutter_app/`, run:

```sh
flutter analyze
flutter test test/marine_theme_pack_pilot_test.dart test/marine_theme_pack_test_screen_test.dart test/local_theme_pack_installer_test.dart test/sudoku_screen_debug_toggle_test.dart
```

Follow [Marine Life pilot testing](Marine_Life_Pilot_Testing.md) for asset
generation, trusted TLS server identity, `ba-serve`, the device's Development
URL Override, opening the debug screen and the download/offline/removal checks.
The helper does not create certificates, change trust, configure device
overrides, upload anything or build the application. No local server or native
download was started by this implementation.

Outstanding: execute real iOS local-server testing and native integration
validation, production retry/update policies, general provider/HTTPS fallback,
TestFlight distribution/asset publication and the Phase 4 theme browser. Review
the changes and commit after manual verification; Phase 3 remains in progress.

Suggested commit message:

```text
Add Marine Life developer delivery and installation test flow
```

### Phase 4: Theme browser UI

- [ ] Show bundled and remote packs.
- [ ] Display installation states.
- [ ] Add download, remove and update actions.
- [ ] Add storage-size information.

### Phase 5: Purchases

- [ ] Add product identifiers.
- [ ] Implement entitlement checks.
- [ ] Add purchase and restore flows.
- [ ] Ensure purchase completion is independent of download success.

### Phase 6: Production hardening

- Add signing or stronger integrity checks if needed.
- Add analytics for failed downloads.
- Add automated pack validation before upload.
- Add compatibility and migration tests.
- Document the release process for new packs.

---

## 23. Pack publishing workflow

For every new or updated theme:

1. prepare the artwork and sounds;
2. generate `manifest.json`;
3. validate file names and dimensions;
4. build the ZIP;
5. calculate SHA-256;
6. upload preview and ZIP;
7. update `catalogue.json`;
8. create or confirm the store product;
9. test on staging;
10. publish the catalogue update.

Recommended command-line validation should check:

- schema validity;
- missing files;
- duplicate tile IDs;
- incorrect tile count;
- invalid paths;
- unsupported formats;
- oversized assets;
- checksum generation.

---

## 24. Suggested first pack

Pilot selected by David on 2026-11-24: **Marine Life** (`marine`). Use the nine
existing PNG images in `flutter_app/assets/images/marine/`, restored from
`assets/images/unused/marine/`. This is the source directory for pack preparation;
do not use the former `unused/marine/` location or copy images from Sudoku_02.

| Digit | Source image | Tile label |
| --- | --- | --- |
| 1 | `1_butterflyfish.png` | Butterflyfish |
| 2 | `2_octopus.png` | Octopus |
| 3 | `3_crab.png` | Crab |
| 4 | `4_seahorse.png` | Seahorse |
| 5 | `5_starfish.png` | Starfish |
| 6 | `6_walrus.png` | Walrus |
| 7 | `7_shark.png` | Shark |
| 8 | `8_jellyfish.png` | Jellyfish |
| 9 | `9_turtle.png` | Turtle |

Keep these source images outside the app's bundled asset list when preparing
the downloadable pilot; the pack builder reads them directly from disk.

Use one small free pack as the pilot.

Recommended characteristics:

- nine tile images;
- one preview;
- no audio initially;
- approximately 2–5 MB;
- no purchase requirement;
- one simple catalogue entry;
- version 1;
- schema version 1.

This proves the architecture before adding paid products or larger packs.

---

## 25. Final recommendation

The most maintainable design for Sudoku Playtime is:

> Keep a small set of polished starter themes inside the app, while treating every additional theme as a versioned, downloadable data pack.

The game UI should depend only on `ThemeDefinition`. The repository layer should hide whether a theme came from bundled assets or local downloaded storage. Purchases should unlock access, while downloads and installations should remain separate, resumable operations.

This architecture controls the initial app size, supports future expansion and avoids creating separate companion applications for every theme collection.
