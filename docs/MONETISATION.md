# Sudoku_01 Monetisation Plan (Seniors, One-Time Premium)

## Goal
This document is the canonical monetisation plan for Sudoku_01.

Commercial model:
- Free app with a genuine, enjoyable core experience.
- One-time Premium unlock (non-consumable IAP).
- No pushy or manipulative patterns.

Design rule:
- Monetisation must feel calm, clear, and respectful.
- Free users should enjoy the app properly.
- Premium should feel like a fuller and more personal experience, not a penalty.

## Product Model

### Free
- Easy and Medium difficulties.
- Full core puzzle loop.
- Clear UI, useful feedback, satisfying completion.
- Basic sounds and celebrations.
- Essential comfort/readability settings.

### Premium (one-time unlock)
- Hard and Very Hard.
- Progress tracking and milestones.
- Personal best history.
- Extra themes/tile styles.
- Extra sounds and celebrations.

Store messaging baseline:
- `One-time purchase`
- `No subscription`
- `Restore Purchases` always visible on Premium surfaces.

## Screen-by-Screen Plan

### 1. First Launch / Welcome
- Do not show a paywall immediately.
- Introduce the app as friendly, easy to use, and enjoyable.
- Mention Premium only as a secondary line.

Suggested supporting line:
- `More themes, progress tracking, and extra levels available in Premium.`

Primary user objective:
- Start first puzzle quickly and comfortably.

### 2. Main Menu / Home
- Show difficulty choices clearly:
  - `Easy`
  - `Medium`
  - `Hard 🔒`
  - `Very Hard 🔒`
- Locked levels should be tappable and visually distinct (not broken-looking).
- Show a small Premium card with:
  - `Premium includes: All difficulty levels, progress tracking, extra themes, sounds, and celebrations.`
- Always show `Unlock Premium` button, but it must not dominate layout.

### 3. Difficulty Tap Behavior
- Tap `Easy`/`Medium`: open puzzle immediately.
- Tap `Hard`/`Very Hard`: open small informative Premium sheet.

Suggested sheet copy:
- Title: `Hard and Very Hard are part of Premium`
- Body: `Unlock all difficulty levels, progress tracking, extra themes, sounds, and celebrations with a one-time purchase.`
- Buttons:
  - `Not now`
  - `Unlock Premium`

Optional pre-tap microcopy:
- `Available in Premium`

### 4. In-Game Experience (Free Users)
- Must feel complete and pleasant.
- Keep interface, feedback, sounds, celebrations, and end-of-game quality high.
- Do not interrupt active puzzles with upgrade prompts.
- Do not use frustration loops as conversion pressure.

### 5. Puzzle Completion Screen
- This is a primary upgrade moment for free users.
- Show success first, then Premium value.

Suggested free-user layout:
- `Well done! You completed the puzzle.`
- `With Premium you can also:`
  - `See your progress history`
  - `Track personal milestones`
  - `Unlock all difficulty levels`
  - `Enjoy extra themes and celebration styles`
- Buttons:
  - `Play again`
  - `Unlock Premium`

Premium user variant:
- Show progress info and enhanced celebration instead of upgrade CTA.

### 6. Drawer / Side Menu
- Avoid dead controls.
- Show active free items and clearly labeled Premium items.

Recommended structure:
- `Home`
- `New Puzzle`
- `How to Play`
- `Settings`
- `Progress Tracker 🔒`
- `Themes 🔒`
- `Sounds & Celebrations 🔒`
- `Unlock Premium`

Tap behavior for locked items:
- Open explanatory panel with value + upgrade option.

Example:
- Title: `Progress Tracker is part of Premium`
- Body: `See completed puzzles, days played, and personal milestones.`
- Buttons:
  - `Not now`
  - `Unlock Premium`

### 7. Settings
- Keep Settings simple and trustworthy.
- Essential comfort/usability controls stay free.
- Group Premium settings in a separate section.

Example grouping:
- `Free Settings`
  - `Sound`
  - `Celebrations`
  - `Number highlighting`
  - `Simple assistance options`
- `Premium Settings`
  - `Extra themes 🔒`
  - `Premium celebration styles 🔒`
  - `Additional sound packs 🔒`
  - `Advanced progress options 🔒`

