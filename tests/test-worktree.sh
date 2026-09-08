#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command="$repo/home/.local/bin/worktree"
completion="$repo/home/.config/fish/completions/worktree.fish"
wcd_function="$repo/home/.config/fish/functions/wcd.fish"
wcd_completion="$repo/home/.config/fish/completions/wcd.fish"
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
export PATH="$repo/home/.local/bin:$PATH"
mkdir -p "$HOME"

cd "$source_repo"
"$command" >/dev/null
safe_path="$($command add safe-remove)"
[[ $safe_path == "$worktrees_dir/source/safe-remove" ]] || fail "add returned an unexpected path"
[[ $($command add safe-remove) == "$safe_path" ]] || fail "add was not idempotent"
[[ $("$command" list --porcelain) == *"branch refs/heads/work/safe-remove"* ]] ||
    fail "porcelain list omitted the managed branch"
[[ $($command list) == *'TASK'* ]] || fail "pretty list omitted the header"
pretty_row="$($command list | grep 'safe-remove')"
[[ $pretty_row == safe-remove* ]] || fail "pretty list TASK column omitted the managed task"
for removed_alias in create ls rm; do
    alias_error="$("$command" "$removed_alias" 2>&1 || true)"
    [[ $alias_error == *"unknown command '$removed_alias'"* ]] ||
        fail "removed alias '$removed_alias' is still accepted"
done

stale_path="$($command add stale)"
mv "$stale_path" "$test_root/moved-stale"
stale_error="$("$command" add stale 2>&1 || true)"
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
elsewhere_error="$("$command" add elsewhere 2>&1 || true)"
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

default_path="$(env -u WORKTREES_DIR "$command" add default)"
default_completions="$(cd "$default_path" && env -u WORKTREES_DIR fish -c 'source $argv[1]; complete -C "worktree remove "' "$completion")"
[[ $default_completions == *default* ]] || fail "default worktree directory was not completed"
env -u WORKTREES_DIR "$command" remove default

relative_error="$(WORKTREES_DIR=relative "$command" path task 2>&1 || true)"
[[ $relative_error == 'worktree: WORKTREES_DIR must be an absolute path' ]] ||
    fail "relative worktree directory was accepted"

reuse_path="$($command add reuse)"
"$command" remove reuse
git -C "$source_repo" branch -m main trunk
[[ $($command add reuse) == "$reuse_path" ]] ||
    fail "existing branch could not be attached without main"
"$command" remove reuse
git -C "$source_repo" branch -m trunk main

"$command" add --help | grep -q 'worktree add' || fail "add --help did not show usage"
"$command" help add | grep -q 'worktree add' || fail "help add did not show usage"
"$command" list -h | grep -q 'worktree list' || fail "list -h did not show usage"
"$command" remove --help | grep -q 'worktree remove' || fail "remove --help did not show usage"
"$command" help | grep -q 'add <task-slug>' || fail "help omitted the add command"
[[ $($command help) != *'alias'* ]] || fail "help still mentions aliases"
if "$command" help bogus 2>/dev/null; then
    fail "help accepted an unknown command"
fi
if "$command" help add extra 2>/dev/null; then
    fail "help accepted extra arguments"
fi

added_path="$($command add help-task)"
[[ $added_path == "$worktrees_dir/source/help-task" ]] || fail "add did not create the worktree"
"$command" remove help-task
[[ ! -e "$worktrees_dir/source/help-task" ]] || fail "remove did not remove the worktree"

git -C "$source_repo" branch -m main master
master_path="$($command add from-master)"
[[ $master_path == "$worktrees_dir/source/from-master" ]] || fail "master was not used as the base branch"
"$command" remove from-master
git -C "$source_repo" branch -m master trunk
no_base_error="$("$command" add no-base 2>&1 || true)"
[[ $no_base_error == *'no suitable base branch'* ]] ||
    fail "missing base branch did not explain itself"
git -C "$source_repo" branch -m trunk main

base_sha="$(git -C "$source_repo" rev-parse HEAD)"
git -C "$source_repo" update-ref refs/remotes/origin/release/stable "$base_sha"
git -C "$source_repo" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/release/stable
slash_path="$($command add slash-base)"
[[ $slash_path == "$worktrees_dir/source/slash-base" ]] || fail "origin default with a slash was not used as the base"
[[ $(git -C "$slash_path" rev-parse HEAD) == "$base_sha" ]] || fail "slash-base did not start at the origin default"
"$command" remove slash-base
# NOTE: `git update-ref -d` silently keeps symbolic refs; only
# `symbolic-ref --delete` removes origin/HEAD (else it dangles).
git -C "$source_repo" symbolic-ref --delete refs/remotes/origin/HEAD
git -C "$source_repo" update-ref -d refs/remotes/origin/release/stable

git -C "$source_repo" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/gone
dangling_path="$($command add dangling-base)"
[[ $dangling_path == "$worktrees_dir/source/dangling-base" ]] || fail "dangling origin/HEAD blocked the main fallback"
"$command" remove dangling-base
git -C "$source_repo" symbolic-ref --delete refs/remotes/origin/HEAD

