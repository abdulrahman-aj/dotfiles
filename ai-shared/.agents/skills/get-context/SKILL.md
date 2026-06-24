---
name: get-context
description: quickly understand the structure and conventions of the current codebase
---

Delegate all work by spawning an agent using the cheapest available model to do the following in the current working directory:

Explore the current codebase and return a concise summary: key directories and their roles, main entry points, conventions, and any patterns worth knowing before making changes. Limit search to files within the codebase — do not explore dependencies. Return findings in under 200 words.
