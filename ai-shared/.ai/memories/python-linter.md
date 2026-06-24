---
name: python-linter
description: Use Ruff to lint Python files
metadata:
  type: feedback
---

Always run `ruff check` on Python files after writing or editing them.

**Why:** The project uses Ruff as its Python linter. Violations (e.g. E401 multiple imports on one line) should be caught before presenting the result.

**How to apply:** After writing any Python file, run `ruff check <file>` and fix any reported issues before finishing.
