# fcmd - Search list of aliases and functions
#
# USAGE:
#   fcmd            : Fuzzy search shell functions and abbreviations.
#                     Pressing Enter will type the command into your 
#                     current prompt without executing it immediately.
#
# DEPENDENCIES:
#   fzf

function fcmd --description "Search list of aliases and functions"
    set -l cmds (
        functions -n
        abbr --show | awk '{print $4}'
    )

    # Use fzf to select a command
    set -l selected_cmd (printf "%s\n" $cmds | sort -u | fzf --reverse --height=40% \
        --prompt="functions/abbrs> " \
        --preview="type {}")

    if test -n "$selected_cmd"
        # Output directly to the commandline for editing/execution
        commandline -r "$selected_cmd "
    end
end
