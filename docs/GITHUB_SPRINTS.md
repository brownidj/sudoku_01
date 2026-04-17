Use this template per issue in GitHub:
#### Goal
#### Scope
#### Tasks
#### Acceptance Criteria
#### Done When

1) **S1: Senior-friendly typography and spacing baseline**
   Goal
   Improve readability and tap comfort for older users.
   Scope
   Core gameplay screens, launch, metadata row, drawer.
   Tasks
   •
   Add readable text scale baseline for key UI text.
   •
   Increase spacing for dense controls where needed.
   •
   Validate tap targets for primary controls.
   •
   Keep layout stable on small devices.
   Acceptance Criteria
   •
   Text is visibly easier to read across key screens.
   •
   No clipped/overflowing controls on standard phone sizes.
   •
   Primary actions remain easy to tap.
   Done When
   •
   Manual pass complete on launch + game + drawer.
   •
   Related widget tests updated if snapshots changed.
2) **S1: Supportive copy pass for launch, dialogs, and metadata tooltips**
   Goal
   Replace pressure-oriented language with supportive, calm wording.
   Scope
   Launch subtitle, new game confirmations, metadata tooltips.
   Tasks
   •
   Update launch subtitle.
   •
   Update new game/difficulty/puzzle mode dialog messages.
   •
   Reword hints/corrections tooltip copy.
   Acceptance Criteria
   •
   Copy avoids “speed/competitive” pressure tone.
   •
   Wording is clear, concise, and friendly.
   Done When
   •
   All targeted strings updated and visible in app.
   •
   No wording regressions in tests.
3) **S1: Locked-feature visual language (no dead controls)**
   Goal
   Show locked features as intentional and tappable, not broken.
   Scope
   Difficulty and premium-gated UI entry points.
   Tasks
   •
   Add lock indicator pattern for gated options.
   •
   Ensure locked items are tappable.
   •
   Route tap to explainer sheet placeholder (non-purchase in S1).
   Acceptance Criteria
   •
   No inert/disabled-feeling premium controls.
   •
   Locked tap gives clear explanation path.
   Done When
   •
   Locked interactions work consistently in all gated places.
   •
   UX pass confirms no dead-control states.
4) **S1: Progress framing update (milestones over speed pressure)**
   Goal
   Frame progress as consistency/milestones, not raw speed.
   Scope
   Board metadata row + progress-related labels/tooltips.
   Tasks
   •
   Reword metrics labels where needed.
   •
   Prioritize completed puzzles, days played, streak-friendly language.
   •
   Keep optional best-time wording non-judgmental.
   Acceptance Criteria
   •
   Visible progress language is encouraging.
   •
   No hard-performance framing in primary UI.
   Done When
   •
   Manual UI pass complete in game flow.
   •
   Copy is consistent with senior-friendly tone.
5) **S2: Add premium entitlement model (state + policy service)**
   Goal
   Create a single source of truth for premium access.
   Scope
   App state + policy service (no store billing yet).
   Tasks
   •
   Add entitlement flag/state model.
   •
   Implement feature policy (isUnlocked(feature)).
   •
   Wire into controller/UI state mapping.
   •
   Persist entitlement locally for now.
   Acceptance Criteria
   •
   Feature checks use policy service, not scattered booleans.
   •
   UI can query premium state reliably.
   Done When
   •
   Entitlement model integrated and unit-tested.
   •
   No direct premium checks outside policy layer.
6) **S2: Gate difficulties for free vs premium**
   Goal
   Restrict difficulty access per freemium rules.
   Scope
   Difficulty selection and game configuration flows.
   Tasks
   •
   Define free difficulties: easy/medium.
   •
   Gate hard (and later very_hard) via premium policy.
   •
   On locked tap, show premium explainer instead of failing silently.
   Acceptance Criteria
   •
   Free users cannot start locked difficulties.
   •
   Premium users can start all allowed difficulties.
   •
   Locked selection always gives clear feedback.
   Done When
   •
   Difficulty gate covered by tests.
   •
   No bypass path found in manual checks.
7) **S2: Add very_hard difficulty end-to-end**
   Goal
   Introduce very_hard across generation, settings, and persistence.
   Scope
   Puzzle generation, settings validation, codec/session restore, UI dropdowns.
   Tasks
   •
   Add very_hard to difficulty enums/validation.
   •
   Add puzzle generation target settings for very_hard.
   •
   Update persistence codec read/write.
   •
   Add UI option and behavior wiring.
   Acceptance Criteria
   •
   very_hard appears and works end-to-end.
   •
   Sessions with very_hard restore correctly.
   •
   No crashes or fallback errors.
   Done When
   •
   Tests for generation + codec + config updated/passing.
   •
   Manual new game + resume verified for very_hard.
