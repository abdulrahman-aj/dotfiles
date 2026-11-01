# dotfiles

Personal configuration managed with GNU Stow.

## Setup

On the ISO or Omarchy, authenticate and clone:

```sh
gh auth login
gh repo clone abdulrahman-aj/dotfiles ~/dotfiles
cd ~/dotfiles
make
```

`make` installs personal apps, links configuration, deploys
[agent-config](https://github.com/abdulrahman-aj/agent-config), and sets up Fish.
Existing files are backed up under `~/.dotfiles-backups/`.

Omarchy keeps its desktop integration. Plain Arch skips Hyprland, Omarchy and
the Omarchy-dependent Alacritty config; Niri/Dux settings stay untouched.
OpenCode config comes from agent-config.

## Commands

- `make bootstrap` — install apps and tools only.
- `make check` — check deployment without changing files.
- `make test` — test deployment in temporary homes.
- `make unstow` — remove managed links.

`TARGET=/another/home` deploys without installing packages or changing the login
shell. `PROFILE=arch` selects portable config; `PROFILE=full` includes desktop
config. Otherwise the profile is detected automatically.

For development, `nix-shell` supplies test tools. Normal setup does not require Nix.
