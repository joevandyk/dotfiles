---
name: github-pr
description: Create or update a GitHub pull request for the current branch. Handles existing PR state and preserves third-party content in PR bodies.
---

# GitHub PR

Create or update a GitHub pull request for the current branch. Handles existing PR state and preserves third-party content in PR bodies.

CRITICAL: You MUST create or update a GitHub PR and report its URL before completion.

## Workflow (strict order)

1. **Check branch and status.**
   - `git branch --show-current`
   - If on `master` or `main`, stop and ask the user to create a branch first.

2. **Push the branch.**
   - `git push -u origin HEAD`

3. **Check for existing PR.**
   - `gh pr view --json number,body,title,state`
   - If PR is OPEN: update title/body, preserving any third-party content (e.g., bot comments, CI status) in the body.
   - If PR is CLOSED (unmerged): reopen or create new.
   - If PR is MERGED: create a new PR.
   - If no PR exists: create a new one.

4. **Create or update PR.**
   - Analyze all commits on the branch vs `origin/master` to build the PR description.
   - Always use HEREDOC for PR bodies.
   - Include a summary section and test plan.

5. **Confirm and report URL.**
   - `gh pr view --json url -q .url`

## Notes

- Hyperlink URLs in the final response.
- Completion gate: do not claim completion unless a PR URL is confirmed.
