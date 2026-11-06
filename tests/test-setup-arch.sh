#!/usr/bin/env bash
set -euo pipefail

[[ -f /etc/arch-release ]] || {
    echo 'Arch setup test skipped: requires an Arch host'
    exit 0
}

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap '/bin/rm -rf "$test_root"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

mkdir -p "$test_root/bin" "$test_root/home"
ln -s "$(command -v realpath)" "$test_root/bin/realpath"
ln -s "$(command -v cut)" "$test_root/bin/cut"
cat > "$test_root/bin/mock" <<'SH'
#!/bin/bash
name="${0##*/}"
printf '%s\n' "$name $*" >> "$SETUP_LOG"
case "$name" in
    sudo) exit "${PACMAN_EXIT:-0}" ;;
    chsh) exit 0 ;;
    tailscale) exit 0 ;;
    mise) [[ "$*" != 'ls -g -i --no-header npm:@opencode/cli' ]] || echo installed ;;
    getent) echo "test:x:1000:1000::${HOME}:/bin/bash" ;;
    *) echo "Unexpected setup command: $name" >&2; exit 1 ;;
esac
SH
chmod +x "$test_root/bin/mock"
for name in sudo tailscale mise getent fish chsh; do
    ln -s mock "$test_root/bin/$name"
done

export HOME="$test_root/home" USER=test PATH="$test_root/bin" SETUP_LOG="$test_root/commands"
/bin/bash "$repo/scripts/setup-arch.sh" "$HOME" > "$test_root/output" \
    || fail 'Arch setup failed'
/usr/bin/grep -q '^sudo pacman -Syu --needed --noconfirm ' "$SETUP_LOG" \
    || fail 'repository packages were not installed with Pacman'
/usr/bin/grep -q '^sudo pacman -Syu .* google-chrome zen-browser-bin t3code-bin$' "$SETUP_LOG" \
    || fail 'extra apps were not installed from binary repositories'
/usr/bin/grep -qx 'sudo systemctl enable --now nix-daemon.service nix-daemon.socket' "$SETUP_LOG" \
    || fail 'Nix service was not enabled'
/usr/bin/grep -qx "chsh -s $test_root/bin/fish test" "$SETUP_LOG" \
    || fail 'Fish was not selected as the login shell'
/usr/bin/grep -qx 'mise use -g herdr codex npm:hunkdiff' "$SETUP_LOG" \
    || fail 'Mise tools were not installed'

: > "$SETUP_LOG"
if PACMAN_EXIT=1 /bin/bash "$repo/scripts/setup-arch.sh" "$HOME" > "$test_root/output"; then
    fail 'setup ignored a failed Pacman installation'
fi
if /usr/bin/grep -q '^mise ' "$SETUP_LOG"; then
    fail 'setup continued after a failed Pacman installation'
fi

echo 'Arch setup test passed'
