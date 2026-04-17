# Monetisation options

For an iOS app, the main monetisation options are:

1. **Paid app upfront**
   You charge once to download the app. This is simple, but it usually works best only when the value proposition is very clear and users can understand the benefit before paying. Apple supports paid apps directly through the App Store.  ￼
In-app purchases for one-off digital items
      This is the standard model for unlocking premium features, extra content, pro tools, level packs, credits, and similar digital goods. Apple’s in-app purchase types include consumables and non-consumables. Consumables are things users can buy repeatedly, while non-consumables are permanent unlocks such as “remove ads” or “pro version.”  ￼ 
3. **Subscriptions**
      Best for apps with ongoing value: content libraries, language apps, fitness apps, cloud sync, education, productivity, or anything that keeps updating. Apple supports auto-renewable subscriptions and non-renewing subscriptions. Auto-renewing subscriptions are the most common recurring-revenue model on iOS.  ￼
4. **Freemium**
   The app is free to download, then you monetise by converting some users to paid features, premium content, or subscriptions through in-app purchases. This is often the strongest option for consumer apps because it reduces download friction while still allowing serious users to pay. Apple’s StoreKit and App Store Connect are built around this model.  ￼

5. **Advertising**
   You can keep the app free and earn via display ads, rewarded ads, sponsorship, or affiliate-style placements. Apple’s monetisation pages focus more on paid apps and in-app purchases than on ad networks, but ads are still a common commercial model for iOS apps. For many apps, this works best either at scale or as a secondary revenue stream alongside subscriptions or IAP. Apple also provides measurement tools such as App Analytics and AdAttributionKit-related resources for acquisition and monetisation analysis.  ￼

6. **Physical goods or real-world services**
   If your app sells physical products, bookings, transport, food delivery, or other real-world services, those payments generally do not use Apple’s in-app purchase system. In practice, that means you can usually use your own payment flow for those cases. Apple’s in-app purchase system is mainly for digital goods and services consumed in the app.  ￼

7. **Reader-app or external account flows in limited cases
   Some qualifying apps, especially reader apps, can request entitlements allowing links to an external website for account creation or management. Apple documents this through the External Link Account entitlement. This is a narrower, category-specific path, not a general substitute for in-app purchase.  ￼

A *few commercial points* matter as well. Apple’s Small Business Program offers a 15% commission rate on paid apps and in-app purchases for qualifying developers. For auto-renewable subscriptions, Apple says your net revenue rises to 85% after a subscriber accumulates one year of paid service. Apple also provides monetisation and subscription analytics inside App Store Connect.  ￼

For most iOS apps, the practical shortlist is:
•	Paid upfront if the app is niche, professional, or clearly valuable on day one.
•	Free + subscription if the app delivers continuing value.
•	Free + one-time upgrade if it is more of a utility tool.
•	Free + ads if you expect a large casual audience.


For your Sudoko model, the **premium unlock** should normally be a non-consumable in-app purchase called something like Premium Unlock or Remove Ads + Premium. Apple supports testing that through TestFlight, and TestFlight purchases run in the sandbox, so testers are not charged and those test purchases do not carry over to production after release.  ￼

The practical flow is:

First, set up the in-app purchase in App Store Connect. Create a non-consumable product, give it a product ID, pricing, and metadata, and wire your app to fetch that product and unlock premium when the transaction is verified. Before you even involve TestFlight, it is worth testing locally with StoreKit Testing in Xcode, because Apple explicitly positions Xcode testing for early development and sandbox/TestFlight for end-to-end testing with real App Store product data.  ￼

Then upload a build to TestFlight. Internal testers can test once the build is available to them; external testers require the build to go through TestFlight App Review first. Apple’s TestFlight docs distinguish those paths clearly.  ￼

