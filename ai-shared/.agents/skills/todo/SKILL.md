---
name: todo
description: manage and execute tasks in .todo-agent.md for the current project
---

- `/todo add <description>` — append `- [ ] <description>` to `.todo-agent.md`. On first
  create, also add `.todo-agent.md` to `.gitignore` if one exists. Confirm: "Added: <description>".
- `/todo` — pick up the next unchecked task (or next logical group of related tasks).
- `/todo pick "<hint>"` — find the unchecked task best matching the hint, confirm the match
  with the user, then enter plan mode.

If `.todo-agent.md` doesn't exist or has no unchecked tasks, say so and stop.

For bare `/todo`, enter plan mode directly. For `/todo pick`, confirm the matched task first.
On completion mark the task `- [x]`. If the user abandons, move it to the end as `- [ ]`
(deprioritized).
