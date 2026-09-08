# dotfiles

Personal dotfiles managed with GNU Stow. Deploying to a new machine: clone the repo and run `make`.

## Structure

`home/` is a stow package that mirrors `~/` 1:1: strip the `home/` prefix to
get the deployed path (e.g. `home/.config/fish/config.fish` → `~/.config/fish/config.fish`).
New dotfiles go under `home/` at their deployed relative path.

## Key Commands

```bash
make          # deploy everything (stow home/ + AI setup)
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
- Fisher is an external bootstrap step run after Stow. It honors
  `TARGET`, preserves unrelated existing configurations, and is safe to retry.
- `home/` is always stowed in full. The Omarchy setup step (preinstall removal,
  package/browser/editor installs, `chsh`) runs only on Omarchy hosts deploying
  to the real `$HOME`; elsewhere the stowed XDG defaults apply as-is.
- The repo owns `shell.json`, `mimeapps.list`, and `xdg-terminals.list` (which
  sets terminal preference order — do not replace it with the single-entry
  output of `omarchy default terminal`). Applications may atomically replace
  their Stow links; the next deployment backs up changed files and restores
  repository versions.

## AI Memories & Skills

Single source of truth for shared rules: `home/.ai/memories/*.md`.
OpenCode-only rules live in `home/.config/opencode/memories/` and are added
to OpenCode's `instructions` array.

Shared skills (`automate-friction`, `frontend-design`, `grill-me`, `remember`, `todo`,
`todo-add`, `update-context`) live in `home/.agents/skills/`. OpenCode reads them natively.

To add a memory, use the `/remember` skill (manual procedure:
`home/.agents/skills/remember/SKILL.md`).

## Constraints

- Keep dotfile configuration portable; avoid platform- or package-manager-specific assumptions.
- Never commit without explicit user authorization.
