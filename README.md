# dotfiles

Managed with GNU Stow.

## Install

**Requirements:** Fish · GNU Stow · Python 3 · curl

```bash
git clone git@github.com:abdulrahman-aj/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && make
```

## Usage

- `make` - deploy everything (stow all packages + AI setup)
- `make check` - dry-run and report conflicts
- `make unstow` - remove all symlinks

Pass `TARGET=/path/to/home` to deploy against a different home directory.
