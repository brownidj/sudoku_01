For your model, the premium unlock should normally be a non-consumable in-app purchase called something like Premium Unlock or Remove Ads + Premium. Apple supports testing that through TestFlight, and TestFlight purchases run in the sandbox, so testers are not charged and those test purchases do not carry over to production after release.  ￼

The practical flow is:

First, set up the in-app purchase in App Store Connect. Create a non-consumable product, give it a product ID, pricing, and metadata, and wire your app to fetch that product and unlock premium when the transaction is verified. Before you even involve TestFlight, it is worth testing locally with StoreKit Testing in Xcode, because Apple explicitly positions Xcode testing for early development and sandbox/TestFlight for end-to-end testing with real App Store product data.  ￼

Then upload a build to TestFlight. Internal testers can test once the build is available to them; external testers require the build to go through TestFlight App Review first. Apple’s TestFlight docs distinguish those paths clearly.  ￼

On the tester’s device, install the app from TestFlight and attempt the purchase normally from your paywall or premium screen. Because the app is running from TestFlight, the purchase flow uses Apple’s sandbox environment automatically. For broader sandbox controls and scenario testing, Apple says you can sign out of the production Media & Purchases account and sign into Developer settings with a Sandbox Apple Account. Apple also notes that Sandbox Apple Accounts for TestFlight can only be used to test apps within your own developer account.  ￼

For your specific Sudoku app, I would test these cases in TestFlight:
1.	Fresh purchase
A free user taps Premium Unlock, completes the sandbox purchase, and the app unlocks premium immediately.
2.	Relaunch persistence
Close and reopen the app and confirm premium stays unlocked.
3.	Restore Purchases
Delete the app or install on a second device using the same Apple ID, tap Restore Purchases, and confirm the non-consumable restores correctly.
4.	Offline / flaky network behavior
Make sure the UI does not falsely unlock if verification fails or the transaction is incomplete.
5.	Reinstall and sign-in edge cases
Premium should be tied to Apple purchase state, not just a local flag, otherwise reinstalls will break.
6.	Paywall messaging
Make sure it is completely clear what the one-time purchase buys: ad removal, advanced stats, themes, harder packs, whatever is included.

For a one-time unlock, the most important implementation detail is this: do not rely only on a local boolean like isPremium = true after purchase. You want the unlock to come from StoreKit transaction state and to support Restore Purchases, because that is how users recover a non-consumable purchase across reinstalls and devices.

A clean testing sequence is:
•	build and test locally with StoreKit in Xcode
•	create the real non-consumable in App Store Connect
•	ship a TestFlight build
•	test purchase, restore, reinstall, and second-device flows in TestFlight
•	only after that, submit the app and IAP for release/review

One subtle point: if you later add a subscription, TestFlight subscription renewals are accelerated, but that does not matter for your current one-time unlock model.  ￼

For your Sudoku app, I would keep the first TestFlight monetisation pass very small: one product only, for example Premium Unlock. Test just these user stories: “buy premium”, “premium remains unlocked tomorrow”, and “restore premium on another device.” If those work cleanly, your monetisation foundation is sound.

If you want, I can map this into the exact App Store Connect objects and the StoreKit 2 logic you need for a Flutter app.