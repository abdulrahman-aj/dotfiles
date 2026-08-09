---
name: remember
description: persist a rule into shared or OpenCode-only AI memory
---

Save a rule into memory and wire it into the right tool(s).

## Destination

Classify, state your choice, proceed unless the user objects:

* **Project-scoped rule** — behavior limited to the current repository. Add it
  to that repository's `AGENTS.md`; do not add it to global memory.
* **`personal.md`** — about *me* (facts, style, tool choices).
* **`principles.md`** — reusable engineering/design rule, under the matching heading.
* **New shared file** — broad topic needing its own headings. Add it to shared
  memory and OpenCode's instructions.
* **Tool-scoped file** — rules referencing OpenCode-specific entities (agent
  names, skills, config). Add it only to OpenCode. Default for OpenCode rules.

Classify repository-specific rules before considering global memory. Default:
`principles.md` or `personal.md`. New file only when the user asks.

## Prose

Match `principles.md`'s voice. Re-read it first.

* One line, one rule.
* `* **Term**: prose.`
* Imperative, actionable — "Prefer X when Y", not "X is good."
* No preamble, no inline examples. 6–14 words of prose.

## Steps

1. **Project-scoped rule**: write it in the current repository's `AGENTS.md` under the relevant section. Do not run `make` from `~/dotfiles`.
2. Write global-memory bullets into the chosen file under the right heading, alongside siblings.
3. **New shared file**: create `~/.ai/memories/{slug}.md` and append
   `"~/.ai/memories/{slug}.md"` to OpenCode's `instructions` array.
4. **Tool-scoped (OpenCode)**: create
   `~/.config/opencode/memories/{slug}.md` (stowed from
   `opencode/.config/opencode/memories/`), and append its path to OpenCode's
   `instructions` array only. Do not add it to shared memory.
5. For changes under `~/dotfiles` (global or tool-scoped), run `make` from
   `~/dotfiles` to re-stow the configuration.

Confirm: "`{file}` updated." (or "`{slug}` saved." for new files).
