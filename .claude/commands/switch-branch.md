---
name: switch-branch
description: Switch to an existing branch or PR. Finds and enters existing worktrees, or checks out the branch. Runs branch-status afterward.
---

# Switch Branch

Switch to a different branch or PR. The argument can be a branch name or a PR number/URL.

## Steps

1. **Parse the argument.**
   - If it looks like a PR number (e.g. `123` or `#123`), resolve the branch name:
     - `gh pr view <number> --json headRefName -q .headRefName`
   - Otherwise, treat it as a branch name directly.

2. **Check current git status.**
   - Run `git status --short`.
   - If the working tree is **not clean**, stop and ask the user what to do (commit, stash, discard, or abort).
   - Do NOT proceed until resolved.

3. **Check for an existing worktree on that branch.**
   - Run `git worktree list` and look for a worktree checked out on the target branch.
   - If a worktree exists:
     - If currently in a worktree, use `ExitWorktree` with `action: "keep"` first.
     - Note the worktree path. **All subsequent Bash commands must be prefixed with `cd <worktree_path> &&`** since the Bash tool resets the working directory between calls.
     - Set tmux window name: `tmux rename-window -t $TMUX_PANE '<short-name>'` (max 12 chars, derived from branch).
   - If no worktree exists:
     - If currently in a worktree, use `ExitWorktree` with `action: "keep"` first, then check out the branch: `git checkout <branch>`.
     - If on main checkout, just `git checkout <branch>`.
     - Set tmux window name: `tmux rename-window -t $TMUX_PANE '<short-name>'` (max 12 chars, derived from branch).

4. **Install dependencies** (worktree only — main checkout already has them).
   - `cd <worktree_path> && bundle install -j4`
   - `cd <worktree_path> && npm ci`
   - These run in the worktree so its Gemfile.lock / package-lock.json are respected.

5. **Run `/branch-status`** to show the current state. Remember to prefix commands with `cd <worktree_path> &&` if in a worktree.
