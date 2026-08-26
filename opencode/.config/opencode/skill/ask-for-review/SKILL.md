---
name: ask-for-review
description: Use when requesting an independent review of a diff, commit, range, or PR.
---

## Scope

Use the user-specified diff, commit, range, or PR. Otherwise:

* Dirty tree → staged, unstaged, and untracked changes.
* Clean tree → `HEAD`.
* Nothing reviewable → report it and stop.

Summarize the change’s intent in 1–2 sentences. Include known acceptance criteria and verification results.

## Reviewers

Two different reviewers, never the author. If neither GLM 5.3 Flash nor Muse Spark
made the change, they review together; if one did, the other joins with Luna.
If a reviewer turns out to be unavailable, swap in Luna, then Sol; if only one
reviewer is left, go ahead with one and say so. A reviewer named by the user
takes one slot under the same rules. At least one reviewer should come from a
different model family than the author — the usual pair already does unless
the author is one of them.

## Delegate

Send one Task call per reviewer, BOTH in a single message—never one after the
other. Pass scope, intent, and verification results—not your own reasoning;
a reviewer who can't run git or edit files also gets the diff pasted in. Keep
each `task_id`; resume any reviewer that returns no verdict.

Instruct the reviewer to:

* Apply `~/.ai/memories/principles.md` pragmatically.
* Focus on correctness, regressions, edge cases, and security/performance risks.
* Output `### Blockers` / `### Concerns` (omit empty). Each finding: `path:line` — issue, proposed fix.
* Review directly; do not delegate.
* Read-only — no edits, no tests.
* End with exactly one verdict: `Verdict: approve` (no findings), `Verdict: approve-with-concerns` (concerns only), or `Verdict: changes-requested` (any blocker).

## Re-review

Resume each reviewer via its `task_id` to verify prior findings against the full
current scope. Start fresh for second opinions, materially changed scope, or
missing `task_id`s.

## Merge verdicts

The primary agent combines both responses: any blocker blocks; concerns just
get noted. If a blocker is still disputed after a fix attempt and re-review,
Sol decides — unless the disputed finding was Sol's own; then ask the user.
