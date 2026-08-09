# dotfiles

Personal dotfiles managed with GNU Stow. Deploying to a new machine: clone the repo and run `make`.

## Structure

Each top-level directory is a stow package that mirrors `~/`:

| Package | Stows to | Contents |
|---------|----------|----------|
| `fish/` | `~/.config/fish/`, `~/.config/starship.toml` | Fish shell config, Starship prompt |
| `alacritty/` | `~/.config/alacritty/` | Terminal config |
| `hypr/` | `~/.config/hypr/` | Hyprland configuration |
| `zed/` | `~/.config/zed/` | Editor settings, keymap, tasks, theme |
| `git/` | `~/.gitconfig`, `~/.config/git/` | Git global config + global gitignore |
| `bin/` | `~/.local/bin/` | Personal executable commands |
| `cloc/` | `~/.config/cloc/` | cloc default options (global excludes) |
| `lazygit/` | `~/.config/lazygit/` | LazyGit configuration |
| `ai-shared/` | `~/.ai/`, `~/.agents/` | Shared AI memories + skills |
| `opencode/` | `~/.config/opencode/` | OpenCode config, agents, skills, tool-scoped memories |

## Key Commands

```bash
make          # deploy everything (stow all packages + AI setup)
make check    # dry-run and report conflicts
make test     # run deployment tests in isolated temporary homes
make unstow   # remove all symlinks
```

Pass `TARGET=/path/to/home` to run the complete workflow against another home
directory.

## Deployment Architecture

- Before Stow runs, unmanaged paths that conflict with repo-managed files are moved
  to a timestamped `.dotfiles-backups/` directory under the target home.
- Stow uses `--no-folding`, keeping managed directories writable and linking their
  individual files instead of linking whole directory trees into the repo.
- Fisher and Kickstart.nvim are external bootstrap steps run after Stow. They honor
  `TARGET`, preserve unrelated existing configurations, and are safe to retry.

## AI Preferences Architecture

Single source of truth for shared rules: `ai-shared/.ai/memories/*.md`.
OpenCode-only rules live in `opencode/.config/opencode/memories/` and are added
to OpenCode's `instructions` array.

Shared skills (`automate-friction`, `get-context`, `remember`, `todo`,
`todo-add`, `update-context`) live in `ai-shared/.agents/skills/`, stowed to
`~/.agents/skills/`. OpenCode reads them natively.

## Adding a New Memory

Use the `/remember` skill — it handles shared and tool-scoped (OpenCode-only) memories end to end. Manual procedure: `ai-shared/.agents/skills/remember/SKILL.md`.

## Constraints

- Keep dotfile configuration portable; avoid platform- or package-manager-specific assumptions.
- `nixos-shell` supplies its required NixOS services, graphical-session
  lifecycle, curated Hyprland appearance, and shell-facing default bindings.
  The Hyprland package loads those defaults first through `modules/shell.lua`;
  personal monitor/input/application/layout/window policy remains here. Remove
  a shell binding through its named handle before defining a replacement.
- Never commit without explicit user authorization.
- When adding a new stow package, update the package table in this file.