On the tester’s device, install the app from TestFlight and attempt the purchase normally from your paywall or premium screen. Because the app is running from TestFlight, the purchase flow uses Apple’s sandbox environment automatically. For broader sandbox controls and scenario testing, Apple says you can sign out of the production Media & Purchases account and sign into Developer settings with a Sandbox Apple Account. Apple also notes that Sandbox Apple Accounts for TestFlight can only be used to test apps within your own developer account.  ￼


***For a Sudoku app, especially one of many, the weakest monetisation model is usually paid upfront.*** The category is crowded, users expect to try before paying, and Apple’s own commerce stack is built around free download plus in-app purchase or subscription models for digital features. Apple supports one-time non-consumables and auto-renewable subscriptions directly through In-App Purchase.

The **three realistic options** are these:

Best default: free app + one-time premium unlock.
This is usually the cleanest fit for a Sudoku app. Give the core game away free, then sell a permanent upgrade such as ad removal, advanced statistics, unlimited hints, extra puzzle packs, daily challenges, custom themes, note-taking enhancements, mistake checking, cloud sync, or harder modes. Apple’s in-app purchase types explicitly support non-consumables, which are purchased once and remain unlocked permanently.  ￼

Second option: free app + ads + paid remove-ads unlock.
This works well if your app has broad casual appeal and frequent repeat play. The key is restraint: banner ads or occasional interstitials can monetise non-paying users, while a one-time “Remove Ads” purchase gives committed users a clean experience. For a puzzle app, this is often more acceptable than pushing a subscription too early. If the ad-free version also bundles a few premium extras, conversion is usually easier than selling ad removal alone.

Third option: subscription, but only if you truly have ongoing value.
A subscription can work only when the app behaves more like a service than a simple game. Examples would be a constantly refreshed puzzle library, daily tournaments, deep analytics, cross-device sync, coaching, curated lesson paths, or a broader brain-training bundle that includes Sudoku. Apple supports auto-renewable subscriptions and provides tooling for trials, offer codes, and subscription management. Apple also states that qualifying subscriptions rise to 85% net revenue after one year of paid service, and qualifying small developers can get a reduced commission rate through the Small Business Program.  ￼

For your situation, I would rank the models like this:

1. Free + ads + one-time premium unlock
   Best if the app is a straightforward Sudoku game.

2. Free + one-time premium unlock, no ads
   Best if you want a cleaner, more premium product positioning.

3. Subscription
   Only if you are building a richer ecosystem, not just a Sudoku board.

*What I would not lead with is a pure paid download.* In a crowded puzzle category, that usually creates too much friction unless the app already has a strong brand, a niche audience, or some very obvious differentiator.

Also keep Apple’s rules in mind: if you sell digital features or content inside the app, that generally needs to use Apple’s in-app purchase system under the App Review Guidelines.  ￼

A **sensible monetisation structure** for your app would be:

Free tier: unlimited easy/medium puzzles, basic notes, basic stats.
Premium one-time unlock: no ads, harder difficulties, advanced stats, themes, puzzle archive, cloud sync.
Optional later subscription: only if you add daily exclusive content, events, or a broader puzzle membership.

For a Sudoku app, the most commercially sensible answer is usually: do not try to monetise the puzzle itself; monetise convenience, polish, analytics, and the ad-free experience.

If you want, I can sketch a concrete pricing ladder for your Sudoku app, including what should be free, what should be paid once, and what—if anything—should sit behind a subscription.


## Testing
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


## The Plan
It could work, but in its current form I think it has one strong idea, two weak ideas, and one risk.

The strong idea is this: free users get a real game, not a demo. That matters. If Easy plus one additional difficulty gives a satisfying experience, people can trust the app before paying. Locking some higher difficulties is reasonable in Sudoku because difficulty is an obvious upgrade path.

The first weak idea is “buy the app” framing. On iOS, if the app is free and users unlock more inside it, they are not really “buying the app”; they are buying Premium. That distinction matters psychologically. “Buy the app” can feel blunt and old-fashioned. “Unlock Premium” or “Unlock all difficulties and stats” is cleaner and more in line with user expectations.

