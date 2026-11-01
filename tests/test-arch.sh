#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
real_fish=$(command -v fish)
real_make=$(command -v make)
mkdir -p "$root/bin" "$root/home" "$root/other" "$root/minimal"
export LOG="$root/log" HOME="$root/home" USER=test
for cmd in bash sh echo realpath cut grep; do ln -s "$(type -P "$cmd")" "$root/bin/$cmd"; done
for cmd in sudo yay mise getent fish chsh; do
    cat > "$root/bin/$cmd" <<'MOCK'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >> "$LOG"
case "${0##*/}" in
    getent) echo "test:x:1:1::/home/test:${MOCK_SHELL:-/bin/bash}" ;;
    mise) if [[ "$1" == ls && ${OPENCODE_INSTALLED:-0} == 1 ]]; then echo 'opencode installed'; fi ;;
esac
MOCK
    chmod +x "$root/bin/$cmd"
done
ln -s "$(command -v realpath)" "$root/minimal/realpath"
if PATH="$root/minimal" /bin/bash scripts/setup-arch.sh "$HOME" 2>"$root/error"; then
    fail 'missing yay was accepted'
fi
grep -q 'Missing required command: yay' "$root/error"
PATH="$root/bin" /bin/bash scripts/setup-arch.sh "$root/other"
[[ ! -e "$LOG" ]] || fail 'alternate target installed packages'
[[ $(env -u PROFILE -u MAKEFLAGS PATH="$root/bin" "$real_make" -s --eval 'print-profile:;@echo $(PROFILE)' print-profile) == arch ]] || fail 'plain Arch profile not detected'
for attempt in 1 2; do PATH="$root/bin" /bin/bash scripts/setup-arch.sh "$HOME"; done
[[ $(grep -c '^sudo pacman -Syu ' "$LOG") == 2 ]] || fail 'Arch package setup did not retry'
[[ $(grep -c '^yay -S --needed ' "$LOG") == 2 ]] || fail 'AUR setup did not retry'
grep -Eq '^sudo pacman .* fzf fd bat ' "$LOG" || fail 'shell dependencies missing'
grep -Fxq 'mise use -g herdr codex npm:hunkdiff' "$LOG" || fail 'shared tools missing'
cat > "$root/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
: > "$LOG"
if PATH="$root/bin" /bin/bash scripts/setup-arch.sh "$HOME"; then fail 'package failure was ignored'; fi
[[ ! -s "$LOG" ]] || fail 'continued after package failure'

# The same setup path must keep Omarchy integration without upgrading it via pacman.
cat > "$root/bin/omarchy" <<'MOCK'
#!/usr/bin/env bash
printf 'omarchy %s\n' "$*" >> "$LOG"
if [[ "$*" == 'plugin list' && ${PLUGIN_INSTALLED:-0} == 1 ]]; then echo aj.opencode-go; fi
MOCK
cp "$root/bin/yay" "$root/bin/omazed"
chmod +x "$root/bin/omarchy"
[[ $(env -u PROFILE -u MAKEFLAGS PATH="$root/bin" "$real_make" -s --eval 'print-profile:;@echo $(PROFILE)' print-profile) == full ]] || fail 'Omarchy profile not detected'
PATH="$root/bin" /bin/bash scripts/setup-arch.sh "$HOME"
grep -q '^omarchy pkg add alacritty neovim python fish ' "$LOG" || fail 'Omarchy missed shared packages'
grep -Fxq 'omarchy install browser zen' "$LOG" || fail 'browser integration lost'
grep -Fxq 'omazed setup' "$LOG" || fail 'Zed integration lost'
grep -q '^omarchy plugin add ' "$LOG" || fail 'plugin setup lost'
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
: > "$LOG"
PATH="$root/bin" PLUGIN_INSTALLED=1 OPENCODE_INSTALLED=1 MOCK_SHELL="$root/bin/fish" /bin/bash scripts/setup-arch.sh "$HOME"
if grep -Eq '^(sudo |chsh |omarchy remove |omarchy plugin add |mise use -g --tool-option)' "$LOG"; then
    fail 'repeated completed Omarchy setup'
fi

mkdir -p "$root/target/.config/hypr" "$root/target/.config/alacritty"
printf 'keep\n' > "$root/target/.config/hypr/bindings.lua"
printf 'keep\n' > "$root/target/.config/alacritty/alacritty.toml"
PROFILE=arch make -s stow TARGET="$root/target" >/dev/null
[[ -L "$root/target/.config/fish/config.fish" ]] || fail 'portable config missing'
[[ ! -L "$root/target/.config/hypr/bindings.lua" ]] || fail 'Hyprland config deployed'
[[ ! -L "$root/target/.config/alacritty/alacritty.toml" ]] || fail 'Alacritty default replaced'
[[ $(cat "$root/target/.config/hypr/bindings.lua") == keep ]] || fail 'excluded Hyprland config was moved'
[[ $(cat "$root/target/.config/alacritty/alacritty.toml") == keep ]] || fail 'excluded Alacritty config was moved'
[[ ! -e "$root/target/.config/omarchy" ]] || fail 'Omarchy config deployed'
[[ ! -e "$root/target/.config/opencode" ]] || fail 'OpenCode config must come from agent-config'
PROFILE=arch make -s unstow TARGET="$root/target" AGENT_CONFIG_DIR="$root/missing" >/dev/null
[[ ! -L "$root/target/.config/fish/config.fish" ]] || fail 'portable link remains'

cat > "$root/order.mk" <<'ORDER'
bootstrap stow agents fisher:
	@echo $@ >> "$(ORDER_LOG)"; sleep 0.02
ORDER
make -s -j4 -f Makefile -f "$root/order.mk" all ORDER_LOG="$root/order.log" 2>/dev/null
[[ $(cat "$root/order.log") == $'bootstrap\nstow\nagents\nfisher' ]] || fail 'parallel make reordered setup'

mkdir "$root/editor"
printf '#!/bin/sh\nprintf "%%s" "$1" > "$EDITOR_LOG"\n' > "$root/editor/zeditor"
printf '#!/bin/sh\nexit 0\n' > "$root/editor/target-command"
chmod +x "$root/editor/"*
EDITOR_LOG="$root/editor.log" "$real_fish" --no-config -c 'source "$argv[1]"; set -gx PATH "$argv[2]" $PATH; zw target-command' "$PWD/home/.config/fish/config.fish" "$root/editor"
[[ $(cat "$root/editor.log") == "$root/editor/target-command" ]] || fail 'zw did not open the command in Zed'
echo 'Arch and Omarchy setup tests passed'
