#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

packages=(bin fish alacritty zed git cloc lazygit ai-shared opencode omarchy)
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

test_conflict_backup() {
    local target="$test_root/conflict-home"
    local backup

    mkdir -p "$target/.config"
    printf 'existing fish config\n' > "$target/.config/fish"
    bash scripts/manage-conflicts.sh backup "$target" "${packages[@]}" >/dev/null

    backup="$(find "$target/.dotfiles-backups" -path '*/.config/fish' -type f -print -quit)"
    [[ -n "$backup" ]] || fail "blocking path was not backed up"
    grep -qx 'existing fish config' "$backup" || fail "backup content changed"
}

test_stow_round_trip() {
    local target="$test_root/stow-home"
    local leftover_link

    mkdir -p "$target"
    stow --no-folding -R -t "$target" "${packages[@]}"

    [[ -d "$target/.config/omarchy" && ! -L "$target/.config/omarchy" ]] \
        || fail "Omarchy directory was folded into the repository"
    [[ -L "$target/.config/omarchy/shell.json" ]] || fail "shell config is not linked"

    make -s check TARGET="$target" >/dev/null
    make -s unstow TARGET="$target" >/dev/null
    leftover_link="$(find "$target" -type l -print -quit)"
    [[ -z "$leftover_link" ]] || fail "managed link was not unstowed: $leftover_link"
}

test_conflict_backup
test_stow_round_trip

echo "Deployment smoke test passed"
