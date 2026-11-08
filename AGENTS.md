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
make refresh  # fast-forward clean main checkouts of both repos, then relink
make unstow   # remove all symlinks
```

Pass `TARGET=/path/to/home` to deploy to another home directory without
installing packages or changing the login shell.

## Deployment Architecture

- Before Stow runs, unmanaged paths that conflict with repo-managed files are moved
  to a timestamped `.dotfiles-backups/` directory under the target home.
- Stow uses `--no-folding`, keeping managed directories writable and linking their
  individual files instead of linking whole directory trees into the repo.
- Fisher is an external bootstrap step run after Stow. It honors
  `TARGET`, preserves unrelated existing configurations, and is safe to retry.
- Arch app/tool setup uses Pacman with configured binary repositories, restricted
  to the real `$HOME`. Do not introduce AUR builds or require an AUR helper.
- All files in `home/` are stowed. OpenCode configuration belongs exclusively
  to agent-config.
- The repo owns `mimeapps.list` and `xdg-terminals.list` (which sets terminal
  preference order). Applications may atomically replace their Stow links; the
  next deployment backs up changed files and restores repository versions.

## AI Memories & Skills

Shared instructions, skills and OpenCode configuration belong in `~/agent-config`.
Use `make agents` to install them or deploy new skills. See that repo's README
for layout and deployment details. This repo installs the OpenCode binary;
agent-config owns its configuration.
OpenCode agent profiles are retired; T3 selects providers and models.

## Constraints

- Keep dotfile configuration portable; avoid platform- or package-manager-specific assumptions.
- Never commit without explicit user authorization.
