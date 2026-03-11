---
name: land-the-plane
description: Finalize work session by running rubocop, specs, committing, syncing with origin/master, pushing, and creating or updating a GitHub PR. Use when the user says to land, finish, or push their work.
---

# Land the Plane

Finalizes a work session by fixing Rubocop errors, running relevant specs, committing changes, syncing with origin/master, pushing the branch, and creating a GitHub PR.

CRITICAL: You MUST create or update a GitHub PR and report its URL before completion. Do not claim the workflow is complete unless a PR URL is confirmed.

## Workflow (strict order)

1. **Check the working tree and branch.**
   - `git status`
   - `git branch --show-current`
   - **If work was done in a worktree:** `cd` into the worktree directory and run ALL subsequent steps there. Do NOT copy files back to the main checkout. The worktree already has its own branch.
   - If on `master` or `main` (and not in a worktree), create a branch: `git switch -c <short-descriptive-branch>`

2. **Fix Rubocop for modified Ruby files.**
   - `bundle exec rubocop <path/to/changed.rb ...>`

3. **Run relevant specs.**
   - `bundle exec rspec <specs>`

4. **Stage and commit.**
   - `git add -A`
   - `git commit -m "..."` (use repo style)

5. **Sync with `origin/master` using merge only.**
   - `git fetch origin`
   - `git merge origin/master`
   - **Never use rebase.** Do not run `git pull --rebase`. Do not force-push.

6. **Push the branch.**
   - `git push -u origin HEAD`

7. **Create or update a GitHub PR with `gh`.**
   - `gh auth status`
   - `gh pr view --json number,body,title,state`
   - If PR is OPEN: update title/body.
   - If PR is CLOSED (unmerged): reopen or create new.
   - If PR is MERGED: create a new PR.
   - Always use HEREDOC for PR bodies.
   - Confirm and report URL: `gh pr view --json url -q .url`

## Notes

- If no relevant specs exist, say so in the PR test plan.
- Hyperlink URLs in the final response.
- Completion gate: do not claim completion unless a PR URL is confirmed.
