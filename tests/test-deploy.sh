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

test_dux_plugins() {
    local target="$test_root/dux-home"
    local clone="$test_root/dux-clone"
    local stubs="$test_root/dux-bin"
    local dms_log="$test_root/dms.log"

    mkdir -p "$target" "$clone/DuxAiUsage" "$stubs"
    printf '{"id":"duxAiUsage"}\n' > "$clone/DuxAiUsage/plugin.json"
    printf '#!/usr/bin/env bash\necho "$@" >> "$DMS_LOG"\n' > "$stubs/dms"
    chmod +x "$stubs/dms"

    # A stale symlink is repointed at the managed clone.
    mkdir -p "$target/.config/dms/plugins"
    ln -s "$test_root" "$target/.config/dms/plugins/DuxAiUsage"

    DMS_LOG="$dms_log" PATH="$stubs:$PATH" \
        make -s dux-plugins TARGET="$target" DUX_AI_USAGE_DIR="$clone" >/dev/null
    [[ "$(readlink "$target/.config/dms/plugins/DuxAiUsage")" == "$clone/DuxAiUsage" ]] \
        || fail 'DuxAiUsage plugin was not linked'
    [[ ! -e "$dms_log" ]] || fail 'dms was called for a non-HOME target'

    # Second run is a no-op.
    DMS_LOG="$dms_log" PATH="$stubs:$PATH" \
        make -s dux-plugins TARGET="$target" DUX_AI_USAGE_DIR="$clone" >/dev/null
    [[ "$(readlink "$target/.config/dms/plugins/DuxAiUsage")" == "$clone/DuxAiUsage" ]] \
        || fail 'DuxAiUsage plugin link did not survive a second run'

    # A real directory is never replaced.
    rm "$target/.config/dms/plugins/DuxAiUsage"
    mkdir -p "$target/.config/dms/plugins/DuxAiUsage"
    if DMS_LOG="$dms_log" PATH="$stubs:$PATH" \
        make -s dux-plugins TARGET="$target" DUX_AI_USAGE_DIR="$clone" >/dev/null 2>&1; then
        fail 'dux-plugins replaced a real directory'
    fi
    rmdir "$target/.config/dms/plugins/DuxAiUsage"

    # Against HOME the plugin is enabled via dms.
    DMS_LOG="$dms_log" PATH="$stubs:$PATH" HOME="$target" DUX_AI_USAGE_DIR="$clone" \
        bash scripts/install-dux-plugins.sh "$target" >/dev/null
    grep -qx 'ipc call plugins enable duxAiUsage' "$dms_log" \
        || fail 'dms plugin enable was not called for a HOME target'
}

test_conflict_backup
mkdir -p "$test_root/bin"
ln -s "$(command -v realpath)" "$test_root/bin/realpath"
# No package tools are available: another target home must skip setup entirely.
PATH="$test_root/bin" /bin/bash scripts/setup-arch.sh "$test_root/alternate-home"
test_stow_round_trip
test_dux_plugins

echo "Deployment smoke test passed"
