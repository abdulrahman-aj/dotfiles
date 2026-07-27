---
name: remember
description: persist a rule into AI memory — shared across all tools or scoped to one
---

Save a rule into memory and wire it into the right tool(s).

## Destination

Classify, state your choice, proceed unless the user objects:

* **`personal.md`** — about *me* (facts, style, tool choices).
* **`principles.md`** — reusable engineering/design rule, under the matching heading.
* **New shared file** — broad topic needing its own headings. Goes to all three tools (Claude, Codex, OpenCode).
* **Tool-scoped file** — rules referencing one tool's specific entities (agent names, skills, config). Goes to that tool only; the other two never see it. Default for OpenCode-specific rules.

Default: `principles.md` or `personal.md`. New file only when the user asks.

## Prose

Match `principles.md`'s voice. Re-read it first.

* One line, one rule.
* `* **Term**: prose.`
* Imperative, actionable — "Prefer X when Y", not "X is good."
* No preamble, no inline examples. 6–14 words of prose.

## Steps

1. Write the bullet(s) into the chosen file under the right heading, alongside siblings.
2. **New shared file**: create `~/.ai/memories/{slug}.md`, append `@~/.ai/memories/{slug}.md` to `~/.claude/CLAUDE.md`, and append `"~/.ai/memories/{slug}.md"` to the `instructions` array in `~/.config/opencode/opencode.jsonc`. (`make` auto-pulls it into Codex's generated `AGENTS.md`.)
3. **Tool-scoped (OpenCode)**: create `~/.config/opencode/memories/{slug}.md` (stowed from `opencode/.config/opencode/memories/`), and append `"~/.config/opencode/memories/{slug}.md"` to OpenCode's `instructions` array only. Do NOT add to `~/.claude/CLAUDE.md` or `~/.ai/memories/` — `make` would auto-pull the latter into Codex.
4. Run `make` from `~/dotfiles` — re-stows, regenerates Codex's `AGENTS.md`.

Confirm: "`{file}` updated." (or "`{slug}` saved." for new files).