The second weak idea is making metrics the main paid value. For many Sudoku users, completion time, best time, and a few metrics are nice, but not compelling enough on their own to drive payment. They are good as part of a premium bundle, but probably not strong enough as the headline reason to upgrade. Most users will pay for one of three things: more content, less friction, or stronger status/customization. Metrics help, but they are not usually the primary conversion driver.

The risk is that difficulty locking alone may not convert well if the free experience is already sufficient. Many casual users will happily stay in Easy/Medium forever. The people who most want harder levels are exactly the people most likely to compare your app with many competitors. If your paid proposition is only “harder puzzles + some stats,” that may be too thin unless the execution is excellent.

My critical view is this:

Your plan is directionally sound, but I would not position it as:

free = two levels
paid = remaining levels + metrics + maybe better celebration

That feels a bit light.

I would position it more like:

### Free
•	Easy and Medium
•	full core gameplay
•	current sounds and celebrations
•	maybe daily play streak or simple session feedback
•	visible but locked premium items in a restrained way

### Premium one-time unlock
•	all difficulties, including Hard and Very Hard
•	advanced statistics and personal bests
•	extra puzzle generation modes or challenge types
•	premium themes / tile styles
•	expanded celebration/sound packs
•	future premium cosmetic/content packs included only if you want to overdeliver early, or sold separately later if you want a longer revenue path

That works better because Premium becomes a bundle of mastery + polish + personalization, not just “more numbers in the drawer.”

A few points where I would push back quite hard:

1. Do not cripple settings too aggressively.
   Showing switches in the drawer that are visible but inert can work, but only if handled carefully. Too many dead controls make the app feel cheap or annoying. A better pattern is:
   •	let the user tap the locked item
   •	show a compact premium sheet
   •	explain the benefit clearly
   •	offer unlock
   Do not leave the interface feeling half-broken.

2. “Better celebration” is not a strong premium anchor.
   It is a nice extra, not a purchase driver. Keep one satisfying celebration in free. Premium can add alternate celebration styles, but that should be garnish, not the meal.

3. Splitting difficulty labels can help, but do not do it just to manufacture scarcity.
   If your current Medium is broad, then splitting it into Medium and Hard may be valid. But if you are just relabeling to make the paid ladder look larger, users may feel manipulated. Difficulty names should reflect real puzzle characteristics.

4. Future add-on packs are plausible, but do not design around them yet.
   For a Sudoku app in a crowded market, your first monetisation job is to prove that one clean Premium unlock converts at all. Only after that should you add icon packs, sound packs, or deeper metric packs. Otherwise you risk overengineering the store before you know what users value.

#### What I think is most likely to convert:

People do not usually pay for Sudoku because it exists. They pay because the app feels better, cleaner, or more serious than alternatives. So your premium pitch should probably emphasize:
•	all difficulty levels
•	advanced stats and records
•	richer customization
•	a cleaner “serious player” experience
•	possibly no ads, if you ever introduce ads

Even if you currently do not want ads, keep that option architecturally available. A very common structure is:
•	free with limited difficulties
•	premium unlock = all difficulties + stats + themes + ad-free forever

That gives you room later without redesigning the proposition.

My honest assessment:
•	Will it work at all? Yes, potentially.
•	Is it strong enough as stated? Not quite.
•	What is missing? A more compelling premium identity.

Right now your premium plan sounds like “more levels and some instrumentation.” I think it needs to sound like “the complete Sudoku experience.”

If I were tuning it, I would recommend this exact commercial shape:

Free
Easy + Medium, full game feel, sounds, celebrations, basic settings, maybe one theme.

Premium unlock
Hard + Very Hard, advanced stats, PB tracking, extra themes/tile sets, premium celebration pack, any future serious-player features.

Then later, only if the app gets traction:
optional cosmetic packs or puzzle-style packs.

So yes, the plan is viable, but I would strengthen the premium bundle and soften the locked-feature UX. The core principle is: free must feel generous; premium must feel aspirational, not merely withheld.

