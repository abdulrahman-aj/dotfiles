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
    mkdir -p "$target/.config/hypr" "$target/.config/alacritty"
    printf 'keep\n' > "$target/.config/hypr/bindings.lua"
    printf 'keep\n' > "$target/.config/alacritty/alacritty.toml"
    make -s stow TARGET="$target" >/dev/null
    make -s agents TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null

    [[ -d "$target/.config/omarchy" && ! -L "$target/.config/omarchy" ]] \
        || fail "Omarchy directory was folded into the repository"
    [[ -L "$target/.config/omarchy/shell.json" ]] || fail "shell config is not linked"
    [[ -L "$target/.config/hypr/bindings.lua" ]] || fail 'Hyprland config is not linked'
    [[ -L "$target/.config/alacritty/alacritty.toml" ]] || fail 'Alacritty config is not linked'
    make -s check TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    make -s unstow TARGET="$target" AGENT_CONFIG_DIR="$agent_checkout" >/dev/null
    leftover_link="$(find "$target" -type l -print -quit)"
    [[ -z "$leftover_link" ]] || fail "managed link was not unstowed: $leftover_link"
}

test_private_browser() {
    local fixture="$test_root/browser test" capture="$test_root/private.desktop"
    mkdir -p "$fixture/bin" "$fixture/data/applications"
    cat >"$fixture/bin/xdg-mime" <<'SH'
#!/usr/bin/env bash
printf '%s\n' browser.desktop
SH
    cat >"$fixture/bin/gio" <<'SH'
#!/usr/bin/env bash
[[ $1 == launch && $# -eq 2 ]] || exit 1
cp -- "$2" "$BROWSER_CAPTURE"
SH
    chmod +x "$fixture/bin/xdg-mime" "$fixture/bin/gio"
    cat >"$fixture/data/applications/browser.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Test browser
Exec=browser --regular
DBusActivatable=true
Actions=new-private-window;
[Desktop Action new-private-window]
Name=Private window
Exec="/opt/Browser App/browser" --private-window %u
DESKTOP
    PATH="$fixture/bin:$PATH" XDG_DATA_HOME="$fixture/data" XDG_DATA_DIRS="$fixture/other" \
        BROWSER_CAPTURE="$capture" home/.local/bin/browser-private
    grep -qxF 'Exec="/opt/Browser App/browser" --private-window %u' "$capture" \
        || fail 'private launcher did not preserve the declared private command'
    grep -qxF 'DBusActivatable=false' "$capture" \
        || fail 'private launcher could activate a regular browser window over D-Bus'
    rm -- "$capture"
    sed -i '/^Actions=/d' "$fixture/data/applications/browser.desktop"
    if PATH="$fixture/bin:$PATH" XDG_DATA_HOME="$fixture/data" XDG_DATA_DIRS="$fixture/other" \
        BROWSER_CAPTURE="$capture" home/.local/bin/browser-private >/dev/null 2>&1; then
        fail 'private launcher accepted a browser without an advertised private action'
    fi
    [[ ! -e "$capture" ]] || fail 'unsupported private mode fell back to a regular window'
}

test_private_browser
test_conflict_backup
mkdir -p "$test_root/bin"
ln -s "$(command -v realpath)" "$test_root/bin/realpath"
# No package tools are available: another target home must skip setup entirely.
PATH="$test_root/bin" /bin/bash scripts/setup-arch.sh "$test_root/alternate-home"
test_stow_round_trip

echo "Deployment smoke test passed"
