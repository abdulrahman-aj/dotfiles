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
Fedora desktop. `make stow` deploys them with the existing individual Stow links,
without app installation or agent setup. Conflicting files are backed up under
`~/.dotfiles-backups/`. Existing unrelated files stay in place. Log out and back
in after the initial deployment so Niri and Dux load the new configuration.

```
home/.config/niri/
  config.kdl                 # hand-written entrypoint with native includes
  dms/binds.kdl              # Dux keybinding editor storage
  dms/windowrules.kdl        # Dux window-rule editor storage
  dms/layout.kdl             # regenerated, but also stores X-ray choices
home/.config/dms/config.d/
  10-preferences.json        # selected Dux preferences
  20-niri.json               # source settings for Niri input/layout
```

Dux loads JSON fragments after `~/.config/dms/settings.json`. Only preferences
declared in a tracked fragment round-trip to Git; other settings remain in
`settings.json`. Dux saves a key to the last fragment declaring it, so avoid
duplicating tracked keys in later fragments. Add further source keys deliberately.
There is no custom JSON merge step or auto-commit. Session state stays outside Git too.

The KDL files under `dms/` are Dux-managed. Use its editors for bindings and window
rules; use JSON preferences for input/layout controls. `layout.kdl` is also
tracked because Dux reads its X-ray choices back from this file. Its generated
content will appear in Git, including changes from JSON settings. This does not
make it a place for hand-written layout overrides. Other generated KDL (colors,
outputs, input, cursor and Alt-Tab) lives in the target home, outside the checkout.
Put hand-written Niri configuration in `config.kdl` or an included personal file.

Dux 2.0's binding/rule writers follow file links. Its layout writer resolves the
link before replacing the target, and its JSON writer uses Qt's symlink-aware
`QSaveFile`. The Qt implementation resolves symlinks before committing the replacement
([source](https://github.com/qt/qtbase/blob/v6.10.0/src/corelib/io/qsavefile.cpp)).
No directory-link exception is needed. To check persistence, change
the clock format or gaps in Dux Settings, inspect `git diff`, run `make stow`
again, and confirm the changes remain. The VM verification below checks the actual
writers rather than simulating a generic atomic replacement.

`make test` checks file links, conflicting-file backups, preservation of unrelated
runtime files, Git-visible edits, redeployment and removal in temporary homes.
`make test-desktop-vm` runs the real Dux writers in an already running disposable
Arch/Niri/Dux VM with a fresh, Git-indexed copy of this checkout deployed. Run it
as the graphical-session user with `ARGS=--disposable-vm`; it also refuses physical
hosts. The probe intentionally leaves a test binding/rule and changed preferences
for a reboot check with `ARGS='--disposable-vm --check-only'`. Discard the VM when
finished. See the script's help for invocation.
