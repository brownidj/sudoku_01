# S1 Issue 4 Manual UI Pass (Game Flow)

Use this checklist to record manual verification for:
S1: Progress framing update (shown in **How am I doing?** modal only).

## Run Metadata
- Date: 20-04-2026
- Tester: DB
- Branch/Commit: Main
- Build Variant: 229
- Device 1 (required): iPhone
- Device 2 (optional):

## Preconditions
- App launches successfully.
- Test account/state is reset or known.
- `How am I doing?` action is available on the main game screen.

## Pass Criteria
- Progress framing appears in the **How am I doing?** modal.
- Language is calm/supportive.
- Progress framing does **not** appear in pressure-sensitive primary gameplay surfaces (for this requirement update).
- `Completed puzzles` increments only after puzzle completion.

## Test Steps
1. Launch app and start a puzzle from the launch screen.
   - Result: Pass
   - Notes:

2. Open **How am I doing?** before completing the puzzle.
   - Verify modal shows:
     - `Completed puzzles: <y>`
     - `Days played: ...`
     - `Streak: ...`
   - Result: Pass
   - Notes:

3. Verify board metadata row does not contain milestone framing text.
   - Result: Pass 
   - Notes:

4. Complete a puzzle (normal play or approved completion path), then reopen **How am I doing?**.
   - Verify `Completed puzzles` increased by 1 from Step 2.
   - Result: Pass
   - Notes:

5. Start a new puzzle and reopen **How am I doing?**.
   - Verify count is persisted and does not reset unexpectedly.
   - Result: Pass
   - Notes:

6. Switch content mode/difficulty and reopen **How am I doing?**.
   - Verify copy remains unchanged in tone and structure.
   - Result: Pass
   - Notes:

7. Verify key controls still work after opening/closing modal:
   - `New Game`
   - `Help`
   - Drawer menu
   - Result: Pass
   - Notes:

### Test Evidence (Local)
- ✅ `flutter test` (all passed)
- ✅ `flutter test integration_test/app_flow_test.dart -d emulator-5554` (all passed)
- ✅ `patrol test patrol_test/smoke_test.dart --target integration_test/test_bundle.dart -d emulator-5554` (all passed)

## Evidence
- Screenshot 1 (modal after first completion): [How am I doing modal before completion](https://github.com/brownidj/sudoku_01/blob/main/docs/qa/screenshots/issue4_modal_before.png)
- Screenshot 2 (modal after second completion): [How am I doing modal after completion](https://github.com/brownidj/sudoku_01/blob/main/docs/qa/screenshots/issue4_modal_after.png)
- Screenshot 3 (main screen showing no milestone framing in metadata row): [Main screen showing no milestone framing](https://github.com/brownidj/sudoku_01/blob/main/docs/qa/screenshots/issue4_no_milestones.png)

## Summary
- Overall Result: Pass
- Blocking Issues: None
- Follow-up Issues Created: None
