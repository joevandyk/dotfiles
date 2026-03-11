---
name: ship-it
description: Full end-to-end workflow that lands work, requests a GitHub Copilot review, waits for feedback, and addresses it in a loop. Use when the user says ship it, or wants to finish work and get it fully reviewed.
---

# Ship It

Full end-to-end workflow that lands work, requests a GitHub Copilot review, waits for feedback, and addresses it in a loop.

## CLI tools

These CLIs wrap complex APIs and handle pagination, polling, and edge cases. **Always use them instead of raw `gh api` calls.**

- **`buildkite`** — CI status, wait-for-completion, failure logs. See `/check-ci` for full reference.
- **`gh-reviews`** — Review threads, replies, resolution, Copilot review requests. See `/check-for-reviews` for full reference.

## Workflow (strict order)

1. **Run the `land-the-plane` workflow.**
   - This handles rubocop, specs, commit, sync, push, and PR creation.

2. **Wait for Buildkite CI to pass.**
   - Run the `check-ci` workflow (uses `buildkite wait` to poll automatically).
   - If CI fails and the failure is fixable (rubocop, specs), fix it, commit, push, and re-run `check-ci`.
   - If CI fails with an infrastructure issue, report it and continue to review.

3. **Request a Copilot review.**
   - `gh-reviews copilot-review`

4. **Wait for review to complete.**
   - `gh-reviews copilot-wait` (polls automatically, 10min max).
   - If timeout, continue anyway.

5. **Address feedback loop.**
   - If there are unresolved threads, run the `check-for-reviews` workflow.
   - **Always use `gh-reviews` for thread operations — never use raw `gh api` calls.**
   - After addressing, re-request review with `gh-reviews copilot-review`, then repeat the wait/poll step (step 4) until no unresolved threads remain.
   - After pushing review fixes, re-run `check-ci` to verify CI still passes.

6. **Confirm and report PR URL.**
   - `gh pr view --json url -q .url`

## Completion criteria

You are **not done** until ALL of the following are true:
- CI is green.
- Every review thread is either **resolved** (valid feedback, fix applied) or has a **reply** explaining why it was not fixed (invalid/inapplicable feedback). No unresolved thread may lack a response.
- PR URL is confirmed.

## Notes

- This is an iterative workflow: land → CI → review → fix → CI → review → fix → done.
- **Never use `gh api` for review operations** — `gh-reviews` handles GraphQL pagination and thread resolution.
- **Never use `gh pr checks` for CI** — `buildkite` has wait/poll and failure log support built in.
