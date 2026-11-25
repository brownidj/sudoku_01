# Marine Life developer pilot

This debug screen exercises Apple delivery, the shared ZIP installer and loading
the installed tile images from private application storage. Full Version and
StoreKit purchases are not required. Once installed, Marine Life appears in the
regular game's theme selector after returning from this screen. Select it to
use the downloaded tiles in the current puzzle. Selection is saved across app
restarts. Missing, invalid or undecodable installations fall back to Animals.
This narrow pilot integration does not implement the full theme browser.

## Prepare the asset server

Current content is **v4**, with nine butterfly fish images and filename-derived
names. `flutter_app/assets/images/marine/` now contains only the nine
`<n>_<name>_butterflyfish.png` source images; the old animal images and
`1_threadfin.png.png` duplicate were removed on 2026-11-25. Archived animal
images remain in `flutter_app/assets/images/unused/`. See the
[current asset table and audio mappings](Theme_Store_TestFlight_Setup.md#marine-life-assets-prepared-for-upload).
V4 links two tunes each to Threadfin, Copperband, Raccoon and Redtail.
Previews choose randomly from the selected fish’s own alternatives,
and all eight tunes form the ambient playlist. WAV sources are packaged as AAC
copies to stay within the download limit. Other fish
have image/name previews without sound. The v1/v2 sections below describe
historical content, not the current source inventory.

From the repository root, generate the two Apple archives if needed:

```sh
python3 scripts/build_marine_theme_pack.py --package-apple
```

The output directory is `flutter_app/build/theme_packs/`. The server needs both
`marine_v4.aar` and `theme_catalogue_v4.aar`. These are Apple's asset archives,
not Android libraries. Generated files are ignored by Git and can be recreated.

Apple's mock server requires a TLS server identity, with its private key, in
your Mac's keychain. Its certificate must match the hostname/IP passed to the
server and be trusted by the simulator or physical device. If needed, follow
[Apple's certificate and local-testing guide](https://developer.apple.com/documentation/backgroundassets/testing-asset-packs-locally).
The helper uses `--choose-identity-automatically` to select the server identity
matching the host, without opening Apple's identity picker. macOS may still
ask permission to use the identity's private key. The helper does not create
certificates, change trust, alter device settings, or upload anything.

For a simulator on this Mac:

```sh
bash scripts/serve_marine_theme_packs.sh localhost
```

For a physical iPhone, pass this Mac's reachable hostname or LAN IP instead of
`localhost`, with a matching certificate. For example, if its hostname is
`Mac.local`:

```sh
bash scripts/serve_marine_theme_packs.sh Mac.local
```

The default port is 63245; an optional second argument changes it. Keep the
server terminal open. Stop it with Control-C when finished. The helper uses
native delivery version 4 for both archives; these native versions are separate
from the theme manifest's content version.

If an older server process is waiting at “Choose an identity in the panel to
continue”, stop it with Control-C and run the helper again. The updated helper
does not use that dialog. Its initial “Starting” message is not confirmation
that the HTTPS listener is ready.

If identity selection fails, check the localhost SSL policy from Terminal:

```sh
security find-identity -v -p ssl-server -s localhost
```

The localhost identity must have its private key and a trusted certificate
chain. `CSSMERR_TP_NOT_TRUSTED` means trust still needs configuring; repeatedly
restarting the server or changing the app's App Group cannot fix it.

## Configure the test device

Enable Developer Mode where required. On the simulated or physical iPhone,
open Settings → Developer → Background Assets Testing → Development Overrides
and enter the server's base URL in URL Override, for example:

```text
https://localhost:63245
```

Use the Mac hostname/IP for a physical device. Include the HTTPS scheme and
port and omit paths to individual archives. If using a development CA, install
and explicitly trust it on the test device as Apple documents. A certificate
or hostname mismatch cannot be fixed by unlocking Full Version.

No server, certificate/trust changes or URL override was activated by the code
implementation. Those steps are required before a local download can work.

## Open the test screen

Rebuild and run a debug build containing the App Group/signing changes. From
`flutter_app/`, the previously used simulator can be selected explicitly:

```sh
flutter run --debug -d 0964BE76-B88B-4875-8682-8C7C17609DBA
```

1. Start or resume a game.
2. Tap the version text at the top **seven times within four seconds**.
3. Open the drawer and scroll down to the developer section.
4. Tap **Theme pack test**.

The entry and screen are restricted to debug builds. No network request occurs
when opening the drawer. Opening the test screen checks native support and
configuration and reads existing local files; it does not fetch packs.

## Background music during tile previews

Background music pauses in place while a tile preview plays, then resumes the
same loaded track from its paused position. It does not stop/reload the song,
choose another track or seek back to the beginning. Repeated previews keep
music paused until four seconds after the most recent preview. Music stays
silent while another suspension is active, or if Audio/Background music is
disabled, the game ends or the selected theme changes. Disposing the screen
cancels the preview's pending resume timer.

Regression coverage is in `test/sudoku_background_music_resume_test.dart`
(native-player command contract, retained source/position, slow pause,
overlapping suspension reasons, track controls, mute/game/theme changes) and
`test/sudoku_cell_tooltip_service_test.dart` (real board long press and latest
preview timer). On 2026-11-25, `flutter analyze` was clean and all 329 Flutter
tests passed. The profile app was rebuilt and installed on David’s iPhone; the eight-tune v4 pack
and app version/build 2.0.1+400 are unchanged.

Listening check: enable background music, listen for several seconds, long-press
a fish with audio and wait for its four-second preview to finish. The same
song should continue from the interrupted point. Repeat with a second long
press before the first preview finishes; music must wait for the last preview.

## Exercise the flow

### Updating the image-only v1 pilot to audio v2

Serve the v2 archives with native delivery version 2. The native bridge checks
for updates before resolving the manifest and tolerates an already-scheduled
refresh. To reset native cached delivery data, first press Remove Apple delivery
copy (this now removes the catalogue delivery cache as well). In the debug test
screen, remove the installed v1 pilot, fetch
the catalogue (expect v2), then download and install. This removes only the
pilot's files; it does not reset the puzzle or purchases. The pilot installer
continues to reject replacing a different installed version implicitly.

In the game, select Marine Life, enable Audio and Background music in the
drawer, and use the next/previous controls to change songs. Long-press a
creature tile or filled cell for its clip. Audio plays from private installed
files via DeviceFileSource; no Marine Life audio is added to the app bundle.
The nine original songs are included; numbered alternate takes remain excluded.
The v2 ZIP is approximately 35 MB. Offline game startup validates the installed
files and refreshes the music service after the pack's paths become available.

Verify on a physical phone that music and creature clips are audible, music
resumes after a preview, volume/mute controls work, and playback survives a
profile-build restart. Automated path-resolution tests cannot establish that
the phone speaker is audible.

After installing, return to the puzzle and open the theme dropdown above the
board (the control showing Animals, Instruments, etc.). Choose **Marine Life**.
The board, tile picker and notes use the private installed images. Long-press
previews use the installed file paths and names. Version 2 contains nine creature clips and nine original background songs.
Normal game startup only reads local files; it never fetches packs. The option
appears only after local validation and image decoding succeed. Returning from
the developer test screen refreshes availability after installation/removal.

1. **Check setup**: expect Apple supported and App Group configured to be true
   on a newly rebuilt iOS 26+ app. A failed support/configuration check disables
   native download actions and displays the reason.
2. **Fetch catalogue**: downloads/opens Apple's `theme_catalogue` asset pack,
   parses the free Marine Life descriptor and atomically caches a valid copy.
   A failed refresh can use the previous valid cache, with a visible warning.
3. **Download and install**: requests `marine`, copies the native ZIP to an
   owned temporary directory, verifies exact size/SHA-256, then calls the shared
   installer with expected theme ID/version and current app build. After
   activation, all nine tile images appear using `RepositoryThemeLoader` and
   file-backed images.
4. **Cancel** while fetching/downloading/verifying: requests native cancellation
   or cancels before activation and removes temporary files. Native
   cancellation may finish asynchronously. The screen permits leaving after a
   successful cancellation request. A cancellation arriving after activation
   does not undo a successful installation.
5. To retry a failed operation, press **Fetch catalogue** or **Download and
   install** again. There is no automatic retry loop in this developer screen.
6. **Verify offline**: stop the server/disconnect networking first. This action
   never calls Apple delivery: it validates installed files and reloads them
   using the shared loader. Restarting the app and returning to the screen
   should show the same installed tiles.
7. **Remove Apple delivery copy**: available after a valid installation. This
   removes Apple's copy of `marine` while preserving the game installation.
   Verify offline again to prove it is independent of native delivery storage.
8. **Remove installed pilot**: removes only the private `marine` installation.
   The cached catalogue remains. Reinstalling the same valid version is safe;
   a different version requires explicit removal in this pilot workflow.

For a fresh network-download test, remove the Apple delivery copy while the
private installation is still valid, then remove the installed pilot and
download again with the server running. Otherwise Apple may reuse its already
downloaded archive. Updates to catalogue/asset archives also require Apple's
native cache/update handling; pressing Fetch is not a guarantee of a fresh
network transfer when a native pack is already available.

Use Xcode's debugger or the displayed error for native/TLS failures. A checksum
failure, wrong theme/version or incompatible manifest must leave `current.json`
unmodified and retain any previous valid installation. The regular game's
current puzzle and bundled themes should remain usable throughout testing.

### Simulator helper failure after downloading

On the iOS 26.5 simulator runtime (23F77), the pilot was observed downloading
`theme_catalogue` successfully, then failing while moving the pack into Apple's
managed container. The helper log reported `NSCocoaErrorDomain` code `4099`:
`com.apple.spaceattributiond` could not be found. The resulting app error was
“Couldn't communicate with a helper application.” This is a simulator system
service failure; the two green setup checks only establish native API support
and App Group configuration.

Inspect the relevant log with:

```sh
xcrun simctl spawn booted log show --last 10m --style compact --predicate 'subsystem == "com.apple.backgroundassets.managed" OR eventMessage CONTAINS "com.apple.spaceattributiond"'
```

If the same missing-service error occurs, use a physical iPhone with iOS 26+
and the Mac's reachable hostname in the development URL override (not
`localhost`), or retry on another simulator runtime. Neither alternative has
been verified for this failure yet. Changing App Groups, rebuilding archives,
or unlocking Full Version does not provide the missing system service. The
native bridge now retains NSError domains/codes and adds simulator recovery
guidance for helper connection failures. It does not bypass Apple's delivery
or integrity checks.

## Automated regression checks

From `flutter_app/`:

```sh
flutter analyze
flutter test --coverage
flutter test integration_test/app_flow_test.dart -d <simulator-id>
bash scripts/run_patrol_release_checklist.sh <simulator-id>
```

Use a simulator for integration and Patrol checks: they change preferences and
game sessions. The integration suite covers launch, board controls, drawer/help,
tooltips, bundled theme changes and saved-game resume. Patrol checks drawer
controls and premium difficulty/theme routing through the running iOS app.

Marine Life regression tests cover selector availability, selection persistence,
audio path resolution, music/volume controls, installation button gating,
pending-operation locking, cancellation, failure/retry, offline verification,
removal, and retention of all nine creature sound files and nine music files
in private storage after delivery-cache removal. UI state tests use a controlled
pilot; installer tests use real temporary archives and filesystem operations.
Their synthetic audio bytes establish storage integrity, not media decoding.

Then perform the real local-server/device flow above. Mocked Dart tests cannot
establish that Apple signing, TLS, development overrides or native delivery
work on a device. Listen on the physical phone to confirm audio quality,
creature playback, and background-music suspension/resume during previews.
The user confirmed phone music playback on 24 November 2026.

The 24 November 2026 regression run passed `flutter analyze`, all 283
unit/widget tests, and all six `app_flow_test.dart` simulator tests.
`coverage/lcov.info` reported 5,833 of 8,466 instrumented lines covered (68.9%);
this is Dart line coverage, not a measure of native delivery or visual quality.
The Patrol runner requires `ENABLE_TESTING_SEARCH_PATHS = YES` in the debug
Xcode configuration for its SwiftPM XCTest/XCUIAutomation linkage. The checklist
script also passes the selected simulator's iOS version explicitly because
Patrol 4.4 otherwise defaults to the latest installed runtime.
The UI-test target links Flutter's generated Swift package and uses Patrol's
supplied Objective-C runner macro. This avoids stale module lookups in a copied
runner. Simulator debug runtime search paths include Apple's test support
libraries. The three native checklist files are bundled into a single run so
Xcode's simulator shutdown does not interrupt subsequent targets. The launch
helper waits for asynchronous first-launch guidance before dismissing it, and
waits for dropdown animations before selecting an item.

The repaired native checklist passed all three tests on the iOS 26.5 iPhone 17
Pro simulator. Its result bundle is
`flutter_app/build/ios_results_1795501323294.xcresult` (generated, not committed).
No new source files were created. Regression changes are in
`test/marine_theme_pack_pilot_test.dart`,
`test/marine_theme_pack_test_screen_test.dart`, and
`test/sudoku_drawer_audio_test.dart`; runner repairs are in
`ios/Flutter/Debug.xcconfig`, `ios/Runner.xcodeproj/project.pbxproj`,
`ios/RunnerUITests/RunnerUITests.m`,
`patrol_test/release_checklist_helpers.dart`, and
`scripts/run_patrol_release_checklist.sh` (paths relative to `flutter_app/`).
Version/build remains `2.0.1+400`. Automated regression validation is complete;
physical-device audio quality and preview/music interaction remain listening
checks. Review the changes before committing; suggested commit message:
`Expand Marine Life regression coverage and repair iOS UI test runner`.

For the gameplay integration, also check that selecting Marine Life preserves
the current puzzle, notes and undo history; restart offline and confirm the
selection persists. Remove the installed pilot from the test screen and return
to the game: Animals should be selected and Marine Life should disappear.

## Tile long-press preview regression

Long-press a populated picture tile on the puzzle board. Its enlarged image
and name appear together for four seconds. With Audio enabled, the existing
short creature/instrument clip plays and background music is suspended for
the preview. The image and name remain available when Audio is off or the
tile has no sound. Numbers and empty board cells do not have creature previews.

The overlay previously hid its text whenever an image was present and relied
on an audio-related snackbar for the name. It now always renders the caption,
fits the image/caption to the viewport with text scaling, and cancels the old
dismissal timer when a new preview replaces it.

The new `flutter_app/test/tooltip_overlay_service_test.dart` covers layout,
replacement timing, and disposal. Updated
`flutter_app/test/sudoku_cell_tooltip_service_test.dart` drives actual board
long-press gestures for butterflies and Marine Life, with enabled, muted, and
missing audio; it checks image/name presentation, audio requests, and music
suspension/resume. Audio controllers are faked in these widget tests.
`flutter_app/integration_test/app_flow_test.dart` also checks the fully wired
game screen with audio explicitly muted. These tests protect both the visual
caption and gesture wiring. The implementation change is in
`flutter_app/lib/ui/services/tooltip_overlay_service.dart`.

Manual phone check after rebuilding: select Marine Life, enable Audio, then
long-press a filled board tile and confirm its image, name, and short sound;
repeat with Audio off and confirm its image/name still appear.

Suggested commit: `Restore named tile previews and add gesture regression tests`.

Follow-up validation on 24 November 2026: `flutter analyze` clean, all 292
unit/widget tests passed, and all seven simulator app-flow tests passed. This
preview regression fix is complete in source; it requires rebuilding the app
before checking it on the physical phone. Version/build remains `2.0.1+400`.

### Pause/resume implementation — 2026-11-25

Updated `SudokuBackgroundMusicService` to retain the native player's source and
position through suspensions using pause/resume. Native playback operations
are serialized; track changes respect active suspensions. A muted/disabled
session or changed theme clears the old paused source rather than reviving it.
`SudokuCellTooltipService` now replaces the prior preview resume timer and
cancels it on screen disposal through the service registry.

Created `test/sudoku_background_music_resume_test.dart` (seven regressions) and
extended `test/sudoku_cell_tooltip_service_test.dart` with the overlapping-clip
case. All 329 Flutter tests passed and `flutter analyze` reported no issues.
Profile build and device installation succeeded for 2.0.1+400. Remote launch remained blocked by iOS with a Locked error after unlock/retry.
The app is installed and can be opened from the phone’s Home Screen. Read back
the installed Marine Life v4 manifest and confirmed all eight tunes remain.
No theme pack rebuild is required for this playback-only change. Physical
speaker continuity remains a listening check. Suggested commit:
`Resume background music in place after tile previews`.

### Activation recovery and measured device playback — 2026-11-25

Device inspection found the v4 assets intact but the theme-level `current.json`
missing after the manual development-pack replacement. Previous checks of the
manifest alone did not prove an active installation. Read back and verified all
18 asset checksums, restored the backed-up v4 activation file, then read it back
again. After restarting, physically checked via iPhone Mirroring that Marine
Life appeared in the puzzle selector and the downloads card showed Installed ·
v4 with all nine images. Selected Marine Life in the existing puzzle. During that check, the store card's Use in puzzle button was still
purchase-gated for the free developer pilot; the later fix below enables it
without altering paid entitlement checks.

Future manual replacements must preserve/restore and verify `current.json`
after copying the version directory. Verify its active version, validate every
manifest asset and confirm the installed theme in the running app. Do not treat
successful copying of `versions/4/manifest.json` as completed activation.

For a real-device position check, built/installed the profile app with
`--dart-define=MUSIC_PLAYBACK_DIAGNOSTICS=true`. This opt-in local trace is
inert in release builds and disabled in ordinary builds. It records preview
boundaries and native audio player track, state and position to
`Library/Application Support/music_playback_diagnostics.json`, retaining at most
100 events and transmitting nothing. Diagnostics failures do not affect audio.
The trace helper is `lib/ui/services/music_playback_diagnostics.dart`.

Native player results on David’s iPhone:

| Scenario | Track | Paused position | Resumed position | Outcome |
| --- | --- | --- | --- | --- |
| One Threadfin preview | `2_copperband_1.m4a` | 26.632 s | 26.632 s | Same source/position |
| Threadfin → Copperband → Redtail, 1.5 s apart | `2_copperband_1.m4a` | 54.794 s | 54.795 s | Stayed paused through all three previews |

The second resume occurred 4.009 seconds after the final preview began. Both
cycles reported native states paused → playing, with no new play/source event
between pause and resume. Evidence was read from the actual phone into
`/tmp/marine-music-device-trace.json`. This verifies native player continuity;
it is not a recording or subjective assessment of speaker quality.

Analyze was clean and all 16 targeted music/tooltip tests passed for this trace
build. The earlier pause/resume change also passed the full 329-test suite.
The profile app 2.0.1+400 is running with Marine Life selected. No content files
or purchases were changed during recovery, and no Git commit was created.
Suggested commit: `Add opt-in playback diagnostics and document device verification`.

### Developer pack Use in puzzle policy — 2026-11-25

The loaded `ThemeDefinition` now retains its manifest `product_id`. The store
screen uses the controller's `canUse` policy: a fully validated installed Marine
Life pack with no product binding may be selected without purchase. Other
installed packs require the expected product ID and verified ownership. The
exception does not grant ownership, permit a paid download, extend to Planets
or Antique Buttons, or allow damaged/missing installations. The game keeps its
independent paid entitlement check.

Updated loader, definition, controller and screen. Extended the controller,
screen-navigation and real installed-media tests, and corrected the shared
store fixture to identify paid definitions explicitly. No new source or test
files were needed. `flutter analyze` was clean and all 48 targeted tests passed.
The profile app was rebuilt and installed as 2.0.1+400; the v4 activation file
was read back before and after installation and was unchanged.
Suggested commit: `Allow validated Marine Life developer pack selection`.

Physical verification of the developer Use in puzzle fix: reconnected with
Mirroring, resumed the existing puzzle, selected Animals, opened Downloadable
themes and confirmed the installed v4 Marine Life card had an enabled Use in
puzzle button. Tapped it and observed the same puzzle return with Marine Life
selected and all nine fish images loaded. The app remains running with Marine
Life selected; the active installation and eight audio tunes were preserved.
Paid-theme behavior was verified by the regression tests, not a live purchase.
