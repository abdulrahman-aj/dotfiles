# dotfiles

Personal configuration managed with GNU Stow.

## Setup

Requires internet access, `make` and `gh`. On Arch, setup also requires `sudo`.
Packages, including Chrome, Zen and T3 Code, are installed with Pacman from
the configured binary repositories. Those repositories must provide these
packages; setup does not fall back to AUR builds.

```sh
gh auth login
gh repo clone abdulrahman-aj/dotfiles ~/dotfiles
cd ~/dotfiles
make
```

`make` links configuration, deploys
[agent-config](https://github.com/abdulrahman-aj/agent-config), and sets up Fish.
OpenCode configuration belongs to agent-config.
On Arch, it also installs personal apps and Nix and sets Fish as the
login shell. Conflicting dotfiles are backed up under `~/.dotfiles-backups/`.

Desktop preferences target Niri and Dux Shell. Personal Niri settings live in
`~/.config/niri/overrides.kdl`, which arch-niri-dux loads last. The managed MIME
configuration sets Zen as the default browser.

## Commands

- `make bootstrap` — run app and shell setup without linking dotfiles.
- `make check` — check deployment without changing files.
- `make test` — test deployment in temporary homes using Nix.
- `make dux-plugins` — install pinned Dux plugins from `dux/plugins.lock.json`.
- `make unstow` — remove managed links.

`TARGET=/another/home` deploys without installing packages or changing the login
shell. Bump Dux plugins with `dms plugins update`, then
`dms plugins lock -o dux/plugins.lock.json` and commit.
