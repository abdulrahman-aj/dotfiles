#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

packages=(bin fish alacritty zed git cloc lazygit ai-shared opencode)
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
    local before after

    mkdir -p "$target"
    before="$(find bin fish -type f -print0 | sort -z | xargs -0 sha256sum)"
    stow --no-folding -R -t "$target" "${packages[@]}"

    [[ -d "$target/.config/fish" && ! -L "$target/.config/fish" ]] \
        || fail "Fish directory was folded into the repository"
    [[ -L "$target/.config/fish/config.fish" ]] || fail "Fish config is not linked"
    after="$(find bin fish -type f -print0 | sort -z | xargs -0 sha256sum)"
    [[ "$before" == "$after" ]] || fail "deployment modified package contents"

    make -s check TARGET="$target" >/dev/null
    make -s unstow TARGET="$target" >/dev/null
}

test_conflict_backup
test_stow_round_trip

echo "Deployment smoke test passed"
