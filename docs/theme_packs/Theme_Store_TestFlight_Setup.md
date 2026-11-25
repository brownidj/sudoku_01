# Downloadable themes and TestFlight setup

## Implemented app flow

Open the side drawer and choose **Downloadable themes**, between the Full
Version section and About. Marine Life, Planets, and Antique Buttons are
separate one-time purchases, independent of Full Version. Prices come from
Apple in the customer's storefront currency; the app does not hard-code a price.

The screen supports purchase, pending/cancelled results, restore, download
progress/cancellation, retry, removal, and **Use in puzzle**. Selection preserves
the current puzzle. Installed images, tile names, creature previews and music
use the same gameplay services as the existing Marine Life pilot.

Purchases are offered only when both the App Store product and the matching
paid catalogue entry are available. Purchase completion is independent of
file installation: failed downloads retain ownership, and retry never buys
again. Removing downloaded files retains the purchase. StoreKit 2 verifies
signed transactions; no preference flag grants a paid download. Paid manifests
identify their product; game loading checks that verified entitlement again.
Existing free developer-pilot files remain development content, not evidence
of ownership of the new product.

### Using an installed developer pilot

A locally validated Marine Life developer pack (installed manifest has no
`product_id`) can use **Use in puzzle** without a store purchase or published
catalogue. This does not grant ownership or permit downloading a paid pack.
The exception is limited to Marine Life. Installed paid packs must retain the
matching product ID and verified ownership; Full Version, unavailable store
products, missing catalogues or a revoked purchase do not unlock them.
Corrupt/missing installations and busy operations keep the button disabled.
The game still independently checks paid ownership before loading media.

## Create the App Store products

In App Store Connect, open **Apps → SuDoKu Playtime → Monetization → In-App
Purchases**, click **+**, and create a **Non-Consumable** for each row below.
Use the Product ID exactly as shown; the Reference Name is for your own use.

| Reference/display name | Product ID | Native asset-pack ID |
| --- | --- | --- |
| Marine Life | `theme_marine` | `marine` |
| Planets | `theme_planets` | `planets` |
| Antique Buttons | `theme_antique_buttons` | `buttons` |

