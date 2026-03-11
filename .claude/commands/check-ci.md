---
name: check-ci
description: Check Buildkite CI status for the current branch, wait for completion, and fetch failure logs. Use when the user asks to check CI, monitor a build, or when another skill needs to verify CI passes.
---

# Check CI

Monitor Buildkite CI builds for the current branch, wait for completion, and diagnose failures.

## CLI reference: `buildkite`

```
buildkite status [BRANCH]          — show latest build status
buildkite wait [BRANCH]            — poll until build completes (15min max)
buildkite failures [BRANCH]        — show logs for failed jobs
buildkite logs BUILD_NUMBER JOB    — show log for a specific job
```

Branch defaults to current git branch when omitted.

Requires `BUILDKITE_API_TOKEN` env var (auto-loaded from `~/.claude/settings.local.json`).

## Workflow (strict order)

1. **Check current build status.**
   - `buildkite status`
   - If already passed, report success and stop.
   - If already failed, go to step 3.

2. **Wait for build to complete.**
   - `buildkite wait`
   - If it passes, report success and stop.
   - If it fails, continue to step 3.

3. **Fetch failure logs.**
   - `buildkite failures`
   - Analyze the output to identify root causes.

4. **Fix failures if possible.**
   - For rubocop failures: fix the offending files, commit, and push.
   - For spec failures: investigate and fix the failing specs, commit, and push.
   - For build/infrastructure failures: report to the user with the error details.
   - After pushing fixes, go back to step 1 to monitor the new build.

5. **Report results.**
   - Summarize what passed, what failed, and what was fixed.

## Notes

- Maximum 3 fix-and-retry cycles to avoid infinite loops.
- If a failure can't be fixed automatically, report the full error to the user.
- Infrastructure failures (Docker build, network, etc.) should be reported, not retried.
