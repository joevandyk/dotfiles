---
name: branch-status
description: Report current branch and PR status — uncommitted changes, commits ahead/behind, CI status, and PR state.
---

# Branch & PR Status

Report a concise summary of the current branch and PR state.

## Steps

1. Run these in parallel:
   - `git branch --show-current`
   - `git status --short`
   - `git log --oneline origin/master..HEAD` (commits not yet on master)
   - `git log --oneline HEAD..origin/master | head -5` (commits on master not in this branch)
   - `gh pr view --json number,title,state,url,reviewDecision 2>&1`
   - `buildkite status` (for CI status — preferred over `gh pr checks` or `statusCheckRollup`)

2. Summarize clearly:
   - **Branch**: name
   - **Uncommitted changes**: list or "clean"
   - **Commits ahead of master**: count and one-line summaries
   - **Commits behind master**: count
   - **PR**: number, title, state (open/closed/merged/draft/none), URL
   - **Reviews**: approved / changes requested / pending
   - **CI**: pass / fail / pending (from statusCheckRollup)

3. Keep it brief. Use a compact format, not walls of text.
