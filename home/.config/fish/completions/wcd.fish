function __wcd_candidates --description 'Complete all worktrees by slug, branch, or directory name'
    for entry in (__worktree_entries)
        set -l parts (string split -f1,2 \t -- $entry)
        set -l dir $parts[1]
        set -l branch (string replace 'refs/heads/' '' -- $parts[2])
        if test "$branch" = '(detached)'
            printf '%s\t%s\n' (path basename -- $dir) $dir
        else if test "$branch" = '(bare)'
            printf '%s\t%s\n' (path basename -- $dir) $dir
        else
            set -l short (string replace -r '^work/' '' -- $branch)
            printf '%s\t%s\n' $short $dir
            if test (path basename -- $dir) != "$short"
                printf '%s\t%s\n' (path basename -- $dir) $dir
            end
        end
    end
    # Managed slugs in other repositories, so wcd works from anywhere.
    for entry in (__worktree_managed)
        set -l parts (string split -f1,2 \t -- $entry)
        printf '%s\t%s\n' $parts[2] $parts[1]
    end
end

complete -c wcd -f -a '(__wcd_candidates | sort -u)'
complete -c wcd -f -s h -l help -d 'Show usage'
