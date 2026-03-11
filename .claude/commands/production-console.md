---
name: production-console
description: Run a read-only Ruby snippet on the production Rails console via Porter. Use when the user needs to inspect production data, check Sidekiq queues, or debug production issues. NEVER run anything that mutates data.
---

# Production Console

Run read-only Ruby snippets on the production Rails console.

## Command template

```bash
script -q /dev/null porter run --cluster 1465 --ram 1024 --non-interactive worker-production -- /bin/sh -c './bin/rails runner "<ruby code>"' 2>&1 | cat
```

**Important:** Porter's non-interactive mode doesn't relay stdout unless wrapped with `script -q /dev/null ... 2>&1 | cat`. Always use this wrapper.

Use double quotes for the Ruby code inside the rails runner call. Escape inner double quotes with `\"`. Join statements with semicolons.

Set a 120-second timeout on commands (Porter pod boot + Rails load takes ~20s).

## CRITICAL SAFETY RULES

1. **READ-ONLY ONLY.** Never run code that creates, updates, destroys, saves, or mutates any record.
2. **Forbidden methods:** `create`, `update`, `save`, `destroy`, `delete`, `insert`, `upsert`, `execute("INSERT/UPDATE/DELETE")`, `perform_async`, `perform_later`, `deliver_now`, `deliver_later`, any ActiveRecord persistence method.
3. **Forbidden patterns:** Assignment to model attributes followed by save, `ActiveRecord::Base.connection.execute` with write SQL, queue operations that enqueue new jobs.
4. **If the user asks to run something that would mutate data**, refuse and explain why. Suggest they do it manually via `bundle exec rake production:console`.

## Workflow

1. **Validate the snippet is read-only** before running.
2. **Run via porter** with `rails runner` using the command template above.
3. **Parse and summarize** the output for the user. Ignore ANSI color codes and Porter boilerplate in the output.

## Examples

```bash
# Check Sidekiq queue sizes
script -q /dev/null porter run --cluster 1465 --ram 1024 --non-interactive worker-production -- /bin/sh -c './bin/rails runner "require \"sidekiq/api\"; Sidekiq::Queue.all.sort_by{|q| -q.size}.each{|q| puts \"#{q.name}: size=#{q.size} latency=#{q.latency.round(1)}s\"}"' 2>&1 | cat

# Check Sidekiq processes
script -q /dev/null porter run --cluster 1465 --ram 1024 --non-interactive worker-production -- /bin/sh -c './bin/rails runner "require \"sidekiq/api\"; Sidekiq::ProcessSet.new.each{|p| puts \"#{p[\"hostname\"]} concurrency=#{p[\"concurrency\"]} busy=#{p[\"busy\"]}\"}"' 2>&1 | cat

# Count records
script -q /dev/null porter run --cluster 1465 --ram 1024 --non-interactive worker-production -- /bin/sh -c './bin/rails runner "puts Order.where(\"created_at > ?\", 1.day.ago).count"' 2>&1 | cat
```

## Notes

- Porter boot + Rails load takes ~20 seconds — be patient.
- Output is plain text (puts). Use `.inspect` or `.to_json` for complex objects.
- Keep snippets short. For complex investigation, run multiple small queries.
- There are 3 worker pods (k8s); all run the same queues with concurrency=1.
- For staging, use cluster 1333 and app `staging-worker` instead.
- **Shell safety:** The Ruby code is interpolated into a `sh -c` string. Only Claude constructs these snippets (not user input), but always escape double quotes and avoid shell metacharacters in the Ruby code.
