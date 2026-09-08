#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command="$repo/home/.local/bin/worktree"
completion="$repo/home/.config/fish/completions/worktree.fish"
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
git -C "$source_repo" branch -m trunk main

mapfile -t batch_paths < <("$command" create batch-a batch-b)
[[ ${#batch_paths[@]} -eq 2 ]] || fail "batch create did not print two paths"
[[ ${batch_paths[0]} == "$worktrees_dir/source/batch-a" ]] || fail "batch create first path was unexpected"
[[ ${batch_paths[1]} == "$worktrees_dir/source/batch-b" ]] || fail "batch create second path was unexpected"
mapfile -t batch_printed < <("$command" path batch-a batch-b)
[[ ${batch_printed[0]} == "${batch_paths[0]}" && ${batch_printed[1]} == "${batch_paths[1]}" ]] ||
    fail "batch path did not print both paths in order"

batch_output="$("$command" path batch-a batch-b)"
[[ $batch_output == "${batch_paths[0]}"$'\n'"${batch_paths[1]}" ]] ||
    fail "batch path output was not one path per line"

if batch_stdout="$("$command" path batch-a 'Bad!' 2>/dev/null)"; then
    fail "batch path accepted an invalid slug"
fi
[[ -z ${batch_stdout:-} ]] || fail "batch path printed partial output"

if "$command" create batch-c 'Bad!' batch-d 2>/dev/null; then
    fail "batch create accepted an invalid slug"
fi
[[ -d "$worktrees_dir/source/batch-c" ]] || fail "batch create did not leave earlier successes"
if git -C "$source_repo" worktree list --porcelain | grep -q 'branch refs/heads/work/batch-d'; then
    fail "batch create continued past the failure"
fi

"$command" create batch-e batch-f >/dev/null
if batch_remove_error="$("$command" remove batch-e no-such batch-f 2>&1)"; then
    fail "batch remove ignored a missing worktree"
fi
[[ $batch_remove_error == *"no-such: no worktree exists at"* ]] ||
    fail "batch remove did not prefix the failure with the slug"
[[ $batch_remove_error == *"removed 2 of 3"* ]] ||
    fail "batch remove did not summarize partial success"
[[ ! -e "$worktrees_dir/source/batch-e" && ! -e "$worktrees_dir/source/batch-f" ]] ||
    fail "batch remove did not continue past the failure"

force_path="$("$command" create force-me)"
echo dirty >"$force_path/dirty.txt"
if "$command" remove force-me 2>/dev/null; then
    fail "remove discarded uncommitted changes without --force"
fi
[[ -d $force_path ]] || fail "failed remove deleted a dirty worktree"
"$command" remove --force force-me
[[ ! -e $force_path ]] || fail "--force did not remove the dirty worktree"

force_wrong_path="$worktrees_dir/source/force-wrong"
git -C "$source_repo" worktree add -q -b other2 "$force_wrong_path"
echo dirty >"$force_wrong_path/dirty.txt"
if "$command" remove --force force-wrong 2>/dev/null; then
    fail "--force bypassed the branch check"
fi
[[ -d $force_wrong_path ]] || fail "--force deleted a worktree on the wrong branch"
git -C "$source_repo" worktree remove --force "$force_wrong_path"

force_self_path="$("$command" create force-self)"
echo dirty >"$force_self_path/dirty.txt"
if (cd "$force_self_path" && "$command" remove --force force-self 2>/dev/null); then
    fail "--force allowed deletion of the caller's worktree"
fi
[[ -d $force_self_path ]] || fail "--force deleted the caller's worktree"
"$command" remove --force force-self

if "$command" create 2>/dev/null; then
    fail "create accepted zero slugs"
fi
if "$command" path 2>/dev/null; then
    fail "path accepted zero slugs"
fi
if "$command" remove 2>/dev/null; then
    fail "remove accepted zero slugs"
fi
if "$command" remove --bogus batch-a 2>/dev/null; then
    fail "remove accepted an unknown flag"
fi
if "$command" create --force batch-g 2>/dev/null; then
    fail "create accepted a flag"
fi

"$command" remove batch-a batch-b batch-c
"$command" remove batch-d 2>/dev/null || true

error="$(cd "$test_root" && "$command" list 2>&1 || true)"
[[ $error == 'worktree: not inside a Git worktree' ]] || fail "non-repository error was not friendly"

printf 'Worktree command tests passed\n'
