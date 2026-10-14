# dotfiles

Personal dotfiles managed with GNU Stow. Deploying to a new machine: clone the repo and run `make`.

## Structure

`home/` is a stow package that mirrors `~/` 1:1: strip the `home/` prefix to
get the deployed path (e.g. `home/.config/fish/config.fish` → `~/.config/fish/config.fish`).
New dotfiles go under `home/` at their deployed relative path.
New files need `make` to be stowed live; edits to stowed files are live
via symlink unless an app replaced the link — run `make` to verify
and restore, unless told otherwise.

## Key Commands

```bash
make          # deploy everything (stow home/ + AI setup)
make agents   # bootstrap and deploy the private agent-config repo
make check    # dry-run and report conflicts
make test     # run deployment tests in isolated temporary homes
make test-herdr  # test the V2 Herdr adapter (requires Node.js)
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

Shared instructions and skills belong in `~/agent-config`, not this repo.
Use `make agents` to install them or deploy new skills. See that repo's README
for layout and deployment details. Harness-specific OpenCode config stays here.

Herdr's bundled OpenCode integration still targets V1; V2 uses the stowed
`herdr-tui-session.js` adapter instead. Remove the V1 Herdr integration at
cutover; do not reinstall it on V2. The TUI adapter reports the selected
session and its child states while running inside a Herdr pane.
Unlike V1's server plugin, it does not report headless `opencode run` activity;
V2's shared server does not inherit each pane's Herdr environment.
OpenCode agent profiles are retired; T3 selects providers and models.

## Constraints

- Keep dotfile configuration portable; avoid platform- or package-manager-specific assumptions.
- Never commit without explicit user authorization.
