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

Content version **4** keeps the v3 butterfly fish images and adds species-specific tunes. Tile order and display
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
| Redtail (8) | `8_redtail_1.wav`, `8_redtail_2.wav` |
| Other fish | No matching recording yet; image and name still appear |

On each Threadfin, Copperband, Raccoon or Redtail long press, the app randomly chooses one of that fish’s two tunes.
Previews remain capped at four seconds. Background music pauses during a preview\nand resumes the same track at its previous position; overlapping previews\nextend the pause until the latest preview ends. Ambient background music uses all eight
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
192 kbps AAC `.m4a` copies, keeping the pack within
the 64 MiB download limit. MP3/M4A inputs are copied unchanged.

Installed v2/v3 content remains unchanged until replaced. In the developer
pilot, remove the Apple delivery copy while the old pack is still installed
(also clearing its catalogue cache), remove the installed pilot, then
fetch/install v4. Restart the local server with the updated helper to serve v4.
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

- `flutter_app/build/theme_packs_testflight/marine_v4.aar`
- `flutter_app/build/theme_packs_testflight/theme_catalogue_v4.aar`
- The ZIP, paid `catalogue.json`, and build report are in that same directory.
- The manifest and catalogue bind Marine Life to `theme_marine`.
- Nine fish images and eight tunes are included: two each for Threadfin, Copperband, Raccoon and Redtail, all available for ambient music.

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

## Planets and Antique Buttons

The app has catalogue, purchase, installer, selector, session persistence and
media-loader support for all three IDs. Only Marine Life has a published-format
archive builder and prepared distribution archives in this change. Planets and
Antique Buttons remain **Not available yet** until their own paid catalogue
entries and asset packs are built and uploaded; the screen cannot charge for
missing content.

Source images have been located:

- `flutter_app/assets/images/planets/`: nine PNGs. The current order is Mars,
  Venus, Earth, Mercury, Jupiter, Saturn, Uranus, Neptune, Pluto. Planet music
  filenames use a different initial ordering (Mercury first), so align music
  by planet name when preparing that pack, rather than blindly by digit.
- `flutter_app/assets/audio/planets/`: candidate music tracks and alternate takes.
- `flutter_app/assets/images/buttons/`: nine PNGs: pearly cream, red coat, blue
  faceted, green marbled, golden brass, lavender flower, brown leather,
  turquoise enamel and black carved. No button audio pack was found.

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
