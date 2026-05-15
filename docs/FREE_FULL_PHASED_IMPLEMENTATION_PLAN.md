# SuDoKu Playtime: Free vs Premium Phased Implementation Plan

## Objective

Implement a clear, reliable split between Free and Premium versions with:

- A genuinely usable Free experience
- Strong Premium upgrade incentives
- Safe rollout with measurable checkpoints
- A temporary developer/tester reset path back to Free

---

## Target Product Split

### Free Version

- Difficulty:
  - `easy` + one additional accessible level
  - `hard` / `very hard` locked
- Themes:
  - Available: `animals`, `instruments`, `numbers`
  - Locked: all other current/future themes (e.g. `butterflies`, `old_opera`)
- Celebrations:
  - `foil` only
- Sounds:
  - Basic only:
    - tile long-press preview
    - basic celebration sound
  - premium-themed background sets locked
- Metrics (`How am I doing?`):
  - show only **number of games played**
  - hide/lock all other metrics

### Premium Version

- Difficulty: unlock all levels
- Themes: unlock all themes (current + future included)
- Celebrations: use random selection across all celebration effects
- Sounds: unlock all themed background audio sets
- Metrics: unlock all current metrics, including:
  - time to complete
  - personal best
  - all currently implemented progress stats

---

## Phased Plan

## Phase 0: Baseline and Feature Flag Setup

### Scope

1. Add/confirm explicit gating checks per feature area:
   - difficulty unlock policy
   - content mode unlock policy
   - celebration style policy
   - metrics visibility policy
   - background music set policy
2. Add a temporary internal flag for reset workflow availability:
   - debug-only preferred, or hidden dev option in settings/drawer
3. Document exact Free/Premium policy keys in one source file/service.

### Deliverables

- Policy matrix in code and docs
- Single source of truth for entitlement checks
- Debug logging around entitlement-gated decisions

### Acceptance Criteria

- No feature checks entitlement ad hoc in UI widgets
- All gating paths resolve through policy service(s)

---

## Phase 1: Enforce Free Version Experience

### Scope

1. Difficulty gating:
   - allow `easy` + one chosen accessible level
   - lock `hard` and `very hard`
2. Theme gating:
   - allow only `animals`, `instruments`, `numbers`
   - lock `butterflies` and `old_opera` in Free
3. Celebration gating:
   - force `foil` only when `premiumActive == false`
4. Sounds gating:
   - permit long-press preview + basic celebration
   - block premium background music sets in Free
5. Metrics gating:
   - `How am I doing?` shows only games played
   - lock/hide time, PB, and other stats

### Deliverables

- Updated policy service + UI wiring
- Locked-feature messaging aligned to friendly tone

### Acceptance Criteria

- Free users can complete full puzzles normally
- Free UI never exposes inaccessible premium functionality without lock messaging
- Free celebration visual is always foil only

---

## Phase 2: Premium Unlock Experience

### Scope

1. Premium unlock flow:
   - ensure purchase + restore flows are stable
   - preserve current debug fallback behavior for local testing only
2. Premium feature activation:
   - all levels, themes, sounds, and metrics unlock immediately after entitlement refresh
3. Celebration randomization:
   - random choice across all configured effects (including foil)

### Deliverables

- Reliable entitlement refresh on purchase/restore
- Premium visual/audio behavior parity across all content modes

### Acceptance Criteria

- Premium entitlement flip is reflected without app restart
- Random premium celebration appears consistently on puzzle solve

---

## Phase 3: Temporary Reset-to-Free Function

### Scope

Add a temporary function on/near the existing Reset control to revert entitlement to Free for testing.

### Implementation Notes

1. Control placement:
   - add a clearly labeled temporary action in debug/dev UI only
   - avoid exposing this in production release builds
2. Behavior:
   - set entitlement to `free`
   - clear any premium-only cached UI state if needed
   - refresh screen state immediately
3. Safety:
   - confirmation dialog before applying
   - developer log entry when used

### Deliverables

- Debug-only “Reset to Free” action
- Test coverage for entitlement reset + UI downgrade behavior

### Acceptance Criteria

- After reset, Free gating is fully re-applied without restart
- Premium-only features become locked immediately

---

## Phase 4: QA, Goldens, and Rollout

### Scope

1. Automated tests:
   - policy tests for Free vs Premium gates
   - widget tests for locked/unlocked flows
   - victory overlay tests (free foil-only + premium random)
2. Goldens:
   - update golden baselines if visual spacing/themes changed
3. Manual QA matrix:
   - Free mode pass
   - Premium mode pass
   - Purchase restore pass
   - Reset-to-free pass

### Deliverables

- Updated tests and documentation
- QA checklist run results in `docs/qa/`

### Acceptance Criteria

- All targeted tests pass in CI/local
- No regressions in core gameplay flow

---

## Suggested Implementation Order (Short Sequence)

1. Finalize policy matrix constants
2. Ship Free gating updates
3. Ship Premium unlock/random celebration updates
4. Add temporary reset-to-free function (debug-only)
5. Complete QA + golden updates + checklist signoff

---

## Risks and Mitigations

- Risk: entitlement state drift after purchase/restore
  - Mitigation: explicit refresh + centralized entitlement sync
- Risk: accidental exposure of reset-to-free in production
  - Mitigation: gate with `kDebugMode` and/or compile-time flag
- Risk: inconsistent locking across screens
  - Mitigation: route all checks through policy service, add tests per surface

---

## Done Definition

This plan is complete when:

1. Free mode exactly matches the target split above.
2. Premium mode unlocks all current gated content areas.
3. Temporary reset-to-free works in debug/testing and is not exposed in production.
4. Tests and QA evidence are updated and passing.
