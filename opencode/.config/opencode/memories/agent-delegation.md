# Agent delegation

Delegate isolated work; keep tiny or context-heavy tasks in the primary agent.
Subagents never call `Task`. The primary agent owns integration and final checks.

## Routing

- Use Muse Spark for everyday work: routine, high-volume, coding, debugging, integration, synthesis, and ambiguity (daily driver).
- Reserve Luna for independent cross-family reviews only.
- Use Sol for architecture, security, hard engineering, or unresolved Muse Spark work.
- Use Kimi only when explicitly requested.

Give each worker a narrow outcome, file scope, and verification. Keep one writer
per file, and do not duplicate delegated work.

## Worktrees

Edit the primary checkout directly. Use the `worktree` CLI for delegated
worktrees, and remove them after integration or abandonment.

## Failure

Resume an agent that stops early or omits a verdict. Route blockers back to the
same implementer. Escalate only if the resumed or remediated attempt remains
incomplete: Muse Spark to Sol.

## Review

Keep reviews read-only and cross-family. Luna is the default reviewer for Muse Spark-authored work. Use Sol only for high-risk work or blockers that survive remediation
and re-review. Use Kimi only when explicitly requested. The `ask-for-review`
skill owns review workflow.

## Acceptance

Require focused verification, resolve review blockers, compare ports with pinned
sources when applicable, and run final checks after integration.
