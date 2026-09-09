# opencode has no native fish completions (as of 1.18.x): ask yargs each tab.
# ~0.7s per completion; switch to `opencode completion fish | source` if upstream adds fish support.

function __opencode_yargs_completions
    # Forward the cursor token even when empty: yargs needs the trailing ""
    # to list subcommands, and -opc excludes the token under the cursor.
    set -l tokens (commandline -opc)
    set tokens $tokens (commandline -ct)
    set -l results (opencode --get-yargs-completions $tokens 2>/dev/null | grep -v '^\$0$')
    if test (count $results) -eq 0
        __fish_complete_path (commandline -ct)
    else
        printf '%s\n' $results
    end
end

complete -c opencode -f -k -a '(__opencode_yargs_completions)'
