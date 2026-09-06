---
name: remember
description: Use when asked to persist a rule in project, shared, or OpenCode-only memory.
---

Choose the narrowest scope:

- Project-specific rules: the repository's `AGENTS.md`.
- Personal facts and preferences: `~/.ai/memories/personal.md`.
- Reusable engineering rules: `~/.ai/memories/principles.md`.
- OpenCode-specific rules: `~/.config/opencode/memories/`.

Read the destination first. Update related rules rather than adding duplicates;
keep wording short, actionable, and consistent with the file.

For global memory, edit the source in `~/dotfiles`. Prefer existing files; create
new ones only when requested. Add new memory files to OpenCode's `instructions`
and deploy only the needed links, not the full dotfiles setup.

Report which file changed.