## The Plan for Seniors
For a seniors-focused Sudoku app, your original plan becomes more plausible, but some parts of it become less important than you think, and a few parts become more important than you may have realized.

The biggest shift is this: if you are targeting older users for mental engagement, enjoyment, confidence, and routine, then you are not really selling “difficulty” in the same way a hardcore puzzle app does. You are selling comfort, clarity, encouragement, and a sense of progress.

That means the premium proposition should not lean too heavily on “Hard” and “Very Hard.” Those can still be premium features, but they are probably not the main conversion driver for your intended audience.

***What matters more for this audience:***
•	clear, readable interface
•	low stress
•	pleasant feedback
•	sense of achievement
•	gentle progression
•	familiar routine
•	optional assistance without shame
•	personalization
•	visible improvement over time

So yes, I would revise my earlier criticism.

Your free tier including celebrations and sounds now makes much more sense, because for this audience those are not just gimmicks. They are part of the emotional design. They help create warmth and reward, which is likely central to replay value for seniors.

But I would now be much more critical of one specific part of your plan: locking metrics in the drawer may not be especially compelling for this audience. Personal best time and completion metrics can be nice, but many older users are not strongly motivated by performance analytics. Some may even find time-based scoring mildly discouraging. If the app is meant to feel enjoyable and affirming, then “you took 14 minutes today instead of 11” is not always a selling point.

So the revised assessment is:

Your freemium model can work, but the paid value should be framed less as advanced play and more as enhanced experience.

I would think about the tiers like this.

Free should feel generous, warm, and complete enough to build trust:
Easy and Medium, full celebrations, pleasant sounds, large clear controls, maybe one or two supportive helpers, and no feeling of being rushed or judged.

**Premium should feel like:**
the fuller, more personalized, more supportive version of the app.

For this audience, premium benefits that may convert better than raw metrics include:
•	more puzzle variety
•	more calming or cheerful sound sets
•	alternative visual themes with high contrast options
•	larger tile styles or easier-to-read visual modes
•	more celebration styles
•	gentle progress/history tracking
•	streaks or “days played” history
•	optional memory-support features
•	maybe printable/shareable completion certificates or little milestones
•	additional assistance modes such as more forgiving hints, highlight aids, or simplified options

In other words, for seniors, “premium” should probably mean more comfort, more delight, more personalization, and more support, not just “more challenge.”

I would be especially cautious with these points:

***First***, do not make the free version feel condescendingly limited. Seniors are often very sensitive to software that feels confusing, patronizing, or manipulative. If they tap locked things too often, it may feel frustrating rather than aspirational.

***Second***, do not overemphasize speed metrics. A better framing might be:
•	puzzles completed
•	days played
•	personal milestones
•	longest streak
•	favorite difficulty
•	improvement over time in a gentle way

That is more encouraging than a hard performance dashboard.

***Third***, do not assume Very Hard is valuable just because it exists. For your stated market, Very Hard may be far less commercially important than:
•	a calm theme
•	bigger text
•	clearer contrast
•	nicer sounds
•	a “relaxed mode”
•	supportive hints
•	progress tracking

Those may actually be the premium features people care about.

So if I were being blunt: your current monetisation idea is still a bit too shaped around what a typical app developer imagines Sudoku users want, rather than what your actual audience may want.

For seniors, I would seriously consider this premium bundle instead:

Free:
Easy and Medium, full basic fun, sounds, celebrations, clean readable design, straightforward success experience.

Premium:
all difficulties, progress history, gentle stats, more visual themes, more sound/celebration packs, supportive play options, and perhaps a calmer “wellbeing” feel overall.

That is a better match for your positioning.

***One more strategic point***: if your app is for older brains and fun, then your real differentiation may not be the puzzle itself at all. It may be the tone. Most Sudoku apps are functional or competitive. Yours could win by being:
•	kinder
•	clearer
•	less intimidating
•	more joyful
•	more age-friendly

