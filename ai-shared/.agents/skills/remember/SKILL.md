---
name: remember
description: persist a preference or rule into all three AI tools (Claude, Codex, OpenCode)
---

Save the direction into shared memory and wire it into all agents.

1. Pick a short kebab-case slug.
2. Create `~/.ai/memories/{slug}.md` — one concise, reusable rule. No preamble.
3. Append `@~/.ai/memories/{slug}.md` to `~/.claude/CLAUDE.md`.
4. Append `"~/.ai/memories/{slug}.md"` to the `instructions` array in `~/.config/opencode/opencode.jsonc`.
5. Run `make` from `~/.dotfiles` — stows the new file and regenerates Codex's `AGENTS.md` (never edit it directly).

Confirm: "`{slug}` saved."
