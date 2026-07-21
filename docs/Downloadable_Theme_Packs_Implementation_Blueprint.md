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
  completion.mp3
  selection.mp3
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
    "completion": "audio/completion.mp3",
    "selection": "audio/selection.mp3"
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

### Recommendation

Start with static HTTPS hosting and platform purchase validation. Add a backend only if download abuse, promotions or cross-platform entitlement requirements justify it.

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

- compressed formats suitable for the target platforms;
- short effects rather than long uncompressed files;
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

- Define `manifest.json`.
- Create a sample ZIP pack.
- Install from a local test file.
- Load theme assets from application storage.
- Add uninstall support.

### Phase 3: Remote catalogue and download

- Host a test catalogue and pack.
- Implement catalogue caching.
- Implement download progress.
- Add checksum verification.
- Add retry and cancellation.

### Phase 4: Theme browser UI

- Show bundled and remote packs.
- Display installation states.
- Add download, remove and update actions.
- Add storage-size information.

### Phase 5: Purchases

- Add product identifiers.
- Implement entitlement checks.
- Add purchase and restore flows.
- Ensure purchase completion is independent of download success.

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
