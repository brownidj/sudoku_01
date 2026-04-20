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


For this updated requirement, treat completion evidence as two artifacts in-repo (or PR) with clear pass/fail criteria.
1) Manual UI pass in game flow Show it as a short checklist doc, e.g. docs/qa/S1_issue4_manual_pass.md, with:
   •
   Device(s), OS, build, date
   •
   Tester name
   •
   Steps executed
   •
   Result per step (Pass/Fail) + notes/screenshots
   Recommended steps:
1.
Launch app and start puzzle from Play.
2.
Open How am I doing? before puzzle completion.
3.
Verify calm framing text appears (completed puzzles / days played / streak).
4.
Finish a puzzle (or use your completion path), reopen modal.
5.
Verify updated completed count and unchanged calm tone.
6.
Switch modes/difficulty, reopen modal, verify copy still consistent.
7.
Verify no milestone framing appears in pressure-sensitive primary surfaces (e.g. board metadata row).
8.
Repeat on at least one small-phone layout.
2) Copy consistency verification This is a targeted content audit plus test guardrails.
   Constitutes “verified” when:
   •
   The exact approved strings are defined in one source location (constants/service), not duplicated ad hoc.
   •
   All user-facing progress-framing surfaces use those strings.
   •
   No conflicting pressure language exists in those surfaces.
   Practical checks:
   •
   rg search for disallowed tone in UI strings (e.g. leaderboard, performance, fastest, beat, score pressure).
   •
   Confirm approved modal strings appear exactly where intended.
   •
   Add/adjust widget test assertions for modal text so regressions fail CI.




5) **S1: Main Screen UI Polish + Reposition “How am I doing?”**
   Goal
   Improve clarity and flow on the in-game main screen by refining top control layout and repositioning the progress action so it is easy to find and less visually crowded.
   Scope
   Main in-game screen top control area.
   Positioning/alignment of New Game, Help, and How am I doing?.
   Spacing/visual rhythm between top rows and board entry area.
   Related test selectors/coverage where layout assumptions changed.
   Tasks
   •
   Audit current top control hierarchy and interaction priority.
   •
   Reposition How am I doing? to the agreed target location on the main page.
   •
   Adjust row structure/alignment so primary actions feel intentional and balanced.
   •
   Normalize spacing and tap-target comfort in the top control region.
   •
   Keep tone and labeling consistent with senior-friendly copy standards.
   •
   Update widget/integration/Patrol selectors if control keys or locations changed.
   •
   Run and fix impacted tests.
   Acceptance Criteria
   •
   How am I doing? appears in the intended position on the main screen.
   •
   Top control layout is clear at a glance on common phone sizes.
   •
   No overlap, clipping, or crowding in portrait layouts.
   •
   Tap targets remain comfortable and reliably hit-testable.
   •
   Existing flows (New Game, Help, drawer access) continue to work.
   •
   Tests pass with updated locators/expectations.
   Done When
   •
   UI change merged with before/after screenshots in PR.
   •
   flutter test passes.
   •
   Integration/Patrol tests covering top controls pass on CI device target.
   •
   No new file-size guardrail violations from the refactor.

Functionally, most of Issue 5 is done:
•
How am I doing? repositioned and state-swapped with Help
•
Top control/app bar layout updated
•
Related widget tests updated and passing
•
File-size guard currently passes (check_file_sizes.sh)
But per the Issue 5 Done When criteria, it is still missing explicit completion evidence:
•
before/after screenshots attached in PR
•
confirmed CI run for integration/Patrol top-control coverage on a device target
So status is: implementation largely complete, closure criteria not fully satisfied yet.





6) **S2: Add premium entitlement model (state + policy service)**
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
7) **S2: Gate difficulties for free vs premium**
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
8) **S2: Add very_hard difficulty end-to-end**
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
9) **S2: Premium explainer sheet and locked-item tap flow**
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
   UX validated on small and large virtual phones (emulator/simulator).
10) **S3: Integrate in_app_purchase service (buy + restore)**
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
11) **S3: Wire entitlement updates into app lifecycle and UI**
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
12) **S3: Add Restore Purchases and Premium status in drawer**
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
13) **S3: Product IDs and environment config for iOS/Android**
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
14) **S4: Monetization QA matrix (purchase/restore/reinstall/offline)**
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
15) **S4: Senior usability pass and final copy polish**
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
16) **S4: Add/expand tests for premium gates and restore flow**
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
