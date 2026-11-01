# dotfiles

Personal configuration managed with GNU Stow.

## Setup

Requires internet access, `make` and `gh`; Arch setup also uses `sudo` and `yay`.

```sh
gh auth login
gh repo clone abdulrahman-aj/dotfiles ~/dotfiles
cd ~/dotfiles
make
```

`make` links configuration, deploys
[agent-config](https://github.com/abdulrahman-aj/agent-config), and sets up Fish.
On Arch and Omarchy, it also installs personal apps and Nix and sets Fish as the
login shell. Conflicting dotfiles are backed up under `~/.dotfiles-backups/`.

On Omarchy, setup offers to remove bundled apps and sets Zen as the default
browser. The `arch` profile excludes OpenCode configuration, leaving it to
agent-config.

## Commands

- `make bootstrap` — run app and shell setup without linking dotfiles.
- `make check` — check deployment without changing files.
- `make test` — test deployment in temporary homes using Nix.
- `make unstow` — remove managed links.

`TARGET=/another/home` deploys without installing packages or changing the login
shell. Plain Arch defaults to `PROFILE=arch`; other systems use `PROFILE=full`.
Set `PROFILE` explicitly to override this.
