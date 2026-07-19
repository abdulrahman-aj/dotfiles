# dotfiles

Managed with GNU Stow.

## Install

**Requirements:** Bash · Fish · GNU Stow · curl · Git · Neovim · Python 3

```bash
git clone git@github.com:abdulrahman-aj/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && make
```

`make` checks all requirements before changing the target. Existing unmanaged files at
repo-managed paths are moved to a timestamped directory under
`~/.dotfiles-backups/`, preserving their relative paths, before the repo links are
installed. Kickstart.nvim and Fisher are then initialized; either step can be safely
retried by running `make` again.

Only the marked block in the live Codex config is managed. Machine-specific settings
outside that block remain local.

## Usage

- `make` - deploy everything (stow all packages + AI, Neovim, and Fish setup)
- `make check` - report missing requirements and unmanaged conflicts without changes
- `make test` - run the deployment tests in isolated temporary homes
- `make unstow` - remove repo-managed links without deleting generated tool data

Pass `TARGET=/path/to/home` to run the complete workflow against a different home
directory. Fisher, Neovim, Codex, and Claude setup all honor the alternate target.
