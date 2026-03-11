---
name: fix-airbrakes
description: Scan open Airbrake GitHub issues, group duplicates, and create PRs to fix them. Uses worktrees and /ship-it for each fix. Skips issues already addressed by open PRs.
---

# Fix Airbrakes

Automatically scan open Airbrake-labeled GitHub issues, identify fixable bugs, and create PRs.

## CLI Helper

Use `airbrake-issues` for dedup, tracking, and Airbrake API:
- `airbrake-issues fixable` — returns open issues NOT already addressed by a PR or in-progress (full JSON with bodies)
- `airbrake-issues claim ISSUE BRANCH` — mark issue as in-progress
- `airbrake-issues unclaim ISSUE` — remove in-progress mark
- `airbrake-issues status` — show what's currently being tracked
- `airbrake-issues comment ISSUE 'message'` — post a comment on a GitHub issue (for skipped issues)
- `airbrake-issues resolve ISSUE` — resolve the Airbrake error group via API

## Workflow (strict order)

### 1. Get and read all fixable issues

```
airbrake-issues fixable
```

Read ALL the issue bodies. Each contains error type, message, backtrace, URL, occurrences, and severity. Use this to:
- Group issues that are the same underlying bug (same error type + same code path)
- Identify which are fixable vs transient/external
- Pick the best one to fix

If no fixable issues, report "No fixable Airbrake issues found" and stop.

### 2. Comment on skipped issues

For each issue you determine is **not fixable by a code change** (external API errors, gem-only backtraces, timeouts, transient issues, `[safely]`-wrapped errors), post a comment explaining why:

```
airbrake-issues comment ISSUE_NUMBER '[Airbrake Bot] Skipping: <reason>'
```

This helps track why issues were not addressed. Only comment once per issue — if the issue already has a skip comment from a previous run, don't duplicate it.

### 3. Select an issue group to fix

Pick **at most 1 issue group** per run. Prioritize by:
1. Groups with higher issue counts (more impact)
2. Groups with clearer, more localized fixes (NoMethodError, NameError > RuntimeError)
3. Older groups first

### 4. Claim the issue

```
airbrake-issues claim ISSUE_NUMBER BRANCH_NAME
```

### 5. Fix the bug in a worktree

Use `EnterWorktree` to create a worktree with name format `airbrake-NNNN` where NNNN is the primary issue number.

After entering the worktree:
- Copy `.env` if needed: `cp ~/projects/crowdcow/.env <worktree>/.env`
- Run `bundle install -j4` and `npm ci`

Then:
1. Read and understand the relevant source files from the backtrace.
2. Identify the root cause.
3. Implement the fix. Keep it minimal — fix the bug, nothing more.
4. If there are relevant specs, run them to verify.

### 6. Ship it

Run the `ship-it` workflow. This will:
- Run rubocop + specs
- Commit, push, and create a PR
- Wait for CI
- Request and address Copilot reviews

**IMPORTANT:** The PR title should start with `[Airbrake]` and the PR body must include `Fixes #NNNN` for each issue in the group so they auto-close when merged.

Example PR body:
```
## Summary
- Fix [brief description of the bug]
- Root cause: [one sentence explanation]

Fixes #17108

## Test plan
- [ ] CI passes
- [ ] Verify error stops occurring in Airbrake after deploy
```

### 7. Clean up tracking and resolve Airbrake

After the PR is created and CI is green (ship-it complete):

```
airbrake-issues unclaim ISSUE_NUMBER
```

Then resolve the Airbrake error group(s) so they stop firing:
```
airbrake-issues resolve ISSUE_NUMBER
```

Do this for each issue in the group. If the resolve call fails, log the error but don't block — the fix will still deploy and the error will stop naturally.

### 8. Report results

Report:
- Which issues were processed
- PR URL if created
- Whether Airbrake errors were resolved
- Any issues that were skipped and why

## Important rules

- **One fix per run.** Do not attempt multiple unrelated fixes in a single run.
- **Stay in the worktree** for the entire workflow including ship-it.
- **Do not fix issues in gem code.** Only fix code under PROJECT_ROOT.
- **If you can't figure out the fix after reading the code, skip the issue.** Add a comment on the GitHub issue explaining what you found, and move on. Do not spend more than a few minutes investigating.
- **Never mutate production data.** Do not use the production console.
- **Prefix Bash commands with `cd <worktree_path> &&`** since cwd resets between calls.
