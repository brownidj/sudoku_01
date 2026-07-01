# Google Play Distribution Checklist — Free and Full Versions

Project: **SuDoKu Fresh**  
Platform: **Google Play Store**  
Purpose: staged release plan for distributing both the **Free** version and the **Full** version on Google Play.

---

## 1. Decide the Google Play product structure

Before changing Play Console settings, decide which commercial structure you are using.

### Recommended structure for this project

Use **one free app with an in-app Full Version unlock**.

This is the safest structure if the same installed app contains both Free and Full features, with paid features present but inaccessible until purchase.

Recommended package structure:

```text
com.angrygrannies.sudokuplaytime
```

Commercial structure:

```text
Free download from Google Play
        ↓
Free features available immediately
        ↓
Full features locked behind Google Play Billing one-time product
```

### Alternative structure

Use **two separate Play Store apps**:

```text
com.angrygrannies.sudokuplaytime.free
com.angrygrannies.sudokuplaytime.full
```

This creates a separate paid app listing for the Full version.

This is more work because both apps need separate package names, separate listings, separate review, separate screenshots, and separate release management.

### Important Google Play pricing rule

Once an app has been offered as **free**, Google Play does not allow that same app to be changed to **paid** later. Google says a free app can be changed from paid to free, but once offered for free it cannot be changed back to paid; charging later requires creating a new app with a new package name.

Source: Google Play Console Help, “Set up your app's prices”.

---

## 2. Confirm the Free vs Full feature boundary

Create a release-gate checklist before any Play Store upload.

### Free version must include

- [x] Main playable Sudoku/picture-Sudoku experience.
- [x] At least one complete puzzle flow.
- [x] Basic difficulty level or starter difficulty set.
- [x] Free theme or starter theme set.
- [x] Basic audio/feedback if this is part of the free promise.
- [x] Clear indication that extra features exist but are locked.
- [x] No accidental access to Full-only features.

### Full version may include

- [x] Additional visual themes.
- [x] Additional difficulty levels.
- [x] More celebration effects.
- [x] Personal bests or completion times.
- [x] Additional audio/voice packs.
- [x] Any other premium features already defined in the app.

### Locking rule

- [x] Paid features are visible enough that users understand the upgrade value.
- [x] Paid features are inaccessible until the Full unlock is purchased or licence-tested.
- [x] Locked features do not crash when tapped.
- [x] Locked features show an upgrade prompt or polite explanation.
- [x] The app never pretends that a feature is available when it is not.

---

## 3. Confirm Android build configuration

### Versioning

- [x] Confirm `versionName` is user-readable, for example `1.0.0`.
- [x] Confirm `versionCode` is an integer and has increased since the previous upload.
- [x] Confirm the app name shown on device is the intended Play Store name.
- [x] Confirm package name / application ID is final.
- [x] Confirm package name is not reused between Free and Full if using separate apps.

### Flutter build command

From the project root, build the Android App Bundle:

```zsh
flutter clean
flutter pub get
flutter build appbundle --release
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

### Build checks

- [x] Build completes without errors.
- [x] No Flutter warning about legacy Kotlin Gradle Plugin usage in the app project.
- [x] No Flutter warning about third-party plugins applying legacy Kotlin Gradle Plugin usage.
- [x] Upgrade or replace any Android plugins that are not compatible with Flutter Built-in Kotlin.
- [x] No debug banners.
- [x] No test menu visible to users.
- [x] No developer-only reset controls visible to users.
- [x] Secret author-only reset gesture still works if intentionally retained.
- [x] Full version can be reset back to Free for testing.
- [x] App starts correctly after fresh install.
- [x] App starts correctly after update over previous test build.

---

## 4. Configure Google Play Console account

- [x] Log in to Google Play Console.
- [x] Confirm the correct developer account is selected.
- [x] Confirm developer identity verification is complete.
- [x] Payments profile exists.
- [x] Merchant registration is available for your country.
- [x] Payment / bank details are added.
- [x] Identity / business verification is not pending.
- [x] Tax details are complete if Google asks for them.
- [x] No "action required" warnings appear in Payments profile.
- [x] You can create or price an in-app product.
- [x] Confirm developer name is correct and public-facing.
- [x] Confirm support email is correct, ideally `support@angrygrannies.com.au`.
- [x] Confirm privacy policy URL is live.
- [x] Confirm support URL is live.

Google’s Play Console help says apps are created from **Home → Create app**, where you choose default language, app name, and whether the item is an app or game.

Source: Google Play Console Help, “Create and set up your app”.

---

## 5. Create the app listing

In Play Console:

```text
Home → Create app
```

Set:

- [ ] Default language.
- [ ] App name.
- [ ] App or game.
- [ ] Free or paid selection.
- [ ] Declarations / terms.

### If using one free app with Full unlock

Set the app as:

```text
Free
```

The Full version is handled through an in-app product.

### If using separate Free and Full apps

Create two app records:

```text
SuDoKu Fresh Free
SuDoKu Fresh Full
```

or equivalent final names.

Use separate package names:

```text
com.angrygrannies.sudokuplaytime.free
com.angrygrannies.sudokuplaytime.full
```

Set:

```text
Free app → Free
Full app → Paid
```

Do not publish the Full app as Free if you intend it to remain a paid download.

---

## 6. Complete the Main Store Listing

Prepare and upload:

- [ ] App name.
- [ ] Short description.
- [ ] Full description.
- [ ] App icon.
- [ ] Feature graphic.
- [ ] Phone screenshots.
- [ ] 7-inch tablet screenshots if relevant.
- [ ] 10-inch tablet screenshots if relevant.
- [ ] Optional promotional video.

### Store listing positioning

The listing should make clear that this is a gentle, visual Sudoku-style game.

Possible description angle:

```text
A relaxing picture-Sudoku puzzle with cheerful tiles, gentle challenge levels, and optional Full Version extras.
```

### Screenshot set

Recommended Play Store screenshots:

- [ ] Home screen.
- [ ] Game board with image tiles.
- [ ] Partly completed puzzle.
- [ ] Drawer open.
- [ ] Theme selection with locked Full features visible.
- [ ] Full Version upgrade prompt.
- [ ] Mid-celebration screenshot.

---

## 7. Complete Play Console App Content declarations

In Play Console, complete every required declaration before review.

Common required sections include:

- [ ] Privacy policy.
- [ ] App access.
- [ ] Ads declaration.
- [ ] Content rating questionnaire.
- [ ] Target audience and content.
- [ ] Data safety form.
- [ ] Data collection and sharing declarations.
- [ ] Financial features declaration if shown.
- [ ] Government apps declaration if shown.
- [ ] Health apps declaration if shown.
- [ ] News apps declaration if shown.
- [ ] Sensitive permissions declarations if shown.

Google’s Data Safety documentation says developers remain responsible for complete and accurate declarations in the Play Store listing.

Source: Google Play Console Help, “Provide information for Google Play’s Data safety section”.

---

## 8. Configure pricing and distribution

### Countries / regions

- [ ] Select launch countries.
- [ ] Confirm whether Australia is included.
- [ ] Confirm whether India, Japan, Germany, Italy, France, Portugal, Spain, and other language markets are included.
- [ ] Confirm tax / merchant availability for paid products.

### Device catalogue

- [ ] Review supported Android phones.
- [ ] Review supported Android tablets.
- [ ] Exclude unsuitable devices only if necessary.
- [ ] Confirm minimum Android version.
- [ ] Confirm app behaves acceptably on tablets.

### Free app with in-app Full unlock

- [ ] App price: Free.
- [ ] Full unlock: configured as an in-app product.

### Separate paid Full app

- [ ] Full app price set before release.
- [ ] Regional prices reviewed.
- [ ] Free app and Full app listings clearly distinguish what each version provides.

---

## 9. Configure Google Play Billing for Full unlock

Use this section if the Full version is an in-app purchase rather than a separate paid app.

### Product type

Use a one-time product / managed product for a permanent Full Version unlock.

Suggested product ID:

```text
full_version_unlock
```

Checklist:

- [ ] Product ID chosen and final.
- [ ] Product title created.
- [ ] Product description created.
- [ ] Price set.
- [ ] Product activated.
- [ ] App code uses the exact same product ID.
- [ ] App handles purchase success.
- [ ] App handles purchase cancellation.
- [ ] App handles purchase failure.
- [ ] App restores existing purchases.
- [ ] App survives restart after purchase.
- [ ] App survives reinstall where possible after purchase restore.
- [ ] App handles no network / Play Billing unavailable.

### Licence testing

- [ ] Add test Gmail accounts in Play Console licence testing.
- [ ] Add internal testers to the testing track.
- [ ] Install the app from Google Play testing link, not by side-loading.
- [ ] Confirm test purchase uses Play Billing test flow.
- [ ] Confirm Full features unlock after test purchase.
- [ ] Confirm secret reset gesture can return the app to Free state for repeated testing.

---

## 10. Internal testing track

Use internal testing first for fast iteration.

In Play Console:

```text
Testing → Internal testing → Create new release
```

Steps:

- [ ] Create an internal testing track.
- [ ] Add tester email list.
- [ ] Upload `.aab`.
- [ ] Add release notes.
- [ ] Review release.
- [ ] Roll out to internal testing.
- [ ] Copy the opt-in link.
- [ ] Send opt-in link to testers.

Testing checklist:

- [ ] Tester can accept the testing invitation.
- [ ] Tester can install from Google Play.
- [ ] Free features work.
- [ ] Full features are visible but locked.
- [ ] Upgrade prompt appears.
- [ ] Test purchase works for licence testers.
- [ ] Full features unlock correctly.
- [ ] Reset-to-Free test works.
- [ ] App does not crash on low-end devices.
- [ ] App does not crash on tablets.

---

## 11. Closed testing track

Use closed testing when the app is stable enough for broader testing.

In Play Console:

```text
Testing → Closed testing
```

Steps:

- [ ] Create or select closed testing track.
- [ ] Add tester group.
- [ ] Upload release `.aab`.
- [ ] Add release notes.
- [ ] Review release.
- [ ] Roll out to closed testing.
- [ ] Send opt-in link.
- [ ] Collect feedback.

### New personal developer account requirement

If the Google Play developer account is a new personal account, Google requires a closed test before production access. Google currently states that at least **12 testers** must be opted in for at least **14 continuous days** before production access can be requested.

Source: Google Play Console Help, “App testing requirements for new personal developer accounts”.

Checklist:

- [ ] At least 12 testers opted in.
- [ ] Testers remain opted in continuously for 14 days.
- [ ] Testers use the app during the testing period.
- [ ] Feedback is collected and addressed.
- [ ] Crashes and ANRs are reviewed.
- [ ] Production access application is completed if required.

---

## 12. Free version release-gate tests

Before production release, install the Play-distributed test version and test the Free state from a clean install.

### Clean install

- [ ] Uninstall app from device.
- [ ] Install from Google Play test track.
- [ ] Open app.
- [ ] Confirm app starts in Free state.
- [ ] Confirm no Full features are accessible without purchase.

### Locked feature tests

For every Full-only feature:

- [ ] Feature is visible or discoverable.
- [ ] Feature is clearly marked as Full / locked.
- [ ] Tap opens upgrade prompt.
- [ ] User can cancel and return safely.
- [ ] No hidden path unlocks the feature.
- [ ] No old preference/state accidentally unlocks the feature.

### Upgrade test

- [ ] Start in Free state.
- [ ] Tap a locked Full feature.
- [ ] Purchase using licence test account.
- [ ] Confirm Full state activates.
- [ ] Close and reopen app.
- [ ] Confirm Full state persists.
- [ ] Use reset gesture to return to Free.
- [ ] Confirm Full features are locked again.

---

## 13. Full version release-gate tests

Use this section for either the in-app Full unlock or a separate paid Full app.

### If Full is an in-app unlock

- [ ] Full unlock product is active.
- [ ] Product ID matches app code.
- [ ] Test purchase works from Play-installed build.
- [ ] Restore purchases works.
- [ ] Full-only features become accessible after purchase.
- [ ] Full state persists after app restart.
- [ ] Full state persists after device restart.
- [ ] Free reset gesture is author-only and not obvious to normal users.

### If Full is a separate paid app

- [ ] Full app has separate package name.
- [ ] Full app is set as Paid before release.
- [ ] Full app listing does not describe itself as a free download.
- [ ] Full app contains no upgrade prompts for features already included.
- [ ] Free and Full apps can coexist if intended.
- [ ] Free app links to Full app listing if allowed and appropriate.
- [ ] Full app has its own screenshots and store metadata.

---

## 14. Production release

In Play Console:

```text
Release → Production → Create new release
```

Steps:

- [ ] Upload final `.aab`.
- [ ] Confirm app signing is enabled.
- [ ] Confirm version code is correct.
- [ ] Add release name.
- [ ] Add release notes.
- [ ] Review warnings.
- [ ] Resolve all blocking errors.
- [ ] Confirm App Content declarations complete.
- [ ] Confirm store listing complete.
- [ ] Confirm pricing and distribution complete.
- [ ] Confirm countries selected.
- [ ] Confirm Data Safety is accurate.
- [ ] Submit for review.

### Staged rollout

Use a staged rollout unless there is a strong reason not to.

Recommended first production rollout:

```text
5% or 10%
```

Checklist:

- [ ] Start staged rollout.
- [ ] Monitor crashes and ANRs.
- [ ] Monitor reviews.
- [ ] Monitor purchase behaviour.
- [ ] Increase rollout only after confidence.

---

## 15. Post-release checks

Immediately after approval:

- [ ] Open Play Store listing on web.
- [ ] Open Play Store listing on Android phone.
- [ ] Confirm screenshots look correct.
- [ ] Confirm app name is correct.
- [ ] Confirm short description is correct.
- [ ] Confirm privacy policy link works.
- [ ] Confirm support email works.
- [ ] Install from production listing if available.
- [ ] Confirm Free state on fresh install.
- [ ] Confirm Full unlock purchase flow if using in-app purchase.
- [ ] Check Android vitals.
- [ ] Check crash reports.
- [ ] Check user reviews.
- [ ] Check Play Console inbox / policy messages.

---

## 16. Suggested release order

### Best release sequence

1. Finalise app name and package ID.
2. Complete Free vs Full feature boundary.
3. Build release `.aab`.
4. Create Play Console app.
5. Complete Store Listing.
6. Complete App Content declarations.
7. Configure pricing and distribution.
8. Configure Full Version in-app product, if used.
9. Release to Internal Testing.
10. Test Free state thoroughly.
11. Test Full unlock thoroughly.
12. Use secret reset gesture to retest Free state.
13. Release to Closed Testing.
14. Meet the 12-tester / 14-day rule if required.
15. Apply for production access if required.
16. Submit Production release.
17. Start staged rollout.
18. Monitor and expand rollout.

---

## 17. Key project-specific risks

### Risk: Free version accidentally includes Full features

Mitigation:

- [ ] Test every Full-only feature in clean Free state.
- [ ] Test after app restart.
- [ ] Test after update.
- [ ] Test after reset gesture.
- [ ] Test with a non-licence-test Google account.

### Risk: Play Store app cannot later become paid

Mitigation:

- [ ] If using a paid-download Full app, create it separately before release.
- [ ] Do not publish the intended paid app as Free.

### Risk: Test purchases behave differently from side-loaded builds

Mitigation:

- [ ] Always test billing using a Play-installed build from internal or closed testing.

### Risk: App review cannot access paid features

Mitigation:

- [ ] Provide clear app access instructions if needed.
- [ ] Ensure locked feature flow is reviewable.
- [ ] Ensure purchase flow uses Google Play Billing.

### Risk: screenshots do not match the current release

Mitigation:

- [ ] Regenerate screenshots from release build or screenshot mode.
- [ ] Include Free locked-feature state.
- [ ] Include Full/celebration value if allowed by listing context.

### Risk: future Flutter Android builds fail due to legacy Kotlin Gradle Plugin usage

Mitigation:

- [x] Migrate the Android app project to Flutter Built-in Kotlin configuration.
- [ ] Check every Android plugin for Built-in Kotlin compatibility before the release build.
- [ ] Upgrade incompatible plugins or replace them before the Play Store submission build.
- [ ] Confirm `flutter build appbundle --release` runs without Kotlin migration warnings.

---

## 18. Source references

- Google Play Console Help — Create and set up your app: https://support.google.com/googleplay/android-developer/answer/9859152
- Google Play Console Help — App testing requirements for new personal developer accounts: https://support.google.com/googleplay/android-developer/answer/14151465
- Google Play Console Help — Set up your app's prices: https://support.google.com/googleplay/android-developer/answer/6334373
- Google Play Console Help — Provide information for Google Play’s Data safety section: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play Console overview: https://developer.android.com/distribute/console
- Google Play Developer API overview, including Subscriptions and In-App Purchases API: https://developers.google.com/android-publisher

---

## 19. Open decisions before implementation

- [x] Final Android app name: `SuDoKu Fresh`.
- [ ] Final package name.
- [ ] One free app with Full unlock, or two separate apps.
- [ ] Full Version price.
- [ ] Launch countries.
- [ ] Final Free feature set.
- [ ] Final Full feature set.
- [ ] Whether the Full unlock is one-time purchase or subscription. Recommended: one-time purchase.
- [ ] Exact wording of upgrade prompts.
- [ ] Exact screenshot set.
