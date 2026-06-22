# dotfiles

Managed with GNU Stow.

## Usage

- `make check` - simulate stowing all packages and report conflicts
- `make stow` - stow all packages
- `make restow` - refresh symlinks
- `make unstow` - remove symlinks

The targets default to `$HOME`; pass `TARGET=/path/to/home` when validating
against another home directory.
