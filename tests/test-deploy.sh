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
    local target="$test_root/stow-home"
    local agent_checkout="$test_root/agents"
    local leftover_link

    mkdir -p "$target"
    mkdir -p "$agent_checkout"
    printf 'install check uninstall:\n\t@test "$(TARGET)" = "%s"\n' "$target" \
        > "$agent_checkout/Makefile"
    mkdir -p "$target/.config/niri/dms" "$target/.config/alacritty"
    printf 'keep\n' > "$target/.config/niri/dms/binds.kdl"
    printf 'keep\n' > "$target/.config/alacritty/alacritty.toml"
    make -s stow TARGET="$target" >/dev/null
    make -s agents TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null

    [[ -d "$target/.config/niri" && ! -L "$target/.config/niri" ]] \
        || fail "Niri directory was folded into the repository"
    [[ -L "$target/.config/niri/dms/binds.kdl" ]] || fail 'Niri bindings are not linked'
    [[ -L "$target/.config/dms/config.d/preferences.json" ]] || fail 'Dux preferences are not linked'
    [[ -L "$target/.config/alacritty/alacritty.toml" ]] || fail 'Alacritty config is not linked'
    make -s check TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    make -s unstow TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    leftover_link="$(find "$target" -type l -print -quit)"
    [[ -z "$leftover_link" ]] || fail "managed link was not unstowed: $leftover_link"
}

test_refresh_only_fast_forwards_clean_main() {
    local origin="$test_root/refresh-origin"
    local clean="$test_root/refresh-clean"
    local dirty="$test_root/refresh-dirty"
    local before

    git init -q -b main "$origin"
    git -C "$origin" -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
    git clone -q "$origin" "$clean"
    git clone -q "$origin" "$dirty"
    printf 'local work\n' > "$dirty/wip"
    git -C "$origin" -c user.name=t -c user.email=t@t commit -q --allow-empty -m two
    before="$(git -C "$dirty" rev-parse HEAD)"

    bash scripts/refresh.sh "$clean" "$dirty" >/dev/null
    bash scripts/refresh.sh "$test_root/missing" "$test_root" >/dev/null \
        || fail 'refresh failed on a missing or non-git checkout'

    [[ "$(git -C "$clean" rev-parse HEAD)" == "$(git -C "$origin" rev-parse HEAD)" ]] \
        || fail 'clean main was not fast-forwarded'
    [[ "$(git -C "$dirty" rev-parse HEAD)" == "$before" ]] \
        || fail 'dirty checkout was updated'
}

test_conflict_backup
test_refresh_only_fast_forwards_clean_main
mkdir -p "$test_root/bin"
ln -s "$(command -v realpath)" "$test_root/bin/realpath"
# No package tools are available: another target home must skip setup entirely.
PATH="$test_root/bin" /bin/bash scripts/setup-arch.sh "$test_root/alternate-home"
test_stow_round_trip

echo "Deployment smoke test passed"
