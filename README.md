# dotfiles

Managed with GNU Stow.

## Usage

- `make` - deploy everything (stow all packages + AI setup)
- `make check` - dry-run and report conflicts
- `make unstow` - remove all symlinks

Pass `TARGET=/path/to/home` to deploy against a different home directory.
