---
name: ask-for-review
description: Use for explicit user review requests, or after verifying your local commit for an approved parallel-work task.
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

Make one Task call. Pass the scope, intent, and verification results—not the diff or implementer reasoning. Keep the returned `task_id` for re-reviews.

Instruct the reviewer to:

* Apply `~/.ai/memories/principles.md` pragmatically.
* Focus on correctness, regressions, edge cases, and security/performance risks.
* Output `### Blockers` / `### Concerns` (omit empty). Each finding: `path:line` — issue, proposed fix.
* Review directly; do not delegate.
* Read-only — no edits, no tests. Say "No blockers or concerns." if clean.

## Remediate

Act on blockers and actionable concerns in the same turn; do not stop at
findings.

1. Apply the smallest correct fixes and add regression coverage.
2. Run relevant verification.
3. Resume the reviewer with its `task_id` for one re-review of the full scope.
4. Repeat for blockers. State why any intentional or unresolved concern remains.

Report fixes, accepted risks, unresolved risks, and verification only after this
loop. Preserve the `task_id` for future re-reviews.

## Re-review

Resume via `task_id` when available to verify prior findings and review the full
current scope for new issues. Start fresh for a second opinion, materially
changed scope, or missing `task_id`.
