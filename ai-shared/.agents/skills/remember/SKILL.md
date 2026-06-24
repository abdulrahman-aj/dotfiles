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
5. Deploy: run `make` from `~/.dotfiles`. This re-stows `ai-shared` (symlinks the new file into `~/.ai/` — a fresh memory won't load in any tool until stowed) and regenerates Codex's `AGENTS.md` (Codex has no import mechanism, so its file is generated from all memories — never edit it directly).

Confirm with a single line: "Remembered as `{slug}`."