8) **S2: Premium explainer sheet and locked-item tap flow**
   Goal
   Provide a calm, informative upgrade path.
   Scope
   Reusable premium sheet + call sites from locked taps.
   Tasks
   •
   Build reusable premium sheet widget/service.
   •
   Add concise benefit list copy.
   •
   Hook locked difficulty/feature taps to open sheet.
   Acceptance Criteria
   •
   Locked taps open the same consistent sheet.
   •
   Sheet explains value clearly and non-pushily.
   •
   Has clear primary action and dismiss action.
   Done When
   •
   All locked entry points route to sheet.
   •
   UX validated on small and large phones.
9) **S3: Integrate in_app_purchase service (buy + restore)**
   Goal
   Implement one-time premium unlock purchase flow.
   Scope
   Store service abstraction for iOS/Android.
   Tasks
   •
   Add in_app_purchase dependency.
   •
   Implement product query + purchase + transaction handling.
   •
   Implement restore purchases.
   •
   Handle failure/cancel states cleanly.
   Acceptance Criteria
   •
   Product loads successfully when store is available.
   •
   Purchase success unlocks premium.
   •
   Restore works for previous purchase.
   Done When
   •
   Service unit/integration tests added where feasible.
   •
   Manual sandbox/internal test purchase completed.
10) **S3: Wire entitlement updates into app lifecycle and UI**
    Goal
    Reflect purchase state changes immediately and persistently.
    Scope
    Controller lifecycle, launch flow, and active screen updates.
    Tasks
    •
    Fetch entitlement on app start.
    •
    Listen for purchase updates during runtime.
    •
    Refresh UI state on entitlement changes.
    •
    Ensure resumed sessions honor latest entitlement.
    Acceptance Criteria
    •
    Unlock appears immediately after purchase.
    •
    Relaunch preserves premium state.
    •
    No stale lock state after restore.
    Done When
    •
    Lifecycle scenarios tested: cold start, resume, reopen.
    •
    No manual refresh needed by user.
11) **S3: Add Restore Purchases and Premium status in drawer**
    Goal
    Give users explicit restore path and visible entitlement status.
    Scope
    Drawer UI + action wiring.
    Tasks
    •
    Add “Restore Purchases” action.
    •
    Add “Premium: Active/Free” status row.
    •
    Add success/failure feedback messaging.
    Acceptance Criteria
    •
    Restore action is easy to find.
    •
    Status reflects current entitlement accurately.
    •
    Feedback shown for restore outcome.
    Done When
    •
    Drawer behavior tested with free and premium states.
    •
    Restore tested on second device/account scenario.
12) **S3: Product IDs and environment config for iOS/Android**
    Goal
    Centralize SKU config and avoid hardcoded product IDs in UI.
    Scope
    Monetization config constants + environment wiring.
    Tasks
    •
    Add product ID constants for premium unlock.
    •
    Wire per-platform config.
    •
    Add basic guardrails for missing config.
    Acceptance Criteria
    •
    App reads SKU from single config location.
    •
    Clear error logging if SKU/config missing.
    Done When
    •
    Build runs for iOS/Android with correct product IDs.
    •
    Config documented in project notes.
13) **S4: Monetization QA matrix (purchase/restore/reinstall/offline)**
    Goal
    Validate monetization reliability before release.
    Scope
    Manual + automated checks for critical commerce flows.
    Tasks
    •
    Run matrix: buy, relaunch, restore, reinstall, second device, offline.
    •
    Verify no false unlock on failed verification.
    •
    Verify restore is idempotent and stable.
    Acceptance Criteria
    •
    All matrix scenarios pass or have tracked fixes.
    •
    No critical monetization blockers remain.
    Done When
    •
    QA checklist completed and stored in repo docs.
    •
    Any failed case has follow-up issue.
14) **S4: Senior usability pass and final copy polish**
    Goal
    Ensure monetization UX remains calm, respectful, and clear.
    Scope
    Upgrade messaging, locked interactions, drawer/paywall copy.
    Tasks
    •
    Review all monetization copy for tone and clarity.
    •
    Remove any aggressive or confusing phrasing.
    •
    Final pass for readability and visual hierarchy.
    Acceptance Criteria
    •
    Upgrade path feels informative, not pushy.
    •
    Locked interactions are understandable without confusion.
    Done When
    •
    Final copy approved for release.
    •
    No outstanding UX wording issues.
15) **S4: Add/expand tests for premium gates and restore flow**
    Goal
    Protect against monetization regressions.
    Scope
    Unit/widget tests for entitlement gating and restore behavior.
    Tasks
    •
    Add tests for difficulty gating by entitlement.
    •
    Add tests for premium sheet routing on locked taps.
    •
    Add tests for restore state updates in drawer/UI.
    Acceptance Criteria
    •
    Core premium paths covered by automated tests.
    •
    CI passes with new tests.
    Done When
    •
    Test coverage added for all critical gate/restore paths.
    •
    Regression checklist satisfied.