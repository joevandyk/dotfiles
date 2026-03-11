---
name: work-done
description: Clean up the current worktree, switch back to master, and reset the tmux window title. Use when finished with a task.
---

# Work Done

Clean up after finishing a task — delete the worktree, return to master, and reset tmux.

## Workflow (strict order)

1. **Check git status in the current directory.**
   - Run `git status` to check for uncommitted changes or untracked files.
   - If the working tree is **not clean**, stop and ask the user what to do:
     - Commit the changes first?
     - Discard the changes?
     - Abort the cleanup entirely?
   - Do NOT proceed until the working tree is clean or the user has resolved the situation.

2. **Exit and delete the worktree.**
   - Use the `ExitWorktree` tool with `action: "delete"` to remove the worktree and return to the main project directory.
   - If not currently in a worktree session, just `cd` to `~/projects/crowdcow`.

3. **Switch to master and pull latest.**
   - `git checkout master`
   - `git pull origin master`

4. **Reset tmux window name.**
   - `tmux rename-window -t $TMUX_PANE 'ready'`

5. **Report done.** Confirm the worktree was cleaned up and you're back on an up-to-date master. Remind the user to run `/clear` to reset context for the next task.
