---
name: parallel-work
description: Use for an approved batch of independent worktree tasks that need isolated implementation and review pairs.
---

# Parallel Work

Use only for independent tasks Abdulrahman has approved and prioritized.

1. Scout only when a task has material uncertainty. Batch questions and wait for answers.
2. Create each managed worktree with `worktree create <task-slug>`. Create a queue card only for todos-tracked work. Give each worker its path, branch, scope, and checks.
3. Tell each worker: "You are the implementation worker for this approved `parallel-work` task. Work only in the assigned worktree. Commit locally; never push. After verification, invoke `ask-for-review`. Do not delegate anything else." Reviewers do not delegate.
4. Require this handoff only: commit, review result, verification, and unresolved risks.
5. After Abdulrahman approves integration, merge and run `worktree remove <task>`.
