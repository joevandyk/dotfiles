---
name: new-work
description: Exit the current worktree, return to master, and optionally start a new feature in a fresh worktree. Checks for clean git status first.
---

# New Work

Exits the current worktree and returns to the main project directory on an up-to-date master branch. If the user provided a feature description (via arguments), immediately starts that feature in a new worktree.

## Workflow (strict order)

1. **Check git status in the current directory.**
   - Run `git status` to check for uncommitted changes or untracked files.
   - If the working tree is **not clean**, stop and ask the user what to do:
     - Commit the changes first?
     - Discard the changes?
     - Abort the workflow entirely?
   - Do NOT proceed until the working tree is clean or the user has resolved the situation.

2. **Exit the worktree.**
   - Use the `ExitWorktree` tool with `action: "keep"` to return to the main project directory.
   - If not currently in a worktree session, just `cd` to `~/projects/crowdcow`.

3. **Switch to master and pull latest.**
   - `git checkout master`
   - `git pull origin master`

4. **Clear context.**
   - Run `/clear` to reset the conversation context for a fresh start.

5. **If no feature was requested:** done.
   - Reset tmux window name: `tmux rename-window -t $TMUX_PANE 'ready'`
   - Report that you're back on master with latest changes, ready for new work.

6. **If a feature/task was requested:** ALWAYS start it in a worktree — even for research-only or read-only tasks.
   - Create a new worktree with `EnterWorktree` (use a short descriptive name based on the task).
   - Set the tmux window name: `tmux rename-window -t $TMUX_PANE '<name>'` (max 12 chars, describing the task).
   - Research the codebase to understand relevant existing code.
   - Plan out the implementation (architecture, files to change, approach).
   - Present the plan to the user and wait for approval before writing code.
