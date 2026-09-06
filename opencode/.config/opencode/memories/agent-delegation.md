# Agent delegation

Delegate when it saves time or adds expertise. Keep key decisions and work that
needs much of the current conversation in the primary agent.

## Routing

- Muse: default worker, including large changes and difficult debugging.
- GLM: alternative when Muse's data-use terms are unsuitable, or for a second opinion.
- Sol: difficult reasoning, engineering, or a second opinion.
- Astra: only when explicitly requested, including for reviews.

Do not assume another model is better. Before switching, check why the worker failed;
give missing context or tools to the same worker and resume it.

Follow the project's provider restrictions for workers and reviewers. Muse Contributor
may use submitted content for training: ask before first use unless already approved
for this work.

## Execution

- Give each worker a clear task and checks to run. Avoid assigning duplicate tasks.
- Use separate worktrees for parallel implementation; see `parallel-work`.
- The primary merges changes, resolves conflicts, and verifies the combined result.

## Review

Self-review and run checks. Add an independent reviewer when a second opinion would
help establish correctness, especially when mistakes would be costly. Add more only
for a specific unresolved concern or the user's request. Follow requested counts,
including no delegation. Use `ask-for-review`; check findings before acting on them.
