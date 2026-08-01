#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command="$repo/bin/.local/bin/worktree"
completion="$repo/fish/.config/fish/completions/worktree.fish"
test_root="$(mktemp -d)"
source_repo="$test_root/source"
physical_worktrees="$test_root/physical-worktrees"
worktrees_dir="$test_root/worktrees"
trap 'rm -rf "$test_root"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

mkdir -p "$source_repo" "$physical_worktrees"
ln -s "$physical_worktrees" "$worktrees_dir"
git -C "$source_repo" init -q -b main
git -C "$source_repo" -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m initial

export HOME="$test_root/home"
export WORKTREES_DIR="$worktrees_dir"
mkdir -p "$HOME"

cd "$source_repo"
"$command" >/dev/null
safe_path="$($command create safe-remove)"
[[ $safe_path == "$worktrees_dir/source/safe-remove" ]] || fail "create returned an unexpected path"
[[ $($command create safe-remove) == "$safe_path" ]] || fail "create was not idempotent"
[[ $("$command" list --porcelain) == *"branch refs/heads/work/safe-remove"* ]] ||
    fail "porcelain list omitted the managed branch"

stale_path="$($command create stale)"
mv "$stale_path" "$test_root/moved-stale"
stale_error="$("$command" create stale 2>&1 || true)"
[[ $stale_error == *"registered worktree "* &&
   $stale_error == *"run 'worktree repair <new-path>' if moved"* &&
   $stale_error == *"'git worktree prune' if deleted"* ]] ||
    fail "stale worktree did not provide recovery guidance"
git -C "$source_repo" worktree prune

if (cd "$safe_path" && "$command" remove safe-remove); then
    fail "remove allowed deletion of the caller's worktree"
fi
repair_error="$(cd "$safe_path" && "$command" repair 2>&1 || true)"
[[ $repair_error == "worktree: run 'worktree repair' from the repository's primary worktree" ]] ||
    fail "repair did not require the primary worktree"

git -C "$source_repo" worktree add -q -b work/unmanaged "$test_root/unmanaged"
completions="$(cd "$safe_path" && fish -c 'source $argv[1]; complete -C "worktree remove "' "$completion")"
[[ $completions == *safe-remove* ]] || fail "managed task was not completed"
[[ $completions != *unmanaged* ]] || fail "unmanaged task was offered for removal"

git -C "$source_repo" worktree add -q -b work/elsewhere "$test_root/elsewhere"
elsewhere_error="$("$command" create elsewhere 2>&1 || true)"
[[ $elsewhere_error == *"branch 'work/elsewhere' is already checked out at"* ]] ||
    fail "existing task branch was misdiagnosed"

wrong_path="$worktrees_dir/source/wrong-branch"
git -C "$source_repo" worktree add -q -b other "$wrong_path"
if "$command" remove wrong-branch; then
    fail "remove accepted a worktree on the wrong branch"
fi

"$command" remove safe-remove
git -C "$source_repo" worktree remove "$wrong_path"
git -C "$source_repo" worktree remove "$test_root/unmanaged"
git -C "$source_repo" worktree remove "$test_root/elsewhere"

default_path="$(env -u WORKTREES_DIR "$command" create default)"
default_completions="$(cd "$default_path" && env -u WORKTREES_DIR fish -c 'source $argv[1]; complete -C "worktree remove "' "$completion")"
[[ $default_completions == *default* ]] || fail "default worktree directory was not completed"
env -u WORKTREES_DIR "$command" remove default

relative_error="$(WORKTREES_DIR=relative "$command" path task 2>&1 || true)"
[[ $relative_error == 'worktree: WORKTREES_DIR must be an absolute path' ]] ||
    fail "relative worktree directory was accepted"

reuse_path="$($command create reuse)"
"$command" remove reuse
git -C "$source_repo" branch -m main trunk
[[ $($command create reuse) == "$reuse_path" ]] ||
    fail "existing branch could not be attached without main"
"$command" remove reuse

error="$(cd "$test_root" && "$command" list 2>&1 || true)"
[[ $error == 'worktree: not inside a Git worktree' ]] || fail "non-repository error was not friendly"

printf 'Worktree command tests passed\n'
