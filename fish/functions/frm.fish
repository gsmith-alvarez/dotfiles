# frm - Fuzzy remove files/directories
#
# USAGE:
#   frm             : Interactively multi-select files/dirs to delete
#   frm <args>      : Fallback to standard `rm -i`
#
# DEPENDENCIES:
#   fd, fzf, bat

function frm --description "Fuzzy remove files/directories"
    if count $argv > /dev/null
        # Fallback to standard rm if arguments are provided
        command rm -i $argv
        return
    end

    # Use fd to find files and directories, fzf for multi-selection
    set -l files (fd --hidden --exclude .git | fzf -m \
        --header="[TAB] to multi-select, [ENTER] to delete" \
        --preview="bat --color=always {}" \
        --preview-window="right:60%")

    if test -n "$files"
        # Ask for confirmation via standard rm -i for each file
        for file in $files
            command rm -i "$file"
        end
    else
        echo "Cancelled frm."
    end
end
