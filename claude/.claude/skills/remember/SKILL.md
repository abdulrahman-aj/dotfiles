---
name: remember
description: persist a preference or rule into all three AI tools (Claude, Codex, OpenCode)
---

Save the direction just given into shared memory and wire it into all agents.

Steps:
1. Choose a short kebab-case slug for the memory (e.g. `no-inline-styles`).
2. Create `~/.ai/memories/{slug}.md` with the content as a clear, reusable rule.
3. Add `@~/.ai/memories/{slug}.md` as a new line in `~/.claude/CLAUDE.md`.
4. Add `"~/.ai/memories/{slug}.md"` to the `instructions` array in `~/.config/opencode/opencode.jsonc`.
5. Regenerate Codex's instructions: run `make build-codex` from `~/.dotfiles` (Codex has no import mechanism, so its `AGENTS.md` is generated from all memory files — never edit it directly).

Confirm with a single line: "Remembered as `{slug}`."
