---
name: todo
description: manage and execute tasks in .todo-agent.md for the current project
---

- `/todo` — enter plan mode on the next unchecked task (or next logical group).
- `/todo <hint>` — find the task best matching the hint, confirm with the user, then enter plan mode.

If `.todo-agent.md` doesn't exist or has no unchecked tasks, say so and stop.

**NEVER skip these steps:**
1. `/todo <hint>`: confirm the task match only.
2. Plan without project edits; wait for approval before implementing.
3. Implement and verify while keeping the task unchecked.
4. After verification, ask the user to confirm completion; only then check it and move it to `## Done`.

Task selection and plan approval never mean completion.
