# Expanding Sudoku Playtime with Downloadable Theme Packs

You do **not** need to compile every theme into the original Flutter
bundle. The cleanest approach is to treat additional themes as
**downloadable content packs**: the app contains the theme engine, while
images, sounds, metadata, and previews are downloaded only after the
player chooses a pack.

## Best option: Downloadable theme packs from your own hosting

Store each pack on a web server or cloud-storage service as a versioned
ZIP file:

``` text
theme-packs/
  garden_pack_v1.zip
  vintage_pack_v1.zip
  australia_pack_v1.zip
```

Each pack could contain:

``` text
manifest.json
preview.webp
tiles/
  tile_01.webp
  tile_02.webp
  ...
sounds/
  completion.mp3
```

The app would:

1.  Download a small catalogue describing available packs.
2.  Show pack previews in a **Theme Packs** screen.
3.  Check whether the player owns or may access the pack.
4.  Download the ZIP when requested.
5.  Verify its checksum or signature.
6.  Extract it into the app's private storage.
7.  Load the images from files rather than Flutter's bundled `assets/`
    directory.
8.  Allow the player to delete and reinstall downloaded packs.

### Why this is probably best for Sudoku Playtime

It gives you one implementation that works across iPhone, iPad, Android
and future macOS releases.

Adding a new pack may require only:

-   Uploading the pack.
-   Updating the online catalogue.
-   Creating the corresponding in-app purchase (if required).

The app code already understands the pack format. Downloaded packs
should contain **data and media only**, never executable code.

## Payment

A typical flow is:

``` text
Apple/Google purchase
        ↓
App confirms entitlement
        ↓
App downloads pack from your server
        ↓
Pack becomes available
```

Possible business models include:

-   Individual paid packs.
-   Bundles of several packs.
-   A "Theme Collection" purchase that unlocks all current packs.
-   Free promotional packs.

Include a **Restore Purchases** option and avoid relying solely on
locally stored entitlement flags.

## Platform-managed asset delivery

### Google Play Asset Delivery

Android supports on-demand asset packs that are hosted by Google Play
and downloaded only when required. This is excellent for Android-only
games, but you would still need a separate implementation for Apple
devices.

### Apple-hosted asset packs

Apple supports hosting downloadable assets separately from the main
application. Apple is moving toward Apple-Hosted Background Assets,
making older On-Demand Resources less suitable for new projects. While
useful, maintaining separate Apple and Android implementations adds
complexity.

## Separate companion theme-pack apps

Publishing separate apps purely to contain themes is generally not
recommended.

Disadvantages include:

-   Platform-specific implementation.
-   User confusion.
-   More complicated purchase restoration.
-   Multiple App Store listings.

## Separate editions of the game

Another option is to publish complete editions such as:

-   SuDoKu Playtime
-   SuDoKu Playtime: Nature Edition
-   SuDoKu Playtime: Japan Edition

This is simple technically but duplicates maintenance, testing,
localisation and store management.

## Optimise bundled assets first

Before introducing downloadable packs, consider reducing the current app
size by:

-   Converting PNG images to WebP.
-   Removing unnecessary alpha channels.
-   Resizing images to their actual display resolution.
-   Removing duplicate assets.
-   Compressing music and sound effects appropriately.

## Recommended architecture

The recommended approach is:

> Keep several starter themes bundled with the app, and deliver all
> additional themes as downloadable content packs hosted on your own
> server.

Suggested architecture:

``` text
Bundled themes
├── Available immediately
├── Work offline
└── Enough variety for the free app

Downloadable themes
├── catalogue.json
├── previews
├── ZIP packages
├── version and checksum
├── purchase entitlement
└── local installation records
```

Suggested Flutter services:

``` text
ThemeCatalogueService
ThemeDownloadService
ThemeInstallationService
ThemeEntitlementService
ThemeRepository
```

The rest of the application should simply request a `ThemeDefinition`,
without needing to know whether it originated from bundled assets or
downloaded content. This keeps the game engine clean, extensible and
easy to maintain.
