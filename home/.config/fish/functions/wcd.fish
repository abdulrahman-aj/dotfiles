function __worktree_entries --description 'Print path<TAB>branch for each worktree in the current repository'
    git worktree list --porcelain 2>/dev/null | awk '
        /^worktree / { path = substr($0, 10); branch = ""; bare = 0; next }
        /^branch / { branch = substr($0, 8); next }
        /^detached$/ { branch = "(detached)"; next }
        /^bare$/ { bare = 1; next }
        /^$/ { if (path != "") print path "\t" (branch != "" ? branch : "(bare)"); path = ""; next }
        END { if (path != "") print path "\t" (branch != "" ? branch : "(bare)") }
    '
end

function __worktree_managed --description 'Print path<TAB>slug for every managed worktree on disk'
    set -l worktrees_dir
    if set -q WORKTREES_DIR
        set worktrees_dir $WORKTREES_DIR
    else
        set worktrees_dir $HOME/Worktrees
    end
    string match -q '/*' -- $worktrees_dir; or return
    for wt in $worktrees_dir/*/*/
        set -l dir (string trim -r -c / -- $wt)
        if test -f "$dir/.git"
            printf '%s\t%s\n' $dir (path basename -- $dir)
        end
    end
end

function __wcd_pick --description 'Pick one path<TAB>label line with fzf'
    fzf --delimiter='\t' --with-nth=2,1 --header='worktree (name — path)' | string split -f1 \t
end

function wcd --description 'cd to a worktree by task slug, branch, or directory name'
    if test (count $argv) -eq 0
        # Inside a repo, list its worktrees; elsewhere, list all managed ones.
        set -l entries (__worktree_entries)
        if test (count $entries) -eq 0
            set entries (__worktree_managed)
        end
        if test (count $entries) -eq 0
            echo "wcd: no worktrees found" >&2
            return 1
        end
        if type -q fzf
            set -l target (printf '%s\n' $entries | __wcd_pick)
            or return
            cd $target; and return
        end
        printf '%s\n' $entries
        return
    end

    switch $argv[1]
        case -h --help
            echo "Usage: wcd [<task-slug>|<branch>|<directory>]"
            echo "cd to a worktree. With no argument, pick with fzf (or list worktrees)."
            return
    end

    if test (count $argv) -gt 1
        echo "Usage: wcd [<task-slug>|<branch>|<directory>]" >&2
        return 1
    end

    # 1. Managed slug in the current repository (single source of truth).
    set -l target (worktree path $argv[1] 2>/dev/null)
    if test -n "$target[1]"
        if test -d "$target[1]"
            cd $target[1]; and return
        end
    end

    # 2. Branch tail or directory basename in the current repository (unmanaged too).
    for entry in (__worktree_entries)
        set -l parts (string split -f1,2 \t -- $entry)
        set -l dir $parts[1]
        set -l branch (string replace 'refs/heads/' '' -- $parts[2])
        if test (path basename -- $dir) = "$argv[1]"
            cd $dir; and return
        else if test "$branch" = "$argv[1]"
            cd $dir; and return
        else if test (path basename -- $branch) = "$argv[1]"
            cd $dir; and return
        end
    end

    # 3. Managed slug in any repository (works from outside a repo).
    set -l matches
    for entry in (__worktree_managed)
        set -l parts (string split -f1,2 \t -- $entry)
        if test "$parts[2]" = "$argv[1]"
            set -a matches $parts[1]
        end
    end
    if test (count $matches) -eq 1
        cd $matches[1]; and return
    else if test (count $matches) -gt 1
        if type -q fzf
            set -l pick (printf '%s\n' $matches | fzf --header="worktree '$argv[1]' in multiple repositories")
            or return
            cd $pick; and return
        end
        printf '%s\n' $matches >&2
        echo "wcd: '$argv[1]' exists in multiple repositories; cd to one explicitly" >&2
        return 1
    end

    echo "wcd: no worktree found for '$argv[1]'" >&2
    return 1
end