That absolutely can support freemium. But then the paid upgrade must extend that same value proposition.

So my revised view is:

Yes, this changes my assessment.
Your plan is now more viable overall, because the emotional/reward aspects make more sense.
But I would downgrade the importance of locked hard levels and time-based metrics, and upgrade the importance of personalization, encouragement, accessibility, and gentle progress tracking.

The model I would recommend is not “free for casuals, paid for experts.”
It is “free for trust and enjoyment, paid for the fuller, warmer, more personalized experience.”

That is a much stronger fit for the audience you actually want.



## How to Proceed
Here is the feature split I would recommend for a seniors-focused Sudoku app with a free app + one-time Premium unlock model.

The key commercial principle is that the free tier must feel complete, enjoyable, and trustworthy, while Premium should feel like the fuller, more comfortable, more personalized version of the app. It should not feel like you are punishing free users. It should feel like an upgrade for people who are getting ongoing value.

#### Recommended positioning

The public message should be something like this:

Free: a friendly, easy-to-use Sudoku app for everyday brain engagement.
Premium: the complete experience, with more variety, more personalization, and more progress features.

That is much better for this audience than “free for beginners, paid for serious players.”

#### Recommended free vs Premium matrix

**Free tier**

The free version should include the full core game loop and enough value that a senior user can genuinely enjoy it for some time.

Include:

Easy puzzles.
Medium puzzles.
Large, clear board and readable numbers.
Clean, simple interface.
Basic sounds and celebrations.
Basic hint/help system.
Mistake checking or gentle assistance, if that is part of the app’s identity.
A simple theme, or at most one light and one dark theme.
Basic settings that are actually usable.
A warm, encouraging tone throughout.
A clear but non-pushy Premium pathway.

The free tier should let someone think, “This is pleasant, I understand it, and I like using it.”

That is what creates trust and later conversion.

**Premium tier**

Premium should feel like the app opens up into a richer, more personal, more rewarding experience.

Include:

All difficulty levels, including Hard and Very Hard.
Progress history.
Personal bests.
Puzzles completed count.
Days played or streak history.
Additional visual themes, especially high-contrast or soothing themes.
Additional tile/icon styles if you want that design path.
Extra sound packs.
Enhanced celebration styles.
A calmer “relaxed play” feel with more customization.
Advanced assistance options, if they fit the product vision.
Any future premium add-on content that you decide to bundle rather than sell separately.

For this audience, Premium should say: more comfort, more encouragement, more choice, more sense of progress.

What should not be the main Premium pitch

I would not make these the headline selling points:

Raw speed metrics.
Very competitive language.
Only “expert” difficulty.
A better celebration by itself.
Visible but unusable controls all over the interface.

Those can exist, but they should not be the heart of the proposition.

For seniors, *“track your improvement gently”* is better than “beat your fastest time.”

How to present locked features

This matters a lot.

Do not make the app look half-broken with lots of dead switches. Instead:

Show Premium items clearly.
Allow tap on the locked item.
Open a short, friendly explanation.
Explain the benefit in plain language.
Offer the one-time unlock.

For example, instead of a dead switch for statistics, use something like:

Progress Tracker
See your completed puzzles, play history, and personal milestones.
Unlock with Premium

That feels much better than a greyed-out control that does nothing.

**Best Premium anchors for your audience**

If I had to choose the strongest likely conversion drivers for your market, I would use these:

1. More puzzle variety
   Easy, Medium, Hard, Very Hard.

2. Gentle progress tracking
   Completed puzzles, milestones, days played, optional best times.

3. Personalization
   Themes, sounds, celebrations, tile styles.

4. Comfort/support features
   Anything that makes the game feel clearer, calmer, or easier to enjoy.

That bundle feels much more appropriate than a “hardcore Sudoku upgrade.”

**Suggested paywall copy direction**

Your paywall should sound warm and simple. Something like:

Unlock Premium
Enjoy the full Sudoku experience with all difficulty levels, progress tracking, extra themes, sounds, and celebrations.

That is much better than:
Buy the app to access locked levels

The second sounds transactional and slightly harsh. The first sounds like an upgrade to something the user already values.

My recommended final structure

I would make the product look like this:

Free
Easy and Medium.
Full basic fun.
Sounds and celebrations.
Simple, readable experience.
Basic help features.

Premium
Hard and Very Hard.
Progress and milestone tracking.
Personal bests and history.
Extra themes and visual styles.
Extra sound and celebration packs.
Any future richer customization features.

That is commercially cleaner and better aligned with your audience.

***One caution***

Do not overload Premium with too many ideas at first. For version 1, I would keep the paid offer very clear:

Unlock all difficulties + progress tracking + extra themes/sounds/celebrations

That is enough to test whether people will pay. Later, if the app gets traction, you can add more Premium benefits or optional add-on packs.

Bottom-line assessment

For a seniors-focused Sudoku app, I think this model is viable if the free version feels kind, polished, and satisfying. The Premium tier should not feel like “hard mode for experts.” It should feel like the fuller, warmer, more personalized version of a game they already enjoy.



##Screen by Screen
Here is a practical screen-by-screen monetisation plan for Sudoku_01, tuned for a seniors-focused audience and a free app + one-time Premium unlock.

The main rule should be this: the monetisation must feel calm, clear, and respectful. Nothing should feel pushy, noisy, or like the app is trying to trick the user. The user should be able to enjoy the free app properly, and then gradually discover that Premium gives them a fuller and more personal experience.

1. First launch / welcome experience

On first launch, do not show a paywall immediately. For this audience, that would likely damage trust. Instead, let the app introduce itself as a friendly Sudoku game for enjoyment and brain engagement.

The opening screen should communicate three things very simply: this is easy to use, this is enjoyable, and there is room to grow. You can mention Premium lightly somewhere on the screen, but only as a small secondary element such as “More themes, progress tracking, and extra levels available in Premium.”

The first session should be entirely focused on getting the user into a puzzle quickly and comfortably.

2. Main menu / home screen

The home screen is where the monetisation structure should become visible, but not aggressive.

I would suggest that the difficulty choices appear directly and clearly:

Easy
Medium
Hard 🔒
Very Hard 🔒

The locked levels should still look like real options, but visually distinct. Do not make them look broken or disabled. They should be tappable.

Below or near the difficulty area, there can be a small Premium card with wording like:

Premium includes:
All difficulty levels, progress tracking, extra themes, sounds, and celebrations.

Then a simple button:

Unlock Premium

This button should always be available from the home screen, but it should not dominate the page.

The home screen’s job is to make the upgrade path understandable without getting in the way of free play.

3. Difficulty tap behaviour

This is one of the most important monetisation points.

When a user taps Easy or Medium, the puzzle should open immediately.

When a user taps Hard or Very Hard, do not just show a harsh “locked” message. Instead, open a small, clean Premium sheet or dialog. It should feel informative, not obstructive.

Something like this would work well:

Hard and Very Hard are part of Premium
Unlock all difficulty levels, progress tracking, extra themes, sounds, and celebrations with a one-time purchase.

Buttons:
Not now
Unlock Premium

That is enough. Do not overload this screen with too much text.

You may also want a very short subtitle under each locked difficulty before tap, such as “Available in Premium,” so the user is not surprised.

4. In-game experience for free users

The free play session must feel complete and pleasant.

That means the free user should still get:
clear interface, good feedback, sounds, celebrations, and a satisfying end-of-game experience.

Do not use play interruption as monetisation pressure. Do not put upgrade popups in the middle of a puzzle. For this audience, that would feel especially unpleasant.

The free user should be able to finish a puzzle, enjoy the success feedback, and feel good about the experience.

That is what makes them willing to consider Premium later.

