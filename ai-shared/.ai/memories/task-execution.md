# Task Execution

Always check for task runners in this order before running any command:

1. **Makefile** — look for relevant targets (test, lint, format, build, check, etc.)
2. **Taskfile** (or Taskfile.yml)
3. **justfile** (Just)
4. **Standard configs** — `package.json` scripts (npm/pnpm/yarn), `pyproject.toml` (pytest, ruff, etc.)

Do not guess commands — look up the actual targets/config before running.

If none exist, suggest creating a Makefile (or TaskFile) to capture commands — don't leave them undocumented.
