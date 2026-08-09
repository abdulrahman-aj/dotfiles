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

## Reviewer

Choose the reviewer using `~/.config/opencode/memories/agent-delegation.md`. An explicit reviewer argument overrides it.

## Delegate

Make one Task call. Pass the scope, intent, and verification results—not the diff or implementer reasoning. Keep the returned `task_id` for re-reviews. Treat a response without a verdict as incomplete: resume the reviewer to supply one.

Instruct the reviewer to:

* Apply `~/.ai/memories/principles.md` pragmatically.
* Focus on correctness, regressions, edge cases, and security/performance risks.
* Output `### Blockers` / `### Concerns` (omit empty). Each finding: `path:line` — issue, proposed fix.
* Review directly; do not delegate.
* Read-only — no edits, no tests.
* End with exactly one verdict: `Verdict: approve` (no findings), `Verdict: approve-with-concerns` (concerns only), or `Verdict: changes-requested` (any blocker).

## Re-review

Resume via `task_id` when available to verify prior findings and review the full
current scope for new issues. Start fresh for a second opinion, materially
changed scope, or missing `task_id`.