5. Puzzle completion screen

This is one of the best places to surface Premium, because the user has just had a successful experience and is more receptive.

For a free user, after completing a puzzle, the celebration screen could show something like:

Well done!
You completed the puzzle.

Then below that:

With Premium you can also:
See your progress history
Track personal milestones
Unlock all difficulty levels
Enjoy extra themes and celebration styles

Buttons:
Play again
Unlock Premium

This is much better than a generic paywall because it appears at a moment of satisfaction.

If the user is Premium, this same screen can instead show their progress information and any enhanced celebration.

6. Drawer / side menu

The drawer is a good place to expose Premium features, but it must be handled carefully.

For free users, I would avoid showing lots of dead switches. Instead, the drawer should contain active free items and clearly labeled Premium items.

For example:

Home
New Puzzle
How to Play
Settings
Progress Tracker 🔒
Themes 🔒
Sounds & Celebrations 🔒
Unlock Premium

If the user taps a locked item, the app should open a small explanatory panel rather than doing nothing.

For example, tapping Progress Tracker could open:

Progress Tracker is part of Premium
See completed puzzles, days played, and personal milestones.

Buttons:
Not now
Unlock Premium

This feels much cleaner than leaving inactive toggles visible but unusable.

7. Settings screen

For seniors, the Settings screen should remain simple and trustworthy.

The free version should include all settings needed for comfortable use. That means things like sound on/off, basic visual clarity, and any genuinely necessary usability controls should stay free.

Premium settings should be grouped separately in a clear section.

For example:

Free Settings

Sound
Celebrations
Number highlighting
Simple assistance options

Premium Settings

Extra themes 🔒
Premium celebration styles 🔒
Additional sound packs 🔒
Advanced progress options 🔒

Again, tapping a locked setting should explain what it does and offer the upgrade.

Do not lock essential accessibility or readability features if those are important to the target audience. If a feature materially helps seniors use the app comfortably, it should probably remain free.

8. Progress / metrics screen

For this audience, this screen should be framed gently.

Do not lead with hard competitive language like “best score leaderboard” or “performance stats.” Instead, use terms like:

Your Progress
Puzzles completed
Days played
Favourite difficulty
Personal best times

For free users, this screen can be previewed in a soft way. For example, instead of completely hiding it, you might show a static preview card:

Track your Sudoku journey with Premium
See your completed puzzles, milestones, and personal bests.

Button:
Unlock Premium

That allows the value to be understood.

9. Premium page / paywall screen

You should have one dedicated Premium page that the user can reach from the home screen, drawer, locked levels, and completion screen.

This page should be very clear and not too long. It should explain the value of the one-time purchase in plain language.

Suggested structure:

Unlock Premium
Enjoy the full Sudoku experience with one simple purchase.

Then a short list:

All difficulty levels
Progress tracking and milestones
Personal bests and history
Extra themes and tile styles
Extra sounds and celebrations

Then:

One-time purchase
No subscription

Then the purchase button:
Unlock Premium

And beneath it:
Restore Purchases

That “No subscription” line may matter a lot for this audience. Many users are wary of recurring charges.

10. Restore Purchases flow

This should be visible and simple, especially on the Premium page and maybe also in Settings.

The wording should be plain:
Already purchased Premium? Restore Purchases

Do not bury it.

11. Timing of upgrade prompts

The app should not ask too often.

The best trigger points are:
after tapping a locked difficulty, after tapping a locked Premium feature, and after finishing a puzzle.

The app should not keep throwing the paywall repeatedly after every action. For seniors especially, repeated interruption can quickly feel irritating or confusing.

A good rule would be that if the user dismisses an upgrade prompt, the app should back off for a while unless they explicitly tap another Premium feature.

12. Wording style throughout

The wording should feel warm and straightforward.

Good:
“Unlock Premium”
“Available in Premium”
“Track your progress”
“Enjoy extra themes and celebrations”

