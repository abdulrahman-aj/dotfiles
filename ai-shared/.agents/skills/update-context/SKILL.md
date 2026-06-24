---
name: update-context
description: bootstrap or refresh project context files (CLAUDE.md + AGENTS.md)
---

Delegate all work by spawning an agent using the cheapest available model to do the following in the current working directory:

1. If `CLAUDE.md` does not exist in the project root, create it with a single line: `@AGENTS.md`
2. If `AGENTS.md` does not exist, create it. If it exists, update it.
3. Write high-level project context into `AGENTS.md`: purpose, key directories, salient commands (test, build, lint), architectural decisions worth knowing. Keep it concise — future sessions should not be burdened with stale detail.
4. Avoid documenting anything likely to change frequently (specific line numbers, implementation details).
