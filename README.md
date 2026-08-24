# dotfiles

Managed with GNU Stow.

## Install

**Requirements:** Bash · Fish · GNU Stow · curl · Git · Neovim · Python 3

```bash
git clone git@github.com:abdulrahman-aj/dotfiles.git ~/dotfiles && cd ~/dotfiles && make
```

`make` backs up unmanaged conflicts under `~/.dotfiles-backups/`, stows the
configuration, and initializes Fisher and Kickstart.nvim.

On Omarchy, `make` also offers to remove bundled preinstalls and sets up the
personal configuration and packages.

## Usage

- `make` - deploy everything (stow all packages + AI, Neovim, and Fish setup)
- `make check` - report missing requirements and unmanaged conflicts without changes
- `make test` - run the deployment tests in isolated temporary homes
- `make unstow` - remove repo-managed links without deleting generated tool data

Pass `TARGET=/path/to/home` to run the complete workflow against a different home
directory. Fisher and Neovim setup honor the alternate target.
