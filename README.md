# dotfiles

Personal configuration managed with GNU Stow.

## Setup

On Arch or Omarchy, start with Git, Make, Yay and AUR build tools installed:

```sh
git clone https://github.com/abdulrahman-aj/dotfiles.git ~/dotfiles
cd ~/dotfiles
make
```

`make` installs personal apps, links configuration, deploys
[agent-config](https://github.com/abdulrahman-aj/agent-config), and sets up Fish.
Authenticate with `gh auth login` if the private agent-config clone needs access.
Existing files are backed up under `~/.dotfiles-backups/`.

Omarchy keeps its desktop integration. Plain Arch skips Hyprland, Omarchy and
the Omarchy-dependent Alacritty config; Niri/Dux settings stay untouched.
OpenCode config comes from agent-config.

## Commands

- `make bootstrap` — install apps and tools only.
- `make check` — check deployment without changing files.
- `make test` — run tests in temporary homes (`nix-shell` supplies dependencies).
- `make unstow` — remove managed links.

`TARGET=/another/home` deploys without installing packages or changing the login
shell. `PROFILE=arch` selects portable config; `PROFILE=full` includes desktop
config. Otherwise the profile is detected automatically.
