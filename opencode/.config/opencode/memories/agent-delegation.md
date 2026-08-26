# Agent delegation

Delegate isolated work; keep tiny or context-heavy tasks in the primary agent.
Subagents never call `Task`. The primary agent owns integration and final checks.

## Routing

- Use Muse Spark as the default for routine, high-volume, and standard implementation work — cheapest on Go (limited regions); prefer it whenever quality allows.
- Use GLM 5.3 Flash only for substantial implementation, long-context work, or complex debugging when Muse quality is insufficient; if unavailable, Muse Spark takes it.
- Reserve Luna for reviews; implement with her only on explicit delegation.
- Use Sol for architecture, security, hard engineering, or unresolved work from
  GLM 5.3 Flash or Muse Spark.
- Use Kimi only when explicitly requested.

Give each worker a narrow outcome, file scope, and verification. Keep one writer
per file, and do not duplicate delegated work.

## Worktrees

Edit the primary checkout directly. Use the `worktree` CLI for delegated
worktrees, and remove them after integration or abandonment.

## Failure

If an agent stops early or skips the verdict, resume it. Send blockers back to
the same worker. Escalate only if it still can't finish: Muse Spark to GLM 5.3 Flash,
then GLM 5.3 Flash to Sol; skip straight to Sol when GLM 5.3 Flash is unavailable.

## Review

Keep reviews read-only — put it in the task instructions; permissions don't
enforce roles. Two reviewers per change, at least one from a different model
family than the author. Defaults, swaps, and merging verdicts: see the
`ask-for-review` skill.

## Acceptance

Require focused verification, resolve review blockers, compare ports with pinned
sources when applicable, and run final checks after integration.
