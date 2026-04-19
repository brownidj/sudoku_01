# S1 Issue 4 Manual UI Pass (Game Flow)

Use this checklist to record manual verification for:
S1: Progress framing update (shown in **How am I doing?** modal only).

## Run Metadata
- Date:
- Tester:
- Branch/Commit:
- Build Variant:
- Device 1 (required):
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
   - Result: Pass / Fail
   - Notes:

2. Open **How am I doing?** before completing the puzzle.
   - Verify modal shows:
     - `Completed puzzles: <n>`
     - `Days played: ...`
     - `Streak: ...`
   - Result: Pass / Fail
   - Notes:

3. Verify board metadata row does not contain milestone framing text.
   - Result: Pass / Fail
   - Notes:

4. Complete a puzzle (normal play or approved completion path), then reopen **How am I doing?**.
   - Verify `Completed puzzles` increased by 1 from Step 2.
   - Result: Pass / Fail
   - Notes:

5. Start a new puzzle and reopen **How am I doing?**.
   - Verify count is persisted and does not reset unexpectedly.
   - Result: Pass / Fail
   - Notes:

6. Switch content mode/difficulty and reopen **How am I doing?**.
   - Verify copy remains unchanged in tone and structure.
   - Result: Pass / Fail
   - Notes:

7. Verify key controls still work after opening/closing modal:
   - `New Game`
   - `Help`
   - Drawer menu
   - Result: Pass / Fail
   - Notes:

## Evidence
- Screenshot 1 (modal before completion):
- Screenshot 2 (modal after completion):
- Screenshot 3 (main screen showing no milestone framing in metadata row):

## Summary
- Overall Result: Pass / Fail
- Blocking Issues:
- Follow-up Issues Created:
