#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

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
    bash scripts/manage-conflicts.sh backup "$target" >/dev/null

    backup="$(find "$target/.dotfiles-backups" -path '*/.config/fish' -type f -print -quit)"
    [[ -n "$backup" ]] || fail "blocking path was not backed up"
    grep -qx 'existing fish config' "$backup" || fail "backup content changed"
}

test_stow_round_trip() {
    local profile=$1
    local target="$test_root/$profile-home"
    local agent_checkout="$test_root/$profile-agents"
    local leftover_link

    mkdir -p "$target"
    mkdir -p "$agent_checkout"
    printf 'install check uninstall:\n\t@test "$(TARGET)" = "%s"\n' "$target" \
        > "$agent_checkout/Makefile"
    mkdir -p "$target/.config/hypr" "$target/.config/alacritty"
    printf 'keep\n' > "$target/.config/hypr/bindings.lua"
    printf 'keep\n' > "$target/.config/alacritty/alacritty.toml"
    PROFILE="$profile" make -s stow TARGET="$target" >/dev/null
    make -s agents TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null

    if [[ "$profile" == full ]]; then
        [[ -d "$target/.config/omarchy" && ! -L "$target/.config/omarchy" ]] \
            || fail "Omarchy directory was folded into the repository"
        [[ -L "$target/.config/omarchy/shell.json" ]] || fail "shell config is not linked"
    else
        [[ $(cat "$target/.config/hypr/bindings.lua") == keep ]] || fail 'Hyprland config replaced'
        [[ $(cat "$target/.config/alacritty/alacritty.toml") == keep ]] || fail 'Alacritty config replaced'
        [[ ! -e "$target/.config/omarchy" && ! -e "$target/.config/opencode" ]] || fail 'desktop config deployed'
    fi

    PROFILE="$profile" make -s check TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    PROFILE="$profile" make -s unstow TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    leftover_link="$(find "$target" -type l -print -quit)"
    [[ -z "$leftover_link" ]] || fail "managed link was not unstowed: $leftover_link"
}

test_conflict_backup
mkdir -p "$test_root/bin"
ln -s "$(command -v realpath)" "$test_root/bin/realpath"
# No package tools are available: another target home must skip setup entirely.
PATH="$test_root/bin" /bin/bash scripts/setup-arch.sh "$test_root/alternate-home"
test_stow_round_trip full
test_stow_round_trip arch

echo "Deployment smoke test passed"