For each product, add the customer-facing name and description, select a price
and availability, and provide the required App Review information/screenshot.
Complete any outstanding paid-app agreements, tax and banking setup. The
prices are David's decision; none has been created or selected by this change.
See [Apple's product creation instructions](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-consumable-or-non-consumable-in-app-purchases)
and [pricing instructions](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/set-a-price-for-an-in-app-purchase).

The defaults above are in `flutter_app/lib/ui/theme/downloadable_theme_catalog.dart`.
If different IDs are created, use `MARINE_THEME_PRODUCT_ID`,
`PLANETS_THEME_PRODUCT_ID`, and `BUTTONS_THEME_PRODUCT_ID` Dart defines consistently
for app builds and catalogue/manifest packaging. Do not reuse `premium_unlock`.

## Marine Life assets prepared for upload

Content version **5** keeps the nine butterfly fish images and includes two tunes for every fish (18 in total). Tile order and display
names come from `<n>_<name>_butterflyfish.png`:

| Digit | Display name |
| --- | --- |
| 1 | Threadfin Butterfly Fish |
| 2 | Copperband Butterfly Fish |
| 3 | Raccoon Butterfly Fish |
| 4 | Saddled Butterfly Fish |
| 5 | Ornate Butterfly Fish |
| 6 | Meyers Butterfly Fish |
| 7 | Blackback Butterfly Fish |
| 8 | Redtail Butterfly Fish |
| 9 | Pyramid Butterfly Fish |

These filename-derived names appear in the preview and long-press caption.
The active source directory, `flutter_app/assets/images/marine/`, contains only
the nine `<n>_<name>_butterflyfish.png` images above. On 2026-11-25, the eight
obsolete animal images (`2_octopus.png` through `9_turtle.png`) and the
misnamed duplicate `1_threadfin.png.png` were removed from that directory.
Archived animal images remain under `flutter_app/assets/images/unused/`,
including `1_butterflyfish_old.png`; they are not inputs to the current pack.

Audio sources are under `flutter_app/assets/audio/marine/`:

| Fish | Long-press tunes |
| --- | --- |
| Threadfin (1) | `1_threadfin_1.mp3`, `1_threadfin_2.mp3` |
| Copperband (2) | `2_copperband_1.wav`, `2_copperband_2.wav` |
| Raccoon (3) | `3_raccoon_1.wav`, `3_raccoon_2.wav` |
| Saddled (4) | `4_saddled_1.wav`, `4_saddled_2.wav` |
| Ornate (5) | `5_ornate_1.wav`, `5_ornate_2.wav` |
| Meyers (6) | `6_meyers_1.wav`, `6_meyers_2.wav` |
| Blackback (7) | `7_blackback_1.wav`, `7_blackback_2.wav` |
| Redtail (8) | `8_redtail_1.wav`, `8_redtail_2.wav` |
| Pyramid (9) | `9_pyramid_1.wav`, `9_pyramid_2.wav` |

On each fish long press, the app randomly chooses one of that fish’s two tunes.
Previews remain capped at four seconds. Background music pauses during a preview
and resumes the same track at its previous position; overlapping previews
extend the pause until the latest preview ends. Ambient background music uses all 18
active tunes, starting at a random track and cycling through the playlist.
The Threadfin songs were renamed from “Butterfly Fish.mp3” and
“Butterfly Fish-2.mp3”; the former ten-second clip was moved to Mac Trash.
Archived audio under `audio/unused/marine/` is excluded. Each audio filename must match both the digit and image species:
`<digit>_<species>[_<take>].mp3`, `.wav`, or `.m4a`. New matching files are picked
up on the next pack build. Invalid digit/species combinations fail packaging.

Manifest `long_press` retains a first-tune fallback for older apps;
`long_press_variants` lists all alternatives. The updated app validates and loads
every variant before choosing randomly. Each tune is stored once in
`audio/tunes/` and referenced by both tile audio and the ambient playlist.
Packaging requires `ffmpeg`: WAV originals are preserved and encoded as
128 kbps AAC `.m4a` copies, keeping the pack within
the 64 MiB download limit. MP3/M4A inputs are copied unchanged.

Previously installed content remains unchanged until replaced. In the developer
pilot, remove the Apple delivery copy while the old pack is still installed
(also clearing its catalogue cache), remove the installed pilot, then
fetch/install v5. Restart the local server with the updated helper to serve v5.
Rebuild the app to enable random preview alternatives. App version/build remains
**2.0.1+400**; content versioning is independent. Existing purchases do not need
to be bought again.

Packaging regression checks from the repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 .venv/bin/python -m unittest discover \
  -s scripts/tests -p 'test_build_marine_theme_pack.py' -v
```

These check filename-derived names, digit order, missing/duplicate sources,
image-to-digit encoding, species-specific preview alternatives, music, checksums and the paid
product ID. Flutter tests also load/decode the nine real fish images, check
the displayed names, and compare installed audio/music to the source by SHA-256.

Historical v3 butterfly fish replacement validation: five packaging tests and all 319 Flutter
tests passed; `flutter analyze` was clean. Both free developer and paid v3 Apple
archives were rebuilt and the generated preview was visually checked. The pack
builder, local-server helper, store description, media-loading/long-press tests,
and this guide were updated; packaging tests were added under `scripts/tests/`.
No app was installed, server restarted, asset uploaded, or commit created in
this replacement step. Suggested commit:
`Replace Marine Life animals with filename-linked butterfly fish media`.

Initial three-tune v4 validation (2026-11-25): `flutter analyze` reported no issues; all 67 targeted
Flutter tests and seven packaging tests passed. Free developer and paid Apple
archives were generated and their ZIP contents/checksums validated. Each ZIP
is approximately 62.3 MB (59.4 MiB), within the 64 MiB delivery limit. Source
audio is copied without conversion. No iPhone app/pack installation, running
server change, App Store upload or commit was performed for v4. To verify on a
phone, install the updated app and v4 pack, long-press Threadfin and Redtail
repeatedly, and enable background music to check all three tunes.
Suggested commit: `Link Marine Life species tunes and random preview variants`.

The paid build is separate from the local developer server's free pilot:

- `flutter_app/build/theme_packs_testflight/marine_v5.aar`
- `flutter_app/build/theme_packs_testflight/theme_catalogue_v5.aar`
- The ZIP, paid `catalogue.json`, and build report are in that same directory.
- The manifest and catalogue bind Marine Life to `theme_marine`.
- Nine fish images and 18 tunes are included: two for every fish, all available for ambient music. Regenerate the paid archives with the command below before uploading v5; previously built paid archives contain older content.

To rebuild from the repository root, using this project's Python environment:

```sh
.venv/bin/python scripts/build_marine_theme_pack.py \
  --output flutter_app/build/theme_packs_testflight \
  --package-apple --product-id theme_marine
```

Upload both `.aar` files to this app in App Store Connect using Transporter or
another supported upload tool, and wait for processing. Upload a distribution
release build of the app as well; the development profile installed on David's
phone is not a TestFlight upload. Check distribution signing/App Group access
for both Runner and ThemePackDownloader. Version/build was left at `2.0.1+400`;
use a new build number if 400 has already been uploaded.

Internal TestFlight testing uses processed asset packs. For external testers,
select and submit the pack versions to TestFlight App Review. Testers need an
Apple Account with access to the beta app for asset delivery; a Sandbox account
alone does not grant beta asset access. TestFlight in-app purchases use the
sandbox, so test purchases do not charge testers. Follow
[Apple's asset-pack testing instructions](https://developer.apple.com/help/app-store-connect/test-a-beta-version/test-apple-hosted-asset-packs)
and [StoreKit testing guidance](https://developer.apple.com/documentation/storekit/testing-at-all-stages-of-development-with-xcode-and-the-sandbox).

On the TestFlight phone, disable the local Background Assets development URL
override. Purchases and assets must both come from Apple's test environment;
no Mac server or development CA is required for that path.

## Planets pack v1

Planets now has a paid on-demand pack, product **`theme_planets`**, content
version **1**, minimum app build **400**. Sources are the existing PNG images
under `flutter_app/assets/images/planets/` and MP3 tunes under
`flutter_app/assets/audio/planets/`. Originals are preserved. The numeric image
prefix fixes puzzle digits; `_01` is an image variant and is omitted from tile
names. The current source audio prefixes now match the images (the earlier
Mercury-first warning no longer applies). The supplied Pluto image is included.

| Digit | Name | Tunes |
| --- | --- | --- |
| 1 | Mars | 3 |
| 2 | Venus | 3 |
| 3 | Earth | 3 |
| 4 | Mercury | 4 |
| 5 | Jupiter | 2 |
| 6 | Saturn | 2 |
| 7 | Uranus | 2 |
| 8 | Neptune | 2 |
| 9 | Pluto | 3 |

On long press the game shows the planet image/name and randomly chooses one of
that planet’s numbered tunes (four-second preview). All **24** tunes form the
ambient playlist. Background music pauses/resumes in place through the shared
playback service. Planets requires its own verified entitlement; neither Marine
Life nor Full Version ownership grants access, and the free Marine Life pilot
exception does not apply to Planets.

The builder encodes 128 kbps AAC `.m4a` copies of all planet MP3s: the source
collection is about 81 MiB, while the pack ZIP is **58,953,359 bytes (56.2 MiB)**,
within the app’s 64 MiB compressed limit. It includes nine 512×512 WebP tiles,
a 768×768 preview, a schema-1 manifest, all 24 tunes and SHA-256 checksums.
Converted audio durations were checked against all 24 originals.

Rebuild from the repository root with the project Python environment:

```sh
.venv/bin/python scripts/build_planets_theme_pack.py --package-apple
```

The paid product ID defaults to `theme_planets`; use `--product-id` only if the
app is configured with the same alternative ID. There is no free Planets build
option. Outputs are in `flutter_app/build/theme_packs_planets/`, including
`planets_v1.aar`, `planets_v1.zip`, build report, manifest, preview, catalogue
and standalone `theme_catalogue_v1.aar`.

### Local Planets testing on David’s iPhone

The release builder always produces a paid `theme_planets` manifest. For local
media testing only, a separate copy can be staged with no product binding and
installed in the phone’s private Planets directory. To load/select that copy,
the app must be built with:

```sh
cd flutter_app
flutter build ios --profile --dart-define=PLANETS_DEVELOPER_PACK=true
```

The exception is limited to Planets in debug/profile builds with the explicit
flag. It is disabled in release builds even if the flag is supplied. Ordinary
builds reject an unbound Planets pack. Paid Planets packs still require verified
ownership in every build, including one with this flag; no purchase is fabricated.
Marine Life’s existing developer policy remains available. Use a normal
release build and the original paid archives for TestFlight/App Store.

After a manual local transfer, validate every asset, write/read back the
Planets `current.json`, restart the opted-in app, and use Downloadable themes →
Planets → Use in puzzle. Preserve other installed themes and their activation
files. A later ordinary build won’t expose the local unbound Planets pack;
the media remains on disk until explicitly removed or replaced.

### Shared catalogue for Marine Life and Planets

Apple delivers one live `theme_catalogue` per distribution context. Do not
replace the shared catalogue with the Planets-only catalogue. Use the prepared
combined upload directory `flutter_app/build/theme_packs_store/`:

- `marine_v5.aar` — paid Marine Life v5, 18 tunes;
- `planets_v1.aar` — paid Planets v1, 24 tunes;
- `theme_catalogue_v6.aar` — both paid entries and both browser previews;
- both ZIPs, `catalogue.json`, previews and the catalogue packaging manifest.

The catalogue archive's local delivery version 6 is distinct from the content
versions 5/1 and App Store Connect’s automatically assigned upload versions.
Recreate the combined directory with:

```sh
.venv/bin/python scripts/build_marine_theme_pack.py \
  --output flutter_app/build/theme_packs_testflight \
  --package-apple --product-id theme_marine
.venv/bin/python scripts/build_planets_theme_pack.py --package-apple
.venv/bin/python scripts/build_theme_pack_catalogue.py \
  --catalogue flutter_app/build/theme_packs_testflight/catalogue.json \
  --catalogue flutter_app/build/theme_packs_planets/catalogue.json \
  --output flutter_app/build/theme_packs_store --version 6 --package-apple
```

The merge validates pack ZIP identities, hashes and sizes, rejects duplicate
IDs/free pilots, and includes each theme's own preview. Regenerate and advance
the local catalogue delivery version for later changes rather than overwriting
an active version during development. Upload all three `.aar` files together,
create/configure both non-consumable products in App Store Connect, then follow
the TestFlight/review steps above. Building files does not publish products or
assets. Physical purchase/download/speaker checks remain rollout validation.

Validation on 2026-11-25: six new Planets packaging tests, seven existing Marine
Life packaging tests and three combined-catalogue tests passed (**16 Python
tests**). `flutter analyze` was clean and **29 targeted Flutter tests** passed.
`test/planets_theme_pack_loading_test.dart` uses the real image/audio sources
to check offline loading, image decoding, all planet names, random tune
alternatives and all 24 background tracks, entitlement revocation and corruption
of an alternate tune. The generated Planets preview was visually checked.
No app build, phone installation, App Store upload or purchase was performed for
this pack preparation. App version/build remains 2.0.1+400.

### Antique Buttons

The app already supports the `buttons` theme ID, but its paid pack is not
prepared yet. It remains Not available yet until its catalogue entry, asset
pack and product `theme_antique_buttons` are ready.

Source images are under `flutter_app/assets/images/buttons/`: pearly cream,
red coat, blue faceted, green marbled, golden brass, lavender flower, brown
leather, turquoise enamel and black carved. No button audio pack was found.

## Validation and manual TestFlight checklist

From `flutter_app/`:

```sh
flutter analyze
flutter test
flutter test integration_test/app_flow_test.dart -d <simulator-id>
flutter build ios --release --no-codesign
```

Automated checks exercise per-product ownership, pending/cancelled purchases,
restore, retries, cancellation, paid manifest/product matching, checksums,
revocation during download, offline installed loading, image decoding, media
paths, persisted selection, drawer placement, and store UI navigation.
Store transactions in Dart tests use controlled gateways, so these do not
prove an actual App Store purchase. The simulator navigation check mocks the
delivery configuration to avoid depending on unpublished Apple-hosted packs.

On a fresh TestFlight installation:

1. Open the drawer entry and inspect Marine Life's preview and localized price.
2. Cancel a purchase and confirm no download is unlocked.
3. Complete the sandbox purchase, download, then choose Use in puzzle.
4. Confirm images, long-press image/name/sound, music and volume controls.
5. Restart offline and confirm the selection and installed media work.
6. Remove the download, restore purchases and download again without buying.
7. Interrupt a download and confirm Retry keeps ownership and the current puzzle.
8. Confirm Full Version alone does not unlock the theme, and buying one theme
   does not unlock another.

No App Store products, prices, uploads, reviews or releases were created by the
assistant. App implementation is ready for sandbox verification; actual
TestFlight purchase/delivery and public release remain external setup steps.

Suggested commit: `Add paid downloadable theme store and purchase-safe delivery`.

## Implementation and validation record — 24 November 2026

- `flutter analyze`: clean.
- Full unit/widget suite: **319 passed**.
- iPhone simulator app-flow suite: **8 passed**, including the drawer/store route
  in the device's natural viewport and the existing tile preview interaction.
- `flutter build ios --release --no-codesign`: passed. This verifies compilation,
  including the StoreKit bridge; it is not a signed TestFlight distribution.
- Paid Marine Life archive builder: passed ZIP/hash, image dimensions, source
  integrity and audio-count checks; both `.aar` files were generated.
- Version/build retained: **2.0.1+400**. No commit or upload was made.

New implementation files are `downloadable_theme_catalog.dart`,
`downloadable_themes_controller.dart`, and `theme_purchase_gateway.dart` under
`flutter_app/lib/ui/theme/`, `flutter_app/lib/ui/themes/downloadable_themes_screen.dart`,
and `flutter_app/ios/Runner/ThemePurchasePlugin.swift`. Native registration and
the Xcode source list were updated. Existing drawer/game builders, theme
selection/persistence, installed-theme/media loaders, manifest validation and
the Marine Life archive builder were extended.

New tests are `downloadable_themes_controller_test.dart`,
`downloadable_themes_screen_test.dart`, `theme_purchase_gateway_test.dart`, and
`paid_theme_game_loading_test.dart`, with a controlled store fixture under
`test/support/`. Existing pilot/installer, selection, selector-label, and
app-flow tests were extended. These paths are under `flutter_app/test/` except
the app-flow test, which is under `flutter_app/integration_test/`.

### Five-tune v4 phone update — 2026-11-25

Both Copperband WAV sources match digit 2 and are included as random preview
alternatives. All five tunes are in the background playlist. `flutter analyze`
was clean; 27 targeted Flutter tests and seven packaging tests passed. The
profile app (2.0.1+400) was rebuilt and installed on David’s iPhone. The free
v4 pack was transferred directly into the app’s private theme storage, read
back and verified against all 15 asset checksums, then activated via
`current.json`. All five installed audio durations match their sources.
The previous v3 pack was backed up at `/tmp/marine-phone-before-v4-20261125`.
The profile app was launched successfully. No puzzle or settings were reset;
no App Store content was uploaded. Speaker playback remains David’s listening
check: long-press Threadfin, Copperband and Redtail repeatedly, then enable
background music and use the track controls to hear all five tunes.

### Eight-tune v4 update and physical UI check — 2026-11-25

Safely moved the old ten-second `1_threadfin_1.mp3` to Mac Trash. Renamed the
full “Butterfly Fish.mp3” and “Butterfly Fish-2.mp3” songs in the active audio
directory to `1_threadfin_1.mp3` and `1_threadfin_2.mp3`, preserving their bytes.
Added the two filename-linked Raccoon WAVs. The existing pack discovery/runtime
supports two random alternatives for each of digits 1, 2, 3 and 8 without a new
application build. All eight tunes are ambient playlist entries.

On David’s iPhone via Mirroring, long-pressed filled puzzle cells and visually
confirmed the correct source image and caption for “Threadfin Butterfly Fish”,
“Copperband Butterfly Fish” and “Redtail Butterfly Fish”. Live audio was not
monitored. `flutter analyze` was clean; all 14 targeted Flutter tests and seven
packaging tests passed after correcting the expanded test fixture.

Rebuilt the developer v4 archives (ZIP approximately 35.8 MB), backed up the
phone’s previous pack to `/tmp/marine-phone-before-eight-tunes-20261125`, replaced
its v4 directory and read back all 18 asset checksums, including the eight tunes.
The existing profile app was relaunched; app version/build remains 2.0.1+400.
Paid archives in `build/theme_packs_testflight/` still contain the earlier five
tunes and must be regenerated before upload using the paid build command above.
No App Store upload or Git commit was performed. Suggested commit:
`Replace Threadfin preview with full songs and include Raccoon tunes`.

## Planets developer installation on David’s iPhone — 2026-11-25

Created a separate local developer copy of Planets v1 by staging the verified
34 assets from the paid build and clearing the product binding only in that
temporary copy. The original paid manifest/catalogue still use `theme_planets`.
Added a shared developer-access policy used by the game loader and store
controller: Planets with no product binding is accepted only when
`PLANETS_DEVELOPER_PACK=true` in a non-release build. Release builds always
reject that exception; a paid Planets manifest still needs its own verified
purchase in every build. Marine Life’s prior developer access remains intact.

Regression coverage was extended in `test/planets_theme_pack_loading_test.dart`,
`test/downloadable_themes_controller_test.dart` and
`test/downloadable_themes_screen_test.dart`. `flutter analyze` was clean. All
28 targeted tests passed in the ordinary configuration, and all 24 Planets/store
tests passed with the developer flag enabled, including checks that paid packs
remain purchase-protected. No new source or test files were needed for this
local access change.

Built and installed profile 2.0.1+400 with both
`PLANETS_DEVELOPER_PACK=true` and `MUSIC_PLAYBACK_DIAGNOSTICS=true`. Transferred
the separate copy to `Library/Application Support/themes/installed/planets/versions/1`,
read it back and verified all 34 asset checksums, then wrote and read back
`planets/current.json` (active_version 1, validated true). Compared the Marine
Life activation before/after: v5 was preserved without modification.

On the physical phone via Mirroring, opened a puzzle and selected Planets from
the theme selector. All nine planet images loaded. Long-pressed Mars and
visually confirmed its large image and caption. Native diagnostics confirmed
`1_mars_2.m4a` playing, while background track `9_pluto_1.m4a` paused at 25,013 ms
and resumed at 25,013 ms. Evidence is in `/tmp/planets-first-phone-playback.json`.
The phone is left in the Planets puzzle with background music enabled for
David to test the other planet tunes. This was a native playback check, not a
remote recording or subjective speaker-quality assessment.

Rebuild future local test apps with the developer flag to keep this local copy
selectable. Use the paid archive and an ordinary release app for TestFlight/App
Store. No store products/entitlements were created, no purchase was made, and
no App Store upload or commit was performed. Suggested commit:
`Enable isolated Planets developer testing in profile builds`.
