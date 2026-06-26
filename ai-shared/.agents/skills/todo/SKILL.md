---
name: todo
description: manage and execute tasks in .todo-agent.md for the current project
---

- `/todo` — enter plan mode on the next unchecked task (or next logical group).
- `/todo <hint>` — find the task best matching the hint, confirm with the user, then enter plan mode.

If `.todo-agent.md` doesn't exist or has no unchecked tasks, say so and stop.

**NEVER skip these steps:**
1. `/todo <hint>`: confirm match with user before proceeding.
2. Enter plan mode. Wait for approval before writing any code.
3. On user confirmation: move the item to `## Done` at the bottom (create if needed).
