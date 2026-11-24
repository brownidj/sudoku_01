# Marine Life developer pilot

This debug screen exercises Apple delivery, the shared ZIP installer and loading
the installed tile images from private application storage. Full Version and
StoreKit purchases are not required. Once installed, Marine Life appears in the
regular game's theme selector after returning from this screen. Select it to
use the downloaded tiles in the current puzzle. Selection is saved across app
restarts. Missing, invalid or undecodable installations fall back to Animals.
This narrow pilot integration does not implement the full theme browser.

## Prepare the asset server

From the repository root, generate the two Apple archives if needed:

```sh
python3 scripts/build_marine_theme_pack.py --package-apple
```

The output directory is `flutter_app/build/theme_packs/`. The server needs both
`marine_v1.aar` and `theme_catalogue_v1.aar`. These are Apple's asset archives,
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
native delivery version 1 for both archives; these native versions are separate
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

## Exercise the flow

After installing, return to the puzzle and open the theme dropdown above the
board (the control showing Animals, Instruments, etc.). Choose **Marine Life**.
The board, tile picker and notes use the private installed images. Long-press
previews use the installed file paths and names. The pilot contains no audio.
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

## Manual checks for this change

From `flutter_app/`:

```sh
flutter analyze
flutter test test/marine_theme_pack_pilot_test.dart test/marine_theme_pack_test_screen_test.dart test/local_theme_pack_installer_test.dart test/sudoku_screen_debug_toggle_test.dart
flutter test test/marine_theme_selection_test.dart test/top_controls_labels_test.dart test/sudoku_screen_asset_loading_test.dart
```

Then perform the real local-server/device flow above. Mocked Dart tests cannot
establish that Apple signing, TLS, development overrides or native delivery
work on a device. No Flutter analysis, tests or app builds were run by the
assistant for this implementation, following `docs/CURRENT_STATE.md`.

For the gameplay integration, also check that selecting Marine Life preserves
the current puzzle, notes and undo history; restart offline and confirm the
selection persists. Remove the installed pilot from the test screen and return
to the game: Animals should be selected and Marine Life should disappear.
