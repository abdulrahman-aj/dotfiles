# dotfiles

Managed with GNU Stow.

## Install

**Requirements:** Bash · Fish · GNU Stow · curl · Git · Neovim · Python 3

```bash
git clone git@github.com:abdulrahman-aj/dotfiles.git ~/dotfiles && cd ~/dotfiles && make
```

`make` backs up unmanaged conflicts under `~/.dotfiles-backups/`, stows the
configuration, sets up [agent-config](https://github.com/abdulrahman-aj/agent-config),
and initializes Fisher.

On Omarchy, `make` also offers to remove bundled preinstalls and sets up the
personal configuration and packages. OpenCode V2 is installed through mise.

## Usage

- `make` - deploy everything (stow home/ + AI and Fish setup)
- `make agents` - install shared instructions and skills from agent-config
- `make check` - report missing requirements and unmanaged conflicts without changing deployed files
- `make test` - run the deployment tests in isolated temporary homes
- `make test-herdr` - test the OpenCode V2 Herdr adapter (requires Node.js)
- `make unstow` - remove repo-managed links without deleting generated tool data

Pass `TARGET=/path/to/home` to run the complete workflow against a different home
directory. Fisher and agent setup honor the alternate target.

Agent-config is cloned into `TARGET/agent-config` when missing; existing checkouts
are never pulled or reset. Override with `AGENT_CONFIG_DIR` or `AGENT_CONFIG_REPO`.
`make check` and `make unstow` include it. See its README for skill deployment.
Legacy links to retired dotfiles OpenCode agent profiles must be removed manually.
