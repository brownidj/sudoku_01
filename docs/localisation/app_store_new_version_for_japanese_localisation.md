# Creating a New Editable App Store Version for Japanese Localisation

Yes — but for this task, create a **new app version**, not just a new build.

In App Store Connect terms:

- **Build number** = a particular uploaded binary, for example build `17`, `18`, or `19`.
- **Version number** = the App Store release version, for example `1.0.2`, `1.0.3`, or `1.1.0`.

To make the App Store metadata editable again, you generally need to create a new **version** in App Store Connect. Apple’s “Create a new version” flow requires a new version number, and any uploaded binary for that version needs its own incremented build number.

## Recommended Choice

Use a **patch version**:

```text
1.0.2 → 1.0.3
```

That is the cleanest option because nothing significant is changing in the app itself. You are mainly preparing a metadata and localisation update.

## Do You Need a New Build?

Probably **yes**, if Apple requires a build before you can submit the new version for review.

Since the app binary is unchanged, you can upload the same code again, but with incremented version/build identifiers:

```text
App Store version: 1.0.3
Build number: next unused build number
```

For example, if your last build number was `18`, use `19`. The app can be functionally identical. Apple does not require every new version to contain code changes, but App Review will still treat it as a new submitted version.

## Practical Path

1. In App Store Connect, click the blue **+** beside **iOS App**.
2. Create version **1.0.3**.
3. While the version is in **Prepare for Submission**, add the Japanese localisation.
4. Add Japanese App Store metadata.
5. Add Japanese screenshots if you have them, especially if your screenshots include text.
6. Upload or select a build for version **1.0.3**.
7. Submit the new version for review.

## Suggested Release Notes

Use something simple, such as:

```text
Added Japanese App Store localisation.
```

Or:

```text
App Store listing updates and localisation improvements.
```

## Recommendation

Use **1.0.3** rather than **1.1.0** unless you are also adding Japanese inside the app, new themes, new UI features, or other visible app changes.

For a metadata/localisation-only update, **1.0.3** is the more appropriate version number.