Rule:
- Do not lock essential accessibility/readability features.

### 8. Progress / Metrics
- Use gentle, non-competitive framing.

Preferred labels:
- `Your Progress`
- `Puzzles completed`
- `Days played`
- `Favourite difficulty`
- `Personal best times`

Free-user preview pattern:
- `Track your Sudoku journey with Premium`
- `See your completed puzzles, milestones, and personal bests.`
- Button: `Unlock Premium`

### 9. Premium Page / Paywall
- One dedicated Premium page reachable from home, locked taps, drawer, and completion.
- Keep it short and plain-language.

Structure:
- Header: `Unlock Premium`
- Subheader: `Enjoy the full Sudoku experience with one simple purchase.`
- Benefits:
  - `All difficulty levels`
  - `Progress tracking and milestones`
  - `Personal bests and history`
  - `Extra themes and tile styles`
  - `Extra sounds and celebrations`
- Pricing framing:
  - `One-time purchase`
  - `No subscription`
- Actions:
  - `Unlock Premium`
  - `Restore Purchases`

### 10. Restore Purchases
- Must be visible and simple.
- Present on Premium page and optionally in Settings.

Suggested copy:
- `Already purchased Premium? Restore Purchases`

### 11. Upgrade Prompt Timing
- Use only these triggers:
  - Tap locked difficulty.
  - Tap locked Premium feature.
  - Puzzle completion.
- Do not repeatedly interrupt after dismissals.
- Back off after `Not now` until user explicitly engages another Premium trigger.

### 12. Wording Style
Preferred:
- `Unlock Premium`
- `Available in Premium`
- `Track your progress`
- `Enjoy extra themes and celebrations`

Avoid:
- `Upgrade now!`
- `Buy the app!`
- `Limited access`
- `Restricted feature`
- `Only for paying users`

### 13. Emotional Outcome
- Free user: `This is pleasant and useful already.`
- Considering user: `I like this, and Premium gives me a fuller version without pressure.`
- Premium user: `I paid once and now I have the complete experience.`

### 14. Version 1 Premium Bundle (Do Not Expand Yet)
- Hard and Very Hard.
- Progress tracking.
- Personal best history.
- Extra themes/tile styles.
- Extra sounds and celebrations.

Do not add separate paid packs in v1. Validate one clean Premium unlock first.

### 15. Critical Recommendation
Do not withhold basic comfort.

Keep free genuinely pleasant. Lock advanced variety, richer personalization, and deeper progress features.

The app should communicate:
- `This is the fuller version`

and never:
- `The free version is intentionally crippled`

## Implementation Guardrails
- No mid-puzzle paywall interruptions.
- No fake scarcity or countdown pressure.
- No hidden restore path.
- No confusing dead UI controls.
- No locking essential readability/accessibility options.

## UX Copy Baseline
Use this exact baseline unless intentionally revised:
- Primary CTA: `Unlock Premium`
- Secondary dismiss: `Not now`
- Locked label: `Available in Premium`
- Restore label: `Restore Purchases`
- Pricing reassurance: `One-time purchase` and `No subscription`

## Analytics Events (Minimal)
Track only what is needed to improve clarity and conversion:
- `premium_sheet_opened` (source: locked_difficulty, locked_feature, completion, home, drawer)
- `premium_unlock_tapped`
- `premium_unlock_success`
- `premium_unlock_cancelled`
- `restore_purchases_tapped`
- `restore_purchases_success`

Use these events to tune copy and placement, not to increase prompt frequency.


## Congratulatory messages
- “Wonderful work — you solved it!”
- “Well done — another ZuDoKu completed.
- “Excellent thinking — you got every tile in place.”
- “Congratulations — puzzle solved beautifully.”
- “Splendid job — your brainpower shines.”
- “You did it — calm, clever, and correct.”
- “Another great win for you in ZuDoKu.”
- “Superb effort — that puzzle didn’t stand a chance.”
- “Brilliant solving — enjoy your success.”
- “Nicely done — every move led to victory.”
- “A lovely result — another puzzle complete.”
- “Fantastic work — you finished the board.”
- “Success — you cracked the puzzle.”
- “Great concentration — and a great result.”