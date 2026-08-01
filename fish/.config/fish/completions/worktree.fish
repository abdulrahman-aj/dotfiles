function __worktree_no_subcommand
    not __fish_seen_subcommand_from create list path remove repair help
end

function __worktree_task_names
    set -l worktrees (command git worktree list --porcelain 2>/dev/null)
    set -l root
    for line in $worktrees
        if string match --quiet 'worktree *' -- "$line"
            set root (string replace 'worktree ' '' -- "$line")
            break
        end
    end
    test -n "$root"
    or return
    set -l worktrees_dir
    if test -n "$WORKTREES_DIR"
        set worktrees_dir "$WORKTREES_DIR"
    else
        set worktrees_dir "$HOME/Worktrees"
    end
    string match --quiet '/*' -- "$worktrees_dir"
    or return
    set -l managed_root (path resolve "$worktrees_dir")/(path basename "$root")/
    set -l path

    for line in $worktrees
        if string match --quiet 'worktree *' -- "$line"
            set path (string replace 'worktree ' '' -- "$line")
        else if string match --quiet 'branch refs/heads/work/*' -- "$line"
            if string match --quiet "$managed_root*" -- "$path"
                string replace 'branch refs/heads/work/' '' -- "$line"
            end
        end
    end
end

complete -c worktree -n __worktree_no_subcommand -f -a create -d 'Create a managed worktree'
complete -c worktree -n __worktree_no_subcommand -f -a list -d 'List repository worktrees'
complete -c worktree -n __worktree_no_subcommand -f -a path -d 'Print a managed worktree path'
complete -c worktree -n __worktree_no_subcommand -f -a remove -d 'Remove a clean managed worktree'
complete -c worktree -n __worktree_no_subcommand -f -a repair -d 'Repair Git worktree metadata'
complete -c worktree -n __worktree_no_subcommand -f -a help -d 'Show command help'
complete -c worktree -n __worktree_no_subcommand -s h -d 'Show command help'
complete -c worktree -n __worktree_no_subcommand -l help -d 'Show command help'
complete -c worktree -n '__fish_seen_subcommand_from create' -f
complete -c worktree -n '__fish_seen_subcommand_from path remove' -f -a '(__worktree_task_names)'
complete -c worktree -n '__fish_seen_subcommand_from list' -f -a '--porcelain' -d 'Use machine-readable output'
