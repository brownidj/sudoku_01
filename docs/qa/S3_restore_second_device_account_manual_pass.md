# S3 Restore Purchases - Second Device/Account Manual Pass

## Metadata
- Date: 2026-04-28
- Tester: _TBD_
- Build: _TBD_
- Platforms: iOS _TBD_, Android _TBD_

## Preconditions
- A real App Store / Play Store premium purchase exists on Account A.
- Device 1 has completed the premium purchase for `premium_unlock`.
- Device 2 is signed into the same store account as Device 1.
- Optional negative check: Device 3 signed into Account B (no premium purchase).

## Steps and Results
1. On Device 2, install and launch app fresh.
   - Expected: Drawer shows `Version` = `Free`.
   - Result: _TBD (Pass/Fail)_
   - Notes: _TBD_

2. Open drawer and tap `Restore Purchases`.
   - Expected: snackbar shows restore initiation feedback.
   - Result: _TBD (Pass/Fail)_
   - Notes: _TBD_

3. Wait for store restore to complete and reopen drawer.
   - Expected: `Version` updates to `Active`.
   - Result: _TBD (Pass/Fail)_
   - Notes: _TBD_

4. Verify locked premium rows are no longer shown.
   - Expected: locked premium entry rows are hidden in drawer for active premium.
   - Result: _TBD (Pass/Fail)_
   - Notes: _TBD_

5. Negative path (Account B / no prior purchase): tap `Restore Purchases`.
   - Expected: premium status remains `Free`; app does not unlock entitlement.
   - Result: _TBD (Pass/Fail)_
   - Notes: _TBD_

## Evidence
- Screenshot 1 (before restore, Free): _TBD_
- Screenshot 2 (after restore, Active): _TBD_
- Screenshot 3 (negative path, still Free): _TBD_

## Status
- Overall: _Pending manual execution_
