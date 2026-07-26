# Launching SudoKu Playtime as a World Edition and a Japan Edition

You have **two practical ways** to do this. I would strongly recommend **Option 1** unless the Japan edition is genuinely a different app.

---

## Option 1 — One App, Localised Japan Edition

This means you launch one app globally, but users in Japan see Japanese store text, Japanese screenshots, and Japanese in-app language/content.

This is usually the best approach.

| Area | World edition | Japan edition |
|---|---|---|
| App binary | Same app | Same app |
| App Store listing | English/world listing | Japanese localised listing |
| Google Play listing | English/world listing | Japanese localised listing |
| In-app language | Device/app language dependent | Japanese if device/app language is Japanese |
| Themes/content | General world content | Optional Japan-specific theme/content |
| Reviews/ratings | Shared | Shared |
| Downloads | Shared | Shared |
| Maintenance | Easier | Easier |

### On iOS

In **App Store Connect**, add a **Japanese localisation** for the same app.

You can localise:

- App name
- Subtitle
- Description
- Keywords
- Screenshots
- App previews

You can also control where the app is available under:

**App Store Connect → My Apps → your app → Pricing and Availability → App Availability**

For a “world edition plus Japan edition,” I would still keep it as **one app available worldwide**, then add the Japanese localisation.

### On Android

In **Google Play Console**, add Japanese translations to your store listing.

You can localise:

- App name
- Short description
- Full description
- Screenshots
- Feature graphic
- In-app product names and descriptions, where relevant

You can also manage country availability under:

**Play Console → your app → Production → Countries/regions**

Again, for your case, I would keep one production app and add Japanese localisation rather than creating a separate Japan-only Android app.

---

## Option 2 — Separate Japan-Only App

This means you create a second app listing, for example:

**SudoKu Playtime — World Edition**  
**SudoKu Playtime Japan**  
**数独プレイタイム**

This is only worth doing if the Japanese version has a genuinely different identity, content set, pricing, branding, or legal/commercial arrangement.

| Advantage | Disadvantage |
|---|---|
| Japan app can have its own name, icon, screenshots, content and pricing | More work |
| Separate reviews and ratings | You start from zero reviews |
| Easier to market as a special Japanese edition | Two apps to maintain |
| Can limit availability to Japan only | More App Store / Play Console complexity |
| Can use a separate bundle ID / package name | More testing and release management |

### On iOS

You would create a separate app record with a separate **Bundle ID**, then set its availability to **Japan only** under:

**Pricing and Availability → App Availability**

### On Android

You would create a separate app with a separate **applicationId/package name**, then make it available only in Japan under:

**Production → Countries/regions**

---

## Recommendation for Sudoku_01

Use **one app**, with a strong Japanese localisation.

That gives you:

| Edition | User experience |
|---|---|
| **World Edition** | English and other languages, general icon/theme set |
| **Japan Edition experience** | Japanese store page, Japanese screenshots, Japanese app name/subtitle, Japanese in-app language, and possibly Japan-themed tiles/sounds |

Do **not** create a second app unless you need a separate brand or Japan-only content model.

---

## Suggested Structure

| Component | Recommendation |
|---|---|
| App name in English markets | **SudoKu Playtime** |
| App name in Japan | Consider **数独プレイタイム** or **SudoKu Playtime** with a Japanese subtitle |
| Store subtitle | “A friendly picture Sudoku game” / Japanese equivalent |
| Screenshots | Use Japanese UI screenshots for Japan |
| First-run language | Follow device/app language |
| In-app content | Include Japanese number set, Japanese animals/objects, or a Japan-themed tile pack |
| Premium | Same premium unlock across all countries unless you have a reason to price differently |
| Testing | Test with device language set to Japanese and, where possible, App Store/Play country set to Japan |

---

## Key Principle

**Country availability controls where the app can be downloaded.**

**Localisation controls how the app appears and feels to users in that language or region.**

For your goal, localisation is probably the right tool.
