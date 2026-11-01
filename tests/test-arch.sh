#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
mkdir -p "$root/bin" "$root/home" "$root/other"
export LOG="$root/log" HOME="$root/home" USER=test
for cmd in sudo yay mise getent fish chsh; do
    cat > "$root/bin/$cmd" <<'MOCK'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >> "$LOG"
case "${0##*/}" in
    getent) echo 'test:x:1:1::/home/test:/bin/bash' ;;
    mise) [[ "${1:-}" != ls ]] || exit 0 ;;
esac
MOCK
    chmod +x "$root/bin/$cmd"
done
mkdir -p "$root/minimal"
ln -s "$(command -v realpath)" "$root/minimal/realpath"
if PATH="$root/minimal" /bin/bash scripts/setup-arch.sh "$HOME" 2>"$root/error"; then
    fail "missing yay was accepted"
fi
/bin/grep -q "Missing required command: yay" "$root/error" || fail "missing prerequisite not reported"
export PATH="$root/bin:$PATH"
bash scripts/setup-arch.sh "$root/other"
[[ ! -e "$LOG" ]] || fail 'alternate target installed packages'
bash scripts/setup-arch.sh "$HOME"
bash scripts/setup-arch.sh "$HOME"
[[ $(grep -c '^sudo pacman ' "$LOG") == 2 ]] || fail 'package installation did not retry'
[[ $(grep -c '^yay ' "$LOG") == 2 ]] || fail 'AUR installation did not retry'
[[ $(head -n 1 "$LOG") == sudo\ pacman* ]] || fail 'packages installed out of order'
grep -Eq '^sudo pacman .* fzf fd bat ' "$LOG" || fail 'fzf directory search dependencies missing'
grep -Eq '^yay .* t3code-bin$' "$LOG" || fail 'configured T3 Code handler has no application'
grep -Fxq 'mise use -g herdr' "$LOG" || fail 'Herdr configuration has no application'
grep -Fxq 'mise use -g codex' "$LOG" || fail 'the coding-agent runtime is missing'
# A failure must stop before later installation steps.
cat > "$root/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
: > "$LOG"
if bash scripts/setup-arch.sh "$HOME"; then fail 'failed package install succeeded'; fi
[[ ! -s "$LOG" ]] || fail 'continued after package failure'

mkdir -p "$root/target/.config/hypr" "$root/target/.config/alacritty"
printf 'keep\n' > "$root/target/.config/hypr/bindings.lua"
printf 'keep\n' > "$root/target/.config/alacritty/alacritty.toml"
PROFILE=arch make -s stow TARGET="$root/target" >/dev/null
[[ -L "$root/target/.config/fish/config.fish" ]] || fail 'portable config missing'
[[ ! -L "$root/target/.config/hypr/bindings.lua" ]] || fail 'Hyprland config deployed'
[[ ! -L "$root/target/.config/alacritty/alacritty.toml" ]] || fail 'Alacritty default replaced'
[[ ! -e "$root/target/.config/omarchy" ]] || fail 'Omarchy config deployed'
[[ ! -e "$root/target/.config/opencode" ]] || fail 'OpenCode config must come from agent-config'
[[ -L "$root/target/.config/mimeapps.list" ]] || fail 'personal browser defaults missing'
[[ -L "$root/target/.config/xdg-terminals.list" ]] || fail 'personal terminal preference missing'
PROFILE=arch make -s unstow TARGET="$root/target" AGENT_CONFIG_DIR="$root/missing" >/dev/null
[[ ! -L "$root/target/.config/fish/config.fish" ]] || fail 'portable link remains'
echo 'Arch deployment tests passed'
