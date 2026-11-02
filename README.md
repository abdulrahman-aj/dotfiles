# dotfiles

Personal configuration managed with GNU Stow.

## Setup

Requires internet access, `make` and `gh`; Arch setup also uses `sudo` and
Omarchy's package repository for Chrome, Zen and T3 Code.

```sh
gh auth login
gh repo clone abdulrahman-aj/dotfiles ~/dotfiles
cd ~/dotfiles
make
```

`make` links configuration, deploys
[agent-config](https://github.com/abdulrahman-aj/agent-config), and sets up Fish.
OpenCode configuration belongs to agent-config.
On Arch and Omarchy, it also installs personal apps and Nix and sets Fish as the
login shell. Conflicting dotfiles are backed up under `~/.dotfiles-backups/`.

On Omarchy, setup offers to remove bundled apps and sets Zen as the default
browser.

## Commands

- `make bootstrap` — run app and shell setup without linking dotfiles.
- `make check` — check deployment without changing files.
- `make test` — test deployment in temporary homes using Nix.
- `make unstow` — remove managed links.

`TARGET=/another/home` deploys without installing packages or changing the login
shell.

## Niri + Dux (v0)

The sample settings establish the file layout; they are not a port of the old
Fedora desktop. `make stow` deploys them without app installation or agent setup.

```
home/.config/niri/
  config.kdl                 # entrypoint with native includes
  dms/binds.kdl              # edited directly by the keybindings GUI
home/.config/dms/config.d/
  10-preferences.json         # Dux loads these after settings.json
  20-niri.json                # source settings for generated Niri input/layout
```

These two directories link into the checkout as directories, so atomic GUI
saves change the real files and appear in `git diff`. Other application configs
keep their individual Stow links. The first deployment backs up conflicting
directories under `~/.dotfiles-backups/`; subsequent deployments preserve edits.
Existing bindings and JSON fragments stay in that backup; the repo versions
become active. Log out and back in after the initial handoff so Niri and Dux load the new paths.
Dux's `settings.json` and `~/.local/state/dms/session.json` remain outside Git.
Dux generates Niri input/layout/colors/outputs and other fragments from its JSON
settings; those KDL files are carried over and Git-ignored. Only `dms/binds.kdl`
is tracked directly. Only preferences declared in `config.d` round-trip to Git;
other GUI settings stay in the writable `settings.json`. Add further source keys
to a tracked fragment deliberately. There is no JSON merge step or auto-commit.

To check persistence: change the clock format in Dux Settings, inspect
`git diff -- home/.config/dms/config.d`, run `make stow` again, and confirm the
change remains. The keybinding editor writes `home/.config/niri/dms/binds.kdl` directly. Niri
layout/input controls save JSON source values and regenerate the ignored KDL.
Edit the source files by hand if preferred; do not override a generated value
later in the Niri entrypoint.