Less good:
“Upgrade now!”
“Buy the app!”
“Limited access”
“Restricted feature”
“Only for paying users”

The tone matters a lot because your market positioning is about enjoyment, reassurance, and friendliness.

13. What the user should feel

A free user should feel:
“This is pleasant and useful already.”

A user considering Premium should feel:
“I like this, and the upgrade gives me a fuller version without pressure.”

A Premium user should feel:
“I paid once and now I have the complete experience.”

That is the emotional arc you want.

14. Best initial Premium bundle for version 1

For your first monetisation pass, I would keep the Premium offer to this exact set:

Hard and Very Hard
Progress tracking
Personal best history
Extra themes or tile styles
Extra sounds and celebrations

That is a clean, understandable package.

I would not try to add separate paid packs yet. First validate whether the one-time Premium unlock converts.

15. My critical recommendation

The most important design decision is this: do not make the app look like it is withholding basic comfort. Keep the free version genuinely pleasant. Locking advanced variety and richer personalization is fine. Locking essential clarity or making the drawer full of unusable controls is not.

So the monetisation should be visible, but always in a way that says:
“This is the fuller version,” not “this version is intentionally crippled.”


## Summary (from MONETISATION.md)
For seniors, the doc’s strongest message is:
1. Free tier must feel complete, warm, and trustworthy.
2. Premium should feel like a fuller, more comfortable experience, not a punishment.
3. Don’t lead with speed/performance pressure.
4. Don’t rely on “Hard mode only” as the main value.
5. Emphasize readability, low stress, encouragement, personalization, gentle progress.
6. Avoid dead/greyed controls; let users tap locked items and show a clear, friendly premium sheet.
7. Best initial monetization shape is freemium with a one-time premium unlock (non-consumable IAP), with subscription only later if you add real ongoing service value.

### Senior-specific requirements to treat as hard constraints
1. Large, clear UI and low cognitive load.
2. Encouraging tone and feedback; avoid competitive/shaming phrasing.
3. Gentle progress tracking: puzzles completed, days played, milestones, optional best times.
4. Accessibility/personalization as core value: high contrast themes, calming options, supportive assists.
5. Free experience must be genuinely usable long-term (not demo-like).

### Implementation strategy
Phase 1: UI/UX first (foundation)
1. Define senior UX baseline: font scales, contrast targets, tap target minimums, simplified labels, reduced clutter.
2. Standardize tone across app copy: “supportive, calm, clear”.
3. Build a locked-feature interaction pattern:
◦ Tappable locked item.
◦ Small explainer sheet.
◦ One clear Unlock Premium action.
4. Reframe metrics screens to “progress” not “performance”.
5. Ship free-tier experience polish before monetization push:
◦ Easy/Medium, core helpers, pleasant feedback, stable settings.

### Phase 2: Freemium monetization (one-time unlock)
1. Product structure:
◦ Free: Easy/Medium, core gameplay, basic sounds/celebrations, basic assist.
◦ Premium: Hard/Very Hard, progress history, extra themes/sounds/celebrations, comfort/support options.
2. IAP setup:
◦ One non-consumable SKU (premium_unlock) on iOS + Android billing equivalent.
3. Entitlement architecture:
◦ Server/store-verified entitlement state.
◦ Restore purchases.
◦  No local-boolean-only unlock logic.
4. Paywall placement:
◦ Home screen premium card.
◦ Locked difficulty taps.
◦ Locked personalization/progress features.
5. QA flows:
◦ Fresh purchase, relaunch persistence, restore, reinstall, second device, offline behavior.
6. Analytics:
◦ Track tap locked feature → paywall view → purchase start → success/restore.
◦ Track retention and conversion by difficulty/theme usage.

### Phase 3: Later optional expansion
1. Add ads only if needed; premium removes ads permanently.
2. Consider subscription only if you add ongoing content/services (events, daily exclusive packs, sync ecosystem).
3. A/B test paywall copy and bundle composition, but keep tone senior-friendly.
