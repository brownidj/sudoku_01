### Implementation Plan: Issue 6 (S2 Premium Entitlement Model)

#### 1. Define Entitlement Domain
- Add an entitlement type in app/domain layer (for example `Entitlement.free` / `Entitlement.premium`).
- Add a premium feature enum (for example `PremiumFeature.hardDifficulty`, `PremiumFeature.progressTracker`, etc.).
- Keep this model independent of UI widgets and platform billing SDKs.

#### 2. Add Persistent Entitlement Storage
- Extend persistence store (existing preferences layer) with:
    - `loadEntitlement()`
    - `saveEntitlement(...)`
- Set default to `free` when no stored value exists.
- Add migration-safe parsing/fallback for unknown persisted values.

#### 3. Build Policy Service
- Create a `PremiumPolicyService` that is the only place deciding access.
- Core API:
    - `bool isUnlocked(PremiumFeature feature, Entitlement entitlement)`
    - optional convenience methods (`isPremiumActive(...)`, `lockedFeatures(...)`)
- Encode current S2 gate rules in one mapping table.

#### 4. Wire Entitlement Into App State
- Add entitlement to app-level state/controller path (not scattered in UI).
- Load entitlement at startup and make it available to controllers.
- Ensure state updates trigger UI refresh when entitlement changes.

#### 5. Replace Direct Checks With Policy Calls
- Audit existing difficulty/feature gates and replace inline checks.
- Update controller/UI flows to ask policy service before allowing actions.
- Ensure locked-path behavior is consistent (e.g., opens explainer path, not silent fail).

#### 6. Add Test Coverage
- Unit tests for `PremiumPolicyService`:
    - free user denied premium features
    - premium user allowed all mapped features
- Persistence tests:
    - default free on missing value
    - saved premium restores correctly
    - unknown value falls back safely
- Controller/service tests:
    - gating uses policy service path
    - no bypass path for locked features

#### 7. Verification and Guardrails
- Run:
    - `./scripts/check_file_sizes.sh flutter_app`
    - `flutter test`
- Add a temporary grep check during review to catch direct checks outside policy layer.

#### 8. Documentation
- Add a short section to docs describing:
    - where entitlement is stored
    - where policy rules are defined
    - how to add a new premium-gated feature
- Link this in Issue 6 for closure evidence.
  - Closure reference anchor: `docs/MONETISATION.md#premium-entitlement-model-implementation-reference`
  - GitHub issue link snippet:
    - `https://github.com/brownidj/sudoku_01/blob/<branch-or-commit>/docs/MONETISATION.md#premium-entitlement-model-implementation-reference`

#### 9. Rollout Sequence (Suggested PR Order)
1. PR A: entitlement model + persistence + unit tests
2. PR B: policy service + unit tests
3. PR C: controller/UI wiring + gate replacement + ordinary test updates
4. PR D (optional): docs cleanup + follow-up hardening
