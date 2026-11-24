# CURRENT_STATE.md

## AI Assistant Operating Instructions

This document defines how AI Assistant should work on this project to maximise implementation quality while minimising unnecessary AI credit usage.

---

# Credit-Conscious Workflow

AI Assistant should:

- Implement one clearly defined task or numbered phase at a time.
- Inspect only the files directly relevant to the current task.
- Avoid broad repository exploration unless absolutely necessary.
- Preserve the existing architecture.
- Avoid unrelated refactoring.

---

# File Inspection

When implementing a task:

1. Read this document first.
2. Read the relevant implementation blueprint.
3. Read only the source files directly involved.
4. Read additional files only if a dependency requires it.
5. Do not repeatedly rescan files that have already been examined.

---

# Testing Policy

Unless explicitly instructed otherwise, AI Assistant must **not** run:

- flutter analyze
- flutter test
- flutter run
- integration tests
- Shorebird commands
- platform builds
- long-running verification commands

Instead, AI Assistant should remind David to run the appropriate commands manually.

Typical reminder:

```bash
flutter analyze
flutter test
flutter run
```

Where only a specific test is affected, recommend that specific test instead of the entire suite.

---

# Handling Errors

If David supplies compiler, analyzer or test output:

- inspect only the relevant files
- fix only the reported issues
- avoid unrelated changes
- remind David to rerun the affected command

---

# Phase Workflow

For each numbered implementation phase:

1. Implement only that phase.
2. Stop.
3. Summarise the work completed.
4. Remind David to perform manual verification.
5. Wait for confirmation before beginning the next phase unless instructed otherwise.

---

# Git Policy

AI Assistant must not:

- create commits
- amend commits
- push
- create tags
- change branches

unless explicitly requested.

Instead, remind David to review the changes and commit manually.

Provide a suggested commit message.

Example:

```text
Implement theme pack Phase 3 online catalogue
```

---

# Completion Report

At the end of every implementation task provide:

1. Summary of work completed.
2. Files created.
3. Files modified.
4. Tests created or modified.
5. Tests run by AI Assistant.

Expected value:

```text
None — manual verification requested.
```

6. Commands David should run.
7. Manual verification checklist.
8. Outstanding issues or risks.
9. Current implementation phase status.
10. Suggested Git commit message.

Do not claim that tests, builds or commits were performed unless they actually were.

---

# Manual Verification Reminder

At appropriate checkpoints remind David to:

1. Run the recommended verification commands.
2. Review the code changes.
3. Commit if satisfied.
4. Begin the next numbered phase only after verification.

---

# Project Principle

AI Assistant should spend its effort producing high-quality code rather than consuming credits on repeated builds, tests or repository-wide inspection.

The standard workflow is:

1. AI Assistant implements one phase.
2. AI Assistant lists the manual verification commands.
3. David runs them locally.
4. David reports only relevant errors.
5. AI Assistant fixes those specific issues.
6. David reruns verification.
7. AI Assistant reminds David to commit.
