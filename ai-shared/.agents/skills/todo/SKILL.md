---
name: todo
description: manage and execute tasks in .todo-agent.md for the current project
---

- `/todo add <description>` — append `- [ ] <description>` to `.todo-agent.md`. On first create, also add `.todo-agent.md` to `.gitignore`. Confirm: "Added: <description>".
- `/todo` — enter plan mode on the next unchecked task (or next logical group).
- `/todo pick "<hint>"` — confirm the matched task with the user, then enter plan mode.

If `.todo-agent.md` doesn't exist or has no unchecked tasks, say so and stop.

**NEVER skip these steps — not even for trivial tasks:**
1. `/todo pick`: wait for user to confirm the match before proceeding.
2. Enter plan mode / present a plan. Wait for approval before writing any code.
3. Mark `- [x]` only after the user confirms it works — "no errors" is not confirmation.
