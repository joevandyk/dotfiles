---
name: check-for-reviews
description: Fetch GitHub PR review threads, address feedback in code, resolve addressed threads, explain non-fixes, and push. Use when the user asks to check reviews, address feedback, or fix review comments.
---

# Check for Reviews

Reviews GitHub pull request feedback, applies fixes, resolves addressed review threads, explains non-fixes, posts a final change summary comment, then runs land-the-plane.

All GitHub review thread operations use the **`gh-reviews`** CLI (handles GraphQL pagination, reply endpoints, and thread resolution automatically).

## Required outcomes

1. Fetch PR comments/review threads.
2. Address reviewer comments in code when appropriate.
3. If fixed, reply and resolve that review thread.
4. If not fixed, reply with a clear rationale explaining why.
5. **Every unresolved thread must be accounted for** — either resolved (fix applied) or replied to (rationale given). You are NOT done until every thread has one of these two outcomes.
6. Post one final PR comment summarizing all changes made.
7. Run the `land-the-plane` command workflow.

## CLI reference: `gh-reviews`

```
gh-reviews threads [PR] [--unresolved|--resolved] [--current|--outdated]
gh-reviews comments [PR]
gh-reviews reply PR COMMENT_ID BODY [--resolve]
gh-reviews resolve PR THREAD_ID
gh-reviews copilot-review [PR]
gh-reviews copilot-status [PR]
gh-reviews copilot-wait [PR]
```

- **threads**: Fetches all review threads as JSON. Each entry includes `thread_id`, `is_resolved`, `is_outdated`, `first_comment` (with `comment_id`, `author`, `path`, `line`, `url`, `body`), and `last_comment`.
- **comments**: Fetches issue-level (general discussion) PR comments as JSON.
- **reply**: Replies to a review comment using its `comment_id`. With `--resolve`, also resolves the parent thread.
- **resolve**: Resolves a thread by its `thread_id`.
- **copilot-review**: Requests a GitHub Copilot review on the PR.
- **copilot-status**: One-shot check if Copilot review is pending or complete.
- **copilot-wait**: Polls until Copilot review completes (10min max). Use this instead of manual polling loops.

PR number auto-detects from the current branch when omitted.

## Workflow (strict order)

1. **Identify PR context**
   - `gh pr view --json number,url,title,state -q '.'`
   - If no PR exists for the current branch, stop and ask the user which PR to review.

2. **Fetch review data**
   ```bash
   gh-reviews threads --unresolved --current
   gh-reviews threads --unresolved --outdated
   gh-reviews threads
   gh-reviews comments
   ```
   Run these `threads` commands sequentially, not in parallel.

3. **Triage comments**
   - Group by actionable vs non-actionable.
   - Triage in order: unresolved+current, unresolved+outdated, general comments.
   - For each actionable thread, decide: fix now or reply with rationale.

4. **Implement fixes**
   - Make focused edits.
   - Run relevant checks (Rubocop/specs) for touched areas.
   - Keep changes scoped to reviewer feedback.
   - **For CI comments (e.g. Copilot) you decide not to act on** (invalid, inapplicable, or intentionally declined): add a brief inline code comment at the flagged location explaining why. This prevents future CI runs from re-flagging the same thing. Example:
     ```ruby
     # copilot: suggested X — not applicable because Y
     ```

5. **Reply + resolve per thread**
   ```bash
   # Reply and resolve (when fix is done)
   gh-reviews reply 17032 2891915017 "$(cat <<'EOF'
   Addressed in abc123: description of fix.
   EOF
   )" --resolve

   # Reply without resolving (when explaining why not fixing)
   gh-reviews reply 17032 2891915017 "$(cat <<'EOF'
   Not changing because: rationale.
   EOF
   )"
   ```

6. **Re-check for newly created threads/comments**
   - After every push, re-run Step 2.
   - Do not finalize while any unresolved non-outdated thread remains.

7. **Post final summary comment**
   ```bash
   gh pr comment <pr_number> --body "$(cat <<'EOF'
   Addressed review feedback:
   - ...

   Not changed (with rationale):
   - ...

   Validation run:
   - ...
   EOF
   )"
   ```

8. **Run land-the-plane**
   - After review fixes/comments are done, execute the land-the-plane workflow.
   - Ensure PR URL is confirmed at the end.

## Completion criteria

You are **not done** until ALL of the following are true:
- Every review thread is either **resolved** (valid feedback, fix applied) or has a **reply** explaining why it was not fixed (invalid/inapplicable feedback).
- No unresolved thread lacks a response.
- The final summary comment has been posted.
- The `land-the-plane` workflow has been run.

## Notes

- Use `gh-reviews` for all review thread operations.
- Use HEREDOCs for reply bodies to avoid shell expansion issues.
- Use `gh pr comment` for posting general PR comments (step 7).
- Re-fetch thread state after each push; do not assume earlier fetches are still current.