git -C "$source_repo" worktree add -q -b work/mismatched "$worktrees_dir/source/other-name"
mismatch_row="$($command list | grep 'other-name')"
[[ $mismatch_row == -* ]] || fail "pretty list labeled a non-managed path as a task"
git -C "$source_repo" worktree remove --force "$worktrees_dir/source/other-name"
git -C "$source_repo" branch -q -D work/mismatched

mapfile -t batch_paths < <("$command" add batch-a batch-b)
[[ ${#batch_paths[@]} -eq 2 ]] || fail "batch add did not print two paths"
[[ ${batch_paths[0]} == "$worktrees_dir/source/batch-a" ]] || fail "batch add first path was unexpected"
[[ ${batch_paths[1]} == "$worktrees_dir/source/batch-b" ]] || fail "batch add second path was unexpected"
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

if "$command" add batch-c 'Bad!' batch-d 2>/dev/null; then
    fail "batch add accepted an invalid slug"
fi
[[ -d "$worktrees_dir/source/batch-c" ]] || fail "batch add did not leave earlier successes"
if git -C "$source_repo" worktree list --porcelain | grep -q 'branch refs/heads/work/batch-d'; then
    fail "batch add continued past the failure"
fi

"$command" add batch-e batch-f >/dev/null
if batch_remove_error="$("$command" remove batch-e no-such batch-f 2>&1)"; then
    fail "batch remove ignored a missing worktree"
fi
[[ $batch_remove_error == *"no-such: no worktree exists at"* ]] ||
    fail "batch remove did not prefix the failure with the slug"
[[ $batch_remove_error == *"removed 2 of 3"* ]] ||
    fail "batch remove did not summarize partial success"
[[ ! -e "$worktrees_dir/source/batch-e" && ! -e "$worktrees_dir/source/batch-f" ]] ||
    fail "batch remove did not continue past the failure"

force_path="$("$command" add force-me)"
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

force_self_path="$("$command" add force-self)"
echo dirty >"$force_self_path/dirty.txt"
if (cd "$force_self_path" && "$command" remove --force force-self 2>/dev/null); then
    fail "--force allowed deletion of the caller's worktree"
fi
[[ -d $force_self_path ]] || fail "--force deleted the caller's worktree"
"$command" remove --force force-self

git -C "$source_repo" worktree add -q --detach "$test_root/detached-wt"
[[ $($command list) == *'(detached)'* ]] || fail "pretty list omitted the detached worktree"
git -C "$source_repo" worktree add -q -b spaced "$worktrees_dir/source/spaced name"
[[ $($command list) == *'spaced name'* ]] || fail "pretty list omitted the path with spaces"
git -C "$source_repo" worktree lock "$worktrees_dir/source/spaced name" --reason testing
[[ $($command list) == *'locked: testing'* ]] || fail "pretty list omitted the lock reason"
git -C "$source_repo" worktree unlock "$worktrees_dir/source/spaced name"
git -C "$source_repo" worktree remove --force "$worktrees_dir/source/spaced name"
git -C "$source_repo" worktree remove --force "$test_root/detached-wt"

wcd_task_path="$($command add wcd-target)"
wcd_resolved="$(fish -c 'source $argv[1]; wcd wcd-target; pwd' "$wcd_function")"
[[ $wcd_resolved == "$wcd_task_path" ]] || fail "wcd did not cd to the managed worktree"
wcd_outside="$(cd "$test_root" && fish -c 'source $argv[1]; wcd wcd-target; pwd' "$wcd_function")"
[[ $wcd_outside == "$wcd_task_path" ]] || fail "wcd did not find the managed worktree from outside the repo"
wcd_candidates="$(cd "$test_root" && fish -c 'source $argv[1]; source $argv[2]; complete -C "wcd wcd-" ' "$wcd_function" "$wcd_completion")"
[[ $wcd_candidates == *wcd-target* ]] || fail "wcd did not complete the managed task"
remove_completions="$(fish -c 'source $argv[1]; complete -C "worktree remove "' "$completion")"
[[ $remove_completions == *wcd-target* ]] || fail "remove did not complete task names"
if fish -c 'source $argv[1]; wcd no-such-thing' "$wcd_function" 2>/dev/null; then
    fail "wcd accepted an unknown worktree"
fi
"$command" remove wcd-target

if "$command" add 2>/dev/null; then
    fail "add accepted zero slugs"
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
if "$command" add --force batch-g 2>/dev/null; then
    fail "add accepted a flag"
fi

"$command" remove batch-a batch-b batch-c
"$command" remove batch-d 2>/dev/null || true

error="$(cd "$test_root" && "$command" list 2>&1 || true)"
[[ $error == 'worktree: not inside a Git worktree' ]] || fail "non-repository error was not friendly"

printf 'Worktree command tests passed\n'
