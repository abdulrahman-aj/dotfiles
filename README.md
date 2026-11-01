# dotfiles

Managed with GNU Stow.

## Install

On a plain Arch installation prepared with Niri/Dux, Git, curl, Yay and base-devel,
connect to the internet and run:

```bash
git clone https://github.com/abdulrahman-aj/dotfiles.git ~/dotfiles
cd ~/dotfiles && make
```

The Arch setup installs Fish, Stow, GitHub CLI, delta, Starship, Worktrunk,
Chrome, Zen, Zed, T3 Code, mise, Node/npm, shell utilities, the JetBrainsMono Nerd Font,
and external-drive and USB mode-switch tools. It uses mise for hunkdiff and
OpenCode, installs Herdr and Codex through mise, and changes the login shell to Fish. Deploying the personal MIME
defaults makes Zen the default browser. It uses sudo and Yay,
and may prompt for authentication. `make` can be retried after a failure.
The private agent-config checkout requires GitHub access: authenticate with
`gh auth login --web --git-protocol https` when needed, then rerun `make`.

On Omarchy, `make` retains the existing Omarchy setup, including preinstall
removal, Zen as default browser, omazed and the Omarchy plugin. On other hosts
it skips system setup and expects the deployment requirements to be installed.

Arch deploys portable app and shell configuration but leaves Niri/Dux defaults,
Alacritty, Hyprland and Omarchy configuration alone. Alacritty's shared config
imports an Omarchy theme path, so its deployment is deferred on plain Arch.
Portable MIME and terminal preferences are deployed.
OpenCode configuration comes from agent-config, including when deploying an older
dotfiles revision that still contains OpenCode files.
Omarchy-specific plugins and omazed are not installed on Arch. The offline ISO
is responsible for the desktop, browser, Neovim, firmware and recovery tools.

`make` backs up unmanaged conflicts under `~/.dotfiles-backups/`, stows the
configuration, sets up [agent-config](https://github.com/abdulrahman-aj/agent-config),
and initializes Fisher. Existing agent-config checkouts are not updated.

## Usage

- `make` — bootstrap the host and deploy configuration, agents and Fisher
- `make bootstrap` — run only the host-specific package setup
- `make check` — report missing requirements and unmanaged conflicts
- `make test` — run deployment tests in isolated temporary homes
- `make test-herdr` — run agent-config's Herdr adapter tests
- `make unstow` — remove managed links without deleting generated data

Pass `TARGET=/path/to/home` for an alternate deployment; package installation
and shell changes run only for the real `$HOME`. Fisher and agents use the
alternate target. The profile is detected from `/etc/os-release`; use
`PROFILE=arch` for the portable Arch selection or `PROFILE=full` for the full
selection, consistently for deployment, check and unstow. Use `AGENT_CONFIG_DIR`
or `AGENT_CONFIG_REPO` to override the agent checkout or repository.

For development, `nix-shell` provides the deployment test dependencies; Nix is
not required on the target machine. See agent-config's documentation for shared
configuration deployment and migration instructions.
