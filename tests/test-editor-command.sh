#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
fish=$(command -v fish)
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
mkdir -p "$root/bin" "$root/home"
config=$repo/home/.config/fish/conf.d/zed.fish
export HOME=$root/home

PATH="$root/bin" "$fish" --no-config -c 'source "$argv[1]"; not type -q zed' "$config"
cat > "$root/bin/zeditor" <<'EDITOR'
#!/bin/sh
printf 'arch-zeditor\n'
EDITOR
chmod +x "$root/bin/zeditor"
result=$(PATH="$root/bin" "$fish" --no-config -c 'source "$argv[1]"; zed --version' "$config")
[[ "$result" == arch-zeditor ]]

cat > "$root/bin/zed" <<'EDITOR'
#!/bin/sh
printf 'existing-zed\n'
EDITOR
chmod +x "$root/bin/zed"
result=$(PATH="$root/bin" "$fish" --no-config -c 'source "$argv[1]"; zed --version' "$config")
[[ "$result" == existing-zed ]]
echo 'Editor command tests passed'
